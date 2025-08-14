---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyInfo
schema: 2.0.0
---

# Get-CMCInfo

## SYNOPSIS
Gets metadata for one or more cryptocurrencies.

## SYNTAX

### Symbol (Default)
```
Get-CMCInfo [-Symbol] <String[]> [-Aux <String[]>] [-SkipInvalid <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Get-CMCInfo -Id <Int32[]> [-Aux <String[]>] [-SkipInvalid <Boolean>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Slug
```
Get-CMCInfo -Slug <String[]> [-Aux <String[]>] [-SkipInvalid <Boolean>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Address
```
Get-CMCInfo -Address <String[]> [-Aux <String[]>] [-SkipInvalid <Boolean>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCInfo cmdlet retrieves static metadata for one or more cryptocurrencies
including name, symbol, logo, description, official website URL, social links,
technical documentation, source code repository, and more.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCInfo -Symbol "BTC","ETH"
```

Gets metadata for Bitcoin and Ethereum.

### EXAMPLE 2
```
Get-CMCInfo -Id 1 -Aux "urls","logo","description"
```

Gets specific metadata fields for Bitcoin.

### EXAMPLE 3
```
"BTC","ETH","ADA" | Get-CMCInfo
```

Gets info for multiple cryptocurrencies using pipeline input.

### EXAMPLE 4
```
Get-CMCInfo -Address "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
```

Gets info for the cryptocurrency at the specified contract address (USDC).

## PARAMETERS

### -Symbol
One or more cryptocurrency symbols to get info for.
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
One or more CoinMarketCap cryptocurrency IDs to get info for.
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
One or more cryptocurrency slugs to get info for.
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

### -Address
One or more contract addresses to get info for.
Pass a contract address to return the cryptocurrency associated with it.

```yaml
Type: String[]
Parameter Sets: Address
Aliases: ContractAddress

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Aux
Optionally specify additional metadata fields to return.
Valid values: urls, logo, description, tags, platform, date_added, notice, status
Default returns all available fields.

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
### Returns cryptocurrency metadata objects.
## NOTES
- You must specify exactly one of: Symbol, Id, Slug, or Address
- This endpoint returns static metadata that doesn't change frequently
- Use Get-CMCQuotes for price data

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyInfo](https://coinmarketcap.com/api/documentation/v1/#operation/getV2CryptocurrencyInfo)

