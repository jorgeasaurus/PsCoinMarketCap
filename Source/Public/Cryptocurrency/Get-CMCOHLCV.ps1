function Get-CMCOHLCV {
    <#
    .SYNOPSIS
        Gets the latest OHLCV (Open, High, Low, Close, Volume) data for cryptocurrencies.
    
    .DESCRIPTION
        The Get-CMCOHLCV cmdlet retrieves the latest OHLCV (Open, High, Low, Close, Volume) 
        market values for one or more cryptocurrencies for the current UTC day.
    
    .PARAMETER Symbol
        One or more cryptocurrency symbols to get OHLCV data for.
        Example: "BTC", "ETH", "ADA"
    
    .PARAMETER Id
        One or more CoinMarketCap cryptocurrency IDs to get OHLCV data for.
        Example: 1, 1027, 2010
    
    .PARAMETER Convert
        Optionally calculate market quotes in up to 120 currencies at once.
        Default: USD
    
    .PARAMETER ConvertId
        Optionally calculate market quotes by CoinMarketCap cryptocurrency ID instead of symbol.
    
    .PARAMETER SkipInvalid
        If true, invalid lookups will be skipped instead of causing an error.
        Default: true
    
    .EXAMPLE
        Get-CMCOHLCV -Symbol "BTC"
        
        Gets today's OHLCV data for Bitcoin.
    
    .EXAMPLE
        Get-CMCOHLCV -Symbol "BTC","ETH","BNB" -Convert "EUR"
        
        Gets OHLCV data for multiple cryptocurrencies in EUR.
    
    .EXAMPLE
        @("BTC","ETH") | Get-CMCOHLCV
        
        Gets OHLCV data using pipeline input.
    
    .EXAMPLE
        Get-CMCOHLCV -Id 1,1027 | Format-Table symbol, USD_open, USD_high, USD_low, USD_close, USD_volume
        
        Gets and formats OHLCV data for display.
    
    .OUTPUTS
        PSCustomObject
        Returns OHLCV data objects with open, high, low, close, and volume values.
    
    .NOTES
        - You must specify either Symbol or Id parameter
        - OHLCV data represents the current UTC day
        - Volume is reported in the quote currency (e.g., USD volume)
        - For historical OHLCV data, use Get-CMCHistoricalOHLCV
    
    .LINK
        https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyOhlcvLatest
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
        
        [Parameter()]
        [ValidateCount(1, 120)]
        [string[]]$Convert = @('USD'),
        
        [Parameter()]
        [string]$ConvertId,
        
        [Parameter()]
        [bool]$SkipInvalid = $true
    )
    
    begin {
        Write-Verbose "Getting OHLCV data from CoinMarketCap"
        
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
                Write-Verbose "Requesting OHLCV for symbols: $($parameters['symbol'])"
            }
            'Id' {
                $parameters['id'] = $items -join ','
                Write-Verbose "Requesting OHLCV for IDs: $($parameters['id'])"
            }
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
            $response = Invoke-CMCRequest -Endpoint '/cryptocurrency/ohlcv/latest' -Parameters $parameters
            
            # Process results
            if ($response -is [PSCustomObject]) {
                foreach ($property in $response.PSObject.Properties) {
                    $crypto = $property.Value
                    
                    # Handle cases where multiple results are returned for a symbol
                    if ($crypto -is [array]) {
                        foreach ($item in $crypto) {
                            ProcessOHLCVData -Crypto $item
                        }
                    }
                    else {
                        ProcessOHLCVData -Crypto $crypto
                    }
                }
            }
            elseif ($response -is [array]) {
                foreach ($crypto in $response) {
                    ProcessOHLCVData -Crypto $crypto
                }
            }
        }
        catch {
            Write-Error "Failed to get OHLCV data: $_"
        }
        
        Write-Verbose "Get-CMCOHLCV completed"
    }
}

# Helper function to process OHLCV data
function ProcessOHLCVData {
    param(
        [PSCustomObject]$Crypto
    )
    
    # Add custom type for formatting
    $Crypto.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.OHLCV')
    
    # Process quote data for each currency
    if ($Crypto.quote) {
        foreach ($currency in $Crypto.quote.PSObject.Properties.Name) {
            $quote = $Crypto.quote.$currency
            
            # Flatten OHLCV properties for easier access
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_open" -NotePropertyValue $quote.open -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_high" -NotePropertyValue $quote.high -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_low" -NotePropertyValue $quote.low -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_close" -NotePropertyValue $quote.close -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_volume" -NotePropertyValue $quote.volume -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_market_cap" -NotePropertyValue $quote.market_cap -Force
            Add-Member -InputObject $Crypto -NotePropertyName "${currency}_timestamp" -NotePropertyValue $quote.timestamp -Force
            
            # Calculate additional metrics
            if ($quote.open -and $quote.close) {
                $change = $quote.close - $quote.open
                $changePercent = if ($quote.open -ne 0) { ($change / $quote.open) * 100 } else { 0 }
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_change" -NotePropertyValue $change -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_change_percent" -NotePropertyValue $changePercent -Force
            }
            
            # Calculate trading range
            if ($quote.high -and $quote.low) {
                $range = $quote.high - $quote.low
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_range" -NotePropertyValue $range -Force
            }
        }
    }
    
    # Output the OHLCV object
    Write-Output $Crypto
}