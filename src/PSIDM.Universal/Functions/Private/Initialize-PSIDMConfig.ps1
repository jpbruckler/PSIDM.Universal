function Initialize-PSIDMConfig {
    <#
    .SYNOPSIS
        Initializes the PSIDM configuration files with default values.
    .DESCRIPTION
        The Initialize-PSIDMConfig function initializes the PSIDM configuration
        files with default values. If the configuration files already exist, the
        function will throw an error unless the -Force switch is used.

        If the configuration files do not exist, the function will initialize them
        from templates in Private\resources.
    .PARAMETER Force
        If specified, any existing configuration files will be overwritten with
        the values generated by this function.
    .PARAMETER PassThru
        If specified, the final merged configuration will be returned to the
        caller.
    .EXAMPLE
        PS C:\> Initialize-PSIDMConfig -Force
        This will initialize the PSIDM configuration files with default values.
    .INPUTS
        None
    .OUTPUTS
        Hashtable
    .NOTES
        Currently tightly coupled with the Get-ConfigFileMap function. If more
        config files are added, this function will need to be updated.
    #>
    [CmdletBinding()]
    param(
        [switch] $Force,
        [switch] $PassThru
    )

    process{
        # @TODO: Decouple this from Get-ConfigFileMap. Convention over configuration,
        #        config file defaults are always in Private\resources, so can this
        #        be done a little more dynamically?
        $moduleRoot = (Resolve-Path ([System.IO.Path]::Combine($PSScriptRoot, '..','..'))).Path
        Write-Debug "Module root: $moduleRoot"

        try {
            $ADDomain   = Get-ADDomain -ErrorAction Stop
        }
        catch {
            throw "Unable to get AD domain information, module import failed. Error: $_"
        }

        $configObject  = @{
            Module  = @{
                AD      = @{
                    Domain  = @{
                        Name    = $ADDomain.Name
                        DNSRoot = $ADDomain.DNSRoot
                    }
                    DefaultUPNSuffix    = $ADDomain.DNSRoot
                    DefaultEmailDomain  = $ADDomain.DNSRoot
                }
                TimeZone    = (Get-TimeZone).Id
                Paths   = @{
                    ModuleRoot      = $moduleRoot
                    ConfigRoot      = Join-Path $moduleRoot -ChildPath 'conf'
                    ResourceRoot    = Join-Path $moduleRoot -ChildPath 'conf\resources'
                    PageRoot        = Join-Path $moduleRoot -ChildPath 'Universal\pages'
                    ScriptRoot      = Join-Path $moduleRoot -ChildPath 'Universal\scripts'
                    JobRoot         = Join-Path $moduleRoot -ChildPath 'Jobs'
                    NotifyRoot      = Join-Path $moduleRoot -ChildPath 'Notification'
                }
            }
            Jobs    = @{
                JobList = @(
                    @{
                        Id          = 'a839b642-c31b-4bb8-8c9e-14cfeebb7cb7'
                        Name        = 'User Offboarding'
                        Description = 'Offboard designated users.'
                        Script      = 'offboard.ps1'
                        Schedule    = @{
                            Cron        = '0 18 * * *' # Every day at 6pm - https://crontab.guru/#0_18_*_*_*
                            TimeZone    = 'UTC'
                            Credential  = 'PSIDM-ADWrite'
                        }
                        CsvPropertyMap = @(
                            @{
                                CsvHeader   = 'EmpDispName'
                                AdProperty  = 'DisplayName'
                            },
                            @{
                                CsvHeader   = 'SamAcct'
                                AdProperty  = 'SamAccountName'
                            },
                            @{
                                CsvHeader   = 'Upn'
                                AdProperty  = 'UserPrincipalName'
                            }
                        )
                    },
                    @{
                        Id          = 'a2290ab1-24fa-4677-bea7-8f1427268e37'
                        Name        = 'User Onboarding'
                        Description = 'Onboard designated users.'
                        Script      = 'onboard.ps1'
                        Schedule    = @{
                            Cron        = '0 6 * * *' # Every day at 6am - https://crontab.guru/#0_6_*_*_*
                            TimeZone    = 'UTC'
                            Credential  = 'PSIDM-ADWrite'
                        }
                    }
                )
            }
        }

        Write-Debug "Testing existence of $($configObject.Module.Paths.ConfigRoot)\config.json"
        if (Test-Path -Path "$($configObject.Module.Paths.ConfigRoot)\config.json" -PathType Leaf) {
            if ($Force) {
                Write-Warning "Configuration file already exists. Overwriting with default values."
            }
            else {
                throw "Configuration file already exists. Use -Force to overwrite."
            }
        }

        $configObject.Module | ConvertTo-Json -Depth 10 | Out-File -FilePath "$($configObject.Module.Paths.ConfigRoot)\config.json" -Force
        $configObject.Jobs | ConvertTo-Json -Depth 10 | Out-File -FilePath "$($configObject.Module.Paths.ConfigRoot)\jobs.json" -Force
        Set-Variable -Scope Script -Name 'PSIDM' -Value $configObject -Force

        if ($PassThru) {
            $Script:PSIDM
        }
    }
}
