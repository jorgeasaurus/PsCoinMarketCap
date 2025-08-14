---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingGainerslosers
schema: 2.0.0
---

# Get-CMCGainersLosers

## SYNOPSIS
Gets the top cryptocurrency gainers and losers.

## SYNTAX

```
Get-CMCGainersLosers [[-Start] <Int32>] [[-Limit] <Int32>] [[-TimePeriod] <String>] [[-SortDirection] <String>]
 [[-Convert] <String[]>] [[-ConvertId] <String>] [[-MarketCapMin] <Double>] [[-MarketCapMax] <Double>]
 [[-Volume24hMin] <Double>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCGainersLosers cmdlet retrieves cryptocurrencies with the biggest gains 
or losses over a specified time period.
This helps identify the best and worst 
performing cryptocurrencies in the market.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCGainersLosers
```

Gets the top 10 gainers in the last 24 hours.

### EXAMPLE 2
```
Get-CMCGainersLosers -SortDirection asc
```

Gets the top 10 losers in the last 24 hours.

### EXAMPLE 3
```
Get-CMCGainersLosers -TimePeriod "7d" -Limit 20 -MarketCapMin 1000000000
```

Gets the top 20 gainers over 7 days with market cap over $1B.

### EXAMPLE 4
```
Get-CMCGainersLosers -SortDirection asc -TimePeriod "1h" | Format-Table name, symbol, USD_price, USD_percent_change_1h
```

Gets hourly losers and displays formatted results.

### EXAMPLE 5
```
# Get both gainers and losers
$gainers = Get-CMCGainersLosers -Limit 5
$losers = Get-CMCGainersLosers -Limit 5 -SortDirection asc
```

Gets the top 5 gainers and top 5 losers.

## PARAMETERS

### -Start
Optionally offset the start (1-based) of the paginated list of items to return.
Default: 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Optionally specify the number of results to return.
Default: 10, Max: 200

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimePeriod
The time period to calculate gains/losses over.
Valid values: 1h, 24h, 7d, 30d, 60d, 90d
Default: 24h

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 24h
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDirection
Return gainers (desc) or losers (asc).
Valid values: desc (gainers), asc (losers)
Default: desc

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Desc
Accept pipeline input: False
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
Position: 5
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
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MarketCapMin
Optionally filter by minimum market cap (USD).

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MarketCapMax
Optionally filter by maximum market cap (USD).

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Volume24hMin
Optionally filter by minimum 24 hour volume (USD).

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
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

### PSCustomObject[]
### Returns an array of cryptocurrency objects sorted by performance.
## NOTES
- Gainers are cryptocurrencies with the highest positive price changes
- Losers are cryptocurrencies with the most negative price changes
- Results are filtered to exclude low volume/market cap coins by default

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingGainerslosers](https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingGainerslosers)

