function Initialize-PSIDMConfig {
    [CmdletBinding()]
    param(
        [switch] $Force,
        [switch] $PassThru
    )

    process{
        $moduleRoot     = (Resolve-Path ([System.IO.Path]::Combine($PSScriptRoot, '..'))).Path
        $configRoot     = Join-Path $moduleRoot -ChildPath 'conf'
        $resourceRoot   = Join-Path $moduleRoot -ChildPath 'Private\resources'
        $configFileMap  = @{
            'Module'    = Join-Path -Path $configRoot -ChildPath 'config.json'
            'Navigator' = Join-Path -Path $configRoot -ChildPath 'navigator.json'
        }
        Write-Debug "Module root: $moduleRoot"
        Write-Debug "Config root: $configRoot"
        Write-Debug "Resource root: $resourceRoot"

        Write-Debug "Testing existence of $($configFileMap['Module'])"
        if (-not (Test-Path $configFileMap['Module']) -or $Force) {
            Write-Verbose "Module config file ($($configFileMap['Module'])) does not exist, or Initialize-PSIDMConfig called with -Force."
            $moduleCfg = Get-Content (Join-Path $resourceRoot -ChildPath 'config.json.tpl') -Raw | ConvertFrom-Json

            Write-Verbose "Initializing configuration with default values."
            Write-Verbose "Setting up Active Directory configuration using Get-ADDomain."
            try {
                $ADDomain   = Get-ADDomain -ErrorAction Stop
                $moduleCfg.AD.Domain.Name      = $ADDomain.Name
                $moduleCfg.AD.Domain.DNSRoot   = $ADDomain.DNSRoot
            }
            catch {
                Write-Warning "Unable to get Active Directory domain information. Please set the 'AD.Domain' configuration values manually."
                Write-Error "The specific error returned was: $_"
            }

            Write-Verbose "Setting up Paths configuration."
            $moduleCfg.Paths.ModuleRoot    = $moduleRoot
            $moduleCfg.Paths.ConfigRoot    = $configRoot
            $moduleCfg.Paths.PageRoot      = Join-Path $moduleRoot -ChildPath 'Public\pages'
            $moduleCfg.Paths.ScriptRoot    = Join-Path $moduleRoot -ChildPath 'Public\scripts'
            $moduleCfg.Paths.JobRoot       = Join-Path $moduleRoot -ChildPath 'Public\jobs'

            Write-Debug "Writing module configuration to $($configFileMap['Module'])"
            Write-Debug "Module configuration (JSON representation): $($moduleCfg | ConvertTo-Json)"

            try {
                $moduleCfg | ConvertTo-Json | Set-Content -Path $configFileMap['Module'] -Force -ErrorAction Stop
            }
            catch {
                throw "Failed to write Module configuration to $($configFileMap['Module']). Error: $_"
            }

            Write-Warning "Module configuration has been set from default values. Please review the configuration file at $($configFileMap['Module']) and make any necessary changes."
        }


        Write-Debug "Testing existence of $($configFileMap['Navigator'])"
        if (-not (Test-Path $configFileMap['Navigator'])) {
            Write-Verbose "Navigator config file ($($configFileMap['Navigator'])) does not exist, or Initialize-PSIDMConfig called with -Force."
            Write-Verbose "Initializing configuration with default values."
            $navigatorCfg = Get-Content (Join-Path $resourceRoot -ChildPath 'navigator.json.tpl') -Raw | ConvertFrom-Json

            Write-Debug "Writing navigator configuration to $($configFileMap['Navigator'])"
            Write-Debug "Module configuration (JSON representation): $($navigatorCfg | ConvertTo-Json)"

            try {
                $navigatorCfg | ConvertTo-Json | Set-Content -Path $configFileMap['Navigator'] -Force -ErrorAction Stop
            }
            catch {
                throw "Failed to write Navigator configuration to $($configFileMap['Navigator']). Error: $_"
            }
            Write-Warning "Navigator configuration has been set from default values. Please review the configuration file at $($configFileMap['Navigator']) and make any necessary changes."
        }

        $moduleCfg      = Get-Content -Path $configFileMap['Module'] -Raw | ConvertFrom-Json -Depth 10 | ConvertTo-Hashtable -Depth 10
        $navigatorCfg   = Get-Content -Path $configFileMap['Navigator'] -Raw | ConvertFrom-Json -Depth 10 | ConvertTo-Hashtable -Depth 10

        $mergedCfg      = @{
            Module      = $moduleCfg
            Navigator   = $navigatorCfg
        }

        Set-Variable -Scope Script -Name 'PSIDM' -Value $mergedCfg -Force

        if ($PassThru) {
            $Script:PSIDM
        }
    }
}
