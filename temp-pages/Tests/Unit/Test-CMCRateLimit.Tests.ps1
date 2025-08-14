BeforeAll {
    # Import the module
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Source\PsCoinMarketCap.psd1'
    Import-Module $modulePath -Force
    
    # Get access to private functions
    $module = Get-Module PsCoinMarketCap
}

AfterAll {
    Remove-Module PsCoinMarketCap -Force -ErrorAction SilentlyContinue
}

Describe 'Test-CMCRateLimit' {
    
    BeforeEach {
        # Reset rate limit history
        & $module { 
            $script:CMCRateLimitHistory = @{
                MinuteHistory = [System.Collections.ArrayList]::new()
                DailyHistory = [System.Collections.ArrayList]::new()
                MonthlyTotal = 0
                LastResetDate = [datetime]::Today
                LastResetMonth = [datetime]::Now.Month
                MinuteLimit = 10
                DailyLimit = 333
                MonthlyLimit = 10000
            }
        }
    }
    
    Context 'Reset Functionality' {
        
        It 'Should reset rate limit tracking' {
            # Add some history
            & $module {
                $script:CMCRateLimitHistory.MinuteHistory.Add([datetime]::Now)
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now)
                $script:CMCRateLimitHistory.MonthlyTotal = 100
            }
            
            # Reset
            & $module { Test-CMCRateLimit -Reset }
            
            # Verify reset
            $history = & $module { $script:CMCRateLimitHistory }
            $history.MinuteHistory.Count | Should -Be 0
            $history.DailyHistory.Count | Should -Be 0
            $history.MonthlyTotal | Should -Be 0
        }
    }
    
    Context 'Status Reporting' {
        
        It 'Should return current rate limit status' {
            # Add some usage
            & $module {
                $script:CMCRateLimitHistory.MinuteHistory.Add([datetime]::Now)
                $script:CMCRateLimitHistory.MinuteHistory.Add([datetime]::Now.AddSeconds(-30))
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now)
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now.AddHours(-1))
                $script:CMCRateLimitHistory.MonthlyTotal = 500
            }
            
            $status = & $module { Test-CMCRateLimit -GetStatus }
            
            $status | Should -Not -BeNullOrEmpty
            $status.MinuteUsage | Should -Be 2
            $status.MinuteLimit | Should -Be 10
            $status.MinuteRemaining | Should -Be 8
            $status.DailyUsage | Should -Be 2
            $status.DailyLimit | Should -Be 333
            $status.DailyRemaining | Should -Be 331
            $status.MonthlyUsage | Should -Be 500
            $status.MonthlyLimit | Should -Be 10000
            $status.MonthlyRemaining | Should -Be 9500
        }
    }
    
    Context 'Rate Limit Enforcement' {
        
        It 'Should track requests' {
            $beforeCount = (& $module { $script:CMCRateLimitHistory.MinuteHistory.Count })
            
            & $module { Test-CMCRateLimit }
            
            $afterCount = (& $module { $script:CMCRateLimitHistory.MinuteHistory.Count })
            $afterCount | Should -Be ($beforeCount + 1)
            
            $monthlyTotal = & $module { $script:CMCRateLimitHistory.MonthlyTotal }
            $monthlyTotal | Should -Be 1
        }
        
        It 'Should clean up old minute history' {
            # Add old entries
            & $module {
                $script:CMCRateLimitHistory.MinuteHistory.Add([datetime]::Now.AddSeconds(-70))
                $script:CMCRateLimitHistory.MinuteHistory.Add([datetime]::Now.AddSeconds(-65))
                $script:CMCRateLimitHistory.MinuteHistory.Add([datetime]::Now.AddSeconds(-30))
            }
            
            & $module { Test-CMCRateLimit }
            
            # Old entries should be removed, plus one new entry added
            $history = & $module { $script:CMCRateLimitHistory.MinuteHistory }
            $history.Count | Should -Be 2  # The -30 second one and the new one
        }
        
        It 'Should clean up old daily history' {
            # Add old entries
            & $module {
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now.AddHours(-25))
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now.AddHours(-24).AddMinutes(-1))
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now.AddHours(-12))
            }
            
            & $module { Test-CMCRateLimit }
            
            # Old entries should be removed, plus one new entry added
            $history = & $module { $script:CMCRateLimitHistory.DailyHistory }
            $history.Count | Should -Be 2  # The -12 hour one and the new one
        }
        
        It 'Should delay when minute limit is reached' {
            # Fill up the minute limit
            & $module {
                $now = [datetime]::Now
                for ($i = 0; $i -lt 10; $i++) {
                    $script:CMCRateLimitHistory.MinuteHistory.Add($now.AddSeconds(-30))
                }
            }
            
            # Measure delay
            $startTime = [datetime]::Now
            
            # This should trigger a delay
            $warningReceived = $false
            try {
                & $module { 
                    Test-CMCRateLimit -WarningAction Stop
                }
            }
            catch [System.Management.Automation.ActionPreferenceStopException] {
                $warningReceived = $true
                $_.Exception.Message | Should -Match "Minute rate limit reached"
            }
            
            $warningReceived | Should -BeTrue
        }
        
        It 'Should reset daily counter on new day' {
            # Set last reset to yesterday
            & $module {
                $script:CMCRateLimitHistory.LastResetDate = [datetime]::Today.AddDays(-1)
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now.AddDays(-1))
                $script:CMCRateLimitHistory.DailyHistory.Add([datetime]::Now.AddDays(-1))
            }
            
            & $module { Test-CMCRateLimit }
            
            $history = & $module { $script:CMCRateLimitHistory }
            $history.DailyHistory.Count | Should -Be 1  # Only the new request
            $history.LastResetDate.Date | Should -Be ([datetime]::Today)
        }
        
        It 'Should reset monthly counter on new month' {
            # Set last reset to last month
            & $module {
                $lastMonth = [datetime]::Now.AddMonths(-1)
                $script:CMCRateLimitHistory.LastResetMonth = $lastMonth.Month
                $script:CMCRateLimitHistory.MonthlyTotal = 5000
            }
            
            & $module { Test-CMCRateLimit }
            
            $history = & $module { $script:CMCRateLimitHistory }
            $history.MonthlyTotal | Should -Be 1  # Reset and added one
            $history.LastResetMonth | Should -Be ([datetime]::Now.Month)
        }
        
        It 'Should error when monthly limit is exceeded' {
            # Set monthly total to limit
            & $module {
                $script:CMCRateLimitHistory.MonthlyTotal = 10000
            }
            
            { & $module { Test-CMCRateLimit } } | Should -Throw "*Monthly API limit reached*"
        }
    }
    
    Context 'Warning Thresholds' {
        
        It 'Should warn when approaching minute limit' {
            # Set usage to 80% of limit
            & $module {
                $now = [datetime]::Now
                for ($i = 0; $i -lt 8; $i++) {
                    $script:CMCRateLimitHistory.MinuteHistory.Add($now.AddSeconds(-30))
                }
            }
            
            # Should see verbose warning (not error)
            $verboseOutput = & $module { Test-CMCRateLimit -Verbose } 4>&1
            $verboseOutput | Where-Object { $_ -match "Approaching minute rate limit" } | Should -Not -BeNullOrEmpty
        }
        
        It 'Should warn when approaching daily limit' {
            # Set usage to 80% of limit
            & $module {
                $now = [datetime]::Now
                for ($i = 0; $i -lt 267; $i++) {  # 80% of 333
                    $script:CMCRateLimitHistory.DailyHistory.Add($now.AddHours(-1))
                }
            }
            
            $warningReceived = $false
            try {
                & $module { 
                    Test-CMCRateLimit -WarningAction Stop
                }
            }
            catch [System.Management.Automation.ActionPreferenceStopException] {
                $warningReceived = $true
                $_.Exception.Message | Should -Match "Approaching daily rate limit"
            }
            
            $warningReceived | Should -BeTrue
        }
        
        It 'Should warn when approaching monthly limit' {
            # Set usage to 80% of limit
            & $module {
                $script:CMCRateLimitHistory.MonthlyTotal = 8000
            }
            
            $warningReceived = $false
            try {
                & $module { 
                    Test-CMCRateLimit -WarningAction Stop
                }
            }
            catch [System.Management.Automation.ActionPreferenceStopException] {
                $warningReceived = $true
                $_.Exception.Message | Should -Match "Approaching monthly rate limit"
            }
            
            $warningReceived | Should -BeTrue
        }
    }
}