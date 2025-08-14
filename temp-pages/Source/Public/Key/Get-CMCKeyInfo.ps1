function Get-CMCKeyInfo {
    <#
    .SYNOPSIS
        Gets information about your CoinMarketCap API key.
    
    .DESCRIPTION
        The Get-CMCKeyInfo cmdlet retrieves information about your CoinMarketCap API key,
        including usage limits, remaining credits, and tier information. This is useful
        for monitoring your API usage and understanding your account limits.
    
    .EXAMPLE
        Get-CMCKeyInfo
        
        Gets the current API key information including usage and limits.
    
    .EXAMPLE
        $keyInfo = Get-CMCKeyInfo
        Write-Host "Daily credits remaining: $($keyInfo.plan.credit_limit_daily_reset)"
        
        Stores key info and displays remaining daily credits.
    
    .OUTPUTS
        PSCustomObject
        Returns an object containing API key information, usage statistics, and limits.
    
    .NOTES
        - This endpoint does not count against your API call limits
        - Useful for monitoring usage and planning API calls
        - Shows both current usage and historical statistics
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV1KeyInfo
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    
    begin {
        Write-Verbose "Retrieving CoinMarketCap API key information"
    }
    
    process {
        try {
            # Make API request to key info endpoint
            $response = Invoke-CMCRequest -Endpoint '/key/info'
            
            # Create result object with enhanced properties
            $result = [PSCustomObject]@{
                PSTypeName = 'PsCoinMarketCap.KeyInfo'
                plan = $response.plan
                usage = $response.usage
            }
            
            # Add computed properties for easy access
            if ($response.plan) {
                Add-Member -InputObject $result -NotePropertyName 'plan_name' -NotePropertyValue $response.plan.name -Force
                Add-Member -InputObject $result -NotePropertyName 'credit_limit_daily' -NotePropertyValue $response.plan.credit_limit_daily -Force
                Add-Member -InputObject $result -NotePropertyName 'credit_limit_daily_reset' -NotePropertyValue $response.plan.credit_limit_daily_reset -Force
                Add-Member -InputObject $result -NotePropertyName 'credit_limit_daily_reset_timestamp' -NotePropertyValue $response.plan.credit_limit_daily_reset_timestamp -Force
                Add-Member -InputObject $result -NotePropertyName 'credit_limit_monthly' -NotePropertyValue $response.plan.credit_limit_monthly -Force
                Add-Member -InputObject $result -NotePropertyName 'credit_limit_monthly_reset' -NotePropertyValue $response.plan.credit_limit_monthly_reset -Force
                Add-Member -InputObject $result -NotePropertyName 'credit_limit_monthly_reset_timestamp' -NotePropertyValue $response.plan.credit_limit_monthly_reset_timestamp -Force
                Add-Member -InputObject $result -NotePropertyName 'rate_limit_request_per_minute' -NotePropertyValue $response.plan.rate_limit_request_per_minute -Force
            }
            
            if ($response.usage) {
                Add-Member -InputObject $result -NotePropertyName 'current_day_credits_used' -NotePropertyValue $response.usage.current_day.credits_used -Force
                Add-Member -InputObject $result -NotePropertyName 'current_day_credits_left' -NotePropertyValue $response.usage.current_day.credits_left -Force
                Add-Member -InputObject $result -NotePropertyName 'current_month_credits_used' -NotePropertyValue $response.usage.current_month.credits_used -Force
                Add-Member -InputObject $result -NotePropertyName 'current_month_credits_left' -NotePropertyValue $response.usage.current_month.credits_left -Force
            }
            
            # Add summary properties
            if ($response.plan -and $response.usage) {
                $dailyUsagePercent = if ($response.plan.credit_limit_daily -gt 0) {
                    [math]::Round(($response.usage.current_day.credits_used / $response.plan.credit_limit_daily) * 100, 2)
                } else { 0 }
                
                $monthlyUsagePercent = if ($response.plan.credit_limit_monthly -gt 0) {
                    [math]::Round(($response.usage.current_month.credits_used / $response.plan.credit_limit_monthly) * 100, 2)
                } else { 0 }
                
                Add-Member -InputObject $result -NotePropertyName 'daily_usage_percent' -NotePropertyValue $dailyUsagePercent -Force
                Add-Member -InputObject $result -NotePropertyName 'monthly_usage_percent' -NotePropertyValue $monthlyUsagePercent -Force
            }
            
            Write-Output $result
        }
        catch {
            Write-Error "Failed to retrieve API key information: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCKeyInfo completed"
    }
}