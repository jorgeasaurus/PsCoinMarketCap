---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyQuotesLatest
schema: 2.0.0
---

# Get-CMCStablecoins

## SYNOPSIS
Gets a list of stablecoin cryptocurrencies with latest market data.

## SYNTAX

```
Get-CMCStablecoins [[-Limit] <Int32>] [[-Convert] <String[]>] [[-Sort] <String>] [[-SortDirection] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCStablecoins cmdlet retrieves stablecoins from CoinMarketCap by filtering
cryptocurrencies that are categorized as stablecoins.
This is a convenience function
that combines Get-CMCMap and Get-CMCQuotes to provide stablecoin-specific data.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCStablecoins
```

Gets the top 20 stablecoins by market cap.

### EXAMPLE 2
```
Get-CMCStablecoins -Limit 10 -Convert "EUR","GBP"
```

Gets the top 10 stablecoins with prices in EUR and GBP.

### EXAMPLE 3
```
Get-CMCStablecoins -Sort "volume_24h" -Limit 5
```

Gets the top 5 stablecoins by 24h trading volume.

## PARAMETERS

### -Limit
Optionally specify the number of results to return.
Default: 20, Max: 100

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 20
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
Position: 2
Default value: @('USD')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
What field to sort the list by.
Valid values: market_cap, price, volume_24h, percent_change_24h
Default: market_cap

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Market_cap
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDirection
The direction in which to order stablecoins.
Valid values: asc, desc
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
### Returns an array of stablecoin cryptocurrency objects with market data.
## NOTES
This function uses a known list of major stablecoins.
For a comprehensive list,
consider using the CoinMarketCap categories endpoint when it becomes available.

## RELATED LINKS
