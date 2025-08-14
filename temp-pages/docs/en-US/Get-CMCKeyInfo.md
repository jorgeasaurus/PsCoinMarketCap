---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1KeyInfo
schema: 2.0.0
---

# Get-CMCKeyInfo

## SYNOPSIS
Gets information about your CoinMarketCap API key.

## SYNTAX

```
Get-CMCKeyInfo [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCKeyInfo cmdlet retrieves information about your CoinMarketCap API key,
including usage limits, remaining credits, and tier information.
This is useful
for monitoring your API usage and understanding your account limits.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCKeyInfo
```

Gets the current API key information including usage and limits.

### EXAMPLE 2
```
$keyInfo = Get-CMCKeyInfo
Write-Host "Daily credits remaining: $($keyInfo.plan.credit_limit_daily_reset)"
```

Stores key info and displays remaining daily credits.

## PARAMETERS

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
### Returns an object containing API key information, usage statistics, and limits.
## NOTES
- This endpoint does not count against your API call limits
- Useful for monitoring usage and planning API calls
- Shows both current usage and historical statistics

## RELATED LINKS

[https://coinmarketcap.com/api/documentation/v1/#operation/getV1KeyInfo](https://coinmarketcap.com/api/documentation/v1/#operation/getV1KeyInfo)

