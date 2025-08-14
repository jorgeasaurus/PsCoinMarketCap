---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyOhlcvLatest
schema: 2.0.0
---

# Get-CMCOHLCV

## SYNOPSIS
Gets the latest OHLCV (Open, High, Low, Close, Volume) data for cryptocurrencies.

## SYNTAX

### Symbol (Default)
```
Get-CMCOHLCV [-Symbol] <String[]> [-Convert <String[]>] [-ConvertId <String>] [-SkipInvalid <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Get-CMCOHLCV -Id <Int32[]> [-Convert <String[]>] [-ConvertId <String>] [-SkipInvalid <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCOHLCV cmdlet retrieves the latest OHLCV (Open, High, Low, Close, Volume) 
market values for one or more cryptocurrencies for the current UTC day.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCOHLCV -Symbol "BTC"
```

Gets today's OHLCV data for Bitcoin.

### EXAMPLE 2
```
Get-CMCOHLCV -Symbol "BTC","ETH","BNB" -Convert "EUR"
```

Gets OHLCV data for multiple cryptocurrencies in EUR.

### EXAMPLE 3
```
@("BTC","ETH") | Get-CMCOHLCV
```

Gets OHLCV data using pipeline input.

### EXAMPLE 4
```
Get-CMCOHLCV -Id 1,1027 | Format-Table symbol, USD_open, USD_high, USD_low, USD_close, USD_volume
```

Gets and formats OHLCV data for display.

## PARAMETERS

### -Symbol
One or more cryptocurrency symbols to get OHLCV data for.
Example: "BTC", "ETH", "ADA"

```yaml
Type: String[]
Parameter Sets: Symbol
Aliases: Ticker

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Id
One or more CoinMarketCap cryptocurrency IDs to get OHLCV data for.
Example: 1, 1027, 2010

```yaml
Type: Int32[]
Parameter Sets: Id
Aliases: CoinId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Convert
Optionally calculate market quotes in up to 120 currencies at once.
Default: USD

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @('USD')
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConvertId
Optionally calculate market quotes by CoinMarketCap cryptocurrency ID instead of symbol.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipInvalid
If true, invalid lookups will be skipped instead of causing an error.
Default: true

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject
### Returns OHLCV data objects with open, high, low, close, and volume values.
## NOTES
- You must specify either Symbol or Id parameter
- OHLCV data represents the current UTC day
- Volume is reported in the quote currency (e.g., USD volume)
- For historical OHLCV data, use Get-CMCHistoricalOHLCV

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyOhlcvLatest](https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyOhlcvLatest)

