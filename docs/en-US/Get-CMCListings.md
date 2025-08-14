---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyListingsLatest
schema: 2.0.0
---

# Get-CMCListings

## SYNOPSIS
Gets a list of all active cryptocurrencies with latest market data.

## SYNTAX

```
Get-CMCListings [[-Start] <Int32>] [[-Limit] <Int32>] [[-PriceMin] <Double>] [[-PriceMax] <Double>]
 [[-MarketCapMin] <Double>] [[-MarketCapMax] <Double>] [[-Volume24hMin] <Double>] [[-Volume24hMax] <Double>]
 [[-CirculatingSupplyMin] <Double>] [[-CirculatingSupplyMax] <Double>] [[-PercentChange24hMin] <Double>]
 [[-PercentChange24hMax] <Double>] [[-Convert] <String[]>] [[-ConvertId] <String>] [[-Sort] <String>]
 [[-SortDirection] <String>] [[-CryptocurrencyType] <String>] [[-Tag] <String[]>] [[-Aux] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCListings cmdlet retrieves a paginated list of all active cryptocurrencies 
with latest market data from CoinMarketCap.
By default, it returns the top 100 
cryptocurrencies by market cap.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCListings
```

Gets the top 100 cryptocurrencies by market cap.

### EXAMPLE 2
```
Get-CMCListings -Limit 10 -Convert "EUR","GBP"
```

Gets the top 10 cryptocurrencies with prices in EUR and GBP.

### EXAMPLE 3
```
Get-CMCListings -Tag "defi" -Sort "percent_change_24h" -Limit 20
```

Gets the top 20 DeFi tokens sorted by 24h price change.

### EXAMPLE 4
```
# To get stablecoins, use Get-CMCCategory instead:
Get-CMCCategory -Id "604f4972deb11b559dfa7220" -Limit 20
```

Gets stablecoins using the stablecoin category ID.

### EXAMPLE 5
```
Get-CMCListings -PriceMin 100 -PriceMax 1000 -Volume24hMin 1000000
```

Gets cryptocurrencies priced between $100-$1000 with at least $1M daily volume.

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
Default: 100, Max: 5000

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -PriceMin
Optionally filter by minimum USD price.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PriceMax
Optionally filter by maximum USD price.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
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
Position: 5
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
Position: 6
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
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Volume24hMax
Optionally filter by maximum 24 hour volume (USD).

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

### -CirculatingSupplyMin
Optionally filter by minimum circulating supply.

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

### -CirculatingSupplyMax
Optionally filter by maximum circulating supply.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PercentChange24hMin
Optionally filter by minimum 24 hour percent change.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PercentChange24hMax
Optionally filter by maximum 24 hour percent change.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: 0
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
Position: 13
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
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
What field to sort the list by.
Valid values: name, symbol, date_added, market_cap, market_cap_strict, price, 
             circulating_supply, total_supply, max_supply, num_market_pairs, 
             volume_24h, percent_change_1h, percent_change_24h, percent_change_7d, 
             market_cap_by_total_supply_strict, volume_7d, volume_30d
Default: market_cap

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: Market_cap
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDirection
The direction in which to order cryptocurrencies.
Valid values: asc, desc
Default: desc

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: Desc
Accept pipeline input: False
Accept wildcard characters: False
```

### -CryptocurrencyType
The type of cryptocurrency to include.
Valid values: all, coins, tokens
Default: all

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Filter by one or more cryptocurrency tags.
Valid values: all, defi, filesharing
Note: For stablecoin filtering, use Get-CMCMap with filtering or Get-CMCCategory with 'stablecoin' category

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Aux
Optionally specify additional data fields to return.
Valid values: num_market_pairs, cmc_rank, date_added, tags, platform, 
             max_supply, circulating_supply, total_supply, market_cap_by_total_supply,
             volume_24h_reported, volume_7d, volume_7d_reported, volume_30d, 
             volume_30d_reported, is_active, is_fiat

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
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
### Returns an array of cryptocurrency objects with market data.
## NOTES
This endpoint requires authentication with a valid API key.
Rate limits apply based on your CoinMarketCap plan.

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyListingsLatest](https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyListingsLatest)

