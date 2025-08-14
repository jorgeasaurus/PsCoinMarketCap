BeforeAll {
    # Import test helpers
    . (Join-Path $PSScriptRoot '..' 'TestHelpers.ps1')
    
    # Import the module
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Source\PsCoinMarketCap.psd1'
    Import-Module $modulePath -Force
    
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
    
    # Mock Import-Module to prevent TypeData errors
    Mock Import-Module -ModuleName PsCoinMarketCap {}
    
    # Store original module variables
    $script:OriginalApiKey = $script:CMCApiKeySecure
    $script:OriginalUseSandbox = $script:CMCUseSandbox
}

AfterAll {
    # Restore original module variables
    $script:CMCApiKeySecure = $script:OriginalApiKey
    $script:CMCUseSandbox = $script:OriginalUseSandbox
    
    # Clean up test files
    $testKeyPath = Join-Path -Path (Get-TestConfigPath) -ChildPath 'PsCoinMarketCap'
    if (Test-Path $testKeyPath) {
        Remove-Item -Path $testKeyPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Remove-Module PsCoinMarketCap -Force -ErrorAction SilentlyContinue
}

Describe 'Set-CMCApiKey' {
    
    BeforeAll {
        # Mock Get-CMCApiKey for tests that check existing keys
        Mock Get-CMCApiKey -ModuleName PsCoinMarketCap {
            param($AsPlainText, $Scope)
            if ($AsPlainText) {
                # Return plain text based on what was set
                if ($script:CMCApiKeySecure) {
                    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($script:CMCApiKeySecure)
                    try {
                        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                    }
                    finally {
                        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                    }
                }
                return $null
            }
            return $script:CMCApiKeySecure
        }
    }
    
    BeforeEach {
        # Clear module variables before each test
        $script:CMCApiKeySecure = $null
        $script:CMCUseSandbox = $false
        
        # Clean up any existing test files
        $testKeyPath = Join-Path -Path (Get-TestConfigPath) -ChildPath 'PsCoinMarketCap'
        if (Test-Path $testKeyPath) {
            Remove-Item -Path $testKeyPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Context 'Parameter Validation' {
        
        It 'Should accept a string API key' {
            { Set-CMCApiKey -ApiKey 'test-api-key-123' } | Should -Not -Throw
        }
        
        It 'Should accept a SecureString API key' {
            $secureKey = ConvertTo-SecureString -String 'test-api-key-456' -AsPlainText -Force
            { Set-CMCApiKey -ApiKey $secureKey } | Should -Not -Throw
        }
        
        It 'Should reject empty API key' {
            { Set-CMCApiKey -ApiKey '' } | Should -Throw
        }
        
        It 'Should reject null API key' {
            { Set-CMCApiKey -ApiKey $null } | Should -Throw
        }
        
        It 'Should accept valid scope values' {
            { Set-CMCApiKey -ApiKey 'test-key' -Scope Session } | Should -Not -Throw
            { Set-CMCApiKey -ApiKey 'test-key' -Scope User } | Should -Not -Throw
        }
    }
    
    Context 'Session Scope Storage' {
        
        It 'Should store API key in session by default' {
            Set-CMCApiKey -ApiKey 'session-test-key'
            
            # Get the module and check the variable
            $module = Get-Module PsCoinMarketCap
            $keySet = & $module { $script:CMCApiKeySecure }
            $keySet | Should -Not -BeNullOrEmpty
            $keySet | Should -BeOfType [System.Security.SecureString]
        }
        
        It 'Should set sandbox mode when specified' {
            Set-CMCApiKey -ApiKey 'sandbox-test-key' -UseSandbox
            
            # Get the module and check the variable
            $module = Get-Module PsCoinMarketCap
            $sandboxSet = & $module { $script:CMCUseSandbox }
            $sandboxSet | Should -BeTrue
        }
        
        It 'Should not set sandbox mode by default' {
            Set-CMCApiKey -ApiKey 'production-test-key'
            
            $script:CMCUseSandbox | Should -BeFalse
        }
        
        It 'Should overwrite existing session key with Force' {
            Set-CMCApiKey -ApiKey 'first-key'
            Set-CMCApiKey -ApiKey 'second-key' -Force
            
            # Verify the key was updated (we can't directly compare SecureStrings)
            $key = Get-CMCApiKey -AsPlainText
            $key | Should -Be 'second-key'
        }
    }
    
    Context 'User Scope Storage' {
        
        It 'Should create storage directory if it does not exist' {
            $keyPath = Join-Path -Path (Get-TestConfigPath) -ChildPath 'PsCoinMarketCap'
            $keyPath | Should -Not -Exist
            
            Set-CMCApiKey -ApiKey 'user-test-key' -Scope User
            
            $keyPath | Should -Exist
        }
        
        It 'Should save API key to file in user profile' {
            Set-CMCApiKey -ApiKey 'persistent-test-key' -Scope User
            
            $keyFile = Join-Path -Path (Get-TestConfigPath) -ChildPath 'PsCoinMarketCap\apikey.xml'
            $keyFile | Should -Exist
        }
        
        It 'Should save sandbox preference to file when enabled' {
            Set-CMCApiKey -ApiKey 'sandbox-user-key' -Scope User -UseSandbox
            
            $sandboxFile = Join-Path -Path (Get-TestConfigPath) -ChildPath 'PsCoinMarketCap\sandbox.txt'
            $sandboxFile | Should -Exist
            Get-Content $sandboxFile | Should -Be 'true'
        }
        
        It 'Should remove sandbox file when disabled' {
            # First set with sandbox
            Set-CMCApiKey -ApiKey 'sandbox-key' -Scope User -UseSandbox
            $sandboxFile = Join-Path -Path (Get-TestConfigPath) -ChildPath 'PsCoinMarketCap\sandbox.txt'
            $sandboxFile | Should -Exist
            
            # Then set without sandbox
            Set-CMCApiKey -ApiKey 'production-key' -Scope User -Force
            $sandboxFile | Should -Not -Exist
        }
        
        It 'Should update session variables when setting user scope' {
            Set-CMCApiKey -ApiKey 'user-session-key' -Scope User -UseSandbox
            
            # Get the module and check the variables
            $module = Get-Module PsCoinMarketCap
            $keySet = & $module { $script:CMCApiKeySecure }
            $sandboxSet = & $module { $script:CMCUseSandbox }
            $keySet | Should -Not -BeNullOrEmpty
            $sandboxSet | Should -BeTrue
        }
    }
    
    Context 'Security' {
        
        It 'Should store API key as SecureString' {
            Set-CMCApiKey -ApiKey 'secure-test-key'
            
            # Get the module and check the variable
            $module = Get-Module PsCoinMarketCap
            $keySet = & $module { $script:CMCApiKeySecure }
            $keySet | Should -BeOfType [System.Security.SecureString]
        }
        
        It 'Should encrypt API key when saving to file' {
            Set-CMCApiKey -ApiKey 'encrypted-test-key' -Scope User
            
            $keyFile = Join-Path -Path (Get-TestConfigPath) -ChildPath 'PsCoinMarketCap\apikey.xml'
            $content = Get-Content $keyFile -Raw
            
            # The file should contain XML with encrypted data
            $content | Should -Match '<Objs'
            $content | Should -Match 'PSCredential'
            $content | Should -Not -Match 'encrypted-test-key'  # Plain text should not be visible
        }
    }
    
    Context 'Pipeline Support' {
        
        It 'Should accept API key from pipeline' {
            'pipeline-test-key' | Set-CMCApiKey
            
            $key = Get-CMCApiKey -AsPlainText
            $key | Should -Be 'pipeline-test-key'
        }
        
        It 'Should accept SecureString from pipeline' {
            $secureKey = ConvertTo-SecureString -String 'secure-pipeline-key' -AsPlainText -Force
            $secureKey | Set-CMCApiKey
            
            $key = Get-CMCApiKey -AsPlainText
            $key | Should -Be 'secure-pipeline-key'
        }
    }
    
    Context 'WhatIf Support' {
        
        It 'Should support WhatIf parameter' {
            $script:CMCApiKeySecure = $null
            
            Set-CMCApiKey -ApiKey 'whatif-test-key' -WhatIf
            
            # Key should not be set when using WhatIf
            $script:CMCApiKeySecure | Should -BeNullOrEmpty
        }
    }
}