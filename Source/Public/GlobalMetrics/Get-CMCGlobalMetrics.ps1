function Get-CMCGlobalMetrics {
    <#
    .SYNOPSIS
        Gets global cryptocurrency market metrics.
    
    .DESCRIPTION
        The Get-CMCGlobalMetrics cmdlet retrieves global cryptocurrency market metrics including
        total market cap, total volume, Bitcoin dominance, number of cryptocurrencies, and more.
        This provides an overview of the entire cryptocurrency market.
    
    .PARAMETER Convert
        Optionally calculate market quotes in up to 120 currencies at once.
        Default: USD
    
    .PARAMETER ConvertId
        Optionally calculate market quotes by CoinMarketCap cryptocurrency ID instead of symbol.
    
    .EXAMPLE
        Get-CMCGlobalMetrics
        
        Gets global market metrics in USD.
    
    .EXAMPLE
        Get-CMCGlobalMetrics -Convert "EUR","GBP","JPY"
        
        Gets global metrics with values in multiple currencies.
    
    .EXAMPLE
        $metrics = Get-CMCGlobalMetrics
        $metrics | Select-Object total_cryptocurrencies, active_market_pairs, USD_total_market_cap, btc_dominance
        
        Gets and displays specific global metrics.
    
    .EXAMPLE
        Get-CMCGlobalMetrics | Format-List
        
        Gets global metrics and displays all properties in list format.
    
    .OUTPUTS
        PSCustomObject
        Returns a global metrics object with market overview data.
    
    .NOTES
        - Global metrics are updated every minute
        - Market cap excludes coins/tokens not actively traded
        - BTC dominance shows Bitcoin's percentage of total market cap
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV1GlobalmetricsQuotesLatest
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [ValidateCount(1, 120)]
        [string[]]$Convert = @('USD'),
        
        [Parameter()]
        [string]$ConvertId
    )
    
    begin {
        Write-Verbose "Getting global cryptocurrency market metrics from CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{}
        
        # Handle convert parameter
        if ($Convert) {
            $parameters['convert'] = $Convert -join ','
        }
        if ($ConvertId) {
            $parameters['convert_id'] = $ConvertId
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/global-metrics/quotes/latest' -Parameters $parameters
            
            # Add custom type for formatting
            $response.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.GlobalMetrics')
            
            # Process quote data for each currency
            if ($response.quote) {
                foreach ($currency in $response.quote.PSObject.Properties.Name) {
                    $quote = $response.quote.$currency
                    
                    # Flatten quote properties for easier access
                    Add-Member -InputObject $response -NotePropertyName "${currency}_total_market_cap" -NotePropertyValue $quote.total_market_cap -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_total_volume_24h" -NotePropertyValue $quote.total_volume_24h -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_total_volume_24h_reported" -NotePropertyValue $quote.total_volume_24h_reported -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_altcoin_market_cap" -NotePropertyValue $quote.altcoin_market_cap -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_altcoin_volume_24h" -NotePropertyValue $quote.altcoin_volume_24h -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_altcoin_volume_24h_reported" -NotePropertyValue $quote.altcoin_volume_24h_reported -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_stablecoin_volume_24h" -NotePropertyValue $quote.stablecoin_volume_24h -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_stablecoin_volume_24h_reported" -NotePropertyValue $quote.stablecoin_volume_24h_reported -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_stablecoin_market_cap" -NotePropertyValue $quote.stablecoin_market_cap -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_defi_volume_24h" -NotePropertyValue $quote.defi_volume_24h -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_defi_volume_24h_reported" -NotePropertyValue $quote.defi_volume_24h_reported -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_defi_market_cap" -NotePropertyValue $quote.defi_market_cap -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_derivatives_volume_24h" -NotePropertyValue $quote.derivatives_volume_24h -Force
                    Add-Member -InputObject $response -NotePropertyName "${currency}_derivatives_volume_24h_reported" -NotePropertyValue $quote.derivatives_volume_24h_reported -Force
                    Add-Member -InputObject $response -NotePropertyName "last_updated" -NotePropertyValue $quote.last_updated -Force
                    
                    # Add calculated values in billions for readability
                    if ($quote.total_market_cap) {
                        Add-Member -InputObject $response -NotePropertyName "${currency}_total_market_cap_billions" -NotePropertyValue ([Math]::Round($quote.total_market_cap / 1000000000, 2)) -Force
                    }
                    if ($quote.total_volume_24h) {
                        Add-Member -InputObject $response -NotePropertyName "${currency}_total_volume_24h_billions" -NotePropertyValue ([Math]::Round($quote.total_volume_24h / 1000000000, 2)) -Force
                    }
                }
            }
            
            # Add dominance percentages if available
            if ($response.btc_dominance) {
                Add-Member -InputObject $response -NotePropertyName 'btc_dominance_percentage' -NotePropertyValue "$([Math]::Round($response.btc_dominance, 2))%" -Force
            }
            if ($response.eth_dominance) {
                Add-Member -InputObject $response -NotePropertyName 'eth_dominance_percentage' -NotePropertyValue "$([Math]::Round($response.eth_dominance, 2))%" -Force
            }
            if ($response.stablecoin_dominance) {
                Add-Member -InputObject $response -NotePropertyName 'stablecoin_dominance_percentage' -NotePropertyValue "$([Math]::Round($response.stablecoin_dominance, 2))%" -Force
            }
            if ($response.defi_dominance) {
                Add-Member -InputObject $response -NotePropertyName 'defi_dominance_percentage' -NotePropertyValue "$([Math]::Round($response.defi_dominance, 2))%" -Force
            }
            
            # Output the global metrics object
            Write-Output $response
        }
        catch {
            Write-Error "Failed to get global metrics: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCGlobalMetrics completed"
    }
}