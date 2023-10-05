function Get-PSCommonParams {
    $commonParametersType = [System.Management.Automation.Cmdlet].Assembly.GetType("System.Management.Automation.Internal.CommonParameters")
    $commonParametersProperties = $commonParametersType.GetProperties()

    $commonParametersNames = $commonParametersProperties | ForEach-Object { $_.Name }
    $commonParametersNames += 'WhatIf'
    $commonParametersNames += 'Confirm'
    return $commonParametersNames
}