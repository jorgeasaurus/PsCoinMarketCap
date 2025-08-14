# 💎 CoinMarketCap Free Tier Guide

## Overview

The CoinMarketCap Free Tier provides access to essential cryptocurrency data at no cost. This guide covers what's available, limitations, and best practices for maximizing your free usage.

## 🆓 What's Included

### 🚨 Key Limitations
- **10,000 API calls per month**
- **1 convert currency option only** (e.g., USD OR EUR, not both)
- **No historical data access**
- **Rate limited to prevent abuse**

### Available Endpoints

| Endpoint | Description | Monthly Calls |
|----------|-------------|---------------|
| **Cryptocurrency** |
| `/cryptocurrency/listings/latest` | Latest cryptocurrency listings | ✅ Included |
| `/cryptocurrency/quotes/latest` | Latest quotes for specific cryptos | ✅ Included |
| `/cryptocurrency/info` | Cryptocurrency metadata | ✅ Included |
| `/cryptocurrency/map` | CoinMarketCap ID map | ✅ Included |
| **Global Metrics** |
| `/global-metrics/quotes/latest` | Global market statistics | ✅ Included |
| **Tools** |
| `/tools/price-conversion` | Price conversion calculator | ✅ Included |
| **Exchange** |
| `/exchange/listings/latest` | Exchange listings | ✅ Included |
| `/exchange/quotes/latest` | Exchange quotes | ✅ Included |
| `/exchange/info` | Exchange metadata | ✅ Included |
| `/exchange/map` | Exchange ID map | ✅ Included |
| **Fiat** |
| `/fiat/map` | Supported fiat currencies | ✅ Included |
| **Key** |
| `/key/info` | API key information | ✅ Included |

## 📊 Rate Limits

### Free Tier Limits
- **10,000 calls per month** 📅
- **333 calls per day** 🌅  
- **10 calls per minute** ⏱️

### Rate Limit Breakdown
```
Monthly:  10,000 calls (resets monthly)
Daily:    333 calls   (resets daily at midnight UTC)  
Minute:   10 calls    (rolling 60-second window)
```

### Monitoring Your Usage
```powershell
# Check current usage and limits
Get-CMCKeyInfo

# Example output shows:
# - Plan information and limits
# - Current day/month usage
# - Credits remaining
# - Usage percentages
```

## 🚀 PowerShell Commands Available

### Authentication
```powershell
Set-CMCApiKey -ApiKey "your-free-api-key"
Get-CMCApiKey
```

### Cryptocurrency Data
```powershell
# Get top cryptocurrencies (free tier - single currency)
Get-CMCListings -Convert "USD" -Limit 100

# Get specific crypto quotes (free tier - single currency)
Get-CMCQuotes -Symbol "BTC","ETH","ADA" -Convert "USD"

# Get crypto information
Get-CMCInfo -Symbol "BTC"

# Get all crypto mapping
Get-CMCMap -Limit 500
```

### Global Market Data
```powershell
# Get global market metrics
Get-CMCGlobalMetrics
```

### Price Conversion
```powershell
# Convert to single currency (free tier limitation)
Convert-CMCPrice -Amount 1 -Symbol "BTC" -Convert "USD"

# Multiple currencies require paid plan
# Convert-CMCPrice -Amount 1 -Symbol "BTC" -Convert "USD","EUR"
```

### Exchange Data
```powershell
# Get exchange listings
Get-CMCExchangeListings -Limit 50

# Get exchange quotes
Get-CMCExchangeQuotes -Slug "binance"

# Get exchange info
Get-CMCExchangeInfo -Slug "binance"
```

### Advanced Tools
```powershell
# Export data
Get-CMCListings -Limit 50 | Export-CMCData -Path "crypto.csv"

# Export data to CSV
Get-CMCListings -Limit 20 | Export-CMCData -Path "market_data.csv" -Format CSV

# Monitor prices
Watch-CMCPrice -Symbol "BTC" -RefreshInterval 60

# Create charts
Get-CMCChart -Symbol "BTC" -ChartType ASCII
```

## ⚠️ Limitations

### What's NOT Available on Free Tier

| Feature | Tier Required |
|---------|---------------|
| Historical data (OHLCV) | Basic+ |
| Professional tools | Standard+ |
| Historical global metrics | Basic+ |
| Exchange historical data | Standard+ |
| Market pairs data | Premium |
| Advanced analytics | Enterprise |

### Data Limitations
- **Real-time data**: Updates every ~5 minutes
- **Historical data**: Not available (current data only)
- **Market pairs**: Limited to basic information
- **Custom time periods**: Not supported

## 💡 Best Practices for Free Tier

### 1. Optimize API Usage

#### Batch Requests
```powershell
# ✅ Good: Get multiple symbols in one call
Get-CMCQuotes -Symbol "BTC","ETH","ADA","DOT","LINK"

# ❌ Bad: Multiple separate calls
Get-CMCQuotes -Symbol "BTC"
Get-CMCQuotes -Symbol "ETH"  
Get-CMCQuotes -Symbol "ADA"
```

#### Use Appropriate Limits
```powershell
# ✅ Good: Get what you need
Get-CMCListings -Limit 50

# ❌ Bad: Always requesting maximum
Get-CMCListings -Limit 5000
```

### 2. Cache Data Locally
```powershell
# Cache frequently used data
$listings = Get-CMCListings -Limit 100
$listings | Export-CMCData -Path "cached_listings.json"

# Reuse cached data
$cachedData = Get-Content "cached_listings.json" | ConvertFrom-Json
```

### 3. Monitor Rate Limits
```powershell
# Check usage before making requests
$keyInfo = Get-CMCKeyInfo
if ($keyInfo.current_day_credits_left -lt 50) {
    Write-Warning "Low on daily credits: $($keyInfo.current_day_credits_left) remaining"
}
```

### 4. Use Efficient Refresh Intervals
```powershell
# ✅ Good: Reasonable refresh for free tier
Watch-CMCPrice -Symbol "BTC" -RefreshInterval 300  # 5 minutes

# ❌ Bad: Too frequent for free tier  
Watch-CMCPrice -Symbol "BTC" -RefreshInterval 10   # 10 seconds
```

## 📈 Sample Workflows

### Daily Portfolio Check
```powershell
# Morning portfolio review (uses ~5 calls)
$portfolio = "BTC","ETH","ADA","DOT","LINK"
$quotes = Get-CMCQuotes -Symbol $portfolio

# Export for tracking
$quotes | Export-CMCData -Path "daily_portfolio.csv" -Format CSV

# Export for tracking
$quotes | Export-CMCData -Path "portfolio_$(Get-Date -Format 'yyyy-MM-dd').csv"
```

### Market Analysis (Weekly)
```powershell
# Weekly market overview (uses ~3 calls)
$global = Get-CMCGlobalMetrics
$top50 = Get-CMCListings -Limit 50

# Find gainers and losers
$gainers = $top50 | Sort-Object USD_percent_change_7d -Descending | Select-Object -First 10
$losers = $top50 | Sort-Object USD_percent_change_7d | Select-Object -First 10

# Export analysis
$top50 | Export-CMCData -Path "weekly_analysis.csv" -Format CSV
```

### Price Monitoring Setup
```powershell
# Set up monitoring with conservative refresh
$watchList = "BTC","ETH","ADA"

# Monitor for 4 hours with 5-minute intervals (48 calls total)
Watch-CMCPrice -Symbol $watchList -Duration 240 -RefreshInterval 300 -LogFile "monitoring.csv"
```

## 🔄 Upgrading Considerations

### When to Upgrade to Paid Tier

Consider upgrading if you need:
- **Historical data** for backtesting or analysis
- **Higher rate limits** for frequent monitoring
- **Real-time data** (sub-minute updates)
- **Professional tools** and analytics
- **Commercial usage** rights

### Cost-Effective Usage Patterns

#### For Hobbyist Traders
- Check portfolio 2-3 times daily
- Weekly market analysis
- Occasional price alerts
- **Monthly usage**: ~500-1000 calls

#### For Educational Use
- Daily assignments or projects
- Market research
- Data analysis exercises  
- **Monthly usage**: ~1000-3000 calls

#### For Development/Testing
- API integration testing
- Application development
- Data format validation
- **Monthly usage**: ~2000-5000 calls

## 📋 Quick Reference

### Essential Commands
```powershell
# Setup
Set-CMCApiKey -ApiKey "your-key"

# Daily essentials
Get-CMCListings -Limit 20                          # 1 call
Get-CMCQuotes -Symbol "BTC","ETH","ADA"            # 1 call  
Get-CMCGlobalMetrics                               # 1 call

# Usage check
Get-CMCKeyInfo                                     # 0 calls
```

### Monthly Budget Planning
```
High Priority (Daily):
- Portfolio check: 30 calls/month
- Global metrics: 30 calls/month
- Subtotal: 60 calls/month

Medium Priority (3x/week):
- Market overview: 36 calls/month
- Price conversions: 12 calls/month  
- Subtotal: 48 calls/month

Low Priority (Weekly):
- Detailed analysis: 16 calls/month
- Exchange data: 8 calls/month
- Subtotal: 24 calls/month

Total: ~132 calls/month (1.3% of limit)
```

## 🎯 Maximizing Free Tier Value

### Data Export Strategy
```powershell
# Export frequently needed data
Get-CMCListings -Limit 200 | Export-CMCData -Path "master_list.xlsx" -IncludeMetadata

# Create offline analysis
Get-CMCGlobalMetrics | Export-CMCData -Path "global_$(Get-Date -Format 'yyyy-MM-dd').json"
```

### Automation Best Practices
```powershell
# Daily data collection script
$today = Get-Date -Format "yyyy-MM-dd"

# Collect essential data (3 calls total)
$global = Get-CMCGlobalMetrics
$top100 = Get-CMCListings -Limit 100  
$portfolio = Get-CMCQuotes -Symbol "BTC","ETH","ADA","DOT","LINK"

# Export for offline analysis
$global | Export-CMCData -Path "global_$today.json"
$top100 | Export-CMCData -Path "market_$today.csv"
$portfolio | Export-CMCData -Path "portfolio_$today.csv"
```

Remember: The free tier is perfect for learning, personal projects, and light commercial use. Monitor your usage and optimize your calls to get maximum value!