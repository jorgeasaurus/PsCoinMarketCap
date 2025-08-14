---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingLatest
schema: 2.0.0
---

# Get-CMCTrending

## SYNOPSIS
Gets trending cryptocurrencies on CoinMarketCap.

## SYNTAX

```
Get-CMCTrending [[-Start] <Int32>] [[-Limit] <Int32>] [[-TimePeriod] <String>] [[-Convert] <String[]>]
 [[-ConvertId] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCTrending cmdlet retrieves a list of trending cryptocurrencies 
based on the highest price movements and social media activity.
This includes
the most searched and most viewed cryptocurrencies over various time periods.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCTrending
```

Gets the top 10 trending cryptocurrencies in the last 24 hours.

### EXAMPLE 2
```
Get-CMCTrending -TimePeriod "7d" -Limit 20
```

Gets the top 20 trending cryptocurrencies over the last 7 days.

### EXAMPLE 3
```
Get-CMCTrending -Convert "EUR","GBP" | Format-Table name, symbol, EUR_price, EUR_percent_change_24h
```

Gets trending cryptos with prices in EUR and GBP.

### EXAMPLE 4
```
Get-CMCTrending | Select-Object -First 5 | Get-CMCQuotes
```

Gets detailed quotes for the top 5 trending cryptocurrencies.

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
The time period to get trending cryptocurrencies for.
Valid values: 24h, 7d, 30d
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

### -Convert
Optionally calculate market quotes in up to 120 currencies at once.
Default: USD

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
Position: 5
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

### PSCustomObject[]
### Returns an array of trending cryptocurrency objects with market data.
## NOTES
- REQUIRES PAID PLAN (Hobbyist or higher)
- Trending is determined by search volume and price movements
- Results are updated regularly throughout the day
- Use this to identify cryptocurrencies gaining attention
- Free tier alternative: Use Get-CMCListings with sort by percent_change

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingLatest](https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingLatest)

