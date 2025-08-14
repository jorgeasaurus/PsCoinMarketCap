---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2ToolsPriceconversion
schema: 2.0.0
---

# Convert-CMCPrice

## SYNOPSIS
Converts cryptocurrency prices between different currencies.

## SYNTAX

### Symbol (Default)
```
Convert-CMCPrice [[-Amount] <Double>] [-Symbol] <String> [-Convert] <String[]> [-ConvertId <String>]
 [-Time <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Convert-CMCPrice [[-Amount] <Double>] -Id <Int32> [-Convert] <String[]> [-ConvertId <String>] [-Time <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Convert-CMCPrice cmdlet converts an amount of one cryptocurrency or fiat currency
to its equivalent value in other cryptocurrencies or fiat currencies.
This is useful
for calculating portfolio values and exchange rates.

## EXAMPLES

### EXAMPLE 1
```
Convert-CMCPrice -Amount 1 -Symbol "BTC" -Convert "USD"
```

Converts 1 Bitcoin to USD.

### EXAMPLE 2
```
Convert-CMCPrice -Amount 100 -Symbol "USD" -Convert "BTC","ETH","EUR"
```

Converts $100 USD to Bitcoin, Ethereum, and Euro values.

### EXAMPLE 3
```
Convert-CMCPrice -Amount 0.5 -Symbol "ETH" -Convert "BTC","USD","GBP"
```

Converts 0.5 Ethereum to Bitcoin, USD, and GBP.

### EXAMPLE 4
```
1000 | Convert-CMCPrice -Symbol "USDT" -Convert "BTC","ETH"
```

Converts 1000 USDT to BTC and ETH using pipeline input.

### EXAMPLE 5
```
Convert-CMCPrice -Amount 1 -Symbol "BTC" -Convert "USD" -Time "2023-01-01"
```

Converts 1 BTC to USD at the specified historical date.

## PARAMETERS

### -Amount
The amount to convert.
Default: 1

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 1
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Symbol
The cryptocurrency or fiat currency symbol to convert from.
Example: "BTC", "ETH", "USD"

```yaml
Type: String
Parameter Sets: Symbol
Aliases: From, FromSymbol

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
The CoinMarketCap currency ID to convert from.

```yaml
Type: Int32
Parameter Sets: Id
Aliases: FromId

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Convert
One or more currency symbols to convert to.
Can include both cryptocurrencies and fiat currencies.
Example: "USD", "EUR", "BTC", "ETH"

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: To, ToSymbol

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConvertId
One or more CoinMarketCap currency IDs to convert to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ToId

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Time
Optional historical timestamp to convert prices at a specific point in time.
Accepts DateTime object or string in ISO 8601 format.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Date, Timestamp

Required: False
Position: Named
Default value: None
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
### Returns a conversion result object with the original amount and converted values.
## NOTES
- Supports both cryptocurrency and fiat currency conversions
- Exchange rates are based on current market prices
- Historical conversions require appropriate API plan

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV2ToolsPriceconversion](https://coinmarketcap.com/api/documentation/v1/#operation/getV2ToolsPriceconversion)

