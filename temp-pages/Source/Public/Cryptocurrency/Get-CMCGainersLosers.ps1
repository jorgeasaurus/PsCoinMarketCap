function Get-CMCGainersLosers {
    <#
    .SYNOPSIS
        Gets the top cryptocurrency gainers and losers.
    
    .DESCRIPTION
        The Get-CMCGainersLosers cmdlet retrieves cryptocurrencies with the biggest gains 
        or losses over a specified time period. This helps identify the best and worst 
        performing cryptocurrencies in the market.
    
    .PARAMETER Start
        Optionally offset the start (1-based) of the paginated list of items to return.
        Default: 1
    
    .PARAMETER Limit
        Optionally specify the number of results to return.
        Default: 10, Max: 200
    
    .PARAMETER TimePeriod
        The time period to calculate gains/losses over.
        Valid values: 1h, 24h, 7d, 30d, 60d, 90d
        Default: 24h
    
    .PARAMETER SortDirection
        Return gainers (desc) or losers (asc).
        Valid values: desc (gainers), asc (losers)
        Default: desc
    
    .PARAMETER Convert
        Optionally calculate market quotes in up to 120 currencies at once.
        Default: USD
    
    .PARAMETER ConvertId
        Optionally calculate market quotes by CoinMarketCap cryptocurrency ID instead of symbol.
    
    .PARAMETER MarketCapMin
        Optionally filter by minimum market cap (USD).
    
    .PARAMETER MarketCapMax
        Optionally filter by maximum market cap (USD).
    
    .PARAMETER Volume24hMin
        Optionally filter by minimum 24 hour volume (USD).
    
    .EXAMPLE
        Get-CMCGainersLosers
        
        Gets the top 10 gainers in the last 24 hours.
    
    .EXAMPLE
        Get-CMCGainersLosers -SortDirection asc
        
        Gets the top 10 losers in the last 24 hours.
    
    .EXAMPLE
        Get-CMCGainersLosers -TimePeriod "7d" -Limit 20 -MarketCapMin 1000000000
        
        Gets the top 20 gainers over 7 days with market cap over $1B.
    
    .EXAMPLE
        Get-CMCGainersLosers -SortDirection asc -TimePeriod "1h" | Format-Table name, symbol, USD_price, USD_percent_change_1h
        
        Gets hourly losers and displays formatted results.
    
    .EXAMPLE
        # Get both gainers and losers
        $gainers = Get-CMCGainersLosers -Limit 5
        $losers = Get-CMCGainersLosers -Limit 5 -SortDirection asc
        
        Gets the top 5 gainers and top 5 losers.
    
    .OUTPUTS
        PSCustomObject[]
        Returns an array of cryptocurrency objects sorted by performance.
    
    .NOTES
        - Gainers are cryptocurrencies with the highest positive price changes
        - Losers are cryptocurrencies with the most negative price changes
        - Results are filtered to exclude low volume/market cap coins by default
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingGainerslosers
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Start = 1,
        
        [Parameter()]
        [ValidateRange(1, 200)]
        [int]$Limit = 10,
        
        [Parameter()]
        [ValidateSet('1h', '24h', '7d', '30d', '60d', '90d')]
        [string]$TimePeriod = '24h',
        
        [Parameter()]
        [ValidateSet('desc', 'asc')]
        [string]$SortDirection = 'desc',
        
        [Parameter()]
        [ValidateCount(1, 120)]
        [string[]]$Convert = @('USD'),
        
        [Parameter()]
        [string]$ConvertId,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$MarketCapMin,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$MarketCapMax,
        
        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$Volume24hMin
    )
    
    begin {
        Write-Verbose "Getting top $( if ($SortDirection -eq 'desc') { 'gainers' } else { 'losers' } ) from CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{
            start = $Start
            limit = $Limit
            time_period = $TimePeriod
            sort_dir = $SortDirection
        }
        
        # Handle convert parameter
        if ($Convert) {
            $parameters['convert'] = $Convert -join ','
        }
        if ($ConvertId) {
            $parameters['convert_id'] = $ConvertId
        }
        
        # Add optional filters
        if ($PSBoundParameters.ContainsKey('MarketCapMin')) {
            $parameters['market_cap_min'] = $MarketCapMin
        }
        if ($PSBoundParameters.ContainsKey('MarketCapMax')) {
            $parameters['market_cap_max'] = $MarketCapMax
        }
        if ($PSBoundParameters.ContainsKey('Volume24hMin')) {
            $parameters['volume_24h_min'] = $Volume24hMin
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/trending/gainers-losers' -Parameters $parameters
            
            # Process and return results
            foreach ($crypto in $response) {
                # Add custom type for formatting
                $typeLabel = if ($SortDirection -eq 'desc') { 'Gainer' } else { 'Loser' }
                $crypto.PSObject.TypeNames.Insert(0, "PsCoinMarketCap.$typeLabel")
                
                # Add metadata
                Add-Member -InputObject $crypto -NotePropertyName 'time_period' -NotePropertyValue $TimePeriod -Force
                Add-Member -InputObject $crypto -NotePropertyName 'type' -NotePropertyValue $typeLabel -Force
                
                # Process quote data if available
                if ($crypto.quote) {
                    foreach ($currency in $crypto.quote.PSObject.Properties.Name) {
                        $quote = $crypto.quote.$currency
                        
                        # Flatten quote properties for easier access
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_price" -NotePropertyValue $quote.price -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_volume_24h" -NotePropertyValue $quote.volume_24h -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_volume_change_24h" -NotePropertyValue $quote.volume_change_24h -Force
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_market_cap" -NotePropertyValue $quote.market_cap -Force
                        
                        # Add the relevant percent change based on time period
                        switch ($TimePeriod) {
                            '1h' {
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change" -NotePropertyValue $quote.percent_change_1h -Force
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_1h" -NotePropertyValue $quote.percent_change_1h -Force
                            }
                            '24h' {
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change" -NotePropertyValue $quote.percent_change_24h -Force
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_24h" -NotePropertyValue $quote.percent_change_24h -Force
                            }
                            '7d' {
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change" -NotePropertyValue $quote.percent_change_7d -Force
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_7d" -NotePropertyValue $quote.percent_change_7d -Force
                            }
                            '30d' {
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change" -NotePropertyValue $quote.percent_change_30d -Force
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_30d" -NotePropertyValue $quote.percent_change_30d -Force
                            }
                            '60d' {
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change" -NotePropertyValue $quote.percent_change_60d -Force
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_60d" -NotePropertyValue $quote.percent_change_60d -Force
                            }
                            '90d' {
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change" -NotePropertyValue $quote.percent_change_90d -Force
                                Add-Member -InputObject $crypto -NotePropertyName "${currency}_percent_change_90d" -NotePropertyValue $quote.percent_change_90d -Force
                            }
                        }
                    }
                }
                
                # Output the cryptocurrency
                Write-Output $crypto
            }
        }
        catch {
            Write-Error "Failed to get gainers/losers: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCGainersLosers completed"
    }
}