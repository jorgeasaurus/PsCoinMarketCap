---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyCategories
schema: 2.0.0
---

# Get-CMCCategories

## SYNOPSIS
Gets a list of all cryptocurrency categories.

## SYNTAX

```
Get-CMCCategories [[-Start] <Int32>] [[-Limit] <Int32>] [[-Id] <String[]>] [[-Slug] <String[]>]
 [[-Symbol] <String[]>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCCategories cmdlet retrieves a list of all cryptocurrency categories
with their associated coins/tokens.
Categories include DeFi, Stablecoins, NFTs,
Exchange Tokens, and many more classification groups.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCCategories
```

Gets all cryptocurrency categories.

### EXAMPLE 2
```
Get-CMCCategories -Slug "defi","stablecoin"
```

Gets information about DeFi and Stablecoin categories.

### EXAMPLE 3
```
Get-CMCCategories | Where-Object { $_.num_tokens -gt 100 }
```

Gets categories with more than 100 tokens.

### EXAMPLE 4
```
Get-CMCCategories -Symbol "BTC","ETH"
```

Gets the categories that Bitcoin and Ethereum belong to.

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
Default: 100

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

### -Id
Filter categories by one or more category IDs.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Slug
Filter categories by one or more category slugs.
Example: "defi", "stablecoin", "exchange-tokens"

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Symbol
Filter by one or more cryptocurrency symbols to see which categories they belong to.

```yaml
Type: String[]
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
### Returns an array of category objects with details about each category.
## NOTES
- Categories help organize and classify cryptocurrencies
- Each cryptocurrency can belong to multiple categories
- Use Get-CMCCategory for detailed info about a specific category

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyCategories](https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyCategories)

