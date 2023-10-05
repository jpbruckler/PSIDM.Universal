function Test-PSIDMJobFile {
    <#
    .SYNOPSIS
        Tests a CSV file to ensure it contains the required headers for a job.

    .DESCRIPTION
        The Test-PSIDMJobFile function validates the headers in a given CSV file
        or a list of headers against the required headers for a specific job.

    .PARAMETER Path
        The path to the CSV file to be tested. This parameter is mandatory when
        using the 'File' parameter set.

    .PARAMETER Delimiter
        The delimiter used in the CSV file. Defaults to a comma.

    .PARAMETER Headers
        An array of headers to be tested. This parameter is mandatory when using
        the 'Headers' parameter set.

    .PARAMETER JobId
        The unique identifier for the job. This parameter is mandatory for both
        parameter sets.

    .PARAMETER Detailed
        If specified, the function will return a detailed object containing the
        results of the test. If not specified, the function will return a boolean
        value indicating whether the test passed or failed.

    .EXAMPLE
        Test-PSIDMJobFile -Path "C:\path\to\file.csv" -JobId "a2290ab1-24fa-4677-bea7-8f1427268e37"

    .EXAMPLE
        Test-PSIDMJobFile -Headers @("Header1", "Header2") -JobId "a2290ab1-24fa-4677-bea7-8f1427268e37"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                    ParameterSetName = 'File')]
        [ValidateScript({
            if (-not (Test-Path -Path $_ -PathType Leaf) -and ($_ -notmatch '\.csv$')) {
                throw "The specified path does not exist or is not a CSV file."
            }
            return $true
        })]
        [System.IO.FileInfo] $Path,

        [Parameter(ParameterSetName = 'File')]
        [ValidateLength(1, 1)]
        [string] $Delimiter = ',',

        [Parameter(Mandatory = $true,
                    ParameterSetName = 'Headers')]
        [string[]] $Headers,

        [Parameter(Mandatory = $true,
                    ParameterSetName = 'Headers')]
        [Parameter(Mandatory = $true,
                    ParameterSetName = 'File')]
        [guid] $JobId,
        [switch] $Detailed
    )

    begin {
        $jobInfo = Get-PSIDMJobInfo -JobId $JobId
        if ($null -eq $jobInfo) {
            throw "No job information found for JobId '$JobId'."
        }
    }

    process {
        $DetailedOutput = [PSCustomObject]@{
            'IsValid'           = $null
            'JobId'             = $JobId
            'JobName'           = $jobInfo.JobName
            'RequiredHeaders'   = $jobInfo.RequiredHeaders
            'MissingHeaders'    = $null

        }
        if ($PSCmdlet.ParameterSetName -eq 'File') {
            try {
                $csv = Import-Csv -Path $Path -Delimiter $Delimiter
            }
            catch {
                throw "Error when attempting to import CSV file at '$Path'. Error: $_"
            }
            $headers = $csv[0].PSObject.Properties.Name
        }
        else {
            $headers = $Headers
        }

        $missingHeaders = @()
        foreach ($header in $jobInfo.RequiredHeaders) {
            if ($headers -notcontains $header) {
                $missingHeaders += $header
            }
        }

        if ($missingHeaders.Count -gt 0) {
            $DetailedOutput.IsValid = $false
            $DetailedOutput.MissingHeaders = $missingHeaders
        }
        else {
            $DetailedOutput.IsValid = $true
        }

        if ($Detailed) {
            return $DetailedOutput
        }
        else {
            return $DetailedOutput.IsValid
        }
    }
}