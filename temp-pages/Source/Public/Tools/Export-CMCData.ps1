function Export-CMCData {
    <#
    .SYNOPSIS
        Exports CoinMarketCap data to various file formats.
    
    .DESCRIPTION
        The Export-CMCData cmdlet exports cryptocurrency data retrieved from CoinMarketCap
        to various file formats including CSV, JSON, and Excel. This is useful for 
        data analysis, reporting, and sharing.
    
    .PARAMETER Data
        The cryptocurrency data to export. This should be output from other CMC cmdlets
        like Get-CMCListings, Get-CMCQuotes, etc.
    
    .PARAMETER Path
        The file path where the data should be exported. The file extension determines
        the export format (.csv, .json, .xlsx).
    
    .PARAMETER Format
        Explicitly specify the export format. Valid values: CSV, JSON, Excel.
        If not specified, the format is determined by the file extension.
    
    .PARAMETER IncludeMetadata
        Include additional metadata in the export (timestamp, source, etc.).
    
    .PARAMETER Currency
        Focus export on specific currency columns (e.g., USD, EUR, BTC).
        Reduces file size by excluding other currency data.
    
    .PARAMETER Properties
        Specify which properties to include in the export. If not specified,
        all properties are included.
    
    .PARAMETER PassThru
        Return the exported data object for further processing.
    
    .EXAMPLE
        Get-CMCListings -Limit 100 | Export-CMCData -Path "top100.csv"
        
        Exports the top 100 cryptocurrencies to a CSV file.
    
    .EXAMPLE
        Get-CMCQuotes -Symbol "BTC","ETH","ADA" | Export-CMCData -Path "portfolio.json" -IncludeMetadata
        
        Exports specific cryptocurrency quotes to JSON with metadata.
    
    .EXAMPLE
        $data = Get-CMCListings -Limit 50
        Export-CMCData -Data $data -Path "crypto_report.xlsx" -Currency "USD" -Properties "Name","Symbol","USD_price","USD_market_cap"
        
        Exports selected properties to Excel focusing on USD values.
    
    .EXAMPLE
        Get-CMCGlobalMetrics | Export-CMCData -Path "market_summary.json" -PassThru
        
        Exports global market metrics and returns the data for further use.
    
    .OUTPUTS
        None or PSCustomObject (with -PassThru)
        Exports data to the specified file format.
    
    .NOTES
        - CSV format is best for simple data analysis in Excel or other tools
        - JSON format preserves complex data structures and is good for APIs
        - Excel format (.xlsx) requires the ImportExcel module for best results
        - Large datasets may take time to export, especially to Excel format
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void], [PSCustomObject])]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = 'Pipeline'
        )]
        [object[]]$Data,
        
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Direct'
        )]
        [object[]]$InputData,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        
        [Parameter()]
        [ValidateSet('CSV', 'JSON', 'Excel')]
        [string]$Format,
        
        [Parameter()]
        [switch]$IncludeMetadata,
        
        [Parameter()]
        [string[]]$Currency,
        
        [Parameter()]
        [string[]]$Properties,
        
        [Parameter()]
        [switch]$PassThru
    )
    
    begin {
        Write-Verbose "Starting data export to: $Path"
        
        # Collect pipeline input
        $allData = @()
        
        # Determine export format
        if (-not $Format) {
            $extension = [System.IO.Path]::GetExtension($Path).ToLower()
            switch ($extension) {
                '.csv' { $Format = 'CSV' }
                '.json' { $Format = 'JSON' }
                '.xlsx' { $Format = 'Excel' }
                default { 
                    throw "Unable to determine format from extension '$extension'. Please specify -Format parameter."
                }
            }
        }
        
        Write-Verbose "Export format: $Format"
        
        # Validate Excel requirements
        if ($Format -eq 'Excel') {
            if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
                Write-Warning "ImportExcel module not found. Excel export will use basic CSV format."
                $Format = 'CSV'
                $Path = [System.IO.Path]::ChangeExtension($Path, '.csv')
            }
        }
        
        # Ensure output directory exists
        $directory = [System.IO.Path]::GetDirectoryName($Path)
        if ($directory -and -not (Test-Path $directory)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }
    }
    
    process {
        # Collect data from pipeline or direct parameter
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            $allData += $Data
        }
    }
    
    end {
        # Use InputData if provided directly
        if ($PSCmdlet.ParameterSetName -eq 'Direct') {
            $allData = $InputData
        }
        
        if (-not $allData) {
            Write-Warning "No data provided for export"
            return
        }
        
        Write-Verbose "Processing $($allData.Count) records for export"
        
        # Filter by currency if specified
        if ($Currency) {
            Write-Verbose "Filtering for currencies: $($Currency -join ', ')"
            $allData = $allData | ForEach-Object {
                $item = $_
                $filteredItem = [PSCustomObject]@{}
                
                # Copy non-currency properties
                $item.PSObject.Properties | Where-Object { 
                    $_.Name -notmatch '^[A-Z]{3}_' 
                } | ForEach-Object {
                    $filteredItem | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
                }
                
                # Copy matching currency properties
                $Currency | ForEach-Object {
                    $curr = $_
                    $item.PSObject.Properties | Where-Object { 
                        $_.Name -match "^${curr}_" 
                    } | ForEach-Object {
                        $filteredItem | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
                    }
                }
                
                $filteredItem
            }
        }
        
        # Filter by properties if specified
        if ($Properties) {
            Write-Verbose "Selecting properties: $($Properties -join ', ')"
            $allData = $allData | Select-Object $Properties
        }
        
        # Add metadata if requested
        if ($IncludeMetadata) {
            $metadata = [PSCustomObject]@{
                ExportTimestamp = [datetime]::Now.ToString('yyyy-MM-dd HH:mm:ss')
                Source = 'CoinMarketCap API'
                Module = 'PsCoinMarketCap'
                RecordCount = $allData.Count
                ExportFormat = $Format
                Currency = $Currency -join ','
                Properties = $Properties -join ','
            }
        }
        
        try {
            switch ($Format) {
                'CSV' {
                    if ($PSCmdlet.ShouldProcess($Path, "Export to CSV")) {
                        Write-Verbose "Exporting to CSV format"
                        
                        if ($IncludeMetadata) {
                            # Add metadata as comments (CSV doesn't support metadata directly)
                            $metadataLines = @(
                                "# CoinMarketCap Data Export"
                                "# Generated: $($metadata.ExportTimestamp)"
                                "# Source: $($metadata.Source)"
                                "# Records: $($metadata.RecordCount)"
                                ""
                            )
                            $metadataLines | Out-File -FilePath $Path -Encoding UTF8
                            $allData | Export-Csv -Path $Path -NoTypeInformation -Append -Encoding UTF8
                        }
                        else {
                            $allData | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
                        }
                        
                        Write-Information "Data exported to CSV: $Path" -InformationAction Continue
                    }
                }
                
                'JSON' {
                    if ($PSCmdlet.ShouldProcess($Path, "Export to JSON")) {
                        Write-Verbose "Exporting to JSON format"
                        
                        $exportObject = if ($IncludeMetadata) {
                            [PSCustomObject]@{
                                metadata = $metadata
                                data = $allData
                            }
                        }
                        else {
                            $allData
                        }
                        
                        $jsonOutput = $exportObject | ConvertTo-Json -Depth 10 -Compress:$false
                        $jsonOutput | Out-File -FilePath $Path -Encoding UTF8
                        
                        Write-Information "Data exported to JSON: $Path" -InformationAction Continue
                    }
                }
                
                'Excel' {
                    if ($PSCmdlet.ShouldProcess($Path, "Export to Excel")) {
                        Write-Verbose "Exporting to Excel format"
                        
                        # Import the ImportExcel module
                        Import-Module ImportExcel -Force
                        
                        # Create Excel package
                        $excelParams = @{
                            Path = $Path
                            WorksheetName = 'CryptocurrencyData'
                            AutoSize = $true
                            FreezeTopRow = $true
                            BoldTopRow = $true
                        }
                        
                        $allData | Export-Excel @excelParams
                        
                        # Add metadata worksheet if requested
                        if ($IncludeMetadata) {
                            $metadata | Export-Excel -Path $Path -WorksheetName 'Metadata' -AutoSize
                        }
                        
                        Write-Information "Data exported to Excel: $Path" -InformationAction Continue
                    }
                }
            }
            
            # Return data if PassThru specified
            if ($PassThru) {
                if ($IncludeMetadata -and $Format -ne 'JSON') {
                    [PSCustomObject]@{
                        Metadata = $metadata
                        Data = $allData
                    }
                }
                else {
                    $allData
                }
            }
        }
        catch {
            Write-Error "Failed to export data to $Path`: $_"
        }
        
        Write-Verbose "Export completed"
    }
}