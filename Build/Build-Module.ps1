# Simple module build script
[CmdletBinding()]
param(
    [Parameter()]
    [string]$SourcePath = (Join-Path $PSScriptRoot "..\Source"),
    
    [Parameter()]
    [string]$OutputPath = (Join-Path $PSScriptRoot "Output")
)

Write-Host "🔧 Building PsCoinMarketCap Module..." -ForegroundColor Cyan
Write-Host "Source: $SourcePath" -ForegroundColor Gray
Write-Host "Output: $OutputPath" -ForegroundColor Gray

# Clean output directory
if (Test-Path $OutputPath) {
    Write-Host "🧹 Cleaning output directory..." -ForegroundColor Yellow
    Remove-Item $OutputPath -Recurse -Force
}

# Create output directory
New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null

# Copy all source files
Write-Host "📦 Copying module files..." -ForegroundColor Yellow
Copy-Item -Path "$SourcePath\*" -Destination $OutputPath -Recurse -Force

# Test module manifest
$manifestPath = Join-Path $OutputPath "PsCoinMarketCap.psd1"
Write-Host "📋 Testing module manifest..." -ForegroundColor Yellow

try {
    $manifest = Test-ModuleManifest $manifestPath -ErrorAction Stop
    Write-Host "✅ Module manifest is valid!" -ForegroundColor Green
    Write-Host "   Name: $($manifest.Name)" -ForegroundColor White
    Write-Host "   Version: $($manifest.Version)" -ForegroundColor White
    Write-Host "   Author: $($manifest.Author)" -ForegroundColor White
} catch {
    Write-Error "❌ Module manifest validation failed: $_"
    return
}

# Test module import
Write-Host "🔄 Testing module import..." -ForegroundColor Yellow
try {
    Import-Module $manifestPath -Force -ErrorAction Stop
    $importedModule = Get-Module PsCoinMarketCap
    Write-Host "✅ Module imported successfully!" -ForegroundColor Green
    Write-Host "   Functions exported: $($importedModule.ExportedFunctions.Count)" -ForegroundColor White
    
    # Test a core function
    if (Get-Command Test-CMCRateLimit -ErrorAction SilentlyContinue) {
        Write-Host "✅ Core functions accessible" -ForegroundColor Green
    } else {
        Write-Warning "⚠️  Some functions may not be accessible"
    }
    
    Remove-Module PsCoinMarketCap -Force
} catch {
    Write-Error "❌ Module import failed: $_"
    return
}

Write-Host "🎉 Module build completed successfully!" -ForegroundColor Green
Write-Host "📁 Built module location: $OutputPath" -ForegroundColor Cyan

return $OutputPath