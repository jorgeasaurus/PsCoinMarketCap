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
    
    # Mock response data
    $script:MockListingsResponse = @(
        [PSCustomObject]@{
            id = 1
            name = 'Bitcoin'
            symbol = 'BTC'
            slug = 'bitcoin'
            cmc_rank = 1
            num_market_pairs = 1000
            circulating_supply = 19000000
            total_supply = 21000000
            max_supply = 21000000
            last_updated = '2024-01-01T00:00:00.000Z'
            date_added = '2013-04-28T00:00:00.000Z'
            tags = @('mineable', 'pow')
            quote = [PSCustomObject]@{
                USD = @{
                    price = 50000
                    volume_24h = 1000000000
                    percent_change_1h = 0.5
                    percent_change_24h = 2.5
                    percent_change_7d = 10.0
                    market_cap = 950000000000
                    last_updated = '2024-01-01T00:00:00.000Z'
                }
            }
        }
        [PSCustomObject]@{
            id = 1027
            name = 'Ethereum'
            symbol = 'ETH'
            slug = 'ethereum'
            cmc_rank = 2
            num_market_pairs = 800
            circulating_supply = 120000000
            total_supply = 120000000
            max_supply = $null
            last_updated = '2024-01-01T00:00:00.000Z'
            date_added = '2015-08-07T00:00:00.000Z'
            tags = @('smart-contracts', 'ethereum')
            quote = [PSCustomObject]@{
                USD = @{
                    price = 3000
                    volume_24h = 500000000
                    percent_change_1h = 0.3
                    percent_change_24h = 1.5
                    percent_change_7d = 8.0
                    market_cap = 360000000000
                    last_updated = '2024-01-01T00:00:00.000Z'
                }
            }
        }
    )
}

AfterAll {
    Remove-Module PsCoinMarketCap -Force -ErrorAction SilentlyContinue
}

Describe 'Get-CMCListings' {
    
    BeforeEach {
        # Mock Set-CMCApiKey to avoid security module issues
        Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
            $script:CMCApiKeySecure = ConvertTo-SecureString -String 'test-api-key' -AsPlainText -Force
        }
        
        # Set a mock API key
        Set-CMCApiKey -ApiKey 'test-api-key' -Scope Session
        
        # Mock the internal request function
        Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
            return $script:MockListingsResponse
        }
    }
    
    Context 'Basic Functionality' {
        
        It 'Should retrieve cryptocurrency listings' {
            $result = Get-CMCListings
            
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].name | Should -Be 'Bitcoin'
            $result[1].name | Should -Be 'Ethereum'
        }
        
        It 'Should include flattened quote properties' {
            $result = Get-CMCListings
            
            $result[0].USD_price | Should -Be 50000
            $result[0].USD_volume_24h | Should -Be 1000000000
            $result[0].USD_percent_change_24h | Should -Be 2.5
            $result[0].USD_market_cap | Should -Be 950000000000
        }
        
        It 'Should add custom type for formatting' {
            $result = Get-CMCListings
            
            $result[0].PSObject.TypeNames | Should -Contain 'PsCoinMarketCap.Cryptocurrency'
        }
    }
    
    Context 'Parameter Handling' {
        
        It 'Should pass limit parameter correctly' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.limit | Should -Be 50
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -Limit 50
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should pass sort parameters correctly' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.sort | Should -Be 'volume_24h'
                $Parameters.sort_dir | Should -Be 'asc'
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -Sort 'volume_24h' -SortDirection 'asc'
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should handle price filters' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.price_min | Should -Be 100
                $Parameters.price_max | Should -Be 1000
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -PriceMin 100 -PriceMax 1000
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should handle market cap filters' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.market_cap_min | Should -Be 1000000000
                $Parameters.market_cap_max | Should -Be 10000000000
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -MarketCapMin 1000000000 -MarketCapMax 10000000000
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should handle multiple convert currencies' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.convert | Should -Be 'USD,EUR,BTC'
                return @(
                    [PSCustomObject]@{
                        id = 1
                        name = 'Test'
                        symbol = 'TEST'
                        quote = [PSCustomObject]@{
                            USD = @{ price = 100 }
                            EUR = @{ price = 85 }
                            BTC = @{ price = 0.002 }
                        }
                    }
                )
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -Convert @('USD', 'EUR', 'BTC')
            
            $result[0].USD_price | Should -Be 100
            $result[0].EUR_price | Should -Be 85
            $result[0].BTC_price | Should -Be 0.002
        }
        
        It 'Should handle cryptocurrency type filter' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.cryptocurrency_type | Should -Be 'tokens'
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -CryptocurrencyType 'tokens'
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should handle tag filter' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.tag | Should -Be 'defi,filesharing'
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -Tag @('defi', 'filesharing')
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should handle aux parameter' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.aux | Should -Be 'num_market_pairs,cmc_rank,date_added'
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -Aux @('num_market_pairs', 'cmc_rank', 'date_added')
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
    }
    
    Context 'Error Handling' {
        
        It 'Should handle API errors gracefully' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                throw "API Error: Invalid request"
            }
            
            { Get-CMCListings -ErrorAction Stop } | Should -Throw "*Failed to get cryptocurrency listings*"
        }
        
        It 'Should handle empty responses' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                return @()
            }
            
            $result = Get-CMCListings
            
            $result | Should -BeNullOrEmpty
        }
        
        It 'Should handle malformed response data' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                return @(
                    [PSCustomObject]@{
                        id = 1
                        name = 'Malformed'
                        # Missing quote data
                    }
                )
            }
            
            $result = Get-CMCListings
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].name | Should -Be 'Malformed'
            $result[0].USD_price | Should -BeNullOrEmpty
        }
    }
    
    Context 'Default Values' {
        
        It 'Should use default parameters' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.start | Should -Be 1
                $Parameters.limit | Should -Be 100
                $Parameters.sort | Should -Be 'market_cap'
                $Parameters.sort_dir | Should -Be 'desc'
                $Parameters.cryptocurrency_type | Should -Be 'all'
                $Parameters.convert | Should -Be 'USD'
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
    }
    
    Context 'Pagination' {
        
        It 'Should handle pagination with start parameter' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.start | Should -Be 101
                $Parameters.limit | Should -Be 100
                return $script:MockListingsResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCListings -Start 101 -Limit 100
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
    }
}