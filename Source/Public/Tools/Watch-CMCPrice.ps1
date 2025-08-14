function Watch-CMCPrice {
    <#
    .SYNOPSIS
        Monitors cryptocurrency prices in real-time with alerts.
    
    .DESCRIPTION
        The Watch-CMCPrice cmdlet continuously monitors cryptocurrency prices and 
        displays updates in real-time. It supports price alerts, percentage change
        notifications, and customizable refresh intervals.
    
    .PARAMETER Symbol
        One or more cryptocurrency symbols to monitor (e.g., "BTC", "ETH").
    
    .PARAMETER Id
        One or more CoinMarketCap cryptocurrency IDs to monitor.
    
    .PARAMETER RefreshInterval
        How often to refresh prices (in seconds). Default: 30 seconds.
        Minimum: 10 seconds (to respect rate limits).
    
    .PARAMETER Currency
        Currency to display prices in. Default: USD.
    
    .PARAMETER AlertAbove
        Alert when price goes above this threshold.
    
    .PARAMETER AlertBelow
        Alert when price goes below this threshold.
    
    .PARAMETER AlertChange
        Alert when price change percentage exceeds this value (positive or negative).
    
    .PARAMETER Duration
        How long to monitor prices (in minutes). If not specified, runs indefinitely.
    
    .PARAMETER Quiet
        Suppress normal output and only show alerts.
    
    .PARAMETER LogFile
        Optional file path to log price data.
    
    .PARAMETER DisplayMode
        How to display the data:
        - Table: Traditional table format
        - Compact: Compact single-line format
        - Detailed: Detailed view with additional metrics
    
    .PARAMETER AlertSound
        Play a system sound when alerts are triggered.
    
    .EXAMPLE
        Watch-CMCPrice -Symbol "BTC" -RefreshInterval 60
        
        Monitors Bitcoin price with 60-second refresh interval.
    
    .EXAMPLE
        Watch-CMCPrice -Symbol "BTC","ETH" -AlertAbove 50000 -AlertBelow 45000 -Currency USD
        
        Monitors Bitcoin and Ethereum with price alerts.
    
    .EXAMPLE
        Watch-CMCPrice -Symbol "ADA" -AlertChange 5 -Duration 60 -LogFile "ada_prices.log"
        
        Monitors ADA for 1 hour, alerting on 5%+ changes and logging to file.
    
    .EXAMPLE
        Watch-CMCPrice -Symbol "DOGE" -DisplayMode Compact -Quiet -AlertAbove 0.10
        
        Quiet monitoring of DOGE with compact display and price alert.
    
    .OUTPUTS
        None (continuous monitoring)
        Price data is displayed in real-time and optionally logged to file.
    
    .NOTES
        - Use Ctrl+C to stop monitoring
        - Minimum refresh interval is 10 seconds to respect API rate limits
        - Alerts are triggered only when thresholds are crossed, not on every update
        - Log files are in CSV format for easy analysis
    #>
    [CmdletBinding(DefaultParameterSetName = 'Symbol')]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Symbol'
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Symbol,
        
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Id'
        )]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$Id,
        
        [Parameter()]
        [ValidateRange(10, 3600)]
        [int]$RefreshInterval = 30,
        
        [Parameter()]
        [string]$Currency = 'USD',
        
        [Parameter()]
        [decimal]$AlertAbove,
        
        [Parameter()]
        [decimal]$AlertBelow,
        
        [Parameter()]
        [ValidateRange(0.1, 100)]
        [decimal]$AlertChange,
        
        [Parameter()]
        [ValidateRange(1, 1440)]
        [int]$Duration,
        
        [Parameter()]
        [switch]$Quiet,
        
        [Parameter()]
        [string]$LogFile,
        
        [Parameter()]
        [ValidateSet('Table', 'Compact', 'Detailed')]
        [string]$DisplayMode = 'Table',
        
        [Parameter()]
        [switch]$AlertSound
    )
    
    begin {
        Write-Host "🚀 Starting price monitoring..." -ForegroundColor Cyan
        Write-Host "📊 Symbols: $($Symbol -join ', ')" -ForegroundColor Yellow
        Write-Host "🔄 Refresh: ${RefreshInterval}s | 💰 Currency: $Currency" -ForegroundColor Yellow
        
        if ($AlertAbove) { Write-Host "⬆️  Alert Above: $AlertAbove $Currency" -ForegroundColor Green }
        if ($AlertBelow) { Write-Host "⬇️  Alert Below: $AlertBelow $Currency" -ForegroundColor Red }
        if ($AlertChange) { Write-Host "📈 Alert Change: ±${AlertChange}%" -ForegroundColor Magenta }
        
        Write-Host "⏹️  Press Ctrl+C to stop monitoring`n" -ForegroundColor Gray
        
        # Initialize tracking variables
        $script:PreviousPrices = @{}
        $script:AlertHistory = @{}
        $script:StartTime = Get-Date
        $script:UpdateCount = 0
        
        # Initialize log file if specified
        if ($LogFile) {
            $logHeader = "Timestamp,Symbol,Price,Change24h,Volume24h,MarketCap"
            $logHeader | Out-File -FilePath $LogFile -Encoding UTF8
            Write-Host "📝 Logging to: $LogFile" -ForegroundColor Blue
        }
        
        # Calculate end time if duration specified
        $endTime = if ($Duration) { 
            (Get-Date).AddMinutes($Duration) 
        } else { 
            $null 
        }
        
        if ($endTime) {
            Write-Host "⏰ Monitoring until: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor Blue
        }
    }
    
    process {
        try {
            while ($true) {
                $script:UpdateCount++
                $currentTime = Get-Date
                
                # Check if duration exceeded
                if ($endTime -and $currentTime -gt $endTime) {
                    Write-Host "`n⏰ Monitoring duration completed." -ForegroundColor Yellow
                    break
                }
                
                try {
                    # Get current prices
                    $quotes = if ($PSCmdlet.ParameterSetName -eq 'Symbol') {
                        Get-CMCQuotes -Symbol $Symbol -Convert $Currency -ErrorAction Stop
                    } else {
                        Get-CMCQuotes -Id $Id -Convert $Currency -ErrorAction Stop
                    }
                    
                    if (-not $Quiet) {
                        # Clear previous output
                        Clear-Host
                        
                        # Display header
                        Write-Host "🚀 CoinMarketCap Price Monitor - Update #$script:UpdateCount" -ForegroundColor Cyan
                        Write-Host "🕐 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Runtime: $((New-TimeSpan -Start $script:StartTime -End $currentTime).ToString('hh\:mm\:ss'))" -ForegroundColor Gray
                        Write-Host ""
                        
                        # Display prices based on mode
                        switch ($DisplayMode) {
                            'Table' { 
                                Display-TableFormat -Quotes $quotes -Currency $Currency
                            }
                            'Compact' { 
                                Display-CompactFormat -Quotes $quotes -Currency $Currency
                            }
                            'Detailed' { 
                                Display-DetailedFormat -Quotes $quotes -Currency $Currency
                            }
                        }
                    }
                    
                    # Check alerts and log data
                    foreach ($quote in $quotes) {
                        $symbolKey = $quote.symbol
                        $currentPrice = $quote."${Currency}_price"
                        $change24h = $quote."${Currency}_percent_change_24h"
                        
                        # Check price alerts
                        Check-PriceAlerts -Symbol $symbolKey -Price $currentPrice -Change24h $change24h
                        
                        # Update previous prices
                        $script:PreviousPrices[$symbolKey] = $currentPrice
                        
                        # Log data if file specified
                        if ($LogFile) {
                            $logEntry = "$($currentTime.ToString('yyyy-MM-dd HH:mm:ss')),$symbolKey,$currentPrice,$change24h,$($quote."${Currency}_volume_24h"),$($quote."${Currency}_market_cap")"
                            $logEntry | Out-File -FilePath $LogFile -Append -Encoding UTF8
                        }
                    }
                    
                } catch {
                    Write-Host "❌ Error fetching data: $_" -ForegroundColor Red
                    Write-Host "🔄 Retrying in $RefreshInterval seconds..." -ForegroundColor Yellow
                }
                
                # Wait for next refresh
                Start-Sleep -Seconds $RefreshInterval
            }
        }
        catch [System.OperationCanceledException] {
            Write-Host "`n⏹️  Monitoring stopped by user." -ForegroundColor Yellow
        }
        catch {
            Write-Host "`n❌ Monitoring error: $_" -ForegroundColor Red
        }
        finally {
            # Display summary
            $totalRuntime = New-TimeSpan -Start $script:StartTime -End (Get-Date)
            Write-Host "`n📊 Monitoring Summary:" -ForegroundColor Cyan
            Write-Host "⏱️  Runtime: $($totalRuntime.ToString('hh\:mm\:ss'))" -ForegroundColor White
            Write-Host "🔄 Updates: $script:UpdateCount" -ForegroundColor White
            if ($LogFile) {
                Write-Host "📝 Log file: $LogFile" -ForegroundColor White
            }
        }
    }
}

function Display-TableFormat {
    param($Quotes, $Currency)
    
    $Quotes | Format-Table @(
        @{N="Symbol"; E={$_.symbol}; A="Center"}
        @{N="Name"; E={$_.name}; A="Left"}
        @{N="Price ($Currency)"; E={$_."${Currency}_price".ToString("N4")}; A="Right"}
        @{N="24h Change"; E={
            $change = $_."${Currency}_percent_change_24h"
            $color = if ($change -gt 0) { "Green" } else { "Red" }
            "$($change.ToString('N2'))%"
        }; A="Right"}
        @{N="Volume (24h)"; E={$_."${Currency}_volume_24h".ToString("N0")}; A="Right"}
        @{N="Market Cap"; E={$_."${Currency}_market_cap".ToString("N0")}; A="Right"}
    ) -AutoSize
}

function Display-CompactFormat {
    param($Quotes, $Currency)
    
    foreach ($quote in $Quotes) {
        $change = $quote."${Currency}_percent_change_24h"
        $changeColor = if ($change -gt 0) { "Green" } elseif ($change -lt 0) { "Red" } else { "Yellow" }
        $changeSymbol = if ($change -gt 0) { "▲" } elseif ($change -lt 0) { "▼" } else { "◄" }
        
        $line = "{0,-6} {1,12} {2} {3,8}" -f `
            $quote.symbol, 
            $quote."${Currency}_price".ToString("N4"),
            $changeSymbol,
            "$($change.ToString('N2'))%"
            
        Write-Host $line -ForegroundColor $changeColor
    }
}

function Display-DetailedFormat {
    param($Quotes, $Currency)
    
    foreach ($quote in $Quotes) {
        $change24h = $quote."${Currency}_percent_change_24h"
        $change7d = $quote."${Currency}_percent_change_7d"
        
        Write-Host "━━━ $($quote.name) ($($quote.symbol)) ━━━" -ForegroundColor Cyan
        Write-Host "💰 Price: $($quote."${Currency}_price".ToString('N4')) $Currency" -ForegroundColor White
        
        $change24hColor = if ($change24h -gt 0) { "Green" } else { "Red" }
        Write-Host "📈 24h: $($change24h.ToString('N2'))%" -ForegroundColor $change24hColor
        
        if ($change7d) {
            $change7dColor = if ($change7d -gt 0) { "Green" } else { "Red" }
            Write-Host "📊 7d:  $($change7d.ToString('N2'))%" -ForegroundColor $change7dColor
        }
        
        Write-Host "🏦 MCap: $($quote."${Currency}_market_cap".ToString('N0'))" -ForegroundColor Gray
        Write-Host "📊 Vol:  $($quote."${Currency}_volume_24h".ToString('N0'))" -ForegroundColor Gray
        Write-Host ""
    }
}

function Check-PriceAlerts {
    param($Symbol, $Price, $Change24h)
    
    $alertTriggered = $false
    $alertMessage = ""
    
    # Check price thresholds
    if ($AlertAbove -and $Price -gt $AlertAbove) {
        if (-not $script:AlertHistory["${Symbol}_above"]) {
            $alertMessage = "🚨 $Symbol ABOVE ALERT: $($Price.ToString('N4')) > $AlertAbove"
            $script:AlertHistory["${Symbol}_above"] = $true
            $script:AlertHistory["${Symbol}_below"] = $false  # Reset opposite alert
            $alertTriggered = $true
        }
    }
    
    if ($AlertBelow -and $Price -lt $AlertBelow) {
        if (-not $script:AlertHistory["${Symbol}_below"]) {
            $alertMessage = "🚨 $Symbol BELOW ALERT: $($Price.ToString('N4')) < $AlertBelow"
            $script:AlertHistory["${Symbol}_below"] = $true
            $script:AlertHistory["${Symbol}_above"] = $false  # Reset opposite alert
            $alertTriggered = $true
        }
    }
    
    # Check percentage change alerts
    if ($AlertChange -and [Math]::Abs($Change24h) -gt $AlertChange) {
        if (-not $script:AlertHistory["${Symbol}_change"]) {
            $direction = if ($Change24h -gt 0) { "UP" } else { "DOWN" }
            $alertMessage = "🚨 $Symbol CHANGE ALERT: $direction $($Change24h.ToString('N2'))% (>${AlertChange}%)"
            $script:AlertHistory["${Symbol}_change"] = $true
            $alertTriggered = $true
        }
    } else {
        $script:AlertHistory["${Symbol}_change"] = $false  # Reset when back in normal range
    }
    
    # Display alert
    if ($alertTriggered -and $alertMessage) {
        Write-Host "`n$alertMessage" -ForegroundColor Red -BackgroundColor Yellow
        
        # Play sound if requested
        if ($AlertSound) {
            try {
                [System.Media.SystemSounds]::Exclamation.Play()
            } catch {
                # Ignore sound errors
            }
        }
        
        # Log alert
        if ($LogFile) {
            "ALERT,$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),$alertMessage" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        }
    }
}