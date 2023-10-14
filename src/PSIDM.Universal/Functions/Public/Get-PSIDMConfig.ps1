function Get-PSIDMConfig {
    <#
        .SYNOPSIS
        Retrieves PSIDM configuration values.

        .DESCRIPTION
        The Get-PSIDMConfig function retrieves specific or all configuration variables
        stored in the script-scoped variable PSIDM. The PSIDM variable is a hashtable
        that represents the configuration settings of the PSIDM.Universal module.

        .PARAMETER FullPath
        Specifies the full path of the configuration setting to retrieve.
        The path should be specified as a dot-separated string representing the
        hierarchy of keys in the hashtable.

        For example, to get the Domain Name under the "AD" key, you would specify
        'AD.Domain.Name'. If this parameter is not provided, the function returns
        the entire PSIDM hashtable.

        .EXAMPLE
        Get-PSIDMConfig -FullPath 'Paths.PageRoot'

        This example retrieves the value of the "PageRoot" under the "Paths" key
        in the PSIDM hashtable.

        .EXAMPLE
        Get-PSIDMConfig

        This example retrieves the entire PSIDM hashtable.

        .NOTES
        If the specified path does not exist in the PSIDM hashtable, the function
        returns $null.

        .INPUTS
        None

        .OUTPUTS
        System.Object
        null
    #>
    param(
        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string] $FullPath
    )

    if (-not $Script:PSIDM) {
        try {
            $CurrentRuntime = Import-PSIDMConfig -PassThru
        }
        catch {
            throw "Unable to import PSIDM configuration. Error: $_"
        }
    }
    else {
        $CurrentRuntime = $Script:PSIDM
    }

    if ([string]::IsNullOrEmpty($FullPath)) {
        return $Script:PSIDM
    }
    else {
        $keys  = $FullPath.Split('.')
        $value = $CurrentRuntime
        foreach ($key in $keys) {
            if ($null -ne $value.$key) {
                $value = $value.$key
            }
            else {
                return $null
            }
        }
        return $value
    }
}