function Import-PSIDMConfig {
    <#
    .SYNOPSIS
        Imports PSIDM configuration files and sets the script-scoped variable
        'PSIDM' to the merged configuration.
    .DESCRIPTION
        The Import-PSIDMConfig function imports the configuration files for the
        PSIDM module and sets the script-scoped variable 'PSIDM' to the merged
        configuration. If the configuration files do not exist, an error will be
        thrown.

        The function will try to leave the existing runtime configuration (stored
        in the script-scoped variable 'PSIDM') intact. If any of the configuration
        values are null, the function will try to set them from the runtime.

        If the -Force switch is used, the runtime configuration files will be
        overwritten with whatever is in the config files.

        The final merged configuration will be returned if the -PassThru switch
        is used.
    .PARAMETER ConfigName
        The configuration file(s) to import. Valid values are 'Module',
        'Navigator', and 'All'. If 'All' is specified, both the 'Module' and
        'Navigator' configuration files will be imported.
    .PARAMETER PassThru
        If specified, the final merged configuration will be returned.
    .PARAMETER Force
        If specified, the runtime configuration variable will be overwritten with
        whatever is in the config files.
    .EXAMPLE
        PS C:\> Import-PSIDMConfig -Config 'Module'
        This will import the 'Module' configuration file and set the script-scoped
        variable 'PSIDM' to the merged configuration.
    .EXAMPLE
        PS C:\> Import-PSIDMConfig -Config 'All'
        This will import both the 'Module' and 'Navigator' configuration files and
        set the script-scoped variable 'PSIDM' to the merged configuration.
    .INPUTS
        None
    .OUTPUTS
        Hashtable
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('Module', 'Navigator', 'All')]
        [string[]] $ConfigName = 'All',
        [switch] $Force,
        [switch] $PassThru
    )

    begin {
        # Assume that the module config is not initialized; but the module has
        # been imported.
        $configFileMap = Get-ConfigFileMap
        Write-Debug -Message "Config file map (JSON representation): $($configFileMap | ConvertTo-Json -Depth 5)"
    }
    process {
        $mergedCfg = @{
            'Module'    = @{  }
            'Navigator' = @{ }
        }

        if ($ConfigName -contains 'All') {
            $ConfigName = @('Module', 'Navigator')
        }

        foreach ($File in $ConfigName) {
            Write-Debug "Checking existence of $($configFileMap[$File])"
            if (-not (Test-Path $configFileMap[$File])) {
                Write-Error "The configuration file '$($configFileMap[$File])' does not exist. Did you forget to call Initialize-PSIDMConfig?."
                continue
            }
            Write-Verbose "Reading configuration from $($configFileMap[$File])"
            $content   = Get-Content -Path $configFileMap[$File] -Raw | ConvertFrom-Json -Depth 10
            Write-Debug "Configuration file '$($configFileMap[$File])' (JSON representation): $($content | ConvertTo-Json -Depth 5)"
            Write-Verbose "Merging configuration file '$($configFileMap[$File])'..."
            $mergedCfg[$File] = $content
        }

        # Throw an exception if no files were found
        if ($mergedCfg.Count -eq 0) {
            $missingFiles = ($configFileMap.Keys | Where-Object { $_ -in @('Module', 'Navigator') } | ForEach-Object { $configFileMap[$_] }) -join ', '
            throw [System.IO.FileNotFoundException] "No configuration files found. Call Initialize-PSIDMConfig to create a new configuration file. If you have already initialized the configuration, make sure the configuration file exists at '$missingFiles'."
        }

        # So now, if any of the merged config values are null, we need to try
        # to set them from the current "runtime" configuration in $Script:PSIDM
        Write-Verbose "Checking for null values in merged configuration..."
        $configFileMap.Keys | ForEach-Object {
            if ($null -eq $mergedCfg[$_]) {
                Write-Verbose "Merged configuration value for '$_' is null. Trying to set from runtime configuration..."
                if ($null -eq $Script:PSIDM[$_]) {
                    Write-Warning "Runtime configuration value for '$_' is null. Please run Initialize-PSIDMConfig to set the configuration value."
                }
                else {
                    Write-Verbose "Setting merged configuration value for '$_' from runtime configuration..."
                    $mergedCfg[$_] = $Script:PSIDM[$_]
                }
            }
        }

        # Now update the current runtime configuration and export to file.
        Write-Verbose "Setting script-scoped variable 'PSIDM'..."
        $mergedCfg | Export-PSIDMConfig -UpdateSession

        if ($PassThru) {
            Write-Verbose "Passing merged configuration to pipeline..."
            $mergedCfg
        }
    }
}