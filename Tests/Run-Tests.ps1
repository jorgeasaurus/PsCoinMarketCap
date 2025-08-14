#Requires -Modules Pester

<#
.SYNOPSIS
    Runs Pester tests for the PsCoinMarketCap module with code coverage.

.DESCRIPTION
    This script runs all unit and integration tests for the PsCoinMarketCap module
    and generates code coverage reports.

.PARAMETER TestPath
    Path to specific test file or folder. Defaults to all tests.

.PARAMETER OutputPath
    Path for test results and coverage reports. Defaults to .\Output\TestResults

.PARAMETER CodeCoverage
    Enable code coverage analysis.

.PARAMETER PassThru
    Return Pester result object.

.EXAMPLE
    .\Tests\Run-Tests.ps1
    
    Runs all tests with code coverage.

.EXAMPLE
    .\Tests\Run-Tests.ps1 -TestPath ".\Tests\Unit\Get-CMCListings.Tests.ps1"
    
    Runs a specific test file.

.EXAMPLE
    .\Tests\Run-Tests.ps1 -CodeCoverage:$false
    
    Runs tests without code coverage (faster).
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$TestPath = "$PSScriptRoot",
    
    [Parameter()]
    [string]$OutputPath = "$PSScriptRoot\..\Output\TestResults",
    
    [Parameter()]
    [switch]$CodeCoverage = $true,
    
    [Parameter()]
    [switch]$PassThru
)

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

# Import the module
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\Source\PsCoinMarketCap.psd1'
Import-Module $modulePath -Force

Write-Host "`n=== PsCoinMarketCap Test Suite ===" -ForegroundColor Cyan
Write-Host "Test Path: $TestPath" -ForegroundColor Gray
Write-Host "Output Path: $OutputPath" -ForegroundColor Gray
Write-Host "Code Coverage: $CodeCoverage" -ForegroundColor Gray

# Configure Pester
$pesterConfig = New-PesterConfiguration

# Run configuration
$pesterConfig.Run.Path = $TestPath
$pesterConfig.Run.PassThru = $true
$pesterConfig.Run.Exit = $false

# Output configuration
$pesterConfig.Output.Verbosity = 'Detailed'

# Test result configuration
$pesterConfig.TestResult.Enabled = $true
$pesterConfig.TestResult.OutputPath = Join-Path -Path $OutputPath -ChildPath 'TestResults.xml'
$pesterConfig.TestResult.OutputFormat = 'NUnitXml'

# Code coverage configuration
if ($CodeCoverage) {
    $sourcePath = Join-Path -Path $PSScriptRoot -ChildPath '..\Source'
    
    $pesterConfig.CodeCoverage.Enabled = $true
    $pesterConfig.CodeCoverage.Path = @(
        Join-Path -Path $sourcePath -ChildPath 'Public\**\*.ps1'
        Join-Path -Path $sourcePath -ChildPath 'Private\*.ps1'
    )
    $pesterConfig.CodeCoverage.OutputPath = Join-Path -Path $OutputPath -ChildPath 'Coverage.xml'
    $pesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'
    $pesterConfig.CodeCoverage.UseBreakpoints = $false  # Faster coverage
}

# Run tests
Write-Host "`nRunning tests..." -ForegroundColor Yellow
$results = Invoke-Pester -Configuration $pesterConfig

# Display results summary
Write-Host "`n=== Test Results Summary ===" -ForegroundColor Cyan

if ($results.FailedCount -eq 0) {
    Write-Host "✓ All tests passed!" -ForegroundColor Green
} else {
    Write-Host "✗ Some tests failed!" -ForegroundColor Red
}

Write-Host "`nTests Run: $($results.TotalCount)" -ForegroundColor Gray
Write-Host "Passed: $($results.PassedCount)" -ForegroundColor Green
Write-Host "Failed: $($results.FailedCount)" -ForegroundColor Red
Write-Host "Skipped: $($results.SkippedCount)" -ForegroundColor Yellow
Write-Host "Not Run: $($results.NotRunCount)" -ForegroundColor Gray

if ($CodeCoverage -and $results.CodeCoverage) {
    Write-Host "`n=== Code Coverage Summary ===" -ForegroundColor Cyan
    
    $coverage = $results.CodeCoverage
    $coveragePercent = if ($coverage.NumberOfCommandsExecuted -gt 0) {
        [Math]::Round(($coverage.NumberOfCommandsExecuted / $coverage.NumberOfCommandsAnalyzed) * 100, 2)
    } else { 0 }
    
    Write-Host "Coverage: $coveragePercent%" -ForegroundColor $(if ($coveragePercent -ge 80) { 'Green' } elseif ($coveragePercent -ge 60) { 'Yellow' } else { 'Red' })
    Write-Host "Commands Analyzed: $($coverage.NumberOfCommandsAnalyzed)" -ForegroundColor Gray
    Write-Host "Commands Executed: $($coverage.NumberOfCommandsExecuted)" -ForegroundColor Gray
    Write-Host "Commands Missed: $($coverage.NumberOfCommandsMissed)" -ForegroundColor Gray
    
    # Show uncovered files
    if ($coverage.NumberOfCommandsMissed -gt 0) {
        Write-Host "`nFiles with incomplete coverage:" -ForegroundColor Yellow
        
        $coverage.AnalyzedFiles | ForEach-Object {
            $fileCoverage = $coverage.HitCommands | Where-Object { $_.File -eq $_ }
            $fileMissed = $coverage.MissedCommands | Where-Object { $_.File -eq $_ }
            
            if ($fileMissed) {
                $fileName = Split-Path $_ -Leaf
                $filePercent = if ($fileCoverage -or $fileMissed) {
                    [Math]::Round(($fileCoverage.Count / ($fileCoverage.Count + $fileMissed.Count)) * 100, 2)
                } else { 100 }
                
                Write-Host "  - $fileName : $filePercent%" -ForegroundColor Gray
            }
        }
    }
    
    # Generate HTML coverage report
    $htmlReportPath = Join-Path -Path $OutputPath -ChildPath 'CoverageReport.html'
    Write-Host "`nGenerating HTML coverage report: $htmlReportPath" -ForegroundColor Gray
    
    # Simple HTML report
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>PsCoinMarketCap Code Coverage Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .summary { background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .covered { color: green; }
        .uncovered { color: red; }
        .partial { color: orange; }
        table { border-collapse: collapse; width: 100%; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>PsCoinMarketCap Code Coverage Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Overall Coverage:</strong> <span class="$(if ($coveragePercent -ge 80) { 'covered' } elseif ($coveragePercent -ge 60) { 'partial' } else { 'uncovered' })">$coveragePercent%</span></p>
        <p><strong>Commands Analyzed:</strong> $($coverage.NumberOfCommandsAnalyzed)</p>
        <p><strong>Commands Executed:</strong> $($coverage.NumberOfCommandsExecuted)</p>
        <p><strong>Commands Missed:</strong> $($coverage.NumberOfCommandsMissed)</p>
    </div>
    <h2>File Coverage</h2>
    <table>
        <tr>
            <th>File</th>
            <th>Coverage</th>
            <th>Commands Hit</th>
            <th>Commands Missed</th>
        </tr>
"@
    
    $coverage.AnalyzedFiles | ForEach-Object {
        $filePath = $_
        if ($filePath) {
            $fileName = Split-Path $filePath -Leaf
            $fileHit = @($coverage.HitCommands | Where-Object { $_.File -eq $filePath }).Count
            $fileMissed = @($coverage.MissedCommands | Where-Object { $_.File -eq $filePath }).Count
            $fileTotal = $fileHit + $fileMissed
            $filePercent = if ($fileTotal -gt 0) {
                [Math]::Round(($fileHit / $fileTotal) * 100, 2)
            } else { 100 }
            
            $html += @"
            <tr>
                <td>$fileName</td>
                <td class="$(if ($filePercent -ge 80) { 'covered' } elseif ($filePercent -ge 60) { 'partial' } else { 'uncovered' })">$filePercent%</td>
                <td>$fileHit</td>
                <td>$fileMissed</td>
            </tr>
"@
        }
    }
    
    $html += @"
    </table>
    <p><em>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</em></p>
</body>
</html>
"@
    
    $html | Out-File -FilePath $htmlReportPath -Encoding UTF8
}

Write-Host "`nTest results saved to: $OutputPath" -ForegroundColor Gray

# Return results if requested
if ($PassThru) {
    return $results
}

# Exit with appropriate code
if ($results.FailedCount -gt 0) {
    exit 1
} else {
    exit 0
}