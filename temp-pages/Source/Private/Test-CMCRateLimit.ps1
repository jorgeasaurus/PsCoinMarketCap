function Test-CMCRateLimit {
    <#
    .SYNOPSIS
        Tests and manages API rate limiting for CoinMarketCap requests.
    
    .DESCRIPTION
        This private function tracks API usage and implements rate limiting to prevent
        exceeding CoinMarketCap API limits. It maintains request history and calculates
        appropriate delays between requests.
    
    .PARAMETER Reset
        Resets the rate limit tracking counters.
    
    .PARAMETER GetStatus
        Returns the current rate limit status without making changes.
    
    .EXAMPLE
        Test-CMCRateLimit
        
        Checks rate limits and delays if necessary before allowing a request.
    
    .EXAMPLE
        Test-CMCRateLimit -GetStatus
        
        Gets the current rate limiting status.
    
    .NOTES
        This is a private helper function for internal use only.
        Rate limits vary by subscription plan:
        - Basic: 10,000 calls/month, 333 calls/day, 10 calls/minute
        - Hobbyist: 100,000 calls/month, 3,333 calls/day, 30 calls/minute
        - Startup: 500,000 calls/month, 16,666 calls/day, 60 calls/minute
        - Standard: 1,500,000 calls/month, 50,000 calls/day, 100 calls/minute
        - Professional: 3,000,000 calls/month, 100,000 calls/day, 300 calls/minute
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Reset,
        
        [Parameter()]
        [switch]$GetStatus
    )
    
    begin {
        # Initialize rate limit tracking if not exists
        if (-not $script:CMCRateLimitHistory) {
            $script:CMCRateLimitHistory = @{
                MinuteHistory = [System.Collections.ArrayList]::new()
                DailyHistory = [System.Collections.ArrayList]::new()
                MonthlyTotal = 0
                LastResetDate = [datetime]::Today
                LastResetMonth = [datetime]::Now.Month
                
                # Default limits (Basic plan) - these should be configurable
                MinuteLimit = 10
                DailyLimit = 333
                MonthlyLimit = 10000
            }
        }
    }
    
    process {
        $now = [datetime]::Now
        $rateLimits = $script:CMCRateLimitHistory
        
        # Handle reset
        if ($Reset) {
            Write-Verbose "Resetting rate limit tracking"
            $rateLimits.MinuteHistory.Clear()
            $rateLimits.DailyHistory.Clear()
            $rateLimits.MonthlyTotal = 0
            $rateLimits.LastResetDate = [datetime]::Today
            $rateLimits.LastResetMonth = $now.Month
            return
        }
        
        # Clean up old history entries
        CleanupRateLimitHistory -Now $now -RateLimits $rateLimits
        
        # Get current usage
        $minuteCount = $rateLimits.MinuteHistory.Count
        $dailyCount = $rateLimits.DailyHistory.Count
        $monthlyCount = $rateLimits.MonthlyTotal
        
        # Return status if requested
        if ($GetStatus) {
            return [PSCustomObject]@{
                MinuteUsage = $minuteCount
                MinuteLimit = $rateLimits.MinuteLimit
                MinuteRemaining = [Math]::Max(0, $rateLimits.MinuteLimit - $minuteCount)
                DailyUsage = $dailyCount
                DailyLimit = $rateLimits.DailyLimit
                DailyRemaining = [Math]::Max(0, $rateLimits.DailyLimit - $dailyCount)
                MonthlyUsage = $monthlyCount
                MonthlyLimit = $rateLimits.MonthlyLimit
                MonthlyRemaining = [Math]::Max(0, $rateLimits.MonthlyLimit - $monthlyCount)
                Timestamp = $now
            }
        }
        
        # Check rate limits
        $delay = 0
        $warnings = @()
        
        # Check minute limit
        if ($minuteCount -ge $rateLimits.MinuteLimit) {
            # Calculate time until oldest request expires
            $oldestMinuteRequest = $rateLimits.MinuteHistory[0]
            $timeUntilExpiry = 60 - ($now - $oldestMinuteRequest).TotalSeconds
            
            if ($timeUntilExpiry -gt 0) {
                $delay = [Math]::Ceiling($timeUntilExpiry * 1000)
                $warnings += "Minute rate limit reached ($minuteCount/$($rateLimits.MinuteLimit)). Waiting $([Math]::Round($timeUntilExpiry, 1)) seconds."
            }
        }
        
        # Check daily limit
        if ($dailyCount -ge $rateLimits.DailyLimit) {
            $warnings += "WARNING: Daily rate limit reached ($dailyCount/$($rateLimits.DailyLimit)). Further requests may fail."
            
            # For daily limits, we can't wait it out in the same session
            if (-not $delay) {
                Write-Warning "Daily API limit reached. Requests will reset at midnight UTC."
            }
        }
        
        # Check monthly limit
        if ($monthlyCount -ge $rateLimits.MonthlyLimit) {
            Write-Error "Monthly API limit reached ($monthlyCount/$($rateLimits.MonthlyLimit)). Cannot make more requests this month." -ErrorAction Stop
        }
        
        # Warn if approaching limits
        if ($minuteCount -ge ($rateLimits.MinuteLimit * 0.8)) {
            Write-Verbose "Approaching minute rate limit: $minuteCount/$($rateLimits.MinuteLimit)"
        }
        
        if ($dailyCount -ge ($rateLimits.DailyLimit * 0.8)) {
            Write-Warning "Approaching daily rate limit: $dailyCount/$($rateLimits.DailyLimit)"
        }
        
        if ($monthlyCount -ge ($rateLimits.MonthlyLimit * 0.8)) {
            Write-Warning "Approaching monthly rate limit: $monthlyCount/$($rateLimits.MonthlyLimit)"
        }
        
        # Apply delay if needed
        if ($delay -gt 0) {
            foreach ($warning in $warnings) {
                Write-Warning $warning
            }
            Write-Verbose "Applying rate limit delay: $delay ms"
            Start-Sleep -Milliseconds $delay
        }
        
        # Record this request
        $null = $rateLimits.MinuteHistory.Add($now)
        $null = $rateLimits.DailyHistory.Add($now)
        $rateLimits.MonthlyTotal++
        
        Write-Verbose "Rate limits - Minute: $($minuteCount + 1)/$($rateLimits.MinuteLimit), Daily: $($dailyCount + 1)/$($rateLimits.DailyLimit), Monthly: $($monthlyCount + 1)/$($rateLimits.MonthlyLimit)"
    }
    
    end {
        Write-Verbose "Test-CMCRateLimit completed"
    }
}

function CleanupRateLimitHistory {
    param(
        [datetime]$Now,
        [hashtable]$RateLimits
    )
    
    # Reset daily counter if it's a new day
    if ($Now.Date -gt $RateLimits.LastResetDate) {
        Write-Verbose "New day detected, resetting daily counter"
        $RateLimits.DailyHistory.Clear()
        $RateLimits.LastResetDate = $Now.Date
    }
    
    # Reset monthly counter if it's a new month
    if ($Now.Month -ne $RateLimits.LastResetMonth) {
        Write-Verbose "New month detected, resetting monthly counter"
        $RateLimits.MonthlyTotal = 0
        $RateLimits.LastResetMonth = $Now.Month
    }
    
    # Remove minute history older than 60 seconds
    $minuteThreshold = $Now.AddSeconds(-60)
    $toRemove = @()
    
    for ($i = 0; $i -lt $RateLimits.MinuteHistory.Count; $i++) {
        if ($RateLimits.MinuteHistory[$i] -lt $minuteThreshold) {
            $toRemove += $RateLimits.MinuteHistory[$i]
        }
        else {
            break  # List is ordered, so we can stop here
        }
    }
    
    foreach ($item in $toRemove) {
        $RateLimits.MinuteHistory.Remove($item)
    }
    
    # Remove daily history older than 24 hours
    $dailyThreshold = $Now.AddHours(-24)
    $toRemove = @()
    
    for ($i = 0; $i -lt $RateLimits.DailyHistory.Count; $i++) {
        if ($RateLimits.DailyHistory[$i] -lt $dailyThreshold) {
            $toRemove += $RateLimits.DailyHistory[$i]
        }
        else {
            break
        }
    }
    
    foreach ($item in $toRemove) {
        $RateLimits.DailyHistory.Remove($item)
    }
}