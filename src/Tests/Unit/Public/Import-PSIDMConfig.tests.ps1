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
    Describe 'Import-PSIDMConfig' {
        Context 'Parameter validation' {
            BeforeEach {
                Mock Test-Path { return $true }
                Mock Get-Content { return '{"key": "value"}' }
                Mock ConvertFrom-Json { return @{ "key" = "value" } }
                Mock ConvertTo-Hashtable { return @{ "key" = "value" } }
                Mock Merge-Object { return @{ "key" = "value" } }
            }
            It 'Should accept valid ConfigName values' {
                { Import-PSIDMConfig -ConfigName 'Module' } | Should -Not -Throw
                { Import-PSIDMConfig -ConfigName 'Navigator' } | Should -Not -Throw
                { Import-PSIDMConfig -ConfigName 'All' } | Should -Not -Throw
            }
            It 'Should reject invalid ConfigName values' {
                { Import-PSIDMConfig -ConfigName 'Invalid' } | Should -Throw
            }
        }
        Context 'File existence' {
            BeforeEach {
                Mock Get-Content { return '{"key": "value"}' }
                Mock ConvertFrom-Json { return @{ "key" = "value" } }
                Mock ConvertTo-Hashtable { return @{ "key" = "value" } }
                Mock Merge-Object { return @{ "key" = "value" } }
            }
            It 'Should throw an error if the config file does not exist' {
                Mock Test-Path { return $false }
                { Import-PSIDMConfig -ConfigName 'Module' -ErrorAction SilentlyContinue } | Should -Throw -ExceptionType 'System.IO.FileNotFoundException'
            }
            It 'Should not throw an error if the config file exists' {
                Mock Test-Path { return $true }
                { Import-PSIDMConfig -ConfigName 'Module' } | Should -Not -Throw
            }
        }
        Context 'Configuration merging' {
            It 'Should merge configurations correctly' {
                Mock Get-Content { return '{"key": "value"}' }
                Mock ConvertFrom-Json { return @{ "key" = "value" } }
                Mock ConvertTo-Hashtable { return @{ "key" = "value" } }
                Mock Merge-Object { return @{ "key" = "value" } }
                $result = Import-PSIDMConfig -ConfigName 'Module' -PassThru
                $result["key"] | Should -BeExactly "value"
            }
        }
        Context 'Script-scoped variable' {
            It 'Should set the script-scoped variable PSIDM' {
                Mock Set-Variable {}
                Import-PSIDMConfig -ConfigName 'Module'
                Assert-MockCalled Set-Variable -Exactly 1 -Scope It -ParameterFilter { $Name -eq 'PSIDM' }
            }
        }
    }
}