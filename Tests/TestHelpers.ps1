# Test Helper Functions for Cross-Platform Compatibility

function Get-TestConfigPath {
    <#
    .SYNOPSIS
        Gets the appropriate configuration path for the current platform
    .DESCRIPTION
        Returns the configuration directory path based on the operating system.
        Uses APPDATA on Windows, ~/.config on Linux, and ~/Library/Application Support on macOS
    #>
    if ($env:APPDATA) {
        # Windows
        return $env:APPDATA
    } elseif ($IsMacOS -or $env:HOME -match '/Users/') {
        # macOS
        $path = "$env:HOME/Library/Application Support"
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
        return $path
    } elseif ($env:HOME) {
        # Linux
        $path = "$env:HOME/.config"
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
        return $path
    } else {
        # Fallback to temp directory
        return [System.IO.Path]::GetTempPath()
    }
}

# Export the function
Export-ModuleMember -Function Get-TestConfigPath