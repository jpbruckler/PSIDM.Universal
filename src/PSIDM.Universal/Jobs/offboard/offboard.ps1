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
$navigator  = Get-PSIDMConfig -Path Jobs.JobList
$pickupFile = $Path.Name.toLower()
$jobInfo    = $navigator | Where-Object { $_.JobPickupFile -eq $pickupFile }
$JobFile    = (Split-Path $PSCommandPath -Leaf).ToLower() # This is the name of the current file
Write-Information -MessageData "Job file: $JobFile" -InformationAction Continue
Write-Information -MessageData "Pickup file: $pickupFile" -InformationAction Continue
Write-Information -MessageData "Job info: $($jobInfo | convertto-json)" -InformationAction Continue
Write-Information -MessageData "CSV headers: $($csv[0].PSObject.Properties.Name -join ', ')" -InformationAction Continue

if (($null -eq $jobInfo) -or ($jobInfo.JobScript -ne $JobFile)) {
    throw "No job information found for pickup file '$path'."
}

# Check that the CSV file contains the required headers
$validHeaders = Test-PSIDMJobFile -Headers $csv[0].PSObject.Properties.Name -JobId $jobInfo.JobId -Detailed
if ($validHeaders.IsValid -eq $false) {
    throw "The CSV file at '$Path' does not contain the required headers for job '$($jobInfo.JobName)'. Required headers: $($jobInfo.RequiredHeaders -join ', ') Missing headers: $($validHeaders.MissingHeaders -join ', ')"
}

# TODO: Implement pre-process logic

foreach ($item in $csv) {
    $user = $item | ConvertTo-PSIDMObject -AdPropertyMap $jobInfo.AdPropertyMap

    # Check that $user has the required attributes to find the AD object based
    # on the requirements for the -Identity property of Get-ADUser
    # See: https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser?view=winserver2012r2-ps
    $idProps = @('SamAccountName','DN', 'DistinguishedName', 'SID', 'ObjectGUID')
    $idProp = $idProps | Where-Object { $user.ContainsKey($_) } | Select-Object -First 1
    if ($null -eq $idProp) {
        throw "The user object does not contain any of the required properties to find the AD object. Required properties: $($idProps -join ', ')"
    }

    try {
        $adUser = Get-ADUser -Identity $user[$idProp] -Properties * -ErrorAction SilentlyContinue
    }
    catch {
        throw "Failed to find AD user with $idProp '$($user[$idProp])'."
    }

    if ($null -eq $jobInfo.Actions) {
        # No actions defined. Just disable the user.
        # check for an OU called 'Disabled Users'
        $jobInfo.Actions += @{
            'ActionName' = 'Disable'
        }
    }

    foreach ($action in $jobInfo.Actions) {
        Invoke-PSIDMAction -Action $action.ActionName -ADObject $adUser -JobInfo $jobInfo
    }
}

# TODO: Implement post-process logic
