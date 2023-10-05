param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({
        if (-not (Test-Path -Path $_ -PathType Leaf)) {
            throw "The specified path does not exist or is not a file."
        }
        if ($_ -notmatch '\.csv$') {
            throw "The specified path is not a CSV file."
        }
        return $true
    })]
    [System.IO.FileInfo] $Path,

    [ValidateLength(1, 1)]
    [string] $Delimiter = ','
)

$csv        = Import-Csv -Path $Path -Delimiter $Delimiter
$navigator  = Get-PSIDMConfig -Path Navigator.JobFileMap
$pickupFile = $Path.BaseName.toLower()
$jobInfo    = $navigator.Jobs | Where-Object { $_.JobPickupFile -eq $pickupFile }
$JobFile    = (Split-Path $PSCommandPath -Leaf).ToLower() # This is the name of the current file

if (($null -eq $jobInfo) -or ($jobInfo.JobScript -ne $JobFile)) {
    throw "No job information found for pickup file '$path'."
}

# Check that the CSV file contains the required headers
$validHeaders = Test-PSIDMJobFile -Headers $csv[0].PSObject.Properties.Name -JobId $jobInfo.JobId -Detailed
if ($validHeaders.IsValid -eq $false) {
    throw "The CSV file at '$Path' does not contain the required headers for job '$($jobInfo.JobName)'. Required headers: $($jobInfo.RequiredHeaders -join ', ') Missing headers: $($validHeaders.MissingHeaders -join ', ')"
}

