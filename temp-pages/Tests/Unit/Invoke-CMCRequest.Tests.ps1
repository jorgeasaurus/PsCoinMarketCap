BeforeAll {
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
    
    # Get access to private functions
    $module = Get-Module PsCoinMarketCap
    $moduleScope = $module.Invoke({ $ExecutionContext.SessionState })
    
    # Mock data for testing
    $script:MockApiResponse = @{
        status = @{
            timestamp = '2024-01-01T00:00:00.000Z'
            error_code = 0
            error_message = $null
            elapsed = 10
            credit_count = 1
        }
        data = @(
            @{
                id = 1
                name = 'Bitcoin'
                symbol = 'BTC'
                price = 50000
            }
        )
    }
    
    $script:MockErrorResponse = @{
        status = @{
            timestamp = '2024-01-01T00:00:00.000Z'
            error_code = 401
            error_message = 'Invalid API key'
            elapsed = 0
            credit_count = 0
        }
    }
}

AfterAll {
    Remove-Module PsCoinMarketCap -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-CMCRequest' {
    
    BeforeAll {
        # Mock Import-Module to prevent TypeData errors
        Mock Import-Module -ModuleName PsCoinMarketCap {}
    }
    
    BeforeEach {
        # Mock Set-CMCApiKey to avoid security module issues
        Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
            $script:CMCApiKeySecure = ConvertTo-SecureString -String 'test-api-key-12345' -AsPlainText -Force
        }
        
        # Set a mock API key
        Set-CMCApiKey -ApiKey 'test-api-key-12345' -Scope Session
        
        # Reset rate limit tracking
        & (Get-Module PsCoinMarketCap) { 
            $script:CMCLastRequestTime = [datetime]::MinValue
            $script:CMCRequestDelay = 0  # No delay for tests
        }
    }
    
    Context 'Successful Requests' {
        
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                return $script:MockApiResponse
            }
        }
        
        It 'Should make a successful GET request' {
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
            }
            
            $result | Should -Not -BeNullOrEmpty
            $result.name | Should -Be 'Bitcoin'
            
            Should -Invoke Invoke-RestMethod -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should include API key in headers' {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                $Headers['X-CMC_PRO_API_KEY'] | Should -Be 'test-api-key-12345'
                return $script:MockApiResponse
            } -ParameterFilter { $Headers }
            
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
            }
            
            Should -Invoke Invoke-RestMethod -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should build correct URL with parameters' {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                $Uri | Should -Match 'https://pro-api.coinmarketcap.com/v1/test'
                $Uri | Should -Match 'limit=10'
                $Uri | Should -Match 'convert=USD'
                return $script:MockApiResponse
            } -ParameterFilter { $Uri }
            
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint '/test' -Parameters @{
                    limit = 10
                    convert = 'USD'
                }
            }
            
            Should -Invoke Invoke-RestMethod -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should use sandbox URL when configured' {
            & (Get-Module PsCoinMarketCap) { $script:CMCUseSandbox = $true }
            
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                $Uri | Should -Match 'https://sandbox-api.coinmarketcap.com/v1'
                return $script:MockApiResponse
            } -ParameterFilter { $Uri }
            
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
            }
            
            Should -Invoke Invoke-RestMethod -ModuleName PsCoinMarketCap -Times 1
            
            & (Get-Module PsCoinMarketCap) { $script:CMCUseSandbox = $false }
        }
    }
    
    Context 'Error Handling' {
        
        It 'Should handle 401 authentication errors' {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [System.Net.WebException]::new('Authentication failed'),
                    'WebException',
                    [System.Management.Automation.ErrorCategory]::AuthenticationError,
                    $null
                )
                $errorDetails = @{
                    Response = @{
                        StatusCode = [System.Net.HttpStatusCode]::Unauthorized
                    }
                }
                $errorRecord | Add-Member -NotePropertyName 'ErrorDetails' -NotePropertyValue $errorDetails -Force
                throw $errorRecord
            }
            
            { 
                & (Get-Module PsCoinMarketCap) { 
                    Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
                }
            } | Should -Throw
        }
        
        It 'Should retry on rate limit errors' {
            $script:callCount = 0
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                $script:callCount++
                if ($script:callCount -lt 3) {
                    $errorResponse = @{
                        status = @{
                            error_code = 429
                            error_message = 'Rate limit exceeded'
                        }
                    }
                    throw [System.Exception]::new(($errorResponse | ConvertTo-Json))
                }
                return $script:MockApiResponse
            }
            
            # Set shorter retry delay for testing
            & (Get-Module PsCoinMarketCap) { $script:CMCRequestDelay = 100 }
            
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint '/test' -Parameters @{} -RetryDelay 100
            }
            
            $result | Should -Not -BeNullOrEmpty
            $script:callCount | Should -Be 3
        }
        
        It 'Should handle API error responses' {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                return @{
                    status = @{
                        error_code = 1002
                        error_message = 'Invalid parameter'
                    }
                }
            }
            
            { 
                & (Get-Module PsCoinMarketCap) { 
                    Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
                }
            } | Should -Throw "*Invalid parameter*"
        }
        
        It 'Should fail after max retries' {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                throw [System.Exception]::new("Network error")
            }
            
            { 
                & (Get-Module PsCoinMarketCap) { 
                    Invoke-CMCRequest -Endpoint '/test' -Parameters @{} -MaxRetries 2 -RetryDelay 100
                }
            } | Should -Throw "*Network error*"
            
            Should -Invoke Invoke-RestMethod -ModuleName PsCoinMarketCap -Times 3
        }
    }
    
    Context 'Rate Limiting' {
        
        BeforeEach {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                return $script:MockApiResponse
            }
        }
        
        It 'Should track last request time' {
            $beforeTime = [datetime]::Now
            
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
            }
            
            $lastRequestTime = & (Get-Module PsCoinMarketCap) { $script:CMCLastRequestTime }
            $lastRequestTime | Should -BeGreaterThan $beforeTime
        }
        
        It 'Should enforce request delay' {
            & (Get-Module PsCoinMarketCap) { 
                $script:CMCRequestDelay = 100
                $script:CMCLastRequestTime = [datetime]::Now
            }
            
            $startTime = [datetime]::Now
            
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
            }
            
            $elapsed = ([datetime]::Now - $startTime).TotalMilliseconds
            $elapsed | Should -BeGreaterOrEqual 90  # Allow some tolerance
        }
    }
    
    Context 'Parameter Validation' {
        
        It 'Should require an endpoint' {
            { 
                & (Get-Module PsCoinMarketCap) { 
                    Invoke-CMCRequest -Endpoint '' -Parameters @{}
                }
            } | Should -Throw
        }
        
        It 'Should require API key to be set' {
            # Clear the API key
            & (Get-Module PsCoinMarketCap) { 
                $script:CMCApiKeySecure = $null
            }
            
            { 
                & (Get-Module PsCoinMarketCap) { 
                    Invoke-CMCRequest -Endpoint '/test' -Parameters @{}
                }
            } | Should -Throw "*No CoinMarketCap API key found*"
        }
        
        It 'Should normalize endpoint with leading slash' {
            Mock Invoke-RestMethod -ModuleName PsCoinMarketCap {
                $Uri | Should -Match '/test'
                return $script:MockApiResponse
            } -ParameterFilter { $Uri }
            
            $result = & (Get-Module PsCoinMarketCap) { 
                Invoke-CMCRequest -Endpoint 'test' -Parameters @{}
            }
            
            Should -Invoke Invoke-RestMethod -ModuleName PsCoinMarketCap -Times 1
        }
    }
}