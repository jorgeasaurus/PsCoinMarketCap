function Get-CMCApiKey {
    <#
    .SYNOPSIS
        Retrieves the stored CoinMarketCap API key.
    
    .DESCRIPTION
        The Get-CMCApiKey cmdlet retrieves the CoinMarketCap API key from either the current session
        or from persistent storage in the user's profile. Returns the key as a SecureString by default.
    
    .PARAMETER Scope
        Specifies where to retrieve the API key from:
        - Session: Retrieves the key from the current PowerShell session
        - User: Retrieves the key from persistent storage in the user's profile
        - Auto: Automatically checks session first, then user profile (default)
    
    .PARAMETER AsPlainText
        If specified, returns the API key as plain text instead of a SecureString.
        WARNING: This exposes the API key in memory and should be used with caution.
    
    .PARAMETER TestConnection
        If specified, tests the API key by making a request to the /key/info endpoint.
    
    .EXAMPLE
        Get-CMCApiKey
        
        Retrieves the API key as a SecureString, checking session first then user profile.
    
    .EXAMPLE
        Get-CMCApiKey -AsPlainText
        
        Retrieves the API key as plain text.
    
    .EXAMPLE
        Get-CMCApiKey -Scope User -TestConnection
        
        Retrieves the API key from user profile and tests if it's valid.
    
    .EXAMPLE
        $key = Get-CMCApiKey
        $credentials = New-Object System.Management.Automation.PSCredential ('api', $key)
        
        Retrieves the API key and uses it to create a credential object.
    
    .OUTPUTS
        System.Security.SecureString or System.String
        Returns the API key as either a SecureString (default) or plain text string.
    
    .NOTES
        For security reasons, it's recommended to work with SecureString whenever possible.
        Use -AsPlainText only when absolutely necessary.
    #>
    [CmdletBinding()]
    [OutputType([System.Security.SecureString], [string])]
    param(
        [Parameter()]
        [ValidateSet('Session', 'User', 'Auto')]
        [string]$Scope = 'Auto',
        
        [Parameter()]
        [switch]$AsPlainText,
        
        [Parameter()]
        [switch]$TestConnection
    )
    
    begin {
        Write-Verbose "Retrieving CoinMarketCap API key with scope: $Scope"
    }
    
    process {
        $apiKey = $null
        $retrievedFrom = $null
        
        # Try to retrieve based on scope
        switch ($Scope) {
            'Session' {
                if ($script:CMCApiKeySecure) {
                    $apiKey = $script:CMCApiKeySecure
                    $retrievedFrom = 'Session'
                    Write-Verbose "API key retrieved from session"
                }
                else {
                    Write-Verbose "No API key found in session"
                }
            }
            
            'User' {
                $keyPath = Get-CMCConfigPath
                $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                
                if (Test-Path -Path $keyFile) {
                    try {
                        $credential = Import-Clixml -Path $keyFile
                        $apiKey = $credential.Password
                        $retrievedFrom = 'User'
                        
                        # Check sandbox preference
                        $sandboxFile = Join-Path -Path $keyPath -ChildPath 'sandbox.txt'
                        if (Test-Path -Path $sandboxFile) {
                            $script:CMCUseSandbox = $true
                        }
                        
                        # Update session variable
                        $script:CMCApiKeySecure = $apiKey
                        
                        Write-Verbose "API key retrieved from user profile"
                    }
                    catch {
                        Write-Error "Failed to retrieve API key from user profile: $_"
                        return
                    }
                }
                else {
                    Write-Verbose "No API key found in user profile"
                }
            }
            
            'Auto' {
                # Try session first
                if ($script:CMCApiKeySecure) {
                    $apiKey = $script:CMCApiKeySecure
                    $retrievedFrom = 'Session'
                    Write-Verbose "API key retrieved from session"
                }
                else {
                    # Try user profile
                    $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
                    $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                    
                    if (Test-Path -Path $keyFile) {
                        try {
                            $credential = Import-Clixml -Path $keyFile
                            $apiKey = $credential.Password
                            $retrievedFrom = 'User'
                            
                            # Check sandbox preference
                            $sandboxFile = Join-Path -Path $keyPath -ChildPath 'sandbox.txt'
                            if (Test-Path -Path $sandboxFile) {
                                $script:CMCUseSandbox = $true
                            }
                            
                            # Update session variable
                            $script:CMCApiKeySecure = $apiKey
                            
                            Write-Verbose "API key retrieved from user profile"
                        }
                        catch {
                            Write-Error "Failed to retrieve API key from user profile: $_"
                            return
                        }
                    }
                    else {
                        Write-Verbose "No API key found in session or user profile"
                    }
                }
            }
        }
        
        # Check if key was found
        if (-not $apiKey) {
            Write-Error "No CoinMarketCap API key found. Use Set-CMCApiKey to configure one."
            return
        }
        
        # Test connection if requested
        if ($TestConnection) {
            Write-Verbose "Testing API key connection..."
            
            try {
                # We'll implement this after creating Invoke-CMCRequest
                # For now, just return a message
                Write-Warning "Connection test will be available after core request functions are implemented"
            }
            catch {
                Write-Error "API key test failed: $_"
                return
            }
        }
        
        # Return the key in requested format
        if ($AsPlainText) {
            # Ensure we can work with SecureStrings
            if (-not (Get-Command ConvertFrom-SecureString -ErrorAction SilentlyContinue)) {
                Import-Module Microsoft.PowerShell.Security -ErrorAction SilentlyContinue
            }
            
            # Convert SecureString to plain text
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)
            try {
                $plainTextKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                Write-Verbose "Returning API key as plain text (retrieved from: $retrievedFrom)"
                return $plainTextKey
            }
            finally {
                # Clean up
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
            }
        }
        else {
            Write-Verbose "Returning API key as SecureString (retrieved from: $retrievedFrom)"
            return $apiKey
        }
    }
    
    end {
        Write-Verbose "Get-CMCApiKey completed"
    }
}