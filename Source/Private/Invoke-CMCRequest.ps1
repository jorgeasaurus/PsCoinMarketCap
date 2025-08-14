function Invoke-CMCRequest {
    <#
    .SYNOPSIS
        Makes HTTP requests to the CoinMarketCap API with authentication and error handling.
    
    .DESCRIPTION
        This is the core function that handles all API requests to CoinMarketCap. It manages:
        - Authentication header injection
        - Rate limiting and retry logic
        - Error handling and response validation
        - Automatic deserialization of JSON responses
        
        This is a private function and should not be called directly by users.
    
    .PARAMETER Endpoint
        The API endpoint path (without base URL). Example: "/cryptocurrency/listings/latest"
    
    .PARAMETER Method
        The HTTP method to use. Default is GET.
    
    .PARAMETER Parameters
        Hashtable of query parameters to include in the request.
    
    .PARAMETER Body
        Request body for POST/PUT requests.
    
    .PARAMETER MaxRetries
        Maximum number of retry attempts for rate-limited or failed requests. Default is 3.
    
    .PARAMETER RetryDelay
        Initial delay in milliseconds between retry attempts. Uses exponential backoff.
    
    .EXAMPLE
        Invoke-CMCRequest -Endpoint "/cryptocurrency/listings/latest" -Parameters @{ limit = 10 }
        
        Makes a GET request to retrieve the latest cryptocurrency listings.
    
    .NOTES
        This function is for internal use only.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Endpoint,
        
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE')]
        [string]$Method = 'GET',
        
        [Parameter()]
        [hashtable]$Parameters = @{},
        
        [Parameter()]
        [object]$Body,
        
        [Parameter()]
        [ValidateRange(0, 10)]
        [int]$MaxRetries = 3,
        
        [Parameter()]
        [ValidateRange(100, 10000)]
        [int]$RetryDelay = 1000
    )
    
    begin {
        Write-Verbose "Preparing CoinMarketCap API request to: $Endpoint"
        
        # Get API key
        $apiKey = Get-CMCApiKey -AsPlainText -ErrorAction Stop
        if (-not $apiKey) {
            throw "No API key configured. Use Set-CMCApiKey to configure authentication."
        }
        
        # Determine base URL
        # Initialize URLs if not set (fallback)
        if (-not $script:CMCBaseUrl) {
            $script:CMCBaseUrl = 'https://pro-api.coinmarketcap.com/v1'
        }
        if (-not $script:CMCSandboxUrl) {
            $script:CMCSandboxUrl = 'https://sandbox-api.coinmarketcap.com/v1'
        }
        
        if ($script:CMCUseSandbox) {
            $baseUrl = $script:CMCSandboxUrl
            Write-Verbose "Using sandbox environment: $baseUrl"
        }
        else {
            $baseUrl = $script:CMCBaseUrl
            Write-Verbose "Using production environment: $baseUrl"
        }
        
        # Ensure endpoint starts with /
        if (-not $Endpoint.StartsWith('/')) {
            $Endpoint = "/$Endpoint"
        }
        
        # Build full URL
        $baseUri = "$baseUrl$Endpoint"
        Write-Verbose "Base URI: $baseUri"
        
        # Add query parameters
        if ($Parameters.Count -gt 0) {
            # Load Web assembly for URL encoding if needed
            Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue
            
            $queryString = @()
            foreach ($key in $Parameters.Keys) {
                # Use Uri.EscapeDataString as a fallback if HttpUtility is not available
                $value = try {
                    [System.Web.HttpUtility]::UrlEncode($Parameters[$key].ToString())
                } catch {
                    [Uri]::EscapeDataString($Parameters[$key].ToString())
                }
                $queryString += "$key=$value"
            }
            $queryPart = $queryString -join '&'
            $uri = "${baseUri}?${queryPart}"
            Write-Verbose "Query string: $queryPart"
        }
        else {
            $uri = $baseUri
        }
        
        Write-Verbose "Full request URI: $uri"
    }
    
    process {
        # Implement rate limiting
        $now = [datetime]::Now
        $timeSinceLastRequest = ($now - $script:CMCLastRequestTime).TotalMilliseconds
        
        if ($timeSinceLastRequest -lt $script:CMCRequestDelay) {
            $waitTime = $script:CMCRequestDelay - $timeSinceLastRequest
            Write-Verbose "Rate limiting: Waiting $waitTime ms before request"
            Start-Sleep -Milliseconds $waitTime
        }
        
        # Prepare request headers
        $headers = @{
            'X-CMC_PRO_API_KEY' = $apiKey
            'Accept' = 'application/json'
            'Accept-Encoding' = 'deflate, gzip'
        }
        
        if ($Body) {
            $headers['Content-Type'] = 'application/json'
        }
        
        # Prepare request parameters for Invoke-RestMethod
        $requestParams = @{
            Uri = $uri
            Method = $Method
            Headers = $headers
            ErrorAction = 'Stop'
            UseBasicParsing = $true
        }
        
        if ($Body) {
            if ($Body -is [hashtable] -or $Body -is [PSCustomObject]) {
                $requestParams['Body'] = $Body | ConvertTo-Json -Depth 10
            }
            else {
                $requestParams['Body'] = $Body
            }
        }
        
        # Execute request with retry logic
        $attempt = 0
        $currentDelay = $RetryDelay
        
        while ($attempt -le $MaxRetries) {
            $attempt++
            
            try {
                Write-Verbose "Attempt $attempt of $($MaxRetries + 1)"
                
                # Make the request
                $response = Invoke-RestMethod @requestParams
                
                # Update last request time
                $script:CMCLastRequestTime = [datetime]::Now
                
                # Check response status
                if ($response.status) {
                    if ($response.status.error_code -ne 0) {
                        # API returned an error
                        $errorMessage = "CoinMarketCap API Error [$($response.status.error_code)]: $($response.status.error_message)"
                        
                        # Check if it's a rate limit error
                        if ($response.status.error_code -eq 1008 -or $response.status.error_code -eq 429) {
                            if ($attempt -le $MaxRetries) {
                                Write-Warning "Rate limit exceeded. Retrying in $currentDelay ms..."
                                Start-Sleep -Milliseconds $currentDelay
                                $currentDelay = $currentDelay * 2  # Exponential backoff
                                continue
                            }
                        }
                        
                        throw $errorMessage
                    }
                    
                    # Log credit usage if available
                    if ($response.status.credit_count) {
                        Write-Verbose "API credits used: $($response.status.credit_count)"
                    }
                }
                
                # Return the data portion of the response
                if ($response.data) {
                    Write-Verbose "Request successful, returning data"
                    return $response.data
                }
                else {
                    Write-Verbose "Request successful, returning full response"
                    return $response
                }
            }
            catch [System.Net.WebException] {
                $statusCode = $_.Exception.Response.StatusCode.value__
                $statusDescription = $_.Exception.Response.StatusDescription
                
                Write-Verbose "HTTP Error $statusCode : $statusDescription"
                
                # Handle specific HTTP errors
                switch ($statusCode) {
                    401 { 
                        throw "Authentication failed. Please check your API key."
                    }
                    403 { 
                        throw "Access forbidden. Your API key may not have access to this endpoint."
                    }
                    429 {
                        # Rate limited
                        if ($attempt -le $MaxRetries) {
                            Write-Warning "Rate limit (HTTP 429) exceeded. Retrying in $currentDelay ms..."
                            Start-Sleep -Milliseconds $currentDelay
                            $currentDelay = $currentDelay * 2
                            continue
                        }
                        throw "Rate limit exceeded. Please try again later."
                    }
                    500 {
                        # Server error - retry
                        if ($attempt -le $MaxRetries) {
                            Write-Warning "Server error (HTTP 500). Retrying in $currentDelay ms..."
                            Start-Sleep -Milliseconds $currentDelay
                            $currentDelay = $currentDelay * 2
                            continue
                        }
                        throw "CoinMarketCap server error. Please try again later."
                    }
                    {$_ -in 502, 503, 504} {
                        # Gateway errors - retry
                        if ($attempt -le $MaxRetries) {
                            Write-Warning "Gateway error (HTTP $statusCode). Retrying in $currentDelay ms..."
                            Start-Sleep -Milliseconds $currentDelay
                            $currentDelay = $currentDelay * 2
                            continue
                        }
                        throw "CoinMarketCap service temporarily unavailable."
                    }
                    default {
                        throw "HTTP Error $statusCode : $statusDescription"
                    }
                }
            }
            catch {
                # Generic error
                if ($attempt -le $MaxRetries) {
                    Write-Warning "Request failed: $_. Retrying in $currentDelay ms..."
                    Start-Sleep -Milliseconds $currentDelay
                    $currentDelay = $currentDelay * 2
                    continue
                }
                
                throw $_
            }
        }
        
        # If we get here, all retries failed
        throw "Failed to complete request after $($MaxRetries + 1) attempts"
    }
    
    end {
        # Clear API key from memory
        if ($apiKey) {
            Clear-Variable -Name apiKey -Force
        }
        
        Write-Verbose "Invoke-CMCRequest completed"
    }
}