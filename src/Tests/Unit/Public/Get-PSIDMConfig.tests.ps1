#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'PSIDM.Universal'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope PSIDM.Universal {
    BeforeAll {
        # Mocking config file contents
        $cfg = @{
            Paths = @{
                PageRoot   = "C:\PageRoot"
                ScriptRoot = "C:\ScriptRoot"
                ConfigRoot = "C:\ConfigRoot"
                ModuleRoot = "C:\ModuleRoot"
            }
            AD = @{
                Domain = @{
                    Name    = "contoso"
                    DNSRoot = "contoso.com"
                }
            }
            SMTP  = @{
                Server        = 'mail.contoso.com'
                Port          = 25
                PSUCredential = ''
                From          = ''
            }
        }

        $CfgPath = (Resolve-Path (Join-Path $PSScriptRoot -ChildPath "..\..\..\PSIDM.Universal\conf\config.json")).Path

        # suppress PSScriptAnalyzer warning
        $CfgPath | Out-Null
        $cfg | Out-Null

    }
    Describe 'Get-PSIDMConfig' {
        Context 'When the $Script:PSIDM variable does not exist' {
            BeforeEach {
                Remove-Variable -Name PSIDM -Scope Script -Force
                Mock Import-PSIDMConfig { return $cfg } -ModuleName PSIDM.Universal -Verifiable
            }

            It 'Makes a call to Import-PSIDMConfig' {
                $null = Get-PSIDMConfig
                Should -Invoke -CommandName Import-PSIDMConfig -Times 1
            }


        }

        Context 'When the configuration file does exist' {
            BeforeEach {
                if ($null -ne $Script:PSIDM) {
                    Remove-Variable -Name PSIDM -Scope Script -Force
                }

                if (Test-Path $CfgPath) {
                    Remove-Item -Path $CfgPath -Force
                }
            }

            It 'Throws a [System.IO.FileNotFoundException] exception' {
                { Get-PSIDMConfig } | Should -Throw -ExceptionType System.IO.FileNotFoundException
            }
        }

        Context 'When no path is given' {
            BeforeEach {
                if ($null -ne $Script:PSIDM) {
                    Remove-Variable -Name PSIDM -Scope Script -Force
                }

                $cfg | ConvertTo-Json -Depth 10 | Out-File -FilePath $CfgPath -Force
            }

            It 'Returns expected values when FullPath is not specified' {
                $result = Get-PSIDMConfig
                $result.keys | Should -Be @('AD', 'SMTP', 'Paths')
                $result | Should -Be System.Collections.Hashtable
            }
        }

        Context 'When a path is given' {
            It 'Returns a top-level element' {
                $result = Get-PSIDMConfig -FullPath 'AD'
                $result | Should -Be System.Collections.Hashtable
                $result.keys | Should -Be @('Domain')
            }

            It 'Returns a nested element' {
                $result = Get-PSIDMConfig -FullPath 'AD.Domain.Name'
                $result | Should -Be 'contoso'
            }
        }
    }
}
