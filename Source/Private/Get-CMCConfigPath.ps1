function Get-CMCConfigPath {
    <#
    .SYNOPSIS
        Gets the configuration directory path for PsCoinMarketCap
    
    .DESCRIPTION
        Returns the appropriate configuration directory based on the operating system.
        Creates the directory if it doesn't exist.
    
    .OUTPUTS
        System.String
        The full path to the PsCoinMarketCap configuration directory
    
    .EXAMPLE
        $configPath = Get-CMCConfigPath
        
        Returns the configuration path for the current platform
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    # Determine base config path based on OS
    $basePath = if ($env:APPDATA) {
        # Windows
        $env:APPDATA
    }
    elseif ($IsMacOS -or $env:HOME -match '/Users/') {
        # macOS
        "$env:HOME/Library/Application Support"
    }
    elseif ($env:HOME) {
        # Linux
        "$env:HOME/.config"
    }
    else {
        # Fallback to temp directory
        [System.IO.Path]::GetTempPath()
    }
    
    # Create full path to PsCoinMarketCap config
    $configPath = Join-Path -Path $basePath -ChildPath 'PsCoinMarketCap'
    
    # Create directory if it doesn't exist
    if (-not (Test-Path -Path $configPath)) {
        try {
            New-Item -ItemType Directory -Path $configPath -Force | Out-Null
            Write-Verbose "Created configuration directory: $configPath"
        }
        catch {
            Write-Warning "Failed to create configuration directory: $_"
            # Fallback to temp directory
            $configPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'PsCoinMarketCap'
            New-Item -ItemType Directory -Path $configPath -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }
    
    return $configPath
}