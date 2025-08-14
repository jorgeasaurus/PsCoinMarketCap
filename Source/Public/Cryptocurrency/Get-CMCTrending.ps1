function Get-CMCTrending {
    <#
    .SYNOPSIS
        Gets trending cryptocurrencies on CoinMarketCap.
    
    .DESCRIPTION
        The Get-CMCTrending cmdlet retrieves a list of trending cryptocurrencies 
        based on the highest price movements and social media activity. This includes
        the most searched and most viewed cryptocurrencies over various time periods.
    
    .PARAMETER Start
        Optionally offset the start (1-based) of the paginated list of items to return.
        Default: 1
    
    .PARAMETER Limit
        Optionally specify the number of results to return.
        Default: 10, Max: 200
    
    .PARAMETER TimePeriod
        The time period to get trending cryptocurrencies for.
        Valid values: 24h, 7d, 30d
        Default: 24h
    
    .PARAMETER Convert
        Optionally calculate market quotes in up to 120 currencies at once.
        Default: USD
    
    .PARAMETER ConvertId
        Optionally calculate market quotes by CoinMarketCap cryptocurrency ID instead of symbol.
    
    .EXAMPLE
        Get-CMCTrending
        
        Gets the top 10 trending cryptocurrencies in the last 24 hours.
    
    .EXAMPLE
        Get-CMCTrending -TimePeriod "7d" -Limit 20
        
        Gets the top 20 trending cryptocurrencies over the last 7 days.
    
    .EXAMPLE
        Get-CMCTrending -Convert "EUR","GBP" | Format-Table name, symbol, EUR_price, EUR_percent_change_24h
        
        Gets trending cryptos with prices in EUR and GBP.
    
    .EXAMPLE
        Get-CMCTrending | Select-Object -First 5 | Get-CMCQuotes
        
        Gets detailed quotes for the top 5 trending cryptocurrencies.
    
    .OUTPUTS
        PSCustomObject[]
        Returns an array of trending cryptocurrency objects with market data.
    
    .NOTES
        - REQUIRES PAID PLAN (Hobbyist or higher)
        - Trending is determined by search volume and price movements
        - Results are updated regularly throughout the day
        - Use this to identify cryptocurrencies gaining attention
        - Free tier alternative: Use Get-CMCListings with sort by percent_change
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingLatest
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
        [ValidateSet('24h', '7d', '30d')]
        [string]$TimePeriod = '24h',
        
        [Parameter()]
        [ValidateCount(1, 120)]
        [string[]]$Convert = @('USD'),
        
        [Parameter()]
        [string]$ConvertId
    )
    
    begin {
        Write-Verbose "Getting trending cryptocurrencies from CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{
            start = $Start
            limit = $Limit
            time_period = $TimePeriod
        }
        
        # Handle convert parameter
        if ($Convert) {
            $parameters['convert'] = $Convert -join ','
        }
        if ($ConvertId) {
            $parameters['convert_id'] = $ConvertId
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/trending/latest' -Parameters $parameters
            
            # Process and return results
            foreach ($crypto in $response) {
                # Add custom type for formatting
                $crypto.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.Trending')
                
                # Add time period to object for reference
                Add-Member -InputObject $crypto -NotePropertyName 'time_period' -NotePropertyValue $TimePeriod -Force
                
                # Process quote data if available
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
                        Add-Member -InputObject $crypto -NotePropertyName "${currency}_market_cap" -NotePropertyValue $quote.market_cap -Force
                    }
                }
                
                # Output the trending cryptocurrency
                Write-Output $crypto
            }
        }
        catch {
            Write-Error "Failed to get trending cryptocurrencies: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCTrending completed"
    }
}