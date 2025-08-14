---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV1CryptocurrencyTrendingLatest
schema: 2.0.0
---

# Set-CMCApiKey

## SYNOPSIS
Sets the CoinMarketCap API key for the current session or persistently.

## SYNTAX

```
Set-CMCApiKey [-ApiKey] <Object> [[-Scope] <String>] [-UseSandbox] [-Force]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-CMCApiKey cmdlet stores the CoinMarketCap API key either in memory for the current session
or persistently in the user's profile.
The API key is stored securely as a SecureString.

## EXAMPLES

### EXAMPLE 1
```
Set-CMCApiKey -ApiKey "your-api-key-here"
```

Sets the API key for the current session.

### EXAMPLE 2
```
Set-CMCApiKey -ApiKey "your-api-key-here" -Scope User
```

Stores the API key persistently in the user's profile.

### EXAMPLE 3
```
$secureKey = Read-Host -AsSecureString "Enter API Key"
Set-CMCApiKey -ApiKey $secureKey -Scope User -UseSandbox
```

Prompts for the API key securely and stores it for the sandbox environment.

## PARAMETERS

### -ApiKey
The CoinMarketCap API key to store.
This can be either a regular string or a SecureString.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Scope
Specifies where to store the API key:
- Session: Stores the key in memory for the current PowerShell session only
- User: Stores the key persistently in the user's profile (encrypted)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Session
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSandbox
If specified, configures the module to use the CoinMarketCap sandbox API endpoint
instead of the production endpoint.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrites an existing API key without prompting for confirmation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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

## NOTES
The API key is required to make requests to the CoinMarketCap API.
You can obtain an API key from: https://coinmarketcap.com/api/

## RELATED LINKS
