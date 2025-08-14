function Get-CMCStablecoins {
    <#
    .SYNOPSIS
        Gets a list of stablecoin cryptocurrencies with latest market data.
    
    .DESCRIPTION
        The Get-CMCStablecoins cmdlet retrieves stablecoins from CoinMarketCap by filtering
        cryptocurrencies that are categorized as stablecoins. This is a convenience function
        that combines Get-CMCMap and Get-CMCQuotes to provide stablecoin-specific data.
    
    .PARAMETER Limit
        Optionally specify the number of results to return.
        Default: 20, Max: 100
    
    .PARAMETER Convert
        Optionally calculate market quotes in up to 120 currencies at once.
        Default: USD
    
    .PARAMETER Sort
        What field to sort the list by.
        Valid values: market_cap, price, volume_24h, percent_change_24h
        Default: market_cap
    
    .PARAMETER SortDirection
        The direction in which to order stablecoins.
        Valid values: asc, desc
        Default: desc
    
    .EXAMPLE
        Get-CMCStablecoins
        
        Gets the top 20 stablecoins by market cap.
    
    .EXAMPLE
        Get-CMCStablecoins -Limit 10 -Convert "EUR","GBP"
        
        Gets the top 10 stablecoins with prices in EUR and GBP.
    
    .EXAMPLE
        Get-CMCStablecoins -Sort "volume_24h" -Limit 5
        
        Gets the top 5 stablecoins by 24h trading volume.
    
    .OUTPUTS
        PSCustomObject[]
        Returns an array of stablecoin cryptocurrency objects with market data.
    
    .NOTES
        This function uses a known list of major stablecoins. For a comprehensive list,
        consider using the CoinMarketCap categories endpoint when it becomes available.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$Limit = 20,
        
        [Parameter()]
        [ValidateCount(1, 120)]
        [string[]]$Convert = @('USD'),
        
        [Parameter()]
        [ValidateSet('market_cap', 'price', 'volume_24h', 'percent_change_24h')]
        [string]$Sort = 'market_cap',
        
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string]$SortDirection = 'desc'
    )
    
    begin {
        Write-Verbose "Getting stablecoin listings from CoinMarketCap"
        
        # Well-known stablecoin symbols
        $stablecoinSymbols = @(
            'USDT',    # Tether
            'USDC',    # USD Coin
            'BUSD',    # Binance USD
            'DAI',     # Dai
            'TUSD',    # TrueUSD
            'USDP',    # Pax Dollar
            'USDD',    # USDD
            'GUSD',    # Gemini Dollar
            'FRAX',    # Frax
            'LUSD',    # Liquity USD
            'USTC',    # TerraClassicUSD
            'FEI',     # Fei USD
            'SUSD',    # sUSD
            'CUSD',    # Celo Dollar
            'HUSD',    # HUSD
            'RSV',     # Reserve
            'EURS',    # STASIS EURO
            'EURT',    # Euro Tether
            'USDN',    # Neutrino USD
            'MIM',     # Magic Internet Money
            'USDX',    # USDX
            'VAI',     # Vai
            'TRIBE',   # Tribe
            'UST',     # TerraUSD
            'USDS',    # USDS
            'PYUSD',   # PayPal USD
            'FDUSD',   # First Digital USD
            'EUROC',   # Euro Coin
            'USDJ',    # JUST Stablecoin
            'HAY',     # Hay Stablecoin
            'ZUSD',    # ZUSD
            'MUSD',    # mStable USD
            'CEUR',    # Celo Euro
            'MAI',     # MAI
            'DUSD',    # DefiChain USD
            'XAI',     # XAI Stablecoin
            'RAI',     # Rai Reflex Index
            'DOLA',    # DOLA
            'USDB',    # USDB
            'USDH',    # USDH
            'GHO',     # GHO
            'MKUSD',   # Maker USD
            'CRVUSD'   # Curve USD
        )
    }
    
    process {
        try {
            # Get quotes for stablecoin symbols
            $params = @{
                Symbol = $stablecoinSymbols[0..([Math]::Min($Limit - 1, $stablecoinSymbols.Count - 1))]
                Convert = $Convert
            }
            
            Write-Verbose "Fetching quotes for stablecoins: $($params.Symbol -join ', ')"
            $stablecoins = Get-CMCQuotes @params
            
            if (-not $stablecoins) {
                Write-Warning "No stablecoin data retrieved"
                return
            }
            
            # Convert to array if single object
            if ($stablecoins -isnot [array]) {
                $stablecoins = @($stablecoins)
            }
            
            # Sort the results
            $sortProperty = switch ($Sort) {
                'market_cap' { "${Convert[0]}_market_cap" }
                'price' { "${Convert[0]}_price" }
                'volume_24h' { "${Convert[0]}_volume_24h" }
                'percent_change_24h' { "${Convert[0]}_percent_change_24h" }
            }
            
            $sorted = if ($SortDirection -eq 'desc') {
                $stablecoins | Sort-Object -Property $sortProperty -Descending
            } else {
                $stablecoins | Sort-Object -Property $sortProperty
            }
            
            # Output limited results
            $sorted | Select-Object -First $Limit | ForEach-Object {
                # Add custom type for stablecoin formatting
                $_.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.Stablecoin')
                Write-Output $_
            }
        }
        catch {
            Write-Error "Failed to get stablecoin listings: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCStablecoins completed"
    }
}