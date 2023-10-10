function Get-PSCommonParams {
    <#
    .SYNOPSIS
        Returns a list of PowerShell's common parameters.
    .DESCRIPTION
        Returns a list of PowerShell's common parameters as contained in the
        System.Management.Automation.Internal.CommonParameters class, and adds
        WhatIf and Confirm to the list.
    #>
    $commonParametersType = [System.Management.Automation.Cmdlet].Assembly.GetType("System.Management.Automation.Internal.CommonParameters")
    $commonParametersProperties = $commonParametersType.GetProperties()

    $commonParametersNames = $commonParametersProperties | ForEach-Object { $_.Name }
    $commonParametersNames += 'WhatIf'
    $commonParametersNames += 'Confirm'
    return $commonParametersNames
}