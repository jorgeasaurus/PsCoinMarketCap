---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyQuotesLatest
schema: 2.0.0
---

# Get-CMCQuotes

## SYNOPSIS
Gets the latest market quote for one or more cryptocurrencies.

## SYNTAX

### Symbol (Default)
```
Get-CMCQuotes [-Symbol] <String[]> [-Convert <String[]>] [-ConvertId <String>] [-Aux <String[]>]
 [-SkipInvalid <Boolean>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Get-CMCQuotes -Id <Int32[]> [-Convert <String[]>] [-ConvertId <String>] [-Aux <String[]>]
 [-SkipInvalid <Boolean>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Slug
```
Get-CMCQuotes -Slug <String[]> [-Convert <String[]>] [-ConvertId <String>] [-Aux <String[]>]
 [-SkipInvalid <Boolean>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCQuotes cmdlet retrieves the latest market quote for one or more cryptocurrencies.
You can identify cryptocurrencies by symbol, CoinMarketCap ID, or slug.
Use this endpoint
to get detailed price and volume information for specific cryptocurrencies.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCQuotes -Symbol "BTC","ETH"
```

Gets the latest quotes for Bitcoin and Ethereum.

### EXAMPLE 2
```
Get-CMCQuotes -Symbol "BTC" -Convert "EUR","GBP","JPY"
```

Gets Bitcoin quote with prices in EUR, GBP, and JPY.

### EXAMPLE 3
```
"BTC","ETH","ADA" | Get-CMCQuotes
```

Gets quotes for multiple cryptocurrencies using pipeline input.

### EXAMPLE 4
```
Get-CMCQuotes -Id 1,1027,2010 -Aux "circulating_supply","max_supply","cmc_rank"
```

Gets quotes by CoinMarketCap ID with additional supply and rank data.

## PARAMETERS

### -Symbol
One or more cryptocurrency symbols to get quotes for.
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
One or more CoinMarketCap cryptocurrency IDs to get quotes for.
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

### -Slug
One or more cryptocurrency slugs to get quotes for.
Example: "bitcoin", "ethereum", "cardano"

```yaml
Type: String[]
Parameter Sets: Slug
Aliases:

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
### Returns cryptocurrency quote objects with detailed market data.
## NOTES
- You must specify exactly one of: Symbol, Id, or Slug
- This endpoint is more efficient than Get-CMCListings for specific cryptocurrencies
- Rate limits apply based on your CoinMarketCap plan

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyQuotesLatest](https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyQuotesLatest)

