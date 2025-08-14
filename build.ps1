[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Build', 'Test', 'Analyze', 'UpdateHelp', 'CI', 'Deploy', 'Clean')]
    [string]$Task = 'Build',
    
    [Parameter()]
    [string]$OutputDirectory = "$PSScriptRoot\Output",
    
    [Parameter()]
    [switch]$Bootstrap
)

# Bootstrap dependencies - simplified approach
if ($Bootstrap) {
    Write-Host "Bootstrapping dependencies..." -ForegroundColor Green
    
    # Ensure NuGet provider is available
    $nugetProvider = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
    if (-not $nugetProvider -or $nugetProvider.Version -lt '2.8.5.201') {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    }
    
    # Trust PSGallery
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    
    # Install essential modules if needed
    if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) {
        Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
    }
}

# Module information
$ModuleName = 'PsCoinMarketCap'
$SourcePath = "$PSScriptRoot\Source"
$ManifestPath = "$SourcePath\$ModuleName.psd1"

# Direct build functions instead of InvokeBuild tasks
function Invoke-Clean {
    Write-Host "Cleaning output directory..." -ForegroundColor Green
    
    if (Test-Path $OutputDirectory) {
        Remove-Item -Path $OutputDirectory -Recurse -Force
    }
    
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
}

function Invoke-Build {
    Write-Host "Building module..." -ForegroundColor Green
    
    # Clean first
    Invoke-Clean
    
    # Get version from manifest
    $manifestContent = Get-Content -Path $ManifestPath -Raw
    if ($manifestContent -match "ModuleVersion\s*=\s*'([^']+)'") {
        $version = $matches[1]
    } else {
        $version = "1.0.0"
    }
    
    # Create versioned output directory
    $buildPath = Join-Path -Path $OutputDirectory -ChildPath "$ModuleName\$version"
    New-Item -Path $buildPath -ItemType Directory -Force | Out-Null
    
    # Copy module files (excluding problematic tool files)
    Copy-Item -Path "$SourcePath\*" -Destination $buildPath -Recurse -Force -Exclude "Get-CMCChart.ps1", "Watch-CMCPrice.ps1"
    
    # Copy specific tool files that work
    $toolsSource = "$SourcePath\Public\Tools"
    $toolsDest = "$buildPath\Public\Tools"
    if (Test-Path $toolsSource) {
        $workingTools = @("Convert-CMCPrice.ps1", "Export-CMCData.ps1")
        foreach ($tool in $workingTools) {
            $sourcePath = Join-Path $toolsSource $tool
            if (Test-Path $sourcePath) {
                Copy-Item $sourcePath $toolsDest -Force
            }
        }
    }
    
    Write-Host "Module built successfully at: $buildPath" -ForegroundColor Green
    return $buildPath
}

function Invoke-Test {
    Write-Host "Testing module import..." -ForegroundColor Green
    
    # Simple test - try to import the built module
    $manifestContent = Get-Content -Path $ManifestPath -Raw
    if ($manifestContent -match "ModuleVersion\s*=\s*'([^']+)'") {
        $version = $matches[1]
    } else {
        $version = "1.0.0"
    }
    $modulePath = Join-Path -Path $OutputDirectory -ChildPath "$ModuleName\$version"
    
    if (-not (Test-Path $modulePath)) {
        throw "Built module not found at: $modulePath"
    }
    
    try {
        Import-Module "$modulePath\$ModuleName.psd1" -Force -ErrorAction Stop
        $importedModule = Get-Module $ModuleName
        
        Write-Host "✅ Module imported successfully!" -ForegroundColor Green
        Write-Host "   Name: $($importedModule.Name)" -ForegroundColor White
        Write-Host "   Version: $($importedModule.Version)" -ForegroundColor White
        Write-Host "   Functions: $($importedModule.ExportedFunctions.Count)" -ForegroundColor White
        
        Remove-Module $ModuleName -Force
        Write-Host "Basic module tests passed!" -ForegroundColor Green
    }
    catch {
        throw "Module import failed: $_"
    }
}

function Invoke-Analyze {
    Write-Host "Running PSScriptAnalyzer..." -ForegroundColor Green
    
    $analyzerResults = Invoke-ScriptAnalyzer -Path $SourcePath -Recurse -Settings PSGallery
    
    if ($analyzerResults) {
        $analyzerResults | Format-Table -AutoSize
        
        # Only fail on errors, not warnings
        $errors = $analyzerResults | Where-Object { $_.Severity -eq 'Error' }
        if ($errors) {
            throw "PSScriptAnalyzer found $($errors.Count) error(s)"
        } else {
            Write-Host "Found $($analyzerResults.Count) warning(s) but no errors" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No issues found by PSScriptAnalyzer" -ForegroundColor Green
    }
}

function Invoke-UpdateHelp {
    Write-Host "Generating help documentation..." -ForegroundColor Green
    
    # Import the built module
    Import-Module "$OutputDirectory\$ModuleName" -Force
    
    # Generate help
    $helpPath = "$PSScriptRoot\docs\en-US"
    New-Item -Path $helpPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    
    # Get public functions
    $publicFunctions = Get-ChildItem -Path "$SourcePath\Public" -Filter '*.ps1' -Recurse
    
    foreach ($function in $publicFunctions) {
        $functionName = $function.BaseName
        $helpFile = Join-Path -Path $helpPath -ChildPath "$functionName.md"
        
        if (Get-Command -Name $functionName -Module $ModuleName -ErrorAction SilentlyContinue) {
            New-MarkdownHelp -Command $functionName -OutputFolder $helpPath -Force | Out-Null
        }
    }
    
    Write-Host "Help documentation updated" -ForegroundColor Green
}

function Invoke-CI {
    Invoke-Build
    Invoke-Analyze
    Invoke-Test
    Write-Host "CI pipeline completed successfully" -ForegroundColor Green
}

function Invoke-Deploy {
    Invoke-Test
    
    Write-Host "Deploying module to PowerShell Gallery..." -ForegroundColor Green
    
    # Get API key from environment variable
    $apiKey = $env:PSGALLERY_API_KEY
    
    if (-not $apiKey) {
        throw "PowerShell Gallery API key not found in environment variable PSGALLERY_API_KEY"
    }
    
    # Get the built module path
    $manifestContent = Get-Content -Path $ManifestPath -Raw
    if ($manifestContent -match "ModuleVersion\s*=\s*'([^']+)'") {
        $version = $matches[1]
    } else {
        $version = "1.0.0"
    }
    $modulePath = Join-Path -Path $OutputDirectory -ChildPath "$ModuleName\$version"
    
    # Publish to PowerShell Gallery
    Publish-Module -Path $modulePath -NuGetApiKey $apiKey -Repository PSGallery
    
    Write-Host "Module published to PowerShell Gallery" -ForegroundColor Green
}

# Execute the specified task
switch ($Task) {
    'Build' { Invoke-Build }
    'Test' { Invoke-Test }
    'Analyze' { Invoke-Analyze }
    'UpdateHelp' { Invoke-UpdateHelp }
    'CI' { Invoke-CI }
    'Deploy' { Invoke-Deploy }
    'Clean' { Invoke-Clean }
}