function Initialize-PSIDMConfig {
    [CmdletBinding()]
    param(
        [switch] $Force
    )

    process{
        $ModuleRoot = (Split-Path -Parent -Path $script:MyInvocation.MyCommand.Path)
        $ConfigRoot = (Join-Path $ModuleRoot -ChildPath 'conf')
        $ConfigPath = Join-Path $ConfigRoot -ChildPath 'config.json'

        $Config = @{
            'Paths' = @{
                'ModuleRoot' = $ModuleRoot
                'ConfigRoot' = $ConfigRoot
                'ScriptRoot' = (Join-Path $ModuleRoot -ChildPath 'Public\scripts')
                'PageRoot'   = (Join-Path $ModuleRoot -ChildPath 'Public\pages')
                'JobRoot'    = (Join-Path $ModuleRoot -ChildPath 'Public\jobs')
            }

            'AD'    = @{
                'Domain' = @{
                    Name    = ''
                    DNSRoot = ''
                }
            }

            'SMTP'  = @{
                'Server'        = ''
                'Port'          = 25
                'PSUCredential' = ''
                'From'          = ''
            }
        }

        if (-not (Test-Path $ConfigPath) -or $Force) {
            $ADDomain = Get-ADDomain

            $Config.AD.Domain.Name = $ADDomain.Name
            $Config.AD.Domain.DNSRoot = $ADDomain.DNSRoot
            $config | ConvertTo-Json -Depth 10 | Out-File -FilePath $ConfigPath -Force
        }
        else {
            $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json -Depth 10
        }

        $config = $config | ConvertTo-HashTable -Depth 10
        Set-Variable -Scope Script -Name 'PSIDM' -Value $config -Force
    }
}
