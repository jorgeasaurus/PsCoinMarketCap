---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyMap
schema: 2.0.0
---

# Get-CMCMap

## SYNOPSIS
Gets a mapping of all cryptocurrencies to their CoinMarketCap IDs.

## SYNTAX

```
Get-CMCMap [[-ListingStatus] <String>] [[-Start] <Int32>] [[-Limit] <Int32>] [[-Sort] <String>]
 [[-Symbol] <String[]>] [[-Aux] <String[]>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCMap cmdlet returns a mapping of all cryptocurrencies listed on CoinMarketCap
including their name, symbol, slug, CoinMarketCap ID, and platform information.
This is useful for converting between different cryptocurrency identifiers.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCMap
```

Gets the ID map for all active cryptocurrencies.

### EXAMPLE 2
```
Get-CMCMap -Symbol "BTC","ETH","USDT"
```

Gets the ID mapping for specific cryptocurrencies.

### EXAMPLE 3
```
Get-CMCMap -ListingStatus "inactive" -Limit 100
```

Gets the first 100 inactive cryptocurrencies.

### EXAMPLE 4
```
Get-CMCMap -Aux "platform","is_active" | Where-Object { $_.platform }
```

Gets all cryptocurrencies with platform information (tokens).

### EXAMPLE 5
```
$map = Get-CMCMap
$btcId = ($map | Where-Object { $_.symbol -eq 'BTC' }).id
```

Gets the CoinMarketCap ID for Bitcoin.

## PARAMETERS

### -ListingStatus
Filter by listing status.
Valid values: active, inactive, untracked
Default: active

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Active
Accept pipeline input: False
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
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Optionally specify the number of results to return.
Default: 5000, Max: 5000

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 5000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
What field to sort the list by.
Valid values: id, cmc_rank
Default: id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Id
Accept pipeline input: False
Accept wildcard characters: False
```

### -Symbol
Optionally filter by one or more cryptocurrency symbols.
Example: "BTC", "ETH"

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

### -Aux
Optionally specify additional data fields to return.
Valid values: platform, first_historical_data, last_historical_data, is_active, status

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
### Returns an array of cryptocurrency mapping objects.
## NOTES
- This endpoint is useful for finding CoinMarketCap IDs to use with other endpoints
- The map includes both active and inactive cryptocurrencies
- Results are cached for performance when called multiple times

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyMap](https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyMap)

