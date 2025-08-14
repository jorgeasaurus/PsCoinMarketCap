function Get-CMCMap {
    <#
    .SYNOPSIS
        Gets a mapping of all cryptocurrencies to their CoinMarketCap IDs.
    
    .DESCRIPTION
        The Get-CMCMap cmdlet returns a mapping of all cryptocurrencies listed on CoinMarketCap
        including their name, symbol, slug, CoinMarketCap ID, and platform information.
        This is useful for converting between different cryptocurrency identifiers.
    
    .PARAMETER ListingStatus
        Filter by listing status.
        Valid values: active, inactive, untracked
        Default: active
    
    .PARAMETER Start
        Optionally offset the start (1-based) of the paginated list of items to return.
        Default: 1
    
    .PARAMETER Limit
        Optionally specify the number of results to return.
        Default: 5000, Max: 5000
    
    .PARAMETER Sort
        What field to sort the list by.
        Valid values: id, cmc_rank
        Default: id
    
    .PARAMETER Symbol
        Optionally filter by one or more cryptocurrency symbols.
        Example: "BTC", "ETH"
    
    .PARAMETER Aux
        Optionally specify additional data fields to return.
        Valid values: platform, first_historical_data, last_historical_data, is_active, status
    
    .EXAMPLE
        Get-CMCMap
        
        Gets the ID map for all active cryptocurrencies.
    
    .EXAMPLE
        Get-CMCMap -Symbol "BTC","ETH","USDT"
        
        Gets the ID mapping for specific cryptocurrencies.
    
    .EXAMPLE
        Get-CMCMap -ListingStatus "inactive" -Limit 100
        
        Gets the first 100 inactive cryptocurrencies.
    
    .EXAMPLE
        Get-CMCMap -Aux "platform","is_active" | Where-Object { $_.platform }
        
        Gets all cryptocurrencies with platform information (tokens).
    
    .EXAMPLE
        $map = Get-CMCMap
        $btcId = ($map | Where-Object { $_.symbol -eq 'BTC' }).id
        
        Gets the CoinMarketCap ID for Bitcoin.
    
    .OUTPUTS
        PSCustomObject[]
        Returns an array of cryptocurrency mapping objects.
    
    .NOTES
        - This endpoint is useful for finding CoinMarketCap IDs to use with other endpoints
        - The map includes both active and inactive cryptocurrencies
        - Results are cached for performance when called multiple times
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyMap
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter()]
        [ValidateSet('active', 'inactive', 'untracked')]
        [string]$ListingStatus = 'active',
        
        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Start = 1,
        
        [Parameter()]
        [ValidateRange(1, 5000)]
        [int]$Limit = 5000,
        
        [Parameter()]
        [ValidateSet('id', 'cmc_rank')]
        [string]$Sort = 'id',
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]$Symbol,
        
        [Parameter()]
        [ValidateSet('platform', 'first_historical_data', 'last_historical_data', 
                     'is_active', 'status')]
        [string[]]$Aux
    )
    
    begin {
        Write-Verbose "Getting cryptocurrency map from CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{
            listing_status = $ListingStatus
            start = $Start
            limit = $Limit
            sort = $Sort
        }
        
        # Add optional parameters
        if ($Symbol) {
            $parameters['symbol'] = ($Symbol | ForEach-Object { $_.ToUpper() }) -join ','
        }
        
        if ($Aux) {
            $parameters['aux'] = $Aux -join ','
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/map' -Parameters $parameters
            
            # Process and return results
            foreach ($crypto in $response) {
                # Add custom type for formatting
                $crypto.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.CryptocurrencyMap')
                
                # Add helper properties
                if ($crypto.platform) {
                    Add-Member -InputObject $crypto -NotePropertyName 'platform_name' -NotePropertyValue $crypto.platform.name -Force
                    Add-Member -InputObject $crypto -NotePropertyName 'platform_symbol' -NotePropertyValue $crypto.platform.symbol -Force
                    Add-Member -InputObject $crypto -NotePropertyName 'token_address' -NotePropertyValue $crypto.platform.token_address -Force
                }
                
                # Output the cryptocurrency mapping object
                Write-Output $crypto
            }
        }
        catch {
            Write-Error "Failed to get cryptocurrency map: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCMap completed"
    }
}