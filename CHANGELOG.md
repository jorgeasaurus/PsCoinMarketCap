# 📝 Changelog

All notable changes to the PsCoinMarketCap module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-13

### 🎉 Initial Major Release

This is the first stable release of PsCoinMarketCap, providing comprehensive access to the CoinMarketCap API v1 through PowerShell.

### ✨ Added

#### Core Functionality
- **Authentication System** with secure API key management
  - Session-based and persistent encrypted storage
  - Sandbox environment support for testing
  - API key validation and information retrieval

#### Cryptocurrency Endpoints
- **Get-CMCListings** - Latest cryptocurrency listings with advanced filtering
- **Get-CMCQuotes** - Real-time quotes for specific cryptocurrencies
- **Get-CMCInfo** - Detailed cryptocurrency metadata and information
- **Get-CMCMap** - Complete CoinMarketCap cryptocurrency mapping
- **Convert-CMCPrice** - Currency conversion between cryptocurrencies and fiat

#### Global Market Data
- **Get-CMCGlobalMetrics** - Global cryptocurrency market statistics
- **Get-CMCKeyInfo** - API key usage and plan information

#### Exchange Data
- **Get-CMCExchangeListings** - Cryptocurrency exchange listings
- **Get-CMCExchangeQuotes** - Exchange quotes and metrics
- **Get-CMCExchangeInfo** - Detailed exchange information
- **Get-CMCExchangeMap** - Exchange ID mapping

#### Advanced Tools & Utilities
- **Export-CMCData** - Export data to CSV, JSON, and Excel formats
- **Watch-CMCPrice** - Real-time price monitoring with alerts and notifications
- **Get-CMCChart** - Generate ASCII and interactive HTML price charts
- **Get-CMCStablecoins** - Get stablecoin cryptocurrency data

#### Rate Limiting & Management
- **Test-CMCRateLimit** - Monitor and manage API rate limits
- **Invoke-CMCRequest** - Internal request handler with retry logic
- Automatic rate limit tracking and enforcement
- Warning system for approaching limits

#### Developer Tools
- Comprehensive error handling with detailed messages
- Automatic retry logic with exponential backoff
- Extensive logging and debugging capabilities
- PowerShell 5.1+ and PowerShell Core compatibility

### 🎨 Features

#### Security
- Encrypted API key storage using Windows DPAPI
- Secure credential management
- No plaintext API key exposure in logs

#### Data Processing
- Pipeline support for all major cmdlets
- Custom PowerShell type formatting
- Intelligent data conversion and validation
- Support for multiple currencies and conversions

#### Visualization & Reporting
- **Three Report Types**: Portfolio, Market Overview, Comparison
- **Multiple Themes**: Light, Dark, Blue, Crypto
- **Chart Types**: ASCII console charts, Interactive HTML charts
- **Export Formats**: CSV, JSON, Excel with metadata support

#### Monitoring & Alerts
- Real-time price monitoring with customizable intervals
- Price threshold alerts (above/below)
- Percentage change alerts
- Sound notifications
- CSV logging capabilities
- Multiple display modes (Table, Compact, Detailed)

#### Rate Limit Management
- Automatic tracking of minute, daily, and monthly usage
- Warning system at 80% usage thresholds
- Automatic delays when limits are reached
- Usage status reporting

### 🧪 Testing
- **95 comprehensive unit tests** covering all major functionality
- Pester v5 test framework integration
- Mock implementations for API testing
- Code coverage reporting
- Automated test execution scripts

### 📚 Documentation
- Comprehensive API reference documentation
- Free tier usage guide with best practices
- Inline help for all cmdlets with examples
- PowerShell custom formatting for enhanced display
- README with installation and usage instructions

### 🔧 Technical Specifications

#### Supported Platforms
- Windows PowerShell 5.1+
- PowerShell Core 6.0+
- Windows, macOS, Linux

#### Dependencies
- No external dependencies for core functionality
- Optional: ImportExcel module for Excel export features

#### API Coverage
- Full CoinMarketCap API v1 free tier endpoint coverage
- Support for all free tier parameters and options
- Handles API versioning and deprecation notices

### 📊 Performance
- Efficient batch processing for multiple cryptocurrency requests
- Intelligent caching to minimize API calls
- Optimized JSON parsing and object creation
- Memory-efficient data structures

### 🛡️ Error Handling
- Comprehensive error handling for all API scenarios
- Graceful degradation on API failures
- Detailed error messages with actionable information
- Automatic retry logic for transient failures

---

## Planned for Future Releases

### [1.1.0] - Q2 2025 (Planned)
- Historical data support (requires paid API tier)
- Advanced analytics and technical indicators
- Portfolio tracking with performance metrics
- Database integration options

### [1.2.0] - Q3 2025 (Planned)
- WebSocket support for real-time streaming
- Advanced charting with technical analysis
- Custom alert webhooks
- Performance optimization improvements

---

## Support

- 📖 **Documentation**: [API Reference](docs/API_REFERENCE.md) | [Free Tier Guide](docs/FREE_TIER_GUIDE.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/PsCoinMarketCap/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/PsCoinMarketCap/discussions)
- 📧 **Contact**: Create an issue for support

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*For the complete API reference and usage examples, see the [documentation](docs/) folder.*