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

        If the -Force switch is used and the configuration files do not exist,
        they will be initialized with default values.

        The final merged configuration will be returned if the -PassThru switch
        is used.
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
        This will import both the 'Module' and 'Jobs' configuration files and
        set the script-scoped variable 'PSIDM' to the merged configuration.
    .INPUTS
        None
    .OUTPUTS
        Hashtable
    #>
    [CmdletBinding()]
    param(
        [switch] $Force,
        [switch] $PassThru
    )

    begin {
        # Assume that the module config is not initialized; but the module has
        # been imported.
        $configRoot = Join-Path -Path (Resolve-Path ([System.IO.Path]::Combine($PSScriptRoot, '..', '..'))) -ChildPath 'conf'
        Write-Debug -Message "Config root: $configRoot"
    }
    process {
        $configFile = Join-Path $configRoot -ChildPath 'config.json'
        $jobFile    = Join-Path $configRoot -ChildPath 'jobs.json'
        Write-Debug -Message "Config file: $configFile"
        Write-Debug -Message "Job file: $jobFile"

        # Check if config.json file exists.
        #   - If file doesn't exist and -Force is used, initialize with default values.
        #   - If file doesn't exist and -Force is not used, throw an error.
        #   - If file exists and -Force is used, overwrite with default values.
        if (-not (Test-Path -Path $configFile) -or ($Force)) {
            Write-Warning "-Force switch used or config file does not exist. Initializing with default values."
            Initialize-PSIDMConfig -Force
        }
        elseif (-not (Test-Path -Path $configFile)) {
            Write-Debug "Configuration file not found. Use -Force to initialize with default values."
            throw [System.IO.FileNotFoundException] "Configuration file not found. Use -Force to initialize with default values."
        }
        else {
            Write-Debug "Configuration file found. Importing..."

            Write-Verbose "Importing configuration file '$configFile'..."
            $moduleCfg = Get-Content -Path $configFile -Raw | ConvertFrom-Json -Depth 10 | ConvertTo-Hashtable -Depth 10

            Write-Verbose "Importing configuration file '$jobFile'..."
            $jobCfg = Get-Content -Path $jobFile -Raw | ConvertFrom-Json -Depth 10 | ConvertTo-Hashtable -Depth 10

            Write-Verbose "Merging configuration files..."
            $mergedCfg = @{
                Module  = $moduleCfg
                Jobs    = $jobCfg
            }

            Write-Debug "Merged configuration: $mergedCfg"
        }
        # Now update the current runtime configuration and export to file.
        Write-Verbose "Setting script-scoped variable 'PSIDM'..."
        Set-Variable -Scope Script -Name 'PSIDM' -Value $mergedCfg -Force

        if ($PassThru) {
            Write-Verbose "Passing merged configuration to pipeline..."
            $mergedCfg
        }
    }
}