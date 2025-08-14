---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1GlobalmetricsQuotesLatest
schema: 2.0.0
---

# Get-CMCGlobalMetrics

## SYNOPSIS
Gets global cryptocurrency market metrics.

## SYNTAX

```
Get-CMCGlobalMetrics [[-Convert] <String[]>] [[-ConvertId] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCGlobalMetrics cmdlet retrieves global cryptocurrency market metrics including
total market cap, total volume, Bitcoin dominance, number of cryptocurrencies, and more.
This provides an overview of the entire cryptocurrency market.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCGlobalMetrics
```

Gets global market metrics in USD.

### EXAMPLE 2
```
Get-CMCGlobalMetrics -Convert "EUR","GBP","JPY"
```

Gets global metrics with values in multiple currencies.

### EXAMPLE 3
```
$metrics = Get-CMCGlobalMetrics
$metrics | Select-Object total_cryptocurrencies, active_market_pairs, USD_total_market_cap, btc_dominance
```

Gets and displays specific global metrics.

### EXAMPLE 4
```
Get-CMCGlobalMetrics | Format-List
```

Gets global metrics and displays all properties in list format.

## PARAMETERS

### -Convert
Optionally calculate market quotes in up to 120 currencies at once.
Default: USD

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 2
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
### Returns a global metrics object with market overview data.
## NOTES
- Global metrics are updated every minute
- Market cap excludes coins/tokens not actively traded
- BTC dominance shows Bitcoin's percentage of total market cap

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV1GlobalmetricsQuotesLatest](https://coinmarketcap.com/api/documentation/v1/#operation/getV1GlobalmetricsQuotesLatest)

