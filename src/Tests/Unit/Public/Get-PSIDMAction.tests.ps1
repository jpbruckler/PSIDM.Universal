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
    Describe 'Get-PSIDMActions' {
        Context 'when ActionName parameter is not specified' {
            It 'should return a hashtable' {
                $result = Get-PSIDMActions
                $result.GetType().Name | Should -Be 'Hashtable'
            }

            It 'should return a hashtable with at least one key-value pair' {
                $result = Get-PSIDMActions
                $result.Count | Should -BeGreaterThan 0
            }
        }

        Context 'when ActionName parameter is specified' {
            It 'should return a string' {
                $result = Get-PSIDMActions -ActionName 'DisableAndMove'
                $result.GetType().Name | Should -Be 'ScriptBlock'
            }

            It 'should return a non-empty string' {
                $result = Get-PSIDMActions -ActionName 'DisableAndMove'
                $result.Length | Should -BeGreaterThan 0
            }

            It 'should return null if the specified action name does not exist' {
                $result = Get-PSIDMActions -ActionName 'NonExistentAction'
                $result | Should -Be $null
            }
        }
    }
}