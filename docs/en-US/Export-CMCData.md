---
external help file: PsCoinMarketCap-help.xml
Module Name: PsCoinMarketCap
online version: https://coinmarketcap.com/api/documentation/v1/#operation/getV2ToolsPriceconversion
schema: 2.0.0
---

# Export-CMCData

## SYNOPSIS
Exports CoinMarketCap data to various file formats.

## SYNTAX

### Pipeline
```
Export-CMCData -Data <Object[]> -Path <String> [-Format <String>] [-IncludeMetadata] [-Currency <String[]>]
 [-Properties <String[]>] [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Direct
```
Export-CMCData -InputData <Object[]> -Path <String> [-Format <String>] [-IncludeMetadata]
 [-Currency <String[]>] [-Properties <String[]>] [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Export-CMCData cmdlet exports cryptocurrency data retrieved from CoinMarketCap
to various file formats including CSV, JSON, and Excel.
This is useful for 
data analysis, reporting, and sharing.

## EXAMPLES

### EXAMPLE 1
```
Get-CMCListings -Limit 100 | Export-CMCData -Path "top100.csv"
```

Exports the top 100 cryptocurrencies to a CSV file.

### EXAMPLE 2
```
Get-CMCQuotes -Symbol "BTC","ETH","ADA" | Export-CMCData -Path "portfolio.json" -IncludeMetadata
```

Exports specific cryptocurrency quotes to JSON with metadata.

### EXAMPLE 3
```
$data = Get-CMCListings -Limit 50
Export-CMCData -Data $data -Path "crypto_report.xlsx" -Currency "USD" -Properties "Name","Symbol","USD_price","USD_market_cap"
```

Exports selected properties to Excel focusing on USD values.

### EXAMPLE 4
```
Get-CMCGlobalMetrics | Export-CMCData -Path "market_summary.json" -PassThru
```

Exports global market metrics and returns the data for further use.

## PARAMETERS

### -Data
The cryptocurrency data to export.
This should be output from other CMC cmdlets
like Get-CMCListings, Get-CMCQuotes, etc.

```yaml
Type: Object[]
Parameter Sets: Pipeline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -InputData
{{ Fill InputData Description }}

```yaml
Type: Object[]
Parameter Sets: Direct
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The file path where the data should be exported.
The file extension determines
the export format (.csv, .json, .xlsx).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format
Explicitly specify the export format.
Valid values: CSV, JSON, Excel.
If not specified, the format is determined by the file extension.

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

### -IncludeMetadata
Include additional metadata in the export (timestamp, source, etc.).

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

### -Currency
Focus export on specific currency columns (e.g., USD, EUR, BTC).
Reduces file size by excluding other currency data.

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

### -Properties
Specify which properties to include in the export.
If not specified,
all properties are included.

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

### -PassThru
Return the exported data object for further processing.

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

### None or PSCustomObject (with -PassThru)
### Exports data to the specified file format.
## NOTES
- CSV format is best for simple data analysis in Excel or other tools
- JSON format preserves complex data structures and is good for APIs
- Excel format (.xlsx) requires the ImportExcel module for best results
- Large datasets may take time to export, especially to Excel format

## RELATED LINKS
