---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyMarketpairsLatest
schema: 2.0.0
---

# Get-CMCMarketPairs

## SYNOPSIS
Gets market pair information for a cryptocurrency.

## SYNTAX

### Symbol (Default)
```
Get-CMCMarketPairs [-Symbol] <String> [-Start <Int32>] [-Limit <Int32>] [-SortDirection <String>]
 [-Sort <String>] [-Aux <String[]>] [-MatchedSymbol <String>] [-MatchedId <Int32>] [-Category <String>]
 [-FeeType <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Get-CMCMarketPairs -Id <Int32> [-Start <Int32>] [-Limit <Int32>] [-SortDirection <String>] [-Sort <String>]
 [-Aux <String[]>] [-MatchedSymbol <String>] [-MatchedId <Int32>] [-Category <String>] [-FeeType <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Slug
```
Get-CMCMarketPairs -Slug <String> [-Start <Int32>] [-Limit <Int32>] [-SortDirection <String>] [-Sort <String>]
 [-Aux <String[]>] [-MatchedSymbol <String>] [-MatchedId <Int32>] [-Category <String>] [-FeeType <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCMarketPairs cmdlet retrieves a list of all active market pairs that a 
cryptocurrency is traded on including the exchange, quote currency, price, and volume.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCMarketPairs -Symbol "BTC"
```

Gets all market pairs for Bitcoin.

### EXAMPLE 2
```
Get-CMCMarketPairs -Symbol "ETH" -MatchedSymbol "USDT" -Limit 10
```

Gets the top 10 ETH/USDT trading pairs.

### EXAMPLE 3
```
Get-CMCMarketPairs -Id 1 -Category "spot" -Sort "market_score"
```

Gets spot market pairs for Bitcoin sorted by market score.

### EXAMPLE 4
```
Get-CMCMarketPairs -Symbol "BNB" | Where-Object { $_.volume_24h -gt 1000000 }
```

Gets all BNB market pairs with over $1M daily volume.

## PARAMETERS

### -Symbol
A cryptocurrency symbol to get market pairs for.
Example: "BTC"

```yaml
Type: String
Parameter Sets: Symbol
Aliases: Ticker

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Id
A CoinMarketCap cryptocurrency ID to get market pairs for.
Example: 1

```yaml
Type: Int32
Parameter Sets: Id
Aliases: CoinId

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Slug
A cryptocurrency slug to get market pairs for.
Example: "bitcoin"

```yaml
Type: String
Parameter Sets: Slug
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Start
Optionally offset the start (1-based) of the paginated list of items to return.
Default: 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDirection
Optionally specify the sort direction of markets returned.
Valid values: asc, desc
Default: desc (best markets first)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Desc
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
Optionally specify the sort field for market pairs.
Valid values: volume_24h_strict, effective_liquidity, market_score, market_reputation
Default: volume_24h_strict

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Volume_24h_strict
Accept pipeline input: False
Accept wildcard characters: False
```

### -Aux
Optionally specify additional data fields to return.
Valid values: num_market_pairs, market_url, price_quote, effective_liquidity, 
             market_score, market_reputation

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MatchedSymbol
Optionally include only market pairs with this symbol as the quote currency.
Example: "USD", "USDT", "BTC"

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

### -MatchedId
Optionally include only market pairs with this CoinMarketCap ID as the quote currency.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
Filter market pairs by exchange category.
Valid values: all, spot, derivatives, otc, futures
Default: all

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -FeeType
Filter market pairs by fee type.
Valid values: all, percentage, no-fees, transactional-mining, unknown
Default: all

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
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
### Returns market pair data including exchange info and trading metrics.
## NOTES
- You must specify exactly one of: Symbol, Id, or Slug
- Market pairs are sorted by 24h volume by default
- This endpoint shows where a cryptocurrency can be traded

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyMarketpairsLatest](https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyMarketpairsLatest)

