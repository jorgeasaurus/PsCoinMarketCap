function Get-CMCInfo {
    <#
    .SYNOPSIS
        Gets metadata for one or more cryptocurrencies.
    
    .DESCRIPTION
        The Get-CMCInfo cmdlet retrieves static metadata for one or more cryptocurrencies
        including name, symbol, logo, description, official website URL, social links,
        technical documentation, source code repository, and more.
    
    .PARAMETER Symbol
        One or more cryptocurrency symbols to get info for.
        Example: "BTC", "ETH", "ADA"
    
    .PARAMETER Id
        One or more CoinMarketCap cryptocurrency IDs to get info for.
        Example: 1, 1027, 2010
    
    .PARAMETER Slug
        One or more cryptocurrency slugs to get info for.
        Example: "bitcoin", "ethereum", "cardano"
    
    .PARAMETER Address
        One or more contract addresses to get info for.
        Pass a contract address to return the cryptocurrency associated with it.
    
    .PARAMETER Aux
        Optionally specify additional metadata fields to return.
        Valid values: urls, logo, description, tags, platform, date_added, notice, status
        Default returns all available fields.
    
    .PARAMETER SkipInvalid
        If true, invalid lookups will be skipped instead of causing an error.
        Default: true
    
    .EXAMPLE
        Get-CMCInfo -Symbol "BTC","ETH"
        
        Gets metadata for Bitcoin and Ethereum.
    
    .EXAMPLE
        Get-CMCInfo -Id 1 -Aux "urls","logo","description"
        
        Gets specific metadata fields for Bitcoin.
    
    .EXAMPLE
        "BTC","ETH","ADA" | Get-CMCInfo
        
        Gets info for multiple cryptocurrencies using pipeline input.
    
    .EXAMPLE
        Get-CMCInfo -Address "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
        
        Gets info for the cryptocurrency at the specified contract address (USDC).
    
    .OUTPUTS
        PSCustomObject
        Returns cryptocurrency metadata objects.
    
    .NOTES
        - You must specify exactly one of: Symbol, Id, Slug, or Address
        - This endpoint returns static metadata that doesn't change frequently
        - Use Get-CMCQuotes for price data
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyInfo
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
        
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Address'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('ContractAddress')]
        [string[]]$Address,
        
        [Parameter()]
        [ValidateSet('urls', 'logo', 'description', 'tags', 'platform', 
                     'date_added', 'notice', 'status')]
        [string[]]$Aux,
        
        [Parameter()]
        [bool]$SkipInvalid = $true
    )
    
    begin {
        Write-Verbose "Getting cryptocurrency info from CoinMarketCap"
        
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
            'Address' {
                $items += $Address
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
                $parameters['symbol'] = ($items | ForEach-Object { $_.ToUpper() }) -join ','
                Write-Verbose "Requesting info for symbols: $($parameters['symbol'])"
            }
            'Id' {
                $parameters['id'] = $items -join ','
                Write-Verbose "Requesting info for IDs: $($parameters['id'])"
            }
            'Slug' {
                $parameters['slug'] = ($items | ForEach-Object { $_.ToLower() }) -join ','
                Write-Verbose "Requesting info for slugs: $($parameters['slug'])"
            }
            'Address' {
                $parameters['address'] = $items -join ','
                Write-Verbose "Requesting info for addresses: $($parameters['address'])"
            }
        }
        
        # Handle aux parameter
        if ($Aux) {
            $parameters['aux'] = $Aux -join ','
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/info' -Parameters $parameters
            
            # Process results
            if ($response -is [PSCustomObject]) {
                foreach ($property in $response.PSObject.Properties) {
                    $crypto = $property.Value
                    
                    # Handle cases where multiple results are returned for a symbol
                    if ($crypto -is [array]) {
                        foreach ($item in $crypto) {
                            ProcessCryptoInfo -Crypto $item
                        }
                    }
                    else {
                        ProcessCryptoInfo -Crypto $crypto
                    }
                }
            }
            elseif ($response -is [array]) {
                foreach ($crypto in $response) {
                    ProcessCryptoInfo -Crypto $crypto
                }
            }
        }
        catch {
            Write-Error "Failed to get cryptocurrency info: $_"
        }
        
        Write-Verbose "Get-CMCInfo completed"
    }
}

# Helper function to process cryptocurrency info object
function ProcessCryptoInfo {
    param(
        [PSCustomObject]$Crypto
    )
    
    # Add custom type for formatting
    $Crypto.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.CryptocurrencyInfo')
    
    # Flatten URLs if present for easier access
    if ($Crypto.urls) {
        if ($Crypto.urls.website) {
            Add-Member -InputObject $Crypto -NotePropertyName 'website' -NotePropertyValue ($Crypto.urls.website -join ', ') -Force
        }
        if ($Crypto.urls.technical_doc) {
            Add-Member -InputObject $Crypto -NotePropertyName 'technical_doc' -NotePropertyValue ($Crypto.urls.technical_doc -join ', ') -Force
        }
        if ($Crypto.urls.twitter) {
            Add-Member -InputObject $Crypto -NotePropertyName 'twitter' -NotePropertyValue ($Crypto.urls.twitter -join ', ') -Force
        }
        if ($Crypto.urls.reddit) {
            Add-Member -InputObject $Crypto -NotePropertyName 'reddit' -NotePropertyValue ($Crypto.urls.reddit -join ', ') -Force
        }
        if ($Crypto.urls.message_board) {
            Add-Member -InputObject $Crypto -NotePropertyName 'message_board' -NotePropertyValue ($Crypto.urls.message_board -join ', ') -Force
        }
        if ($Crypto.urls.announcement) {
            Add-Member -InputObject $Crypto -NotePropertyName 'announcement' -NotePropertyValue ($Crypto.urls.announcement -join ', ') -Force
        }
        if ($Crypto.urls.chat) {
            Add-Member -InputObject $Crypto -NotePropertyName 'chat' -NotePropertyValue ($Crypto.urls.chat -join ', ') -Force
        }
        if ($Crypto.urls.explorer) {
            Add-Member -InputObject $Crypto -NotePropertyName 'explorer' -NotePropertyValue ($Crypto.urls.explorer -join ', ') -Force
        }
        if ($Crypto.urls.source_code) {
            Add-Member -InputObject $Crypto -NotePropertyName 'source_code' -NotePropertyValue ($Crypto.urls.source_code -join ', ') -Force
        }
    }
    
    # Output the cryptocurrency object
    Write-Output $Crypto
}