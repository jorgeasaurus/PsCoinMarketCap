<#
.SYNOPSIS
    Deploys PsCoinMarketCap module to PowerShell Gallery
.DESCRIPTION
    This script builds, tests, and publishes the PsCoinMarketCap module to the PowerShell Gallery
.PARAMETER ApiKey
    Your PowerShell Gallery API key (get from https://www.powershellgallery.com/account)
.PARAMETER WhatIf
    Shows what would happen without actually publishing
.EXAMPLE
    .\Deploy-ToGallery.ps1 -ApiKey "your-api-key"
    
    Publishes the module to PowerShell Gallery
.EXAMPLE
    .\Deploy-ToGallery.ps1 -WhatIf
    
    Shows what would be published without actually doing it
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ApiKey,
    
    [Parameter()]
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'

Write-Host "🚀 PsCoinMarketCap Deployment Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Step 1: Clean and Build
Write-Host "`n📦 Building module..." -ForegroundColor Yellow
.\build.ps1 -Task Clean
.\build.ps1 -Task Build

# Step 2: Run Tests (unless skipped)
if (-not $SkipTests) {
    Write-Host "`n🧪 Running tests..." -ForegroundColor Yellow
    try {
        .\build.ps1 -Task Test
        Write-Host "✅ All tests passed!" -ForegroundColor Green
    } catch {
        Write-Warning "⚠️ Some tests failed. Review and fix before publishing."
        if (-not (Read-Host "Continue anyway? (y/N)").ToLower().StartsWith('y')) {
            return
        }
    }
} else {
    Write-Warning "⚠️ Skipping tests - not recommended for production deployment"
}

# Step 3: Validate Module
Write-Host "`n🔍 Validating module manifest..." -ForegroundColor Yellow
$modulePath = ".\Output\PsCoinMarketCap\1.0.0"
$manifestPath = Join-Path $modulePath "PsCoinMarketCap.psd1"

$manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
Write-Host "✅ Module manifest is valid" -ForegroundColor Green
Write-Host "   Version: $($manifest.Version)" -ForegroundColor Gray
Write-Host "   Functions: $(($manifest.ExportedFunctions.Keys | Measure-Object).Count)" -ForegroundColor Gray

# Step 4: Import and Test Module
Write-Host "`n📥 Testing module import..." -ForegroundColor Yellow
Import-Module $manifestPath -Force
$commands = Get-Command -Module PsCoinMarketCap
Write-Host "✅ Module imported successfully" -ForegroundColor Green
Write-Host "   Exported commands: $($commands.Count)" -ForegroundColor Gray

# Step 5: Check if module already exists in gallery
Write-Host "`n🔍 Checking PowerShell Gallery..." -ForegroundColor Yellow
$existingModule = Find-Module -Name PsCoinMarketCap -ErrorAction SilentlyContinue
if ($existingModule) {
    Write-Host "📌 Module exists in gallery" -ForegroundColor Yellow
    Write-Host "   Current version: $($existingModule.Version)" -ForegroundColor Gray
    Write-Host "   New version: $($manifest.Version)" -ForegroundColor Gray
    
    if ([version]$manifest.Version -le [version]$existingModule.Version) {
        Write-Error "New version ($($manifest.Version)) must be greater than existing version ($($existingModule.Version))"
        return
    }
} else {
    Write-Host "✅ This will be the first publication" -ForegroundColor Green
}

# Step 6: Publish to Gallery
if ($PSCmdlet.ShouldProcess("PsCoinMarketCap v$($manifest.Version)", "Publish to PowerShell Gallery")) {
    if (-not $ApiKey) {
        Write-Host "`n🔑 Enter your PowerShell Gallery API Key" -ForegroundColor Yellow
        Write-Host "   Get your key from: https://www.powershellgallery.com/account" -ForegroundColor Gray
        $secureKey = Read-Host "API Key" -AsSecureString
        $ApiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey))
    }
    
    Write-Host "`n📤 Publishing to PowerShell Gallery..." -ForegroundColor Yellow
    try {
        Publish-Module -Path $modulePath -NuGetApiKey $ApiKey -Verbose
        Write-Host "✅ Module published successfully!" -ForegroundColor Green
        
        Write-Host "`n🎉 Deployment Complete!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host "Module: PsCoinMarketCap" -ForegroundColor Cyan
        Write-Host "Version: $($manifest.Version)" -ForegroundColor Cyan
        Write-Host "Gallery: https://www.powershellgallery.com/packages/PsCoinMarketCap" -ForegroundColor Cyan
        Write-Host "GitHub: https://github.com/jorgeasaurus/PsCoinMarketCap" -ForegroundColor Cyan
        
        Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Create a GitHub release for v$($manifest.Version)"
        Write-Host "2. Test installation: Install-Module -Name PsCoinMarketCap"
        Write-Host "3. Monitor for user feedback and issues"
        
    } catch {
        Write-Error "Failed to publish module: $_"
    }
} else {
    Write-Host "`n📋 Deployment Summary (WhatIf Mode)" -ForegroundColor Yellow
    Write-Host "Would publish:" -ForegroundColor Gray
    Write-Host "   Module: PsCoinMarketCap" -ForegroundColor Gray
    Write-Host "   Version: $($manifest.Version)" -ForegroundColor Gray
    Write-Host "   Path: $modulePath" -ForegroundColor Gray
    Write-Host "`nRun without -WhatIf to actually publish" -ForegroundColor Cyan
}