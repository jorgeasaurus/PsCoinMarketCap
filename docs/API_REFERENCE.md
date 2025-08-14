# 📚 PsCoinMarketCap API Reference

## Table of Contents

- [Authentication](#authentication)
- [Cryptocurrency Endpoints](#cryptocurrency-endpoints)
- [Global Metrics](#global-metrics)
- [Tools & Utilities](#tools--utilities)
- [Exchange Endpoints](#exchange-endpoints)
- [Rate Limiting](#rate-limiting)
- [Error Handling](#error-handling)

---

## Authentication

### Set-CMCApiKey
Securely stores your CoinMarketCap API key.

```powershell
# Store for current session
Set-CMCApiKey -ApiKey "your-api-key-here"

# Store persistently (encrypted)
Set-CMCApiKey -ApiKey "your-api-key-here" -Scope User

# Use sandbox environment
Set-CMCApiKey -ApiKey "your-sandbox-key" -UseSandbox
```

**Parameters:**
- `ApiKey` - Your CoinMarketCap API key
- `Scope` - Session (default) or User for persistent storage
- `UseSandbox` - Use sandbox environment for testing

### Get-CMCApiKey
Retrieves the currently configured API key information.

```powershell
Get-CMCApiKey
```

---

## Cryptocurrency Endpoints

### Get-CMCListings
Get the latest cryptocurrency listings with market data.

```powershell
# Get top 10 cryptocurrencies
Get-CMCListings -Limit 10

# Get specific range
Get-CMCListings -Start 11 -Limit 20

# Filter by market cap
Get-CMCListings -MarketCapMin 1000000000 -Limit 50

# Sort by different metrics
Get-CMCListings -Sort "percent_change_24h" -SortDir "desc" -Limit 10
```

**Parameters:**
- `Start` - Starting position (default: 1)
- `Limit` - Number of results (default: 100, max: 5000)
- `Convert` - Target currency for conversions
- `Sort` - Sort field (market_cap, name, symbol, date_added, etc.)
- `SortDir` - Sort direction (asc/desc)
- `MarketCapMin/Max` - Market cap filtering
- `PriceMin/Max` - Price filtering
- `Volume24hMin/Max` - Volume filtering
- `CirculatingSupplyMin/Max` - Supply filtering
- `PercentChange24hMin/Max` - Change filtering
- `Category` - Category filter
- `Tag` - Tag filter

### Get-CMCQuotes
Get the latest quotes for specific cryptocurrencies.

```powershell
# Get Bitcoin quotes
Get-CMCQuotes -Symbol "BTC"

# Get multiple quotes
Get-CMCQuotes -Symbol "BTC","ETH","ADA"

# Use IDs instead of symbols
Get-CMCQuotes -Id 1,1027,2010

# Convert to different currencies
Get-CMCQuotes -Symbol "BTC" -Convert "EUR","GBP","JPY"
```

**Parameters:**
- `Symbol` - Cryptocurrency symbols (up to 100)
- `Id` - CoinMarketCap IDs (up to 100)
- `Convert` - Target currencies for conversion
- `Aux` - Additional data fields to include

### Get-CMCInfo
Get detailed metadata for cryptocurrencies.

```powershell
# Get Bitcoin info
Get-CMCInfo -Symbol "BTC"

# Get multiple cryptocurrency info
Get-CMCInfo -Symbol "BTC","ETH","ADA"

# Use IDs
Get-CMCInfo -Id 1,1027,2010
```

### Get-CMCMap
Get the complete cryptocurrency mapping.

```powershell
# Get all cryptocurrencies
Get-CMCMap

# Limit results
Get-CMCMap -Limit 100

# Filter by listing status
Get-CMCMap -ListingStatus "active"

# Filter by date range
Get-CMCMap -Start 1 -Limit 50
```

### Convert-CMCPrice
Convert cryptocurrency amounts between different currencies.

```powershell
# Convert 1 BTC to USD
Convert-CMCPrice -Amount 1 -Symbol "BTC" -Convert "USD"

# Convert to multiple currencies
Convert-CMCPrice -Amount 0.5 -Symbol "ETH" -Convert "USD","EUR","BTC"

# Use IDs
Convert-CMCPrice -Amount 100 -Id 1027 -Convert "USD"
```

---

## Global Metrics

### Get-CMCGlobalMetrics
Get global cryptocurrency market metrics.

```powershell
# Get current global metrics
Get-CMCGlobalMetrics

# Convert to different currency
Get-CMCGlobalMetrics -Convert "EUR"
```

---

## Tools & Utilities

### Export-CMCData
Export cryptocurrency data to various formats.

```powershell
# Export to CSV
Get-CMCListings -Limit 50 | Export-CMCData -Path "crypto_data.csv"

# Export to JSON with metadata
Get-CMCQuotes -Symbol "BTC","ETH" | Export-CMCData -Path "portfolio.json" -IncludeMetadata

# Export to Excel with filtering
Get-CMCListings -Limit 100 | Export-CMCData -Path "report.xlsx" -Currency "USD" -Properties "name","symbol","USD_price","USD_market_cap"
```

**Parameters:**
- `Path` - Output file path (extension determines format)
- `Format` - Explicit format (CSV, JSON, Excel)
- `IncludeMetadata` - Include export metadata
- `Currency` - Filter currency columns
- `Properties` - Select specific properties
- `PassThru` - Return data for further processing

- `Theme` - Light, Dark, Blue
- `IncludeCharts` - Include interactive charts
- `OpenInBrowser` - Auto-open in browser
- `Title` - Custom report title

### Watch-CMCPrice
Monitor cryptocurrency prices in real-time.

```powershell
# Basic monitoring
Watch-CMCPrice -Symbol "BTC" -RefreshInterval 30

# With price alerts
Watch-CMCPrice -Symbol "ETH" -AlertAbove 3000 -AlertBelow 2500 -AlertSound

# Monitor multiple with logging
Watch-CMCPrice -Symbol "BTC","ETH" -Duration 60 -LogFile "prices.log" -DisplayMode Compact

# Percentage change alerts
Watch-CMCPrice -Symbol "ADA" -AlertChange 5 -Quiet
```

**Parameters:**
- `Symbol/Id` - Cryptocurrencies to monitor
- `RefreshInterval` - Update frequency in seconds (10-3600)
- `AlertAbove/Below` - Price alert thresholds
- `AlertChange` - Percentage change alert (0.1-100%)
- `Duration` - Monitoring duration in minutes
- `DisplayMode` - Table, Compact, Detailed
- `LogFile` - CSV log file path
- `AlertSound` - Play sound on alerts
- `Quiet` - Show only alerts

### Get-CMCChart
Generate price charts in various formats.

```powershell
# ASCII chart in console
Get-CMCChart -Symbol "BTC" -ChartType ASCII -Period 24H

# Interactive HTML chart
Get-CMCChart -Symbol "ETH" -ChartType HTML -Period 7D -OutputPath "eth_chart.html" -OpenInBrowser

# Comparison chart
Get-CMCChart -Symbol "BTC","ETH","ADA" -ChartType HTML -CompareSymbols -Theme Dark

# Export data for external tools
Get-CMCChart -Symbol "DOGE" -ChartType Data -Period 30D -ShowVolume -OutputPath "doge_data.json"
```

**Parameters:**
- `Symbol/Id` - Cryptocurrencies to chart
- `ChartType` - ASCII, HTML, Data
- `Period` - 1H, 24H, 7D, 30D
- `OutputPath` - File output path
- `Theme` - Light, Dark, Crypto (for HTML)
- `CompareSymbols` - Multi-crypto comparison
- `ShowVolume` - Include volume data
- `Width/Height` - ASCII chart dimensions

---

## Exchange Endpoints

### Get-CMCExchangeListings
Get cryptocurrency exchange listings.

```powershell
# Get top exchanges
Get-CMCExchangeListings -Limit 20

# Sort by volume
Get-CMCExchangeListings -Sort "volume_24h" -Limit 10
```

### Get-CMCExchangeQuotes
Get quotes for specific exchanges.

```powershell
# Get Binance quotes
Get-CMCExchangeQuotes -Slug "binance"

# Multiple exchanges
Get-CMCExchangeQuotes -Slug "binance","coinbase-pro"
```

---

## Rate Limiting

### Test-CMCRateLimit
Monitor and manage API rate limits.

```powershell
# Check current rate limit status
Test-CMCRateLimit -GetStatus

# Reset rate limit tracking
Test-CMCRateLimit -Reset

# Track a request (used internally)
Test-CMCRateLimit
```

**Free Tier Limits:**
- **10,000** calls per month
- **333** calls per day
- **10** calls per minute

---

## Error Handling

The module provides comprehensive error handling:

### Common Error Types
- **API Key Missing**: No API key configured
- **Rate Limit Exceeded**: API calls per period exceeded
- **Invalid Parameters**: Bad request parameters
- **Network Issues**: Connection problems
- **API Errors**: CoinMarketCap service errors

### Error Examples
```powershell
try {
    Get-CMCQuotes -Symbol "INVALID"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
```

### Automatic Retries
The module automatically retries failed requests with exponential backoff:
- Initial delay: 1 second
- Maximum retries: 3
- Exponential backoff multiplier: 2

---

## Best Practices

### 1. API Key Security
- Use `-Scope User` for persistent storage
- Never hardcode API keys in scripts
- Use sandbox for testing

### 2. Rate Limit Management
- Monitor usage with `Test-CMCRateLimit -GetStatus`
- Use appropriate delays between bulk requests
- Batch requests when possible

### 3. Error Handling
- Always wrap API calls in try-catch blocks
- Check for rate limit warnings
- Implement graceful degradation

### 4. Data Processing
- Use pipeline for efficient data processing
- Export data for analysis in external tools
- Leverage custom formatting for display

---

## Examples by Use Case

### Portfolio Tracking
```powershell
# Set up portfolio monitoring
$symbols = "BTC","ETH","ADA","DOT","LINK"
$portfolio = Get-CMCQuotes -Symbol $symbols

# Export portfolio data
$portfolio | Export-CMCData -Path "portfolio.csv" -Format CSV

# Export for spreadsheet analysis
$portfolio | Export-CMCData -Path "portfolio.xlsx" -IncludeMetadata
```

### Market Analysis
```powershell
# Get top 100 by market cap
$top100 = Get-CMCListings -Limit 100

# Find biggest gainers
$gainers = $top100 | Sort-Object USD_percent_change_24h -Descending | Select-Object -First 10

# Export analysis data
$top100 | Export-CMCData -Path "market_analysis.csv" -Format CSV
```

### Real-time Monitoring
```powershell
# Monitor Bitcoin with alerts
Watch-CMCPrice -Symbol "BTC" -AlertAbove 50000 -AlertBelow 45000 -LogFile "btc_monitoring.log" -Duration 480
```