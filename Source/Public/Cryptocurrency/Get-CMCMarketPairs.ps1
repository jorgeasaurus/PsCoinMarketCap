function Get-CMCMarketPairs {
    <#
    .SYNOPSIS
        Gets market pair information for a cryptocurrency.
    
    .DESCRIPTION
        The Get-CMCMarketPairs cmdlet retrieves a list of all active market pairs that a 
        cryptocurrency is traded on including the exchange, quote currency, price, and volume.
    
    .PARAMETER Symbol
        A cryptocurrency symbol to get market pairs for.
        Example: "BTC"
    
    .PARAMETER Id
        A CoinMarketCap cryptocurrency ID to get market pairs for.
        Example: 1
    
    .PARAMETER Slug
        A cryptocurrency slug to get market pairs for.
        Example: "bitcoin"
    
    .PARAMETER Start
        Optionally offset the start (1-based) of the paginated list of items to return.
        Default: 1
    
    .PARAMETER Limit
        Optionally specify the number of results to return.
        Default: 100, Max: 5000
    
    .PARAMETER SortDirection
        Optionally specify the sort direction of markets returned.
        Valid values: asc, desc
        Default: desc (best markets first)
    
    .PARAMETER Sort
        Optionally specify the sort field for market pairs.
        Valid values: volume_24h_strict, effective_liquidity, market_score, market_reputation
        Default: volume_24h_strict
    
    .PARAMETER Aux
        Optionally specify additional data fields to return.
        Valid values: num_market_pairs, market_url, price_quote, effective_liquidity, 
                     market_score, market_reputation
    
    .PARAMETER MatchedSymbol
        Optionally include only market pairs with this symbol as the quote currency.
        Example: "USD", "USDT", "BTC"
    
    .PARAMETER MatchedId
        Optionally include only market pairs with this CoinMarketCap ID as the quote currency.
    
    .PARAMETER Category
        Filter market pairs by exchange category.
        Valid values: all, spot, derivatives, otc, futures
        Default: all
    
    .PARAMETER FeeType
        Filter market pairs by fee type.
        Valid values: all, percentage, no-fees, transactional-mining, unknown
        Default: all
    
    .EXAMPLE
        Get-CMCMarketPairs -Symbol "BTC"
        
        Gets all market pairs for Bitcoin.
    
    .EXAMPLE
        Get-CMCMarketPairs -Symbol "ETH" -MatchedSymbol "USDT" -Limit 10
        
        Gets the top 10 ETH/USDT trading pairs.
    
    .EXAMPLE
        Get-CMCMarketPairs -Id 1 -Category "spot" -Sort "market_score"
        
        Gets spot market pairs for Bitcoin sorted by market score.
    
    .EXAMPLE
        Get-CMCMarketPairs -Symbol "BNB" | Where-Object { $_.volume_24h -gt 1000000 }
        
        Gets all BNB market pairs with over $1M daily volume.
    
    .OUTPUTS
        PSCustomObject
        Returns market pair data including exchange info and trading metrics.
    
    .NOTES
        - You must specify exactly one of: Symbol, Id, or Slug
        - Market pairs are sorted by 24h volume by default
        - This endpoint shows where a cryptocurrency can be traded
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyMarketpairsLatest
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
        [string]$Symbol,
        
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Id'
        )]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('CoinId')]
        [int]$Id,
        
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Slug'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Slug,
        
        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Start = 1,
        
        [Parameter()]
        [ValidateRange(1, 5000)]
        [int]$Limit = 100,
        
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string]$SortDirection = 'desc',
        
        [Parameter()]
        [ValidateSet('volume_24h_strict', 'effective_liquidity', 'market_score', 'market_reputation')]
        [string]$Sort = 'volume_24h_strict',
        
        [Parameter()]
        [ValidateSet('num_market_pairs', 'market_url', 'price_quote', 'effective_liquidity',
                     'market_score', 'market_reputation')]
        [string[]]$Aux,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$MatchedSymbol,
        
        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$MatchedId,
        
        [Parameter()]
        [ValidateSet('all', 'spot', 'derivatives', 'otc', 'futures')]
        [string]$Category = 'all',
        
        [Parameter()]
        [ValidateSet('all', 'percentage', 'no-fees', 'transactional-mining', 'unknown')]
        [string]$FeeType = 'all'
    )
    
    begin {
        Write-Verbose "Getting market pairs from CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{
            start = $Start
            limit = $Limit
            sort_dir = $SortDirection
            sort = $Sort
            category = $Category
            fee_type = $FeeType
        }
        
        # Add the appropriate identifier parameter
        switch ($PSCmdlet.ParameterSetName) {
            'Symbol' {
                $parameters['symbol'] = $Symbol.ToUpper()
                Write-Verbose "Requesting market pairs for symbol: $($parameters['symbol'])"
            }
            'Id' {
                $parameters['id'] = $Id
                Write-Verbose "Requesting market pairs for ID: $($parameters['id'])"
            }
            'Slug' {
                $parameters['slug'] = $Slug.ToLower()
                Write-Verbose "Requesting market pairs for slug: $($parameters['slug'])"
            }
        }
        
        # Add optional parameters
        if ($Aux) {
            $parameters['aux'] = $Aux -join ','
        }
        
        if ($MatchedSymbol) {
            $parameters['matched_symbol'] = $MatchedSymbol.ToUpper()
        }
        
        if ($PSBoundParameters.ContainsKey('MatchedId')) {
            $parameters['matched_id'] = $MatchedId
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/market-pairs/latest' -Parameters $parameters
            
            # Extract the market pairs data
            if ($response.market_pairs) {
                $marketPairs = $response.market_pairs
                
                # Add metadata to each market pair
                foreach ($pair in $marketPairs) {
                    # Add custom type for formatting
                    $pair.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.MarketPair')
                    
                    # Add cryptocurrency info from response root
                    if ($response.id) {
                        Add-Member -InputObject $pair -NotePropertyName 'cryptocurrency_id' -NotePropertyValue $response.id -Force
                    }
                    if ($response.name) {
                        Add-Member -InputObject $pair -NotePropertyName 'cryptocurrency_name' -NotePropertyValue $response.name -Force
                    }
                    if ($response.symbol) {
                        Add-Member -InputObject $pair -NotePropertyName 'cryptocurrency_symbol' -NotePropertyValue $response.symbol -Force
                    }
                    
                    # Flatten exchange info for easier access
                    if ($pair.exchange) {
                        Add-Member -InputObject $pair -NotePropertyName 'exchange_name' -NotePropertyValue $pair.exchange.name -Force
                        Add-Member -InputObject $pair -NotePropertyName 'exchange_slug' -NotePropertyValue $pair.exchange.slug -Force
                        Add-Member -InputObject $pair -NotePropertyName 'exchange_id' -NotePropertyValue $pair.exchange.id -Force
                    }
                    
                    # Flatten market pair info
                    if ($pair.market_pair_base) {
                        Add-Member -InputObject $pair -NotePropertyName 'base_symbol' -NotePropertyValue $pair.market_pair_base.symbol -Force
                        Add-Member -InputObject $pair -NotePropertyName 'base_id' -NotePropertyValue $pair.market_pair_base.currency_id -Force
                    }
                    
                    if ($pair.market_pair_quote) {
                        Add-Member -InputObject $pair -NotePropertyName 'quote_symbol' -NotePropertyValue $pair.market_pair_quote.symbol -Force
                        Add-Member -InputObject $pair -NotePropertyName 'quote_id' -NotePropertyValue $pair.market_pair_quote.currency_id -Force
                    }
                    
                    # Flatten quote data
                    if ($pair.quote) {
                        foreach ($currency in $pair.quote.PSObject.Properties.Name) {
                            $quote = $pair.quote.$currency
                            Add-Member -InputObject $pair -NotePropertyName "${currency}_price" -NotePropertyValue $quote.price -Force
                            Add-Member -InputObject $pair -NotePropertyName "${currency}_volume_24h" -NotePropertyValue $quote.volume_24h -Force
                            Add-Member -InputObject $pair -NotePropertyName "${currency}_effective_liquidity" -NotePropertyValue $quote.effective_liquidity -Force
                            Add-Member -InputObject $pair -NotePropertyName "${currency}_last_updated" -NotePropertyValue $quote.last_updated -Force
                        }
                    }
                    
                    # Output the market pair
                    Write-Output $pair
                }
                
                # Add summary information
                if ($response.num_market_pairs) {
                    Write-Verbose "Total market pairs available: $($response.num_market_pairs)"
                }
            }
            else {
                Write-Warning "No market pairs found for the specified cryptocurrency"
            }
        }
        catch {
            Write-Error "Failed to get market pairs: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCMarketPairs completed"
    }
}