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
    Describe 'Initialize-PSIDMConfig' {
        Context 'When no config files exist' {
            BeforeEach {
                Mock Test-Path { return $false }
                Mock Set-Content {}
            }
            It 'Should create Module config file if it does not exist' {

                Initialize-PSIDMConfig
                Assert-MockCalled Set-Content -Exactly 1 -Scope It -ParameterFilter { $Path -match 'config.json' }
            }
            It 'Should create Navigator config file if it does not exist' {
                Mock Test-Path { return $false }
                Mock Set-Content {}
                Initialize-PSIDMConfig
                Assert-MockCalled Set-Content -Exactly 1 -Scope It -ParameterFilter { $Path -match 'navigator.json' }
            }
        }

        Context 'Force flag' {
            It 'Should overwrite existing Module config file when -Force is used' {
                Mock Test-Path { return $true }
                Mock Set-Content {}
                Initialize-PSIDMConfig -Force
                Assert-MockCalled Set-Content -Exactly 1 -Scope It -ParameterFilter { $Path -match 'config.json' }
            }
        }
        Context 'PassThru flag' {
            It 'Should return the merged configuration when -PassThru is used' {
                Mock Get-Content { return '{"key": "value"}' }
                Mock ConvertFrom-Json { return @{ "key" = "value" } }
                Mock ConvertTo-Hashtable { return @{ "key" = "value" } }
                $result = Initialize-PSIDMConfig -PassThru
                $result.Module["key"] | Should -BeExactly "value"
                $result.Navigator["key"] | Should -BeExactly "value"
            }
        }
    }
}