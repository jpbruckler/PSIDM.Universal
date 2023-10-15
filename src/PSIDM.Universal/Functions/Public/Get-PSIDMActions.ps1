function Get-PSIDMActions {
    <#
    .SYNOPSIS
        Gets the action map for the PSIDM module.

    .DESCRIPTION
        The Get-PSIDMActions function retrieves the action map for the PSIDM module.
        The action map is a hashtable that maps action names to their corresponding
        PowerShell scripts.

    .PARAMETER ActionName
        Specifies the name of the action to retrieve. If this parameter is not
        specified, the entire action map is returned.

    .EXAMPLE
        PS C:\> Get-PSIDMActions -ActionName 'CreateUser'
        Returns the PowerShell script for the 'CreateUser' action.

    .EXAMPLE
        PS C:\> Get-PSIDMActions
        Returns the entire action map for the PSIDM module.

    .INPUTS
        None.

    .OUTPUTS
        Hashtable
        If the ActionName parameter is specified, the function returns a hashtable
        that maps the specified action name to its corresponding PowerShell script.
        If the ActionName parameter is not specified, the function returns a
        hashtable that maps all action names to their corresponding PowerShell
        scripts.

    .NOTES
        Author: John Doe
        Date: 01/01/2022
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string] $ActionName
    )

    $moduleRoot     = Get-PSIDMConfig -Path Module.Paths.ModuleRoot
    $actionMapPath  = Join-Path -Path $moduleRoot -ChildPath 'Private\resources\ActionMap.ps1'

    try {
        $actionMap      = . $actionMapPath

        if ($ActionName) {
            if ($ActionMap.ContainsKey($ActionName)) {
                return $actionMap[$ActionName]
            }
            else {
                return $null
            }
        }
        else {
            return $actionMap
        }
    }
    catch {
        throw "Failed to load action map from '$actionMapPath'."
    }
}