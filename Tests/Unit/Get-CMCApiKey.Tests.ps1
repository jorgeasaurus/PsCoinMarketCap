BeforeAll {
    # Import the module
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Source\PsCoinMarketCap.psd1'
    
    # Remove module if already loaded
    if (Get-Module PsCoinMarketCap) {
        Remove-Module PsCoinMarketCap -Force
    }
    
    Import-Module $modulePath -Force
    
    # Get module for accessing script variables
    $script:TestModule = Get-Module PsCoinMarketCap
    
    # Mock ConvertTo-SecureString if not available
    if (-not (Get-Command ConvertTo-SecureString -ErrorAction SilentlyContinue)) {
        function global:ConvertTo-SecureString {
            param(
                [Parameter(Mandatory, ValueFromPipeline)]
                [string]$String,
                [switch]$AsPlainText,
                [switch]$Force
            )
            # Create a mock secure string
            $secureString = New-Object System.Security.SecureString
            foreach ($char in $String.ToCharArray()) {
                $secureString.AppendChar($char)
            }
            $secureString.MakeReadOnly()
            return $secureString
        }
    }
    
    # Mock ConvertFrom-SecureString if not available
    if (-not (Get-Command ConvertFrom-SecureString -ErrorAction SilentlyContinue)) {
        function global:ConvertFrom-SecureString {
            param(
                [Parameter(Mandatory, ValueFromPipeline)]
                [System.Security.SecureString]$SecureString
            )
            # Return a fake encrypted string
            return '01000000d08c9ddf0115d1118c7a00c04fc297eb...'
        }
    }
}

AfterAll {
    # Clean up test files
    $testKeyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
    if (Test-Path $testKeyPath) {
        Remove-Item -Path $testKeyPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Remove-Module PsCoinMarketCap -Force -ErrorAction SilentlyContinue
}

Describe 'Get-CMCApiKey' {
    
    BeforeEach {
        # Clear module variables before each test
        if ($script:TestModule) {
            & $script:TestModule {
                $script:CMCApiKeySecure = $null
                $script:CMCUseSandbox = $false
            }
        }
        
        # Clean up any existing test files
        $testKeyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
        if (Test-Path $testKeyPath) {
            Remove-Item -Path $testKeyPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Context 'No API Key Set' {
        
        It 'Should throw error when no key is found' {
            { Get-CMCApiKey -ErrorAction Stop } | Should -Throw "*No CoinMarketCap API key found*"
        }
        
        It 'Should return null with SilentlyContinue' {
            $result = Get-CMCApiKey -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context 'Session Scope Retrieval' {
        
        It 'Should retrieve API key from session' {
            # Mock Set-CMCApiKey to directly set the module variable
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                if ($script:TestModule) {
                    & $script:TestModule {
                        param($key, $sandbox)
                        $script:CMCApiKeySecure = $key
                        $script:CMCUseSandbox = $sandbox
                    } -ArgumentList @(
                        (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force),
                        $UseSandbox.IsPresent
                    )
                }
            }
            
            # Set key in session
            Set-CMCApiKey -ApiKey 'session-retrieve-test' -Scope Session -Force
            
            # Retrieve key
            $key = Get-CMCApiKey -Scope Session
            $key | Should -Not -BeNullOrEmpty
            $key | Should -BeOfType [System.Security.SecureString]
            
            # Verify it's the right key
            $plainKey = Get-CMCApiKey -Scope Session -AsPlainText
            $plainKey | Should -Be 'session-retrieve-test'
        }
        
        It 'Should return plain text when AsPlainText is specified' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                if ($script:TestModule) {
                    & $script:TestModule {
                        param($key)
                        $script:CMCApiKeySecure = $key
                    } -ArgumentList (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                }
            }
            
            Set-CMCApiKey -ApiKey 'plaintext-test-key' -Scope Session -Force
            
            $key = Get-CMCApiKey -Scope Session -AsPlainText
            $key | Should -Be 'plaintext-test-key'
            $key | Should -BeOfType [string]
        }
        
        It 'Should return null when session key not set' {
            # Clear session key
            if ($script:TestModule) {
                & $script:TestModule { $script:CMCApiKeySecure = $null }
            }
            
            $key = Get-CMCApiKey -Scope Session -ErrorAction SilentlyContinue
            $key | Should -BeNullOrEmpty
        }
    }
    
    Context 'User Scope Retrieval' {
        
        It 'Should retrieve API key from user profile' {
            # Mock Set-CMCApiKey for user scope
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
                if (-not (Test-Path -Path $keyPath)) {
                    New-Item -Path $keyPath -ItemType Directory -Force | Out-Null
                }
                $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                $credential = New-Object System.Management.Automation.PSCredential (
                    'CMCApiKey',
                    (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                )
                $credential | Export-Clixml -Path $keyFile
            }
            
            # Set key in user profile
            Set-CMCApiKey -ApiKey 'user-retrieve-test' -Scope User -Force
            
            # Clear session to ensure we're reading from file
            if ($script:TestModule) {
                & $script:TestModule { $script:CMCApiKeySecure = $null }
            }
            
            # Retrieve from user profile
            $key = Get-CMCApiKey -Scope User -AsPlainText
            $key | Should -Be 'user-retrieve-test'
        }
        
        It 'Should load sandbox preference from user profile' {
            # Mock Set-CMCApiKey for user scope with sandbox
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
                if (-not (Test-Path -Path $keyPath)) {
                    New-Item -Path $keyPath -ItemType Directory -Force | Out-Null
                }
                $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                $credential = New-Object System.Management.Automation.PSCredential (
                    'CMCApiKey',
                    (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                )
                $credential | Export-Clixml -Path $keyFile
                
                if ($UseSandbox) {
                    $sandboxFile = Join-Path -Path $keyPath -ChildPath 'sandbox.txt'
                    'true' | Set-Content -Path $sandboxFile
                }
            }
            
            # Set with sandbox enabled
            Set-CMCApiKey -ApiKey 'sandbox-user-test' -Scope User -UseSandbox -Force
            
            # Clear session variables
            if ($script:TestModule) {
                & $script:TestModule { 
                    $script:CMCApiKeySecure = $null
                    $script:CMCUseSandbox = $false
                }
            }
            
            # Get key should also restore sandbox setting
            $key = Get-CMCApiKey -Scope User
            $key | Should -Not -BeNullOrEmpty
            
            # Check sandbox was loaded
            if ($script:TestModule) {
                $sandboxStatus = & $script:TestModule { $script:CMCUseSandbox }
                $sandboxStatus | Should -BeTrue
            }
        }
        
        It 'Should update session variables when retrieving from user profile' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
                if (-not (Test-Path -Path $keyPath)) {
                    New-Item -Path $keyPath -ItemType Directory -Force | Out-Null
                }
                $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                $credential = New-Object System.Management.Automation.PSCredential (
                    'CMCApiKey',
                    (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                )
                $credential | Export-Clixml -Path $keyFile
            }
            
            # Set in user profile
            Set-CMCApiKey -ApiKey 'user-to-session-test' -Scope User -Force
            
            # Clear session
            if ($script:TestModule) {
                & $script:TestModule { $script:CMCApiKeySecure = $null }
            }
            
            # Get from user should populate session
            $key = Get-CMCApiKey -Scope User
            $key | Should -Not -BeNullOrEmpty
            
            # Verify session was updated
            $sessionKey = Get-CMCApiKey -Scope Session -AsPlainText -ErrorAction SilentlyContinue
            $sessionKey | Should -Be 'user-to-session-test'
        }
    }
    
    Context 'Auto Scope Retrieval' {
        
        It 'Should prefer session over user profile' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                if ($Scope -eq 'User') {
                    $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
                    if (-not (Test-Path -Path $keyPath)) {
                        New-Item -Path $keyPath -ItemType Directory -Force | Out-Null
                    }
                    $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                    $credential = New-Object System.Management.Automation.PSCredential (
                        'CMCApiKey',
                        (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                    )
                    $credential | Export-Clixml -Path $keyFile
                } else {
                    if ($script:TestModule) {
                        & $script:TestModule {
                            param($key)
                            $script:CMCApiKeySecure = $key
                        } -ArgumentList (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                    }
                }
            }
            
            # Set different keys in session and user
            Set-CMCApiKey -ApiKey 'user-auto-test' -Scope User -Force
            Set-CMCApiKey -ApiKey 'session-auto-test' -Scope Session -Force
            
            $key = Get-CMCApiKey -Scope Auto -AsPlainText
            $key | Should -Be 'session-auto-test'
        }
        
        It 'Should fall back to user profile when session is empty' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
                if (-not (Test-Path -Path $keyPath)) {
                    New-Item -Path $keyPath -ItemType Directory -Force | Out-Null
                }
                $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
                $credential = New-Object System.Management.Automation.PSCredential (
                    'CMCApiKey',
                    (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                )
                $credential | Export-Clixml -Path $keyFile
            }
            
            # Set in user profile
            Set-CMCApiKey -ApiKey 'user-fallback-test' -Scope User -Force
            
            # Clear session
            if ($script:TestModule) {
                & $script:TestModule { $script:CMCApiKeySecure = $null }
            }
            
            $key = Get-CMCApiKey -Scope Auto -AsPlainText
            $key | Should -Be 'user-fallback-test'
        }
        
        It 'Should use Auto scope by default' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                if ($script:TestModule) {
                    & $script:TestModule {
                        param($key)
                        $script:CMCApiKeySecure = $key
                    } -ArgumentList (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                }
            }
            
            Set-CMCApiKey -ApiKey 'default-scope-test' -Scope Session -Force
            
            # Call without specifying scope
            $key = Get-CMCApiKey -AsPlainText
            $key | Should -Be 'default-scope-test'
        }
    }
    
    Context 'Return Types' {
        
        It 'Should return SecureString by default' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                if ($script:TestModule) {
                    & $script:TestModule {
                        param($key)
                        $script:CMCApiKeySecure = $key
                    } -ArgumentList (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                }
            }
            
            Set-CMCApiKey -ApiKey 'secure-return-test' -Force
            
            $key = Get-CMCApiKey
            $key | Should -BeOfType [System.Security.SecureString]
        }
        
        It 'Should return plain text string with AsPlainText' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                if ($script:TestModule) {
                    & $script:TestModule {
                        param($key)
                        $script:CMCApiKeySecure = $key
                    } -ArgumentList (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                }
            }
            
            Set-CMCApiKey -ApiKey 'plain-return-test' -Force
            
            $key = Get-CMCApiKey -AsPlainText
            $key | Should -BeOfType [string]
            $key | Should -Be 'plain-return-test'
        }
    }
    
    Context 'Error Handling' {
        
        It 'Should handle corrupted user profile file gracefully' {
            # Create a corrupted file
            $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
            New-Item -Path $keyPath -ItemType Directory -Force | Out-Null
            
            $keyFile = Join-Path -Path $keyPath -ChildPath 'apikey.xml'
            'This is not valid XML' | Set-Content -Path $keyFile
            
            { Get-CMCApiKey -Scope User -ErrorAction Stop } | Should -Throw "*Failed to retrieve API key from user profile*"
        }
        
        It 'Should handle missing user profile directory' {
            $keyPath = Join-Path -Path $env:APPDATA -ChildPath 'PsCoinMarketCap'
            if (Test-Path $keyPath) {
                Remove-Item -Path $keyPath -Recurse -Force
            }
            
            $key = Get-CMCApiKey -Scope User -ErrorAction SilentlyContinue
            $key | Should -BeNullOrEmpty
        }
    }
    
    Context 'TestConnection Parameter' {
        
        It 'Should include TestConnection parameter' {
            $command = Get-Command Get-CMCApiKey
            $command.Parameters.ContainsKey('TestConnection') | Should -BeTrue
        }
        
        It 'Should warn when TestConnection is used before implementation' {
            # Mock Set-CMCApiKey
            Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
                if ($script:TestModule) {
                    & $script:TestModule {
                        param($key)
                        $script:CMCApiKeySecure = $key
                    } -ArgumentList (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
                }
            }
            
            Set-CMCApiKey -ApiKey 'test-connection-key' -Force
            
            $warnings = @()
            $key = Get-CMCApiKey -TestConnection -WarningVariable warnings -WarningAction SilentlyContinue
            
            $warnings.Count | Should -BeGreaterThan 0
            $warnings[0] | Should -Match "Connection test will be available"
        }
    }
}