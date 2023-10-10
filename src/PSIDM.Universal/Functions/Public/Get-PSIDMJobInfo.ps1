function Get-PSIDMJobInfo {
    <#
    .SYNOPSIS
        Retrieves job information from the PSIDM configuration.

    .DESCRIPTION
        The Get-PSIDMJobInfo function retrieves job information from the PSIDM
        configuration based on the specified criteria.

    .PARAMETER JobId
        The unique identifier (GUID) of the job to retrieve.

    .PARAMETER JobName
        The name of the job to retrieve.

    .PARAMETER JobScript
        The script associated with the job to retrieve.

    .PARAMETER JobPickupFile
        The pickup file associated with the job to retrieve.

    .EXAMPLE
        Get-PSIDMJobInfo -JobId 'a2290ab1-24fa-4677-bea7-8f1427268e37'
        Retrieves job information by JobId.

    .EXAMPLE
        Get-PSIDMJobInfo -JobName 'onboard'
        Retrieves job information by JobName.

    .INPUTS
        None

    .OUTPUTS
        Hashtable
    #>
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param(
        [Parameter(ParameterSetName = 'ById')]
        [guid] $JobId,

        [Parameter(ParameterSetName = 'ByName')]
        [string] $JobName,

        [Parameter(ParameterSetName = 'ByScript')]
        [string] $JobScript,

        [Parameter(ParameterSetName = 'ByPickupFile')]
        [string] $JobPickupFile
    )

    $jobCfg = Get-PSIDMConfig -Path Navigator.JobFileMap

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            $jobInfo = $jobCfg | Where-Object { $_.JobId -eq $JobId }
        }
        'ByName' {
            $jobInfo = $jobCfg | Where-Object { $_.JobName -eq $JobName }
        }
        'ByScript' {
            $jobInfo = $jobCfg | Where-Object { $_.JobScript -eq $JobScript }
        }
        'ByPickupFile' {
            $jobInfo = $jobCfg | Where-Object { $_.JobPickupFile -eq $JobPickupFile }
        }
        'None' {
            Write-Warning "No parameters specified. Returning null."
            return $null
        }
    }

    if ($null -eq $jobInfo) {
        Write-Warning "No job found with the specified criteria. Returning null."
        return $null
    }

    return $jobInfo
}
