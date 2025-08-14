function Convert-CMCPrice {
    <#
    .SYNOPSIS
        Converts cryptocurrency prices between different currencies.
    
    .DESCRIPTION
        The Convert-CMCPrice cmdlet converts an amount of one cryptocurrency or fiat currency
        to its equivalent value in other cryptocurrencies or fiat currencies. This is useful
        for calculating portfolio values and exchange rates.
    
    .PARAMETER Amount
        The amount to convert.
        Default: 1
    
    .PARAMETER Symbol
        The cryptocurrency or fiat currency symbol to convert from.
        Example: "BTC", "ETH", "USD"
    
    .PARAMETER Id
        The CoinMarketCap currency ID to convert from.
    
    .PARAMETER Convert
        One or more currency symbols to convert to.
        Can include both cryptocurrencies and fiat currencies.
        Example: "USD", "EUR", "BTC", "ETH"
    
    .PARAMETER ConvertId
        One or more CoinMarketCap currency IDs to convert to.
    
    .PARAMETER Time
        Optional historical timestamp to convert prices at a specific point in time.
        Accepts DateTime object or string in ISO 8601 format.
    
    .EXAMPLE
        Convert-CMCPrice -Amount 1 -Symbol "BTC" -Convert "USD"
        
        Converts 1 Bitcoin to USD.
    
    .EXAMPLE
        Convert-CMCPrice -Amount 100 -Symbol "USD" -Convert "BTC","ETH","EUR"
        
        Converts $100 USD to Bitcoin, Ethereum, and Euro values.
    
    .EXAMPLE
        Convert-CMCPrice -Amount 0.5 -Symbol "ETH" -Convert "BTC","USD","GBP"
        
        Converts 0.5 Ethereum to Bitcoin, USD, and GBP.
    
    .EXAMPLE
        1000 | Convert-CMCPrice -Symbol "USDT" -Convert "BTC","ETH"
        
        Converts 1000 USDT to BTC and ETH using pipeline input.
    
    .EXAMPLE
        Convert-CMCPrice -Amount 1 -Symbol "BTC" -Convert "USD" -Time "2023-01-01"
        
        Converts 1 BTC to USD at the specified historical date.
    
    .OUTPUTS
        PSCustomObject
        Returns a conversion result object with the original amount and converted values.
    
    .NOTES
        - Supports both cryptocurrency and fiat currency conversions
        - Exchange rates are based on current market prices
        - Historical conversions require appropriate API plan
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV2ToolsPriceconversion
    #>
    [CmdletBinding(DefaultParameterSetName = 'Symbol')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(0.0000000001, [double]::MaxValue)]
        [double]$Amount = 1,
        
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'Symbol'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('From', 'FromSymbol')]
        [string]$Symbol,
        
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Id'
        )]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('FromId')]
        [int]$Id,
        
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(1, 120)]
        [Alias('To', 'ToSymbol')]
        [string[]]$Convert,
        
        [Parameter()]
        [Alias('ToId')]
        [string]$ConvertId,
        
        [Parameter()]
        [Alias('Date', 'Timestamp')]
        [object]$Time
    )
    
    begin {
        Write-Verbose "Converting cryptocurrency prices using CoinMarketCap"
    }
    
    process {
        # Build parameters hashtable
        $parameters = @{
            amount = $Amount
        }
        
        # Add the appropriate source currency parameter
        switch ($PSCmdlet.ParameterSetName) {
            'Symbol' {
                $parameters['symbol'] = $Symbol.ToUpper()
                Write-Verbose "Converting $Amount $($Symbol.ToUpper())"
            }
            'Id' {
                $parameters['id'] = $Id
                Write-Verbose "Converting $Amount of currency ID $Id"
            }
        }
        
        # Handle convert parameter
        if ($Convert) {
            $parameters['convert'] = ($Convert | ForEach-Object { $_.ToUpper() }) -join ','
        }
        if ($ConvertId) {
            $parameters['convert_id'] = $ConvertId
        }
        
        # Handle time parameter for historical conversion
        if ($Time) {
            if ($Time -is [DateTime]) {
                $parameters['time'] = $Time.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            }
            elseif ($Time -is [string]) {
                # Assume ISO 8601 format
                $parameters['time'] = $Time
            }
            else {
                Write-Warning "Time parameter must be a DateTime object or ISO 8601 string"
            }
        }
        
        try {
            # Make API request
            $response = Invoke-CMCRequest -Endpoint '/tools/price-conversion' -Parameters $parameters
            
            # Create result object
            $result = [PSCustomObject]@{
                PSTypeName = 'PsCoinMarketCap.PriceConversion'
                amount = $Amount
                id = $response.id
                symbol = $response.symbol
                name = $response.name
                last_updated = $response.last_updated
            }
            
            # Add source currency info
            if ($PSCmdlet.ParameterSetName -eq 'Symbol') {
                Add-Member -InputObject $result -NotePropertyName 'from_symbol' -NotePropertyValue $Symbol.ToUpper() -Force
            }
            else {
                Add-Member -InputObject $result -NotePropertyName 'from_id' -NotePropertyValue $Id -Force
            }
            
            # Process conversion results
            if ($response.quote) {
                $conversions = @{}
                
                foreach ($currency in $response.quote.PSObject.Properties.Name) {
                    $quote = $response.quote.$currency
                    
                    # Add converted amount
                    Add-Member -InputObject $result -NotePropertyName "${currency}_price" -NotePropertyValue $quote.price -Force
                    Add-Member -InputObject $result -NotePropertyName "${currency}_converted" -NotePropertyValue ($quote.price * $Amount) -Force
                    
                    # Store in conversions hashtable for easy access
                    $conversions[$currency] = [PSCustomObject]@{
                        currency = $currency
                        price = $quote.price
                        converted_amount = $quote.price * $Amount
                        last_updated = $quote.last_updated
                    }
                }
                
                # Add conversions as a property
                Add-Member -InputObject $result -NotePropertyName 'conversions' -NotePropertyValue $conversions -Force
            }
            
            # If historical conversion, add timestamp
            if ($Time) {
                Add-Member -InputObject $result -NotePropertyName 'conversion_time' -NotePropertyValue $parameters['time'] -Force
                Add-Member -InputObject $result -NotePropertyName 'is_historical' -NotePropertyValue $true -Force
            }
            else {
                Add-Member -InputObject $result -NotePropertyName 'is_historical' -NotePropertyValue $false -Force
            }
            
            # Output the conversion result
            Write-Output $result
        }
        catch {
            Write-Error "Failed to convert price: $_"
        }
    }
    
    end {
        Write-Verbose "Convert-CMCPrice completed"
    }
}