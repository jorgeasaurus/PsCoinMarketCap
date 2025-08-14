---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2ToolsPriceconversion
schema: 2.0.0
---

# Get-CMCApiKey

## SYNOPSIS
Retrieves the stored CoinMarketCap API key.

## SYNTAX

```
Get-CMCApiKey [[-Scope] <String>] [-AsPlainText] [-TestConnection] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-CMCApiKey cmdlet retrieves the CoinMarketCap API key from either the current session
or from persistent storage in the user's profile.
Returns the key as a SecureString by default.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCApiKey
```

Retrieves the API key as a SecureString, checking session first then user profile.

### EXAMPLE 2
```
Get-CMCApiKey -AsPlainText
```

Retrieves the API key as plain text.

### EXAMPLE 3
```
Get-CMCApiKey -Scope User -TestConnection
```

Retrieves the API key from user profile and tests if it's valid.

### EXAMPLE 4
```
$key = Get-CMCApiKey
$credentials = New-Object System.Management.Automation.PSCredential ('api', $key)
```

Retrieves the API key and uses it to create a credential object.

## PARAMETERS

### -Scope
Specifies where to retrieve the API key from:
- Session: Retrieves the key from the current PowerShell session
- User: Retrieves the key from persistent storage in the user's profile
- Auto: Automatically checks session first, then user profile (default)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Auto
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsPlainText
If specified, returns the API key as plain text instead of a SecureString.
WARNING: This exposes the API key in memory and should be used with caution.

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

### -TestConnection
If specified, tests the API key by making a request to the /key/info endpoint.

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

### System.Security.SecureString or System.String
### Returns the API key as either a SecureString (default) or plain text string.
## NOTES
For security reasons, it's recommended to work with SecureString whenever possible.
Use -AsPlainText only when absolutely necessary.

## RELATED LINKS
