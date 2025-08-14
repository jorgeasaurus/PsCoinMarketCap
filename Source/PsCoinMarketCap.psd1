@{
    RootModule = 'PsCoinMarketCap.psm1'
    ModuleVersion = '1.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'a8e7f4d5-2c3b-4f1a-9e8d-6b5a3c2d1f0e'
    Author = 'Jorgeasaurus'
    CompanyName = 'Unknown'
    Copyright = '(c) 2025 Jorgeasaurus. All rights reserved.'
    Description = 'PowerShell module for interacting with the CoinMarketCap API v1. Provides cmdlets for retrieving cryptocurrency data, market metrics, exchange information, and more.'
    PowerShellVersion = '5.1'
    
    FunctionsToExport = @(
        # Authentication
        'Set-CMCApiKey',
        'Get-CMCApiKey',
        
        # Cryptocurrency
        'Get-CMCListings',
        'Get-CMCQuotes',
        'Get-CMCInfo',
        'Get-CMCMap',
        'Get-CMCMarketPairs',
        'Get-CMCOHLCV',
        'Get-CMCHistoricalOHLCV',
        'Get-CMCPricePerformance',
        'Get-CMCCategories',
        'Get-CMCCategory',
        'Get-CMCAirdrops',
        'Get-CMCTrending',
        'Get-CMCMostVisited',
        'Get-CMCGainersLosers',
        'Get-CMCStablecoins',
        
        # Global Metrics
        'Get-CMCGlobalMetrics',
        'Get-CMCHistoricalGlobalMetrics',
        
        # Tools
        'Convert-CMCPrice',
        'Export-CMCData',
        
        # Rate Limiting & Utilities (Private functions - not exported)
        
        # Exchange
        'Get-CMCExchangeListings',
        'Get-CMCExchangeQuotes',
        'Get-CMCExchangeInfo',
        'Get-CMCExchangeMap',
        'Get-CMCExchangeMarketPairs',
        
        # Fiat
        'Get-CMCFiatMap',
        
        # Key
        'Get-CMCKeyInfo'
    )
    
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    
    FormatsToProcess = @('Formats\PsCoinMarketCap.Format.ps1xml')
    
    PrivateData = @{
        PSData = @{
            Tags = @('CoinMarketCap', 'Cryptocurrency', 'Bitcoin', 'Ethereum', 'API', 'Trading', 'Finance')
            LicenseUri = 'https://github.com/jorgeasaurus/PsCoinMarketCap/blob/main/LICENSE'
            ProjectUri = 'https://github.com/jorgeasaurus/PsCoinMarketCap'
            IconUri = ''
            ReleaseNotes = @'
## 1.0.0 - Major Release
- Complete CoinMarketCap API v1 implementation
- Secure API key management with encryption
- Comprehensive cryptocurrency data endpoints
- Real-time price monitoring with alerts
- Professional HTML reporting with charts
- Data export to CSV, JSON, and Excel formats
- ASCII and interactive web charts
- Rate limiting and error handling
- PowerShell 5.1+ and PowerShell Core support
- Extensive test coverage with Pester
- Custom formatting for enhanced display
'@
            RequireLicenseAcceptance = $false
            ExternalModuleDependencies = @()
        }
    }
    
    HelpInfoURI = ''
}