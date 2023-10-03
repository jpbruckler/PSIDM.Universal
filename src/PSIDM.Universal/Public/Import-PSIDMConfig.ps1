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

        The final merged configuration will be returned if the -PassThru switch
        is used.
    .PARAMETER ConfigName
        The configuration file(s) to import. Valid values are 'Module',
        'Navigator', and 'All'. If 'All' is specified, both the 'Module' and
        'Navigator' configuration files will be imported.
    .PARAMETER PassThru
        If specified, the final merged configuration will be returned.
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
        [string[]] $ConfigName,
        [switch] $PassThru
    )

    begin {
        # Assume that the module config is not initialized; but the module has
        # been imported.
        $configRoot = Join-Path -Path (Resolve-Path ([System.IO.Path]::Combine($PSScriptRoot, '..'))) -ChildPath 'conf'
        Write-Debug -Message "Config root: $configRoot"
        $configFileMap = @{
            'Module'    = Join-Path -Path $configRoot -ChildPath 'config.json'
            'Navigator' = Join-Path -Path $configRoot -ChildPath 'navigator.json'
        }
        Write-Debug -Message "Config file map (JSON representation): $($configFileMap | ConvertTo-Json)"
    }
    process {
        $mergedCfg = @{}

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
            $content   = Get-Content -Path $configFileMap[$File] -Raw | ConvertFrom-Json -Depth 10 | ConvertTo-Hashtable -Depth 10

            Write-Verbose "Merging configuration file '$($configFileMap[$File])'..."
            $mergedCfg = Merge-Object -Objects $mergedCfg, $content
        }

        # Throw an exception if no files were found
        if ($mergedCfg.Count -eq 0) {
            $missingFiles = ($configFileMap.Keys | Where-Object { $_ -in @('Module', 'Navigator') } | ForEach-Object { $configFileMap[$_] }) -join ', '
            throw [System.IO.FileNotFoundException] "No configuration files found. Call Initialize-PSIDMConfig to create a new configuration file. If you have already initialized the configuration, make sure the configuration file exists at '$missingFiles'."
        }

        # Set the script-scoped config variable
        Write-Verbose "Setting script-scoped variable 'PSIDM'..."
        Set-Variable -Scope Script -Name 'PSIDM' -Value $mergedCfg -Force

        if ($PassThru) {
            Write-Verbose "Passing merged configuration to pipeline..."
            $mergedCfg
        }
    }
}