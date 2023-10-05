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
    Describe "Get-PSIDMJobInfo" {
        BeforeAll {
            # Mock Get-PSIDMConfig to return a sample job configuration
            Mock Get-PSIDMConfig {
                return @(
                    @{
                        JobId = 'a2290ab1-24fa-4677-bea7-8f1427268e37'
                        JobScript = 'onboard.ps1'
                        JobName = 'onboard'
                        JobPickupFile = 'onboard.csv'
                    },
                    @{
                        JobId = 'a839b642-c31b-4bb8-8c9e-14cfeebb7cb7'
                        JobScript = 'offboard.ps1'
                        JobName = 'offboard'
                        JobPickupFile = 'offboard.csv'
                    }
                )
            }
        }

        It "Should return job by JobId" {
            $result = Get-PSIDMJobInfo -JobId 'a2290ab1-24fa-4677-bea7-8f1427268e37'
            $result.JobId | Should -Be 'a2290ab1-24fa-4677-bea7-8f1427268e37'
        }

        It "Should return job by JobName" {
            $result = Get-PSIDMJobInfo -JobName 'onboard'
            $result.JobName | Should -Be 'onboard'
        }

        It "Should return job by JobScript" {
            $result = Get-PSIDMJobInfo -JobScript 'offboard.ps1'
            $result.JobScript | Should -Be 'offboard.ps1'
        }

        It "Should return job by JobPickupFile" {
            $result = Get-PSIDMJobInfo -JobPickupFile 'onboard.csv'
            $result.JobPickupFile | Should -Be 'onboard.csv'
        }

        It "Should return null if no job is found" {
            $result = Get-PSIDMJobInfo -JobId '00000000-0000-0000-0000-000000000000' -WarningAction 'SilentlyContinue'
            $result | Should -Be $null
        }
    }
}