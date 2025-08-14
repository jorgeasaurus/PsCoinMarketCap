function Get-CMCQuotes {
    <#
    .SYNOPSIS
        Gets the latest market quote for one or more cryptocurrencies.
    
    .DESCRIPTION
        The Get-CMCQuotes cmdlet retrieves the latest market quote for one or more cryptocurrencies.
        You can identify cryptocurrencies by symbol, CoinMarketCap ID, or slug. Use this endpoint
        to get detailed price and volume information for specific cryptocurrencies.
    
    .PARAMETER Symbol
        One or more cryptocurrency symbols to get quotes for.
        Example: "BTC", "ETH", "ADA"
    
    .PARAMETER Id
        One or more CoinMarketCap cryptocurrency IDs to get quotes for.
        Example: 1, 1027, 2010
    
    .PARAMETER Slug
        One or more cryptocurrency slugs to get quotes for.
        Example: "bitcoin", "ethereum", "cardano"
    
    .PARAMETER Convert
        Optionally calculate market quotes in up to 120 currencies at once.
        Default: USD
    
    .PARAMETER ConvertId
        Optionally calculate market quotes by CoinMarketCap cryptocurrency ID instead of symbol.
    
    .PARAMETER Aux
        Optionally specify additional data fields to return.
        Valid values: num_market_pairs, cmc_rank, date_added, tags, platform, 
                     max_supply, circulating_supply, total_supply, market_cap_by_total_supply,
                     volume_24h_reported, volume_7d, volume_7d_reported, volume_30d, 
                     volume_30d_reported, is_active, is_fiat
    
    .PARAMETER SkipInvalid
        If true, invalid lookups will be skipped instead of causing an error.
        Default: true
    
    .EXAMPLE
        Get-CMCQuotes -Symbol "BTC","ETH"
        
        Gets the latest quotes for Bitcoin and Ethereum.
    
    .EXAMPLE
        Get-CMCQuotes -Symbol "BTC" -Convert "EUR","GBP","JPY"
        
        Gets Bitcoin quote with prices in EUR, GBP, and JPY.
    
    .EXAMPLE
        "BTC","ETH","ADA" | Get-CMCQuotes
        
        Gets quotes for multiple cryptocurrencies using pipeline input.
    
    .EXAMPLE
        Get-CMCQuotes -Id 1,1027,2010 -Aux "circulating_supply","max_supply","cmc_rank"
        
        Gets quotes by CoinMarketCap ID with additional supply and rank data.
    
    .OUTPUTS
        PSCustomObject
        Returns cryptocurrency quote objects with detailed market data.
    
    .NOTES
        - You must specify exactly one of: Symbol, Id, or Slug
        - This endpoint is more efficient than Get-CMCListings for specific cryptocurrencies
        - Rate limits apply based on your CoinMarketCap plan
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyQuotesLatest
    #>
    [CmdletBinding(DefaultParameterSetName = 'Symbol')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Symbol'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Ticker')]
        [string[]]$Symbol,
        
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Id'
        )]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('CoinId')]
        [int[]]$Id,
        
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Slug'
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Slug,
        
        [Parameter()]
        [ValidateCount(1, 120)]
        [string[]]$Convert = @('USD'),
        
        [Parameter()]
        [string]$ConvertId,
        
        [Parameter()]
        [ValidateSet('num_market_pairs', 'cmc_rank', 'date_added', 'tags', 'platform',
                     'max_supply', 'circulating_supply', 'total_supply', 
                     'market_cap_by_total_supply', 'volume_24h_reported', 'volume_7d',
                     'volume_7d_reported', 'volume_30d', 'volume_30d_reported',
                     'is_active', 'is_fiat')]
        [string[]]$Aux,
        
        [Parameter()]
        [bool]$SkipInvalid = $true
    )
    
    begin {
        Write-Verbose "Getting cryptocurrency quotes from CoinMarketCap"
        
        # Collect items when using pipeline
        $items = @()
    }
    
    process {
        # Collect pipeline input
        switch ($PSCmdlet.ParameterSetName) {
            'Symbol' {
                $items += $Symbol
            }
            'Id' {
                $items += $Id
            }
            'Slug' {
                $items += $Slug
            }
        }
    }
    
    end {
        # Build parameters hashtable
        $parameters = @{
            skip_invalid = $SkipInvalid.ToString().ToLower()
        }
        
        # Add the appropriate identifier parameter
        switch ($PSCmdlet.ParameterSetName) {
            'Symbol' {
                # Convert array to uppercase and join
                $parameters['symbol'] = ($items | ForEach-Object { $_.ToUpper() }) -join ','
                Write-Verbose "Requesting quotes for symbols: $($parameters['symbol'])"
            }
            'Id' {
                $parameters['id'] = $items -join ','
                Write-Verbose "Requesting quotes for IDs: $($parameters['id'])"
            }
            'Slug' {
                # Convert array to lowercase and join
                $parameters['slug'] = ($items | ForEach-Object { $_.ToLower() }) -join ','
                Write-Verbose "Requesting quotes for slugs: $($parameters['slug'])"
            }
        }
        
        # Handle convert parameter
        if ($Convert) {
            $parameters['convert'] = $Convert -join ','
        }
        if ($ConvertId) {
            $parameters['convert_id'] = $ConvertId
        }
        
        # Handle aux parameter
        if ($Aux) {
            $parameters['aux'] = $Aux -join ','
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/quotes/latest' -Parameters $parameters
            
            # Process results based on response structure
            # The API returns an object with properties for each requested cryptocurrency
            if ($response -is [PSCustomObject]) {
                foreach ($property in $response.PSObject.Properties) {
                    $crypto = $property.Value
                    
                    # Handle cases where multiple results are returned for a symbol
                    if ($crypto -is [array]) {
                        foreach ($item in $crypto) {
                            ProcessCryptoQuote -Crypto $item
                        }
                    }
                    else {
                        ProcessCryptoQuote -Crypto $crypto
                    }
                }
            }
            elseif ($response -is [array]) {
                # Sometimes the API returns an array directly
                foreach ($crypto in $response) {
                    ProcessCryptoQuote -Crypto $crypto
                }
            }
        }
        catch {
            Write-Error "Failed to get cryptocurrency quotes: $_"
        }
        
        Write-Verbose "Get-CMCQuotes completed"
    }
}

# Helper function to process cryptocurrency quote object
function ProcessCryptoQuote {
    param(
        [PSCustomObject]$Crypto
    )
    
    # Add custom type for formatting
    $Crypto.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.CryptocurrencyQuote')
    
    # Add calculated properties for easier access
    if ($Crypto.quote) {
        foreach ($currency in $Crypto.quote.PSObject.Properties.Name) {
            $quote = $Crypto.quote.$currency
            
            # Flatten quote properties for easier access
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_price" -NotePropertyValue $quote.price -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_volume_24h" -NotePropertyValue $quote.volume_24h -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_volume_change_24h" -NotePropertyValue $quote.volume_change_24h -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_1h" -NotePropertyValue $quote.percent_change_1h -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_24h" -NotePropertyValue $quote.percent_change_24h -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_7d" -NotePropertyValue $quote.percent_change_7d -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_30d" -NotePropertyValue $quote.percent_change_30d -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_60d" -NotePropertyValue $quote.percent_change_60d -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_90d" -NotePropertyValue $quote.percent_change_90d -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_market_cap" -NotePropertyValue $quote.market_cap -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_market_cap_dominance" -NotePropertyValue $quote.market_cap_dominance -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_fully_diluted_market_cap" -NotePropertyValue $quote.fully_diluted_market_cap -Force
            Add-Member -InputObject $Crypto -NotePropertyName "last_updated" -NotePropertyValue $quote.last_updated -Force
        }
    }
    
    # Output the cryptocurrency object
    Write-Output $Crypto
}