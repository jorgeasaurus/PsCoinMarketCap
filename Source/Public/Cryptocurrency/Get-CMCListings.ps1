function Get-CMCListings {
    <#
    .SYNOPSIS
        Gets a list of all active cryptocurrencies with latest market data.
    
    .DESCRIPTION
        The Get-CMCListings cmdlet retrieves a paginated list of all active cryptocurrencies 
        with latest market data from CoinMarketCap. By default, it returns the top 100 
        cryptocurrencies by market cap.
    
    .PARAMETER Start
        Optionally offset the start (1-based) of the paginated list of items to return.
        Default: 1
    
    .PARAMETER Limit
        Optionally specify the number of results to return. 
        Default: 100, Max: 5000
    
    .PARAMETER PriceMin
        Optionally filter by minimum USD price.
    
    .PARAMETER PriceMax
        Optionally filter by maximum USD price.
    
    .PARAMETER MarketCapMin
        Optionally filter by minimum market cap (USD).
    
    .PARAMETER MarketCapMax
        Optionally filter by maximum market cap (USD).
    
    .PARAMETER Volume24hMin
        Optionally filter by minimum 24 hour volume (USD).
    
    .PARAMETER Volume24hMax
        Optionally filter by maximum 24 hour volume (USD).
    
    .PARAMETER CirculatingSupplyMin
        Optionally filter by minimum circulating supply.
    
    .PARAMETER CirculatingSupplyMax
        Optionally filter by maximum circulating supply.
    
    .PARAMETER PercentChange24hMin
        Optionally filter by minimum 24 hour percent change.
    
    .PARAMETER PercentChange24hMax
        Optionally filter by maximum 24 hour percent change.
    
    .PARAMETER Convert
        Optionally calculate market quotes in up to 120 currencies at once.
        Default: USD
    
    .PARAMETER ConvertId
        Optionally calculate market quotes by CoinMarketCap cryptocurrency ID instead of symbol.
    
    .PARAMETER Sort
        What field to sort the list by.
        Valid values: name, symbol, date_added, market_cap, market_cap_strict, price, 
                     circulating_supply, total_supply, max_supply, num_market_pairs, 
                     volume_24h, percent_change_1h, percent_change_24h, percent_change_7d, 
                     market_cap_by_total_supply_strict, volume_7d, volume_30d
        Default: market_cap
    
    .PARAMETER SortDirection
        The direction in which to order cryptocurrencies.
        Valid values: asc, desc
        Default: desc
    
    .PARAMETER CryptocurrencyType
        The type of cryptocurrency to include.
        Valid values: all, coins, tokens
        Default: all
    
    .PARAMETER Tag
        Filter by one or more cryptocurrency tags.
        Valid values: all, defi, filesharing
        Note: For stablecoin filtering, use Get-CMCMap with filtering or Get-CMCCategory with 'stablecoin' category
    
    .PARAMETER Aux
        Optionally specify additional data fields to return.
        Valid values: num_market_pairs, cmc_rank, date_added, tags, platform, 
                     max_supply, circulating_supply, total_supply, market_cap_by_total_supply,
                     volume_24h_reported, volume_7d, volume_7d_reported, volume_30d, 
                     volume_30d_reported, is_active, is_fiat
    
    .EXAMPLE
        Get-CMCListings
        
        Gets the top 100 cryptocurrencies by market cap.
    
    .EXAMPLE
        Get-CMCListings -Limit 10 -Convert "EUR","GBP"
        
        Gets the top 10 cryptocurrencies with prices in EUR and GBP.
    
    .EXAMPLE
        Get-CMCListings -Tag "defi" -Sort "percent_change_24h" -Limit 20
        
        Gets the top 20 DeFi tokens sorted by 24h price change.
    
    .EXAMPLE
        # To get stablecoins, use Get-CMCCategory instead:
        Get-CMCCategory -Id "604f4972deb11b559dfa7220" -Limit 20
        
        Gets stablecoins using the stablecoin category ID.
    
    .EXAMPLE
        Get-CMCListings -PriceMin 100 -PriceMax 1000 -Volume24hMin 1000000
        
        Gets cryptocurrencies priced between $100-$1000 with at least $1M daily volume.
    
    .OUTPUTS
        PSCustomObject[]
        Returns an array of cryptocurrency objects with market data.
    
    .NOTES
        This endpoint requires authentication with a valid API key.
        Rate limits apply based on your CoinMarketCap plan.
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyListingsLatest
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Start = 1,
        
        [Parameter()]
        [ValidateRange(1, 5000)]
        [int]$Limit = 100,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$PriceMin,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$PriceMax,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$MarketCapMin,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$MarketCapMax,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$Volume24hMin,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$Volume24hMax,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$CirculatingSupplyMin,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$CirculatingSupplyMax,
        
        [Parameter()]
        [ValidateRange(-100, [double]::MaxValue)]
        [double]$PercentChange24hMin,
        
        [Parameter()]
        [ValidateRange(-100, [double]::MaxValue)]
        [double]$PercentChange24hMax,
        
        [Parameter()]
        [ValidateCount(1, 120)]
        [string[]]$Convert = @('USD'),
        
        [Parameter()]
        [string]$ConvertId,
        
        [Parameter()]
        [ValidateSet('name', 'symbol', 'date_added', 'market_cap', 'market_cap_strict', 
                     'price', 'circulating_supply', 'total_supply', 'max_supply', 
                     'num_market_pairs', 'volume_24h', 'percent_change_1h', 
                     'percent_change_24h', 'percent_change_7d', 
                     'market_cap_by_total_supply_strict', 'volume_7d', 'volume_30d')]
        [string]$Sort = 'market_cap',
        
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string]$SortDirection = 'desc',
        
        [Parameter()]
        [ValidateSet('all', 'coins', 'tokens')]
        [string]$CryptocurrencyType = 'all',
        
        [Parameter()]
        [ValidateSet('all', 'defi', 'filesharing')]
        [string[]]$Tag,
        
        [Parameter()]
        [ValidateSet('num_market_pairs', 'cmc_rank', 'date_added', 'tags', 'platform',
                     'max_supply', 'circulating_supply', 'total_supply', 
                     'market_cap_by_total_supply', 'volume_24h_reported', 'volume_7d',
                     'volume_7d_reported', 'volume_30d', 'volume_30d_reported',
                     'is_active', 'is_fiat')]
        [string[]]$Aux
    )
    
    begin {
        Write-Verbose "Getting cryptocurrency listings from CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{
            start = $Start
            limit = $Limit
            sort = $Sort
            sort_dir = $SortDirection
            cryptocurrency_type = $CryptocurrencyType
        }
        
        # Add optional filters
        if ($PSBoundParameters.ContainsKey('PriceMin')) {
            $parameters['price_min'] = $PriceMin
        }
        if ($PSBoundParameters.ContainsKey('PriceMax')) {
            $parameters['price_max'] = $PriceMax
        }
        if ($PSBoundParameters.ContainsKey('MarketCapMin')) {
            $parameters['market_cap_min'] = $MarketCapMin
        }
        if ($PSBoundParameters.ContainsKey('MarketCapMax')) {
            $parameters['market_cap_max'] = $MarketCapMax
        }
        if ($PSBoundParameters.ContainsKey('Volume24hMin')) {
            $parameters['volume_24h_min'] = $Volume24hMin
        }
        if ($PSBoundParameters.ContainsKey('Volume24hMax')) {
            $parameters['volume_24h_max'] = $Volume24hMax
        }
        if ($PSBoundParameters.ContainsKey('CirculatingSupplyMin')) {
            $parameters['circulating_supply_min'] = $CirculatingSupplyMin
        }
        if ($PSBoundParameters.ContainsKey('CirculatingSupplyMax')) {
            $parameters['circulating_supply_max'] = $CirculatingSupplyMax
        }
        if ($PSBoundParameters.ContainsKey('PercentChange24hMin')) {
            $parameters['percent_change_24h_min'] = $PercentChange24hMin
        }
        if ($PSBoundParameters.ContainsKey('PercentChange24hMax')) {
            $parameters['percent_change_24h_max'] = $PercentChange24hMax
        }
        
        # Handle convert parameter
        if ($Convert) {
            $parameters['convert'] = $Convert -join ','
        }
        if ($ConvertId) {
            $parameters['convert_id'] = $ConvertId
        }
        
        # Handle tag parameter
        if ($Tag) {
            $parameters['tag'] = $Tag -join ','
        }
        
        # Handle aux parameter
        if ($Aux) {
            $parameters['aux'] = $Aux -join ','
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/listings/latest' -Parameters $parameters
            
            # Process and return results
            foreach ($crypto in $response) {
                # Add custom type for formatting
                $crypto.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.Cryptocurrency')
                
                # Add calculated properties for easier access
                if ($crypto.quote) {
                    foreach ($currency in $crypto.quote.PSObject.Properties.Name) {
                        $quote = $crypto.quote.$currency
                        
                        # Flatten quote properties for easier access
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_price" -NotePropertyValue $quote.price -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_volume_24h" -NotePropertyValue $quote.volume_24h -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_volume_change_24h" -NotePropertyValue $quote.volume_change_24h -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_1h" -NotePropertyValue $quote.percent_change_1h -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_24h" -NotePropertyValue $quote.percent_change_24h -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_7d" -NotePropertyValue $quote.percent_change_7d -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_30d" -NotePropertyValue $quote.percent_change_30d -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_market_cap" -NotePropertyValue $quote.market_cap -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_market_cap_dominance" -NotePropertyValue $quote.market_cap_dominance -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_fully_diluted_market_cap" -NotePropertyValue $quote.fully_diluted_market_cap -Force
                    }
                }
                
                # Output the cryptocurrency object
                Write-Output $crypto
            }
        }
        catch {
            Write-Error "Failed to get cryptocurrency listings: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCListings completed"
    }
}