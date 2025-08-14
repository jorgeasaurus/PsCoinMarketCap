function Set-CMCApiKey {
    <#
    .SYNOPSIS
        Sets the CoinMarketCap API key for the current session or persistently.
    
    .DESCRIPTION
        The Set-CMCApiKey cmdlet stores the CoinMarketCap API key either in memory for the current session
        or persistently in the user's profile. The API key is stored securely as a SecureString.
    
    .PARAMETER ApiKey
        The CoinMarketCap API key to store. This can be either a regular string or a SecureString.
    
    .PARAMETER Scope
        Specifies where to store the API key:
        - Session: Stores the key in memory for the current PowerShell session only
        - User: Stores the key persistently in the user's profile (encrypted)
    
    .PARAMETER UseSandbox
        If specified, configures the module to use the CoinMarketCap sandbox API endpoint
        instead of the production endpoint.
    
    .PARAMETER Force
        Overwrites an existing API key without prompting for confirmation.
    
    .EXAMPLE
        Set-CMCApiKey -ApiKey "your-api-key-here"
        
        Sets the API key for the current session.
    
    .EXAMPLE
        Set-CMCApiKey -ApiKey "your-api-key-here" -Scope User
        
        Stores the API key persistently in the user's profile.
    
    .EXAMPLE
        $secureKey = Read-Host -AsSecureString "Enter API Key"
        Set-CMCApiKey -ApiKey $secureKey -Scope User -UseSandbox
        
        Prompts for the API key securely and stores it for the sandbox environment.
    
    .NOTES
        The API key is required to make requests to the CoinMarketCap API.
        You can obtain an API key from: https://coinmarketcap.com/api/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [object]$ApiKey,
        
        [Parameter()]
        [ValidateSet('Session', 'User')]
        [string]$Scope = 'Session',
        
        [Parameter()]
        [switch]$UseSandbox,
        
        [Parameter()]
        [switch]$Force
    )
    
    begin {
        Write-Verbose "Setting CoinMarketCap API key with scope: $Scope"
    }
    
    process {
        # Ensure Security module is loaded for ConvertTo-SecureString
        if (-not (Get-Command ConvertTo-SecureString -ErrorAction SilentlyContinue)) {
            Import-Module Microsoft.PowerShell.Security -ErrorAction SilentlyContinue
        }
        
        # Convert string to SecureString if necessary
        if ($ApiKey -is [string]) {
            $secureApiKey = ConvertTo-SecureString -String $ApiKey -AsPlainText -Force
        }
        elseif ($ApiKey -is [System.Security.SecureString]) {
            $secureApiKey = $ApiKey
        }
        else {
            throw "ApiKey must be either a String or SecureString"
        }
        
        # Check if key already exists and confirm overwrite
        if (-not $Force) {
            $existingKey = Get-CMCApiKey -Scope $Scope -ErrorAction SilentlyContinue
            if ($existingKey) {
                if ($PSCmdlet.ShouldProcess("Existing API key", "Overwrite")) {
                    Write-Verbose "Overwriting existing API key"
                }
                else {
                    Write-Warning "Operation cancelled. Use -Force to overwrite without confirmation."
                    return
                }
            }
        }
        
        # Store the API key based on scope
        switch ($Scope) {
            'Session' {
                # Store in module-level variable
                $script:CMCApiKeySecure = $secureApiKey
                $script:CMCUseSandbox = $UseSandbox
                Write-Verbose "API key stored in current session"
            }
            
            'User' {
                # Store persistently in user profile
                $keyPath = Get-CMCConfigPath
                
                if (-not (Test-Path -Path $keyPath)) {
                    New-Item -Path $keyPath -ItemType Directory -Force | Out-Null
                }
                
                $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                
                # Create credential object for secure storage
                $credential = New-Object System.Management.Automation.PSCredential ('CMCApiKey', $secureApiKey)
                
                # Export credential to file (encrypted with DPAPI on Windows)
                $credential | Export-Clixml -Path $keyFile
                
                # Store sandbox preference
                if ($UseSandbox) {
                    $sandboxFile = Join-Path -Path $keyPath -ChildPath 'sandbox.txt'
                    'true' | Set-Content -Path $sandboxFile
                }
                else {
                    $sandboxFile = Join-Path -Path $keyPath -ChildPath 'sandbox.txt'
                    if (Test-Path -Path $sandboxFile) {
                        Remove-Item -Path $sandboxFile -Force
                    }
                }
                
                Write-Verbose "API key stored persistently in user profile"
            }
        }
        
        # Update module-level variables regardless of scope
        $script:CMCApiKeySecure = $secureApiKey
        $script:CMCUseSandbox = $UseSandbox
        
        # Clear any plain text key from memory
        # Note: We can't clear parameter variables, but they go out of scope automatically
        if ($ApiKey -is [string]) {
            Remove-Variable -Name secureApiKey -Force -ErrorAction SilentlyContinue
        }
        
        Write-Information "CoinMarketCap API key has been set successfully" -InformationAction Continue
        
        if ($UseSandbox) {
            Write-Information "Module configured to use sandbox environment" -InformationAction Continue
        }
    }
    
    end {
        Write-Verbose "Set-CMCApiKey completed"
    }
}