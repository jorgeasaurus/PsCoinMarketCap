#Requires -Version 5.1

$script:ModuleRoot = $PSScriptRoot
# Get module version from manifest
try {
    $manifestContent = Get-Content -Path "$script:ModuleRoot\PsCoinMarketCap.psd1" -Raw
    if ($manifestContent -match "ModuleVersion\s*=\s*'([^']+)'") {
        $script:ModuleVersion = $matches[1]
    } else {
        $script:ModuleVersion = '0.1.0'
    }
} catch {
    $script:ModuleVersion = '0.1.0'
}

# Import everything in these folders
foreach ($folder in @('Private', 'Public')) {
    $folderPath = Join-Path -Path $script:ModuleRoot -ChildPath $folder
    
    if (Test-Path -Path $folderPath) {
        Write-Verbose "Importing from $folder"
        $files = Get-ChildItem -Path $folderPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
        
        foreach ($file in $files) {
            Write-Verbose "  Importing $($file.BaseName)"
            . $file.FullName
        }
    }
}

# Import classes
$classPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Classes'
if (Test-Path -Path $classPath) {
    Write-Verbose "Importing classes"
    $classes = Get-ChildItem -Path $classPath -Filter '*.ps1' -ErrorAction SilentlyContinue
    
    foreach ($class in $classes) {
        Write-Verbose "  Importing $($class.BaseName)"
        . $class.FullName
    }
}

# Module-level variables
$script:CMCApiKey = $null
$script:CMCApiKeySecure = $null
$script:CMCBaseUrl = 'https://pro-api.coinmarketcap.com/v1'
$script:CMCSandboxUrl = 'https://sandbox-api.coinmarketcap.com/v1'
$script:CMCUseSandbox = $false
$script:CMCLastRequestTime = [datetime]::MinValue
$script:CMCRequestDelay = 100  # Milliseconds between requests

# Export module member (this is handled by the manifest, but good for testing)
Export-ModuleMember -Function (Get-ChildItem -Path "$script:ModuleRoot\Public" -Filter '*.ps1' -Recurse).BaseName