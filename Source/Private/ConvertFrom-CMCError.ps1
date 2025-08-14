function ConvertFrom-CMCError {
    <#
    .SYNOPSIS
        Converts CoinMarketCap API error responses into structured error objects.
    
    .DESCRIPTION
        This private function processes error responses from the CoinMarketCap API and 
        converts them into PowerShell error records with detailed information for debugging.
    
    .PARAMETER ErrorResponse
        The error response object from the API.
    
    .PARAMETER StatusCode
        The HTTP status code of the error response.
    
    .PARAMETER Endpoint
        The API endpoint that generated the error.
    
    .EXAMPLE
        ConvertFrom-CMCError -ErrorResponse $response -StatusCode 401 -Endpoint "/cryptocurrency/listings/latest"
    
    .NOTES
        This is a private helper function for internal use only.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$ErrorResponse,
        
        [Parameter()]
        [int]$StatusCode,
        
        [Parameter()]
        [string]$Endpoint
    )
    
    begin {
        Write-Verbose "Processing CoinMarketCap API error"
    }
    
    process {
        # Initialize error details
        $errorDetails = @{
            ErrorCode = $null
            ErrorMessage = 'Unknown error'
            ErrorCategory = 'NotSpecified'
            RecommendedAction = $null
            Endpoint = $Endpoint
            StatusCode = $StatusCode
        }
        
        # Parse error response
        if ($ErrorResponse) {
            if ($ErrorResponse.status) {
                $errorDetails.ErrorCode = $ErrorResponse.status.error_code
                $errorDetails.ErrorMessage = $ErrorResponse.status.error_message
                
                # Add credit count if available
                if ($ErrorResponse.status.credit_count) {
                    $errorDetails.CreditsUsed = $ErrorResponse.status.credit_count
                }
            }
            elseif ($ErrorResponse.error) {
                $errorDetails.ErrorMessage = $ErrorResponse.error
            }
            elseif ($ErrorResponse -is [string]) {
                $errorDetails.ErrorMessage = $ErrorResponse
            }
        }
        
        # Map error codes to categories and recommendations
        switch ($errorDetails.ErrorCode) {
            400 {
                $errorDetails.ErrorCategory = 'InvalidArgument'
                $errorDetails.RecommendedAction = 'Check your request parameters for validity.'
            }
            401 {
                $errorDetails.ErrorCategory = 'AuthenticationError'
                $errorDetails.ErrorMessage = 'API key is invalid or missing'
                $errorDetails.RecommendedAction = 'Verify your API key is correct and active. Use Set-CMCApiKey to update it.'
            }
            402 {
                $errorDetails.ErrorCategory = 'QuotaExceeded'
                $errorDetails.ErrorMessage = 'Payment required - account subscription expired or credits exhausted'
                $errorDetails.RecommendedAction = 'Check your CoinMarketCap account subscription status.'
            }
            403 {
                $errorDetails.ErrorCategory = 'PermissionDenied'
                $errorDetails.ErrorMessage = 'Access forbidden - endpoint not available for your subscription'
                $errorDetails.RecommendedAction = 'This endpoint may require a higher tier subscription plan.'
            }
            429 {
                $errorDetails.ErrorCategory = 'LimitsExceeded'
                $errorDetails.ErrorMessage = 'Rate limit exceeded'
                $errorDetails.RecommendedAction = 'Reduce request frequency or upgrade your plan for higher limits.'
            }
            500 {
                $errorDetails.ErrorCategory = 'ConnectionError'
                $errorDetails.ErrorMessage = 'Internal server error at CoinMarketCap'
                $errorDetails.RecommendedAction = 'This is a temporary issue. Please try again later.'
            }
            1001 {
                $errorDetails.ErrorCategory = 'InvalidArgument'
                $errorDetails.ErrorMessage = 'Invalid request format'
                $errorDetails.RecommendedAction = 'Review the API documentation for correct parameter format.'
            }
            1002 {
                $errorDetails.ErrorCategory = 'InvalidArgument'
                $errorDetails.ErrorMessage = 'Invalid parameter value'
                $errorDetails.RecommendedAction = 'Check that all parameter values are within acceptable ranges.'
            }
            1003 {
                $errorDetails.ErrorCategory = 'InvalidArgument'
                $errorDetails.ErrorMessage = 'Required parameter missing'
                $errorDetails.RecommendedAction = 'Ensure all required parameters are provided.'
            }
            1004 {
                $errorDetails.ErrorCategory = 'ResourceUnavailable'
                $errorDetails.ErrorMessage = 'Resource not found'
                $errorDetails.RecommendedAction = 'The requested cryptocurrency or resource does not exist.'
            }
            1005 {
                $errorDetails.ErrorCategory = 'PermissionDenied'
                $errorDetails.ErrorMessage = 'Forbidden - API key does not have permission'
                $errorDetails.RecommendedAction = 'Your API key lacks permission for this endpoint.'
            }
            1006 {
                $errorDetails.ErrorCategory = 'InvalidArgument'
                $errorDetails.ErrorMessage = 'Invalid result count requested'
                $errorDetails.RecommendedAction = 'Adjust the limit parameter to be within acceptable range.'
            }
            1007 {
                $errorDetails.ErrorCategory = 'InvalidArgument'
                $errorDetails.ErrorMessage = 'Invalid start value'
                $errorDetails.RecommendedAction = 'The start parameter must be a positive integer.'
            }
            1008 {
                $errorDetails.ErrorCategory = 'LimitsExceeded'
                $errorDetails.ErrorMessage = 'Minute rate limit exceeded'
                $errorDetails.RecommendedAction = 'Wait before making more requests or upgrade your plan.'
            }
            1009 {
                $errorDetails.ErrorCategory = 'LimitsExceeded'
                $errorDetails.ErrorMessage = 'Daily rate limit exceeded'
                $errorDetails.RecommendedAction = 'Daily limit reached. Requests will reset tomorrow or upgrade your plan.'
            }
            1010 {
                $errorDetails.ErrorCategory = 'LimitsExceeded'
                $errorDetails.ErrorMessage = 'Monthly rate limit exceeded'
                $errorDetails.RecommendedAction = 'Monthly limit reached. Upgrade your plan for more requests.'
            }
            1011 {
                $errorDetails.ErrorCategory = 'LimitsExceeded'
                $errorDetails.ErrorMessage = 'IP rate limit exceeded'
                $errorDetails.RecommendedAction = 'Too many requests from this IP address. Please wait before retrying.'
            }
        }
        
        # Create error record
        $exception = New-Object System.Exception($errorDetails.ErrorMessage)
        $errorRecord = New-Object System.Management.Automation.ErrorRecord(
            $exception,
            "CMC.$($errorDetails.ErrorCode)",
            $errorDetails.ErrorCategory,
            $Endpoint
        )
        
        # Add error details to error record
        $errorRecord.ErrorDetails = @"
CoinMarketCap API Error $($errorDetails.ErrorCode): $($errorDetails.ErrorMessage)
Endpoint: $($errorDetails.Endpoint)
HTTP Status: $($errorDetails.StatusCode)
$($errorDetails.RecommendedAction)
"@
        
        return $errorRecord
    }
    
    end {
        Write-Verbose "ConvertFrom-CMCError completed"
    }
}