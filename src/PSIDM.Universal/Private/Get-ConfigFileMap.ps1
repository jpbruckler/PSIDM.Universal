function Get-ConfigFileMap {
    <#
    .SYNOPSIS
        Returns a hashtable of configuration file paths used by the module.
    .DESCRIPTION
        The Get-ConfigFileMap function returns a hashtable of configuration file
        paths used by the module. The hashtable is keyed by the configuration
        name, and the value is the path to the configuration file.
    .EXAMPLE
        PS C:\> Get-ConfigFileMap
        This will return a hashtable of configuration file paths used by the
        module.
    .INPUTS
        None
    .OUTPUTS
        Hashtable
    #>
    $configRoot = Join-Path -Path (Resolve-Path ([System.IO.Path]::Combine($PSScriptRoot, '..'))) -ChildPath 'conf'
    Write-Debug -Message "Config root: $configRoot"
    $configFileMap = @{
        'Module'    = Join-Path -Path $configRoot -ChildPath 'config.json'
        'Navigator' = Join-Path -Path $configRoot -ChildPath 'navigator.json'
    }

    return $configFileMap
}