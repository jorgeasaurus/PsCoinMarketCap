# PsCoinMarketCap PowerShell Module

**Version:** 1.0.0  
**Author:** Jorgeasaurus  
**Generated:** 2025-08-14 16:58:24 UTC

## Description
PowerShell module for interacting with the CoinMarketCap API v1. Provides cmdlets for retrieving cryptocurrency data, market metrics, exchange information, and more.

## Installation

### From PowerShell Gallery
```powershell
Install-Module -Name PsCoinMarketCap
Import-Module PsCoinMarketCap
```

### From Source
```powershell
git clone https://github.com/jorgeasaurus/PsCoinMarketCap.git
Import-Module ./PsCoinMarketCap/Source/PsCoinMarketCap.psd1
```

## Quick Start

```powershell
# Set up your API key
Set-CMCApiKey -ApiKey "your-api-key-here"

# Get top 10 cryptocurrencies
Get-CMCListings -Limit 10

# Get Bitcoin price
Get-CMCQuotes -Symbol "BTC"

# Monitor prices with alerts
Watch-CMCPrice -Symbol "BTC" -AlertAbove 50000
```

## Available Functions

This module exports **16 functions** organized by category:

### Authentication
- [Get-CMCApiKey](en-US/Get-CMCApiKey.md)
- [Set-CMCApiKey](en-US/Set-CMCApiKey.md)

### Cryptocurrency Data
- [Get-CMCCategories](en-US/Get-CMCCategories.md)
- [Get-CMCGainersLosers](en-US/Get-CMCGainersLosers.md)
- [Get-CMCInfo](en-US/Get-CMCInfo.md)
- [Get-CMCKeyInfo](en-US/Get-CMCKeyInfo.md)
- [Get-CMCListings](en-US/Get-CMCListings.md)
- [Get-CMCMap](en-US/Get-CMCMap.md)
- [Get-CMCMarketPairs](en-US/Get-CMCMarketPairs.md)
- [Get-CMCOHLCV](en-US/Get-CMCOHLCV.md)
- [Get-CMCQuotes](en-US/Get-CMCQuotes.md)
- [Get-CMCStablecoins](en-US/Get-CMCStablecoins.md)
- [Get-CMCTrending](en-US/Get-CMCTrending.md)

### Global Metrics
- [Get-CMCGlobalMetrics](en-US/Get-CMCGlobalMetrics.md)

### Tools & Utilities
- [Convert-CMCPrice](en-US/Convert-CMCPrice.md)
- [Export-CMCData](en-US/Export-CMCData.md)

### Exchange Data


### Rate Limiting & Utilities


## Complete Function List

| Function | Synopsis | Category |
|----------|----------|----------|
| [Convert-CMCPrice](en-US/Convert-CMCPrice.md) | Converts cryptocurrency prices between different currencies. | Tools & Utilities |
| [Export-CMCData](en-US/Export-CMCData.md) | Exports CoinMarketCap data to various file formats. | Tools & Utilities |
| [Get-CMCApiKey](en-US/Get-CMCApiKey.md) | Retrieves the stored CoinMarketCap API key. | Authentication |
| [Get-CMCCategories](en-US/Get-CMCCategories.md) | Gets a list of all cryptocurrency categories. | Other |
| [Get-CMCGainersLosers](en-US/Get-CMCGainersLosers.md) | Gets the top cryptocurrency gainers and losers. | Other |
| [Get-CMCGlobalMetrics](en-US/Get-CMCGlobalMetrics.md) | Gets global cryptocurrency market metrics. | Global Metrics |
| [Get-CMCInfo](en-US/Get-CMCInfo.md) | Gets metadata for one or more cryptocurrencies. | Cryptocurrency |
| [Get-CMCKeyInfo](en-US/Get-CMCKeyInfo.md) | Gets information about your CoinMarketCap API key. | Other |
| [Get-CMCListings](en-US/Get-CMCListings.md) | Gets a list of all active cryptocurrencies with latest market data. | Cryptocurrency |
| [Get-CMCMap](en-US/Get-CMCMap.md) | Gets a mapping of all cryptocurrencies to their CoinMarketCap IDs. | Cryptocurrency |
| [Get-CMCMarketPairs](en-US/Get-CMCMarketPairs.md) | Gets market pair information for a cryptocurrency. | Other |
| [Get-CMCOHLCV](en-US/Get-CMCOHLCV.md) | Gets the latest OHLCV (Open, High, Low, Close, Volume) data for cryptocurrenc... | Other |
| [Get-CMCQuotes](en-US/Get-CMCQuotes.md) | Gets the latest market quote for one or more cryptocurrencies. | Cryptocurrency |
| [Get-CMCStablecoins](en-US/Get-CMCStablecoins.md) | Gets a list of stablecoin cryptocurrencies with latest market data. | Other |
| [Get-CMCTrending](en-US/Get-CMCTrending.md) | Gets trending cryptocurrencies on CoinMarketCap. | Other |
| [Set-CMCApiKey](en-US/Set-CMCApiKey.md) | Sets the CoinMarketCap API key for the current session or persistently. | Authentication |

## Additional Resources

- [API Reference Guide](API_REFERENCE.md) - Comprehensive API documentation
- [Free Tier Guide](FREE_TIER_GUIDE.md) - Maximizing free tier usage
- [Deployment Guide](../DEPLOYMENT_GUIDE.md) - Module deployment and distribution
- [Changelog](../CHANGELOG.md) - Version history and release notes
- [GitHub Repository](https://github.com/jorgeasaurus/PsCoinMarketCap)
- [CoinMarketCap API Documentation](https://coinmarketcap.com/api/documentation/v1/)

## Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/jorgeasaurus/PsCoinMarketCap/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/jorgeasaurus/PsCoinMarketCap/discussions)
- 📖 **Documentation**: Complete guides in the [docs folder](.)

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
