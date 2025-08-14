function Get-CMCCategories {
    <#
    .SYNOPSIS
        Gets a list of all cryptocurrency categories.
    
    .DESCRIPTION
        The Get-CMCCategories cmdlet retrieves a list of all cryptocurrency categories
        with their associated coins/tokens. Categories include DeFi, Stablecoins, NFTs,
        Exchange Tokens, and many more classification groups.
    
    .PARAMETER Start
        Optionally offset the start (1-based) of the paginated list of items to return.
        Default: 1
    
    .PARAMETER Limit
        Optionally specify the number of results to return.
        Default: 100
    
    .PARAMETER Id
        Filter categories by one or more category IDs.
    
    .PARAMETER Slug
        Filter categories by one or more category slugs.
        Example: "defi", "stablecoin", "exchange-tokens"
    
    .PARAMETER Symbol
        Filter by one or more cryptocurrency symbols to see which categories they belong to.
    
    .EXAMPLE
        Get-CMCCategories
        
        Gets all cryptocurrency categories.
    
    .EXAMPLE
        Get-CMCCategories -Slug "defi","stablecoin"
        
        Gets information about DeFi and Stablecoin categories.
    
    .EXAMPLE
        Get-CMCCategories | Where-Object { $_.num_tokens -gt 100 }
        
        Gets categories with more than 100 tokens.
    
    .EXAMPLE
        Get-CMCCategories -Symbol "BTC","ETH"
        
        Gets the categories that Bitcoin and Ethereum belong to.
    
    .OUTPUTS
        PSCustomObject[]
        Returns an array of category objects with details about each category.
    
    .NOTES
        - Categories help organize and classify cryptocurrencies
        - Each cryptocurrency can belong to multiple categories
        - Use Get-CMCCategory for detailed info about a specific category
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyCategories
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Start = 1,
        
        [Parameter()]
        [ValidateRange(1, 1000)]
        [int]$Limit = 100,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]$Id,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]$Slug,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]$Symbol
    )
    
    begin {
        Write-Verbose "Getting cryptocurrency categories from CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{
            start = $Start
            limit = $Limit
        }
        
        # Add optional filters
        if ($Id) {
            $parameters['id'] = $Id -join ','
        }
        
        if ($Slug) {
            $parameters['slug'] = ($Slug | ForEach-Object { $_.ToLower() }) -join ','
        }
        
        if ($Symbol) {
            $parameters['symbol'] = ($Symbol | ForEach-Object { $_.ToUpper() }) -join ','
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/categories' -Parameters $parameters
            
            # Process and return results
            foreach ($category in $response) {
                # Add custom type for formatting
                $category.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.Category')
                
                # Add calculated properties
                if ($category.market_cap) {
                    Add-Member -InputObject $category -NotePropertyName 'market_cap_billions' -NotePropertyValue ([Math]::Round($category.market_cap / 1000000000, 2)) -Force
                }
                
                if ($category.volume) {
                    Add-Member -InputObject $category -NotePropertyName 'volume_billions' -NotePropertyValue ([Math]::Round($category.volume / 1000000000, 2)) -Force
                }
                
                # Output the category object
                Write-Output $category
            }
        }
        catch {
            Write-Error "Failed to get cryptocurrency categories: $_"
        }
    }
    
    end {
        Write-Verbose "Get-CMCCategories completed"
    }
}