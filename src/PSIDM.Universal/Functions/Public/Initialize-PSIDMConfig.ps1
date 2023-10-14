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
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [switch] $Force,
        [switch] $PassThru
    )

    begin {
        Write-Debug "Initializing PSIDM configuration files with default values."
        $moduleRoot = (Resolve-Path ([System.IO.Path]::Combine($PSScriptRoot, '..', '..'))).Path
        Write-Debug "Module root: $moduleRoot"

        $configFileExists = Test-Path -Path (Join-Path $moduleRoot -ChildPath 'conf\config.json') -PathType leaf
        $jobFileExists = Test-Path -Path (Join-Path $moduleRoot -ChildPath 'conf\jobs.json') -PathType leaf

        # Allow -Force to be used to suppress the confirmation prompt. Otherwise,
        # the user will be prompted to confirm overwriting the existing file, or
        # call the function with -Confirm:$true
        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }
    }

    process {
        $configObject = [ordered] @{
            Version  = '1.0.0'
            AD       = @{
                Domain          = @{
                    Name    = $env:USERDOMAIN
                    DNSRoot = $env:USERDNSDOMAIN
                }
                ReadCredential  = 'PSIDM-ADRead'
                WriteCredential = 'PSIDM-ADWrite'
                AccountDefaults = @{
                    UpnSuffix   = $env:USERDNSDOMAIN
                    EmailDomain = $env:USERDNSDOMAIN
                    Password    = @{
                        Length = 16
                    }
                    UpnFormat   = '{{GivenName}}.{{Surname}}@{{UpnSuffix}}'
                    EmailFormat = '{{GivenName}}.{{Surname}}@{{EmailDomain}}'
                }
            }
            TimeZone = (Get-TimeZone).Id
            Paths    = @{
                ModuleRoot   = $moduleRoot
                ConfigRoot   = Join-Path $moduleRoot -ChildPath 'conf'
                ResourceRoot = Join-Path $moduleRoot -ChildPath 'conf\resources'
                PageRoot     = Join-Path $moduleRoot -ChildPath 'Universal\pages'
                ScriptRoot   = Join-Path $moduleRoot -ChildPath 'Universal\scripts'
                JobRoot      = Join-Path $moduleRoot -ChildPath 'Jobs'
                NotifyRoot   = Join-Path $moduleRoot -ChildPath 'Notification'
                ActionRoot   = Join-Path $moduleRoot -ChildPath 'Universal\Actions'
            }
            SMTP     = @{
                Server         = ''
                Port           = 25
                From           = ''
                UseSSL         = $true
                CredentialName = 'PSIDM-SMTP'
            }
            NetShare = @{
                CredentialName = 'PSIDM-NetShare'
                Path           = '\\server\share'
            }
            LiteDB   = @{
                Path = Join-Path $moduleRoot -ChildPath 'conf\psidm.db'
            }
        }
        $jobObject = [ordered] @{
            Jobs = @{
                JobList = @(
                    [ordered] @{
                        Id             = 'a839b642-c31b-4bb8-8c9e-14cfeebb7cb7'
                        Name           = 'User Offboarding'
                        Description    = 'Offboard designated users.'
                        Script         = 'offboard.ps1'
                        Schedule       = @{
                            Cron       = '0 18 * * *' # Every day at 6pm - https://crontab.guru/#0_18_*_*_*
                            TimeZone   = 'UTC'
                            Credential = 'PSIDM-ADWrite'
                        }
                        CsvPropertyMap = @(
                            @{
                                CsvHeader  = 'EmpDispName'
                                AdProperty = 'DisplayName'
                            },
                            @{
                                CsvHeader  = 'SamAcct'
                                AdProperty = 'SamAccountName'
                            },
                            @{
                                CsvHeader  = 'Upn'
                                AdProperty = 'UserPrincipalName'
                            }
                        )
                    },
                    [ordered] @{
                        Id          = 'a2290ab1-24fa-4677-bea7-8f1427268e37'
                        Name        = 'User Onboarding'
                        Description = 'Onboard designated users.'
                        Script      = 'onboard.ps1'
                        Schedule    = @{
                            Cron       = '0 6 * * *' # Every day at 6am - https://crontab.guru/#0_6_*_*_*
                            TimeZone   = 'UTC'
                            Credential = 'PSIDM-ADWrite'
                        }
                    }
                )
            }
        }

        $configFilePath = Join-Path $configObject.Paths.ConfigRoot -ChildPath 'config.json'
        $jobFilePath = Join-Path $configObject.Paths.ConfigRoot -ChildPath 'jobs.json'

        Write-Debug "Testing existence of $configFilePath and $jobFilePath"
        if ($configFileExists) {
            if ($PSCmdlet.ShouldProcess(
                    ("Overwritting existing file {0}" -f $configFilePath),
                    ("Would you like to overwrite {0}?" -f $configFilePath),
                    "Create File Prompt"
                )
            ) {
                Write-Warning "Configuration file '$configFilePath' already exists. Overwriting with default values."
                $configObject   | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFilePath -Force
            }

        }
        else {
            $configObject   | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFilePath -Force
        }

        if ($jobFileExists) {
            if ($PSCmdlet.ShouldProcess(
                    ("Overwritting existing file {0}" -f $jobFilePath),
                    ("Would you like to overwrite {0}?" -f $jobFilePath),
                    "Create File Prompt"
                )
            ) {
                Write-Warning "Configuration file '$jobFilePath' already exists. Overwriting with default values."
                $jobObject      | ConvertTo-Json -Depth 10 | Out-File -FilePath $jobFilePath -Force
            }

        }
        else {
            $jobObject      | ConvertTo-Json -Depth 10 | Out-File -FilePath $jobFilePath -Force
        }

        Set-Variable -Scope Script -Name 'PSIDM' -Value $configObject -Force

        if ($PassThru) {
            $Script:PSIDM
        }
    }
}