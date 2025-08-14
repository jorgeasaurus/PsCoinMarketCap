function Get-CMCChart {
    <#
    .SYNOPSIS
        Generates price charts from CoinMarketCap data.
    
    .DESCRIPTION
        The Get-CMCChart cmdlet creates visual price charts for cryptocurrencies using
        ASCII art, HTML with Chart.js, or exports data for external charting tools.
        It supports various time periods and chart types.
    
    .PARAMETER Symbol
        One or more cryptocurrency symbols to chart (e.g., "BTC", "ETH").
    
    .PARAMETER Id
        One or more CoinMarketCap cryptocurrency IDs to chart.
    
    .PARAMETER ChartType
        The type of chart to generate:
        - ASCII: Text-based chart in console
        - HTML: Interactive HTML chart with Chart.js
        - Data: Returns formatted data for external tools
    
    .PARAMETER Period
        Time period for the chart:
        - 1H: Last hour (simulated with current data)
        - 24H: Last 24 hours (simulated)
        - 7D: Last 7 days (simulated)
        - 30D: Last 30 days (simulated)
    
    .PARAMETER Width
        Width of ASCII chart in characters (default: 60).
    
    .PARAMETER Height
        Height of ASCII chart in lines (default: 20).
    
    .PARAMETER Currency
        Currency to display prices in (default: USD).
    
    .PARAMETER OutputPath
        File path to save HTML charts or data exports.
    
    .PARAMETER ShowVolume
        Include volume data in the chart.
    
    .PARAMETER CompareSymbols
        Create comparison chart with multiple cryptocurrencies.
    
    .PARAMETER Theme
        Visual theme for HTML charts:
        - Light: Light theme
        - Dark: Dark theme
        - Crypto: Cryptocurrency-themed colors
    
    .PARAMETER OpenInBrowser
        Automatically open HTML charts in default browser.
    
    .EXAMPLE
        Get-CMCChart -Symbol "BTC" -ChartType ASCII
        
        Displays a simple ASCII price chart for Bitcoin in the console.
    
    .EXAMPLE
        Get-CMCChart -Symbol "ETH" -ChartType HTML -Period 7D -OutputPath "eth_chart.html" -OpenInBrowser
        
        Creates an interactive 7-day Ethereum chart and opens it in browser.
    
    .EXAMPLE
        Get-CMCChart -Symbol "BTC","ETH","ADA" -ChartType HTML -CompareSymbols -Theme Dark
        
        Creates a dark-themed comparison chart for multiple cryptocurrencies.
    
    .EXAMPLE
        Get-CMCChart -Symbol "DOGE" -ChartType Data -Period 24H -ShowVolume
        
        Returns formatted price and volume data for external charting tools.
    
    .OUTPUTS
        Varies by ChartType:
        - ASCII: Displays chart in console
        - HTML: Creates HTML file, optionally returns file path
        - Data: Returns PSCustomObject with chart data
    
    .NOTES
        - ASCII charts provide quick console visualization
        - HTML charts require internet connection for Chart.js
        - Historical data is simulated based on current prices (free tier limitation)
        - Use Chart.js for interactive features like zoom and tooltips
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
        [ValidateSet('ASCII', 'HTML', 'Data')]
        [string]$ChartType = 'ASCII',
        
        [Parameter()]
        [ValidateSet('1H', '24H', '7D', '30D')]
        [string]$Period = '24H',
        
        [Parameter()]
        [ValidateRange(40, 120)]
        [int]$Width = 60,
        
        [Parameter()]
        [ValidateRange(10, 40)]
        [int]$Height = 20,
        
        [Parameter()]
        [string]$Currency = 'USD',
        
        [Parameter()]
        [string]$OutputPath,
        
        [Parameter()]
        [switch]$ShowVolume,
        
        [Parameter()]
        [switch]$CompareSymbols,
        
        [Parameter()]
        [ValidateSet('Light', 'Dark', 'Crypto')]
        [string]$Theme = 'Light',
        
        [Parameter()]
        [switch]$OpenInBrowser
    )
    
    begin {
        Write-Verbose "Starting chart generation for $ChartType chart"
        
        # Define chart themes
        $themes = @{
            Light = @{
                Background = '#ffffff'
                Grid = '#e0e0e0'
                Text = '#333333'
                Primary = '#007bff'
                Success = '#28a745'
                Warning = '#ffc107'
                Danger = '#dc3545'
            }
            Dark = @{
                Background = '#1a1a1a'
                Grid = '#404040'
                Text = '#e0e0e0'
                Primary = '#4dabf7'
                Success = '#51cf66'
                Warning = '#ffd43b'
                Danger = '#ff6b6b'
            }
            Crypto = @{
                Background = '#0d1421'
                Grid = '#2a3441'
                Text = '#f7fafc'
                Primary = '#f7931a'
                Success = '#00d4aa'
                Warning = '#ffb020'
                Danger = '#ff4747'
            }
        }
        
        $selectedTheme = $themes[$Theme]
        
        # Calculate time period settings
        $periodSettings = @{
            '1H' = @{ Hours = 1; Points = 60; Interval = 'minute' }
            '24H' = @{ Hours = 24; Points = 48; Interval = '30 minutes' }
            '7D' = @{ Hours = 168; Points = 84; Interval = '2 hours' }
            '30D' = @{ Hours = 720; Points = 60; Interval = '12 hours' }
        }
        
        $settings = $periodSettings[$Period]
    }
    
    process {
        try {
            # Get current market data
            Write-Verbose "Fetching current market data"
            $currentData = if ($PSCmdlet.ParameterSetName -eq 'Symbol') {
                Get-CMCQuotes -Symbol $Symbol -Convert $Currency -ErrorAction Stop
            } else {
                Get-CMCQuotes -Id $Id -Convert $Currency -ErrorAction Stop
            }
            
            if (-not $currentData) {
                Write-Error "No market data retrieved"
                return
            }
            
            # Generate historical data (simulated for free tier)
            Write-Verbose "Generating simulated historical data for $Period period"
            $chartData = foreach ($crypto in $currentData) {
                $priceHistory = Generate-SimulatedPriceHistory -CurrentPrice $crypto."${Currency}_price" -Period $settings -Volatility $crypto."${Currency}_percent_change_24h"
                $volumeHistory = if ($ShowVolume) { 
                    Generate-SimulatedVolumeHistory -CurrentVolume $crypto."${Currency}_volume_24h" -Period $settings
                } else { $null }
                
                [PSCustomObject]@{
                    Symbol = $crypto.symbol
                    Name = $crypto.name
                    CurrentPrice = $crypto."${Currency}_price"
                    PriceHistory = $priceHistory
                    VolumeHistory = $volumeHistory
                    Change24h = $crypto."${Currency}_percent_change_24h"
                    Currency = $Currency
                }
            }
            
            # Generate chart based on type
            switch ($ChartType) {
                'ASCII' {
                    foreach ($data in $chartData) {
                        if ($CompareSymbols -and $chartData.Count -gt 1) {
                            Generate-ASCIIComparisonChart -ChartData $chartData -Width $Width -Height $Height -Currency $Currency
                            break
                        } else {
                            Generate-ASCIIChart -Data $data -Width $Width -Height $Height -ShowVolume $ShowVolume
                        }
                    }
                }
                
                'HTML' {
                    $htmlChart = Generate-HTMLChart -ChartData $chartData -Theme $selectedTheme -ShowVolume $ShowVolume -CompareSymbols $CompareSymbols -Period $Period -Currency $Currency
                    
                    if ($OutputPath) {
                        $htmlChart | Out-File -FilePath $OutputPath -Encoding UTF8
                        Write-Information "Chart saved to: $OutputPath" -InformationAction Continue
                        
                        if ($OpenInBrowser) {
                            Start-Process $OutputPath
                        }
                        
                        Get-Item $OutputPath
                    } else {
                        # Return HTML content
                        $htmlChart
                    }
                }
                
                'Data' {
                    if ($OutputPath) {
                        $extension = [System.IO.Path]::GetExtension($OutputPath).ToLower()
                        switch ($extension) {
                            '.json' {
                                $chartData | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
                            }
                            '.csv' {
                                $flattenedData = $chartData | ForEach-Object {
                                    $crypto = $_
                                    for ($i = 0; $i -lt $crypto.PriceHistory.Count; $i++) {
                                        [PSCustomObject]@{
                                            Symbol = $crypto.Symbol
                                            Name = $crypto.Name
                                            Timestamp = $crypto.PriceHistory[$i].Timestamp
                                            Price = $crypto.PriceHistory[$i].Price
                                            Volume = if ($crypto.VolumeHistory) { $crypto.VolumeHistory[$i].Volume } else { $null }
                                        }
                                    }
                                }
                                $flattenedData | Export-Csv -Path $OutputPath -NoTypeInformation
                            }
                            default {
                                Write-Warning "Unsupported export format: $extension. Returning data object."
                                $chartData
                            }
                        }
                        Write-Information "Chart data exported to: $OutputPath" -InformationAction Continue
                    } else {
                        $chartData
                    }
                }
            }
        }
        catch {
            Write-Error "Chart generation failed: $_"
        }
    }
}

function Generate-SimulatedPriceHistory {
    param($CurrentPrice, $Period, $Volatility)
    
    $points = $Period.Points
    $hours = $Period.Hours
    $priceHistory = @()
    
    # Calculate volatility factor (higher for more volatile coins)
    $volatilityFactor = [Math]::Abs($Volatility) / 100 * 0.3 + 0.02
    
    $price = $CurrentPrice
    for ($i = $points - 1; $i -ge 0; $i--) {
        $timeOffset = [TimeSpan]::FromHours($hours * $i / $points)
        $timestamp = (Get-Date).Subtract($timeOffset)
        
        # Add some realistic price movement (random walk with slight trend)
        $randomChange = (Get-Random -Minimum -1.0 -Maximum 1.0) * $volatilityFactor
        $trendFactor = ($Volatility / 100) * (($points - $i) / $points) * 0.1
        
        $price = $price * (1 + $randomChange + $trendFactor)
        
        $priceHistory += [PSCustomObject]@{
            Timestamp = $timestamp
            Price = [Math]::Max($price, 0.000001)  # Ensure positive prices
        }
    }
    
    return $priceHistory
}

function Generate-SimulatedVolumeHistory {
    param($CurrentVolume, $Period)
    
    $points = $Period.Points
    $hours = $Period.Hours
    $volumeHistory = @()
    
    for ($i = $points - 1; $i -ge 0; $i--) {
        $timeOffset = [TimeSpan]::FromHours($hours * $i / $points)
        $timestamp = (Get-Date).Subtract($timeOffset)
        
        # Volume varies more randomly
        $volumeMultiplier = Get-Random -Minimum 0.5 -Maximum 2.0
        $volume = $CurrentVolume * $volumeMultiplier
        
        $volumeHistory += [PSCustomObject]@{
            Timestamp = $timestamp
            Volume = $volume
        }
    }
    
    return $volumeHistory
}

function Generate-ASCIIChart {
    param($Data, $Width, $Height, $ShowVolume)
    
    $prices = $Data.PriceHistory.Price
    $minPrice = ($prices | Measure-Object -Minimum).Minimum
    $maxPrice = ($prices | Measure-Object -Maximum).Maximum
    $priceRange = $maxPrice - $minPrice
    
    if ($priceRange -eq 0) { $priceRange = 1 }
    
    Write-Host "`n🚀 $($Data.Name) ($($Data.Symbol)) - $($Data.Currency) Price Chart" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    
    # Create chart grid
    $chart = New-Object 'string[,]' $Height, $Width
    for ($y = 0; $y -lt $Height; $y++) {
        for ($x = 0; $x -lt $Width; $x++) {
            $chart[$y, $x] = ' '
        }
    }
    
    # Plot price line
    for ($i = 0; $i -lt [Math]::Min($prices.Count, $Width); $i++) {
        $price = $prices[$i]
        $x = [Math]::Floor($i * ($Width - 1) / ($prices.Count - 1))
        $y = [Math]::Floor(($maxPrice - $price) * ($Height - 1) / $priceRange)
        
        if ($x -ge 0 -and $x -lt $Width -and $y -ge 0 -and $y -lt $Height) {
            $chart[$y, $x] = '█'
        }
    }
    
    # Display chart
    for ($y = 0; $y -lt $Height; $y++) {
        $currentPrice = $maxPrice - ($y * $priceRange / ($Height - 1))
        $priceLabel = if ($y -eq 0 -or $y -eq $Height - 1 -or $y -eq [Math]::Floor($Height / 2)) {
            $currentPrice.ToString('N2').PadLeft(8)
        } else {
            "        "
        }
        
        Write-Host $priceLabel -NoNewline -ForegroundColor Yellow
        Write-Host " │" -NoNewline -ForegroundColor Gray
        
        $line = ""
        for ($x = 0; $x -lt $Width; $x++) {
            $char = $chart[$y, $x]
            $line += if ($char -eq '█') { $char } else { '·' }
        }
        
        Write-Host $line -ForegroundColor Green
    }
    
    # Display x-axis
    Write-Host "         └" -NoNewline -ForegroundColor Gray
    Write-Host ("─" * $Width) -ForegroundColor Gray
    
    # Show current stats
    Write-Host "`n📊 Current Price: " -NoNewline -ForegroundColor White
    Write-Host "$($Data.CurrentPrice.ToString('N2')) $($Data.Currency)" -ForegroundColor Yellow
    
    $changeColor = if ($Data.Change24h -gt 0) { "Green" } else { "Red" }
    $changeSymbol = if ($Data.Change24h -gt 0) { "📈 +" } else { "📉 " }
    Write-Host "🔄 24h Change: " -NoNewline -ForegroundColor White
    Write-Host "$changeSymbol$($Data.Change24h.ToString('N2'))%" -ForegroundColor $changeColor
    
    Write-Host "📏 Range: $($minPrice.ToString('N2')) - $($maxPrice.ToString('N2'))" -ForegroundColor Gray
    Write-Host ""
}

function Generate-ASCIIComparisonChart {
    param($ChartData, $Width, $Height, $Currency)
    
    Write-Host "`n📊 Cryptocurrency Comparison Chart" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    
    $colors = @('Green', 'Blue', 'Magenta', 'Yellow', 'Cyan', 'Red')
    $symbols = @('█', '▓', '▒', '░', '■', '●')
    
    foreach ($i in 0..($ChartData.Count - 1)) {
        $data = $ChartData[$i]
        $color = $colors[$i % $colors.Count]
        $symbol = $symbols[$i % $symbols.Count]
        
        Write-Host "$symbol " -NoNewline -ForegroundColor $color
        Write-Host "$($data.Symbol): $($data.CurrentPrice.ToString('N2')) $Currency " -NoNewline -ForegroundColor White
        
        $changeColor = if ($data.Change24h -gt 0) { "Green" } else { "Red" }
        $changeSymbol = if ($data.Change24h -gt 0) { "+" } else { "" }
        Write-Host "($changeSymbol$($data.Change24h.ToString('N2'))%)" -ForegroundColor $changeColor
    }
    
    Write-Host "`n💡 Use individual symbol charts for detailed analysis" -ForegroundColor Gray
}

function Generate-HTMLChart {
    param($ChartData, $Theme, $ShowVolume, $CompareSymbols, $Period, $Currency)
    
    $datasets = @()
    $labels = @()
    
    if ($CompareSymbols -and $ChartData.Count -gt 1) {
        # Multi-cryptocurrency comparison
        $labels = $ChartData[0].PriceHistory | ForEach-Object { $_.Timestamp.ToString('MM/dd HH:mm') }
        
        foreach ($i in 0..($ChartData.Count - 1)) {
            $data = $ChartData[$i]
            $color = switch ($i % 6) {
                0 { '#f7931a' }  # Bitcoin orange
                1 { '#627eea' }  # Ethereum blue
                2 { '#3cc8c8' }  # Cardano teal
                3 { '#e6007a' }  # Polkadot pink
                4 { '#00d4aa' }  # BNB green
                5 { '#ff4747' }  # Red
            }
            
            $datasets += @{
                label = "$($data.Symbol) Price"
                data = $data.PriceHistory.Price
                borderColor = $color
                backgroundColor = "$color20"
                tension = 0.4
                fill = $false
            }
        }
    } else {
        # Single cryptocurrency chart
        $data = $ChartData[0]
        $labels = $data.PriceHistory | ForEach-Object { $_.Timestamp.ToString('MM/dd HH:mm') }
        
        $datasets += @{
            label = "$($data.Symbol) Price ($Currency)"
            data = $data.PriceHistory.Price
            borderColor = $Theme.Primary
            backgroundColor = "$($Theme.Primary)20"
            tension = 0.4
            fill = $true
        }
        
        if ($ShowVolume -and $data.VolumeHistory) {
            $datasets += @{
                label = "Volume"
                data = $data.VolumeHistory.Volume
                borderColor = $Theme.Warning
                backgroundColor = "$($Theme.Warning)40"
                tension = 0.4
                fill = $true
                yAxisID = 'volume'
            }
        }
    }
    
    $title = if ($CompareSymbols -and $ChartData.Count -gt 1) {
        "Cryptocurrency Comparison - $Period"
    } else {
        "$($ChartData[0].Name) ($($ChartData[0].Symbol)) - $Period Chart"
    }
    
    @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: $($Theme.Background);
            color: $($Theme.Text);
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: $($Theme.Grid);
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .chart-container {
            position: relative;
            height: 500px;
            background: $($Theme.Background);
            border-radius: 8px;
            padding: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$title</h1>
            <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        </div>
        
        <div class="stats">
            $(($ChartData | ForEach-Object {
                $changeClass = if ($_.Change24h -gt 0) { 'color: ' + $Theme.Success } else { 'color: ' + $Theme.Danger }
                "<div class='stat-card'>
                    <h3>$($_.Symbol)</h3>
                    <div style='font-size: 1.5em; font-weight: bold;'>$($_.CurrentPrice.ToString('N2')) $Currency</div>
                    <div style='$changeClass'>$($_.Change24h.ToString('N2'))% (24h)</div>
                </div>"
            }) -join "`n")
        </div>
        
        <div class="chart-container">
            <canvas id="priceChart"></canvas>
        </div>
    </div>
    
    <script>
        const ctx = document.getElementById('priceChart').getContext('2d');
        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: $(($labels | ConvertTo-Json)),
                datasets: $(($datasets | ConvertTo-Json))
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: '$title',
                        color: '$($Theme.Text)'
                    },
                    legend: {
                        labels: {
                            color: '$($Theme.Text)'
                        }
                    }
                },
                scales: {
                    x: {
                        ticks: {
                            color: '$($Theme.Text)'
                        },
                        grid: {
                            color: '$($Theme.Grid)'
                        }
                    },
                    y: {
                        ticks: {
                            color: '$($Theme.Text)'
                        },
                        grid: {
                            color: '$($Theme.Grid)'
                        }
                    }$(if ($ShowVolume) {
                        ",
                    volume: {
                        type: 'linear',
                        position: 'right',
                        ticks: {
                            color: '$($Theme.Text)'
                        },
                        grid: {
                            drawOnChartArea: false,
                            color: '$($Theme.Grid)'
                        }
                    }"
                    })
                },
                interaction: {
                    intersect: false,
                },
                elements: {
                    point: {
                        radius: 0
                    }
                }
            }
        });
    </script>
</body>
</html>
"@
}