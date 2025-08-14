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
    
    # Mock the ProcessCryptoQuote helper function
    function global:ProcessCryptoQuote {
        param([PSCustomObject]$Crypto)
        
        # Add custom type for formatting
        $Crypto.PSObject.TypeNames.Insert(0, 'PsCoinMarketCap.CryptocurrencyQuote')
        
        # Add calculated properties for easier access
        if ($Crypto.quote) {
            foreach ($currency in $Crypto.quote.PSObject.Properties.Name) {
                $quote = $Crypto.quote.$currency
                
                # Flatten quote properties for easier access
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_price" -NotePropertyValue $quote.price -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_volume_24h" -NotePropertyValue $quote.volume_24h -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_volume_change_24h" -NotePropertyValue $quote.volume_change_24h -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_1h" -NotePropertyValue $quote.percent_change_1h -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_24h" -NotePropertyValue $quote.percent_change_24h -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_7d" -NotePropertyValue $quote.percent_change_7d -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_percent_change_30d" -NotePropertyValue $quote.percent_change_30d -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_market_cap" -NotePropertyValue $quote.market_cap -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_market_cap_dominance" -NotePropertyValue $quote.market_cap_dominance -Force
                Add-Member -InputObject $Crypto -NotePropertyName "${currency}_fully_diluted_market_cap" -NotePropertyValue $quote.fully_diluted_market_cap -Force
            }
        }
        
        # Output the cryptocurrency object
        Write-Output $Crypto
    }
    
    # Mock response data
    $script:MockQuotesResponse = [PSCustomObject]@{
        BTC = [PSCustomObject]@{
            id = 1
            name = 'Bitcoin'
            symbol = 'BTC'
            slug = 'bitcoin'
            is_active = 1
            is_fiat = 0
            circulating_supply = 19000000
            total_supply = 21000000
            max_supply = 21000000
            date_added = '2013-04-28T00:00:00.000Z'
            num_market_pairs = 1000
            cmc_rank = 1
            last_updated = '2024-01-01T00:00:00.000Z'
            tags = @('mineable', 'pow')
            quote = [PSCustomObject]@{
                USD = [PSCustomObject]@{
                    price = 50000
                    volume_24h = 1000000000
                    volume_change_24h = 10.5
                    percent_change_1h = 0.5
                    percent_change_24h = 2.5
                    percent_change_7d = 10.0
                    percent_change_30d = 20.0
                    market_cap = 950000000000
                    market_cap_dominance = 55
                    fully_diluted_market_cap = 1050000000000
                    last_updated = '2024-01-01T00:00:00.000Z'
                }
            }
        }
        ETH = [PSCustomObject]@{
            id = 1027
            name = 'Ethereum'
            symbol = 'ETH'
            slug = 'ethereum'
            is_active = 1
            is_fiat = 0
            circulating_supply = 120000000
            total_supply = 120000000
            max_supply = $null
            date_added = '2015-08-07T00:00:00.000Z'
            num_market_pairs = 800
            cmc_rank = 2
            last_updated = '2024-01-01T00:00:00.000Z'
            tags = @('smart-contracts')
            quote = [PSCustomObject]@{
                USD = [PSCustomObject]@{
                    price = 3000
                    volume_24h = 500000000
                    volume_change_24h = 8.2
                    percent_change_1h = 0.3
                    percent_change_24h = 1.5
                    percent_change_7d = 8.0
                    percent_change_30d = 15.0
                    market_cap = 360000000000
                    market_cap_dominance = 20
                    fully_diluted_market_cap = 360000000000
                    last_updated = '2024-01-01T00:00:00.000Z'
                }
            }
        }
    }
}

AfterAll {
    Remove-Module PsCoinMarketCap -Force -ErrorAction SilentlyContinue
}

Describe 'Get-CMCQuotes' {
    
    BeforeEach {
        # Mock Set-CMCApiKey to avoid security module issues
        Mock Set-CMCApiKey -ModuleName PsCoinMarketCap {
            $script:CMCApiKeySecure = ConvertTo-SecureString -String 'test-api-key' -AsPlainText -Force
        }
        
        # Set a mock API key
        Set-CMCApiKey -ApiKey 'test-api-key' -Scope Session
        
        # Mock the internal request function
        Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
            return $script:MockQuotesResponse
        }
    }
    
    Context 'Symbol Parameter Set' {
        
        It 'Should get quotes by symbol' {
            $result = Get-CMCQuotes -Symbol 'BTC','ETH'
            
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].symbol | Should -BeIn @('BTC', 'ETH')
            $result[1].symbol | Should -BeIn @('BTC', 'ETH')
        }
        
        It 'Should convert symbols to uppercase' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.symbol | Should -Be 'BTC,ETH'
                return $script:MockQuotesResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Symbol 'btc','eth'
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
        
        It 'Should accept pipeline input for symbols' {
            $symbols = 'BTC','ETH'
            $result = $symbols | Get-CMCQuotes
            
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
        }
        
        It 'Should handle single symbol' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                return [PSCustomObject]@{ BTC = $script:MockQuotesResponse.BTC }
            }
            
            $result = Get-CMCQuotes -Symbol 'BTC'
            
            $result | Should -Not -BeNullOrEmpty
            $result.symbol | Should -Be 'BTC'
        }
    }
    
    Context 'ID Parameter Set' {
        
        It 'Should get quotes by ID' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.id | Should -Be '1,1027'
                return $script:MockQuotesResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Id 1,1027
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
            $result.Count | Should -Be 2
        }
        
        It 'Should accept pipeline input for IDs' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                return [PSCustomObject]@{ '1' = $script:MockQuotesResponse.BTC }
            }
            
            $id = 1
            $result = $id | Get-CMCQuotes -Id { $_ }
            
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Slug Parameter Set' {
        
        It 'Should get quotes by slug' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.slug | Should -Be 'bitcoin,ethereum'
                return $script:MockQuotesResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Slug 'bitcoin','ethereum'
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
            $result.Count | Should -Be 2
        }
        
        It 'Should convert slugs to lowercase' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.slug | Should -Be 'bitcoin'
                return @{ bitcoin = $script:MockQuotesResponse.BTC }
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Slug 'BITCOIN'
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
    }
    
    Context 'Convert Parameter' {
        
        It 'Should handle multiple convert currencies' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.convert | Should -Be 'USD,EUR,BTC'
                return [PSCustomObject]@{
                    TEST = [PSCustomObject]@{
                        id = 1
                        symbol = 'TEST'
                        quote = [PSCustomObject]@{
                            USD = [PSCustomObject]@{ price = 100 }
                            EUR = [PSCustomObject]@{ price = 85 }
                            BTC = [PSCustomObject]@{ price = 0.002 }
                        }
                    }
                }
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Symbol 'TEST' -Convert 'USD','EUR','BTC'
            
            $result.USD_price | Should -Be 100
            $result.EUR_price | Should -Be 85
            $result.BTC_price | Should -Be 0.002
        }
        
        It 'Should default to USD' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.convert | Should -Be 'USD'
                return $script:MockQuotesResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Symbol 'BTC'
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
    }
    
    Context 'Aux Parameter' {
        
        It 'Should pass aux parameters correctly' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.aux | Should -Be 'num_market_pairs,cmc_rank,circulating_supply'
                return $script:MockQuotesResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Symbol 'BTC' -Aux 'num_market_pairs','cmc_rank','circulating_supply'
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
    }
    
    Context 'SkipInvalid Parameter' {
        
        It 'Should handle skip invalid flag' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                $Parameters.skip_invalid | Should -Be 'false'
                return $script:MockQuotesResponse
            } -ParameterFilter { $Parameters }
            
            $result = Get-CMCQuotes -Symbol 'BTC' -SkipInvalid $false
            
            Should -Invoke Invoke-CMCRequest -ModuleName PsCoinMarketCap -Times 1
        }
    }
    
    Context 'Output Processing' {
        
        It 'Should flatten quote properties' {
            $result = Get-CMCQuotes -Symbol 'BTC'
            
            $result[0] | Should -Not -BeNullOrEmpty
            $result[0].USD_price | Should -Be 50000
            $result[0].USD_volume_24h | Should -Be 1000000000
            $result[0].USD_percent_change_24h | Should -Be 2.5
            $result[0].USD_market_cap | Should -Be 950000000000
        }
        
        It 'Should add custom type for formatting' {
            $result = Get-CMCQuotes -Symbol 'BTC'
            
            $result[0].PSObject.TypeNames | Should -Contain 'PsCoinMarketCap.CryptocurrencyQuote'
        }
        
        It 'Should handle array response for same symbol' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                return [PSCustomObject]@{
                    BTC = @(
                        $script:MockQuotesResponse.BTC,
                        $script:MockQuotesResponse.BTC
                    )
                }
            }
            
            $result = Get-CMCQuotes -Symbol 'BTC'
            
            $result.Count | Should -Be 2
            $result[0].symbol | Should -Be 'BTC'
            $result[1].symbol | Should -Be 'BTC'
        }
    }
    
    Context 'Error Handling' {
        
        It 'Should handle API errors gracefully' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                throw "API Error: Invalid symbol"
            }
            
            { Get-CMCQuotes -Symbol 'INVALID' -ErrorAction Stop } | Should -Throw "*Failed to get cryptocurrency quotes*"
        }
        
        It 'Should handle empty responses' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                return @{}
            }
            
            $result = Get-CMCQuotes -Symbol 'BTC'
            
            $result | Should -BeNullOrEmpty
        }
        
        It 'Should handle malformed response data' {
            Mock Invoke-CMCRequest -ModuleName PsCoinMarketCap {
                return [PSCustomObject]@{
                    BTC = [PSCustomObject]@{
                        id = 1
                        symbol = 'BTC'
                        # Missing quote data
                    }
                }
            }
            
            $result = Get-CMCQuotes -Symbol 'BTC'
            
            $result | Should -Not -BeNullOrEmpty
            $result.symbol | Should -Be 'BTC'
            $result.USD_price | Should -BeNullOrEmpty
        }
    }
}