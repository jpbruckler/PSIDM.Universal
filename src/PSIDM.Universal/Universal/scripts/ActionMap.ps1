<#
.SYNOPSIS
    This file returns a hashtable of actions that can be used during PSIDM jobs.
.DESCRIPTION
    This file returns a hashtable of actions that can be used during PSIDM jobs.
    The hashtable is used by the PSIDM job scripts to determine which actions
    are available for the job.
#>
$Actions = @(
    @{
        Name = 'Enable'
        ScriptBlock = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $User
        )

            $User | Enable-ADAccount
        }
    },
    @{
        Name = 'Disable'
        ScriptBlock = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $User
        )

            $User | Disable-ADAccount
        }
    },
    @{
        Name = 'DisableAndMove'
        ScriptBlock = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $User
        )
            $targetPath = Get-PSIDMConfig -Key 'DisabledUsersOU'
            if ($null -eq $targetPath) {
                throw 'Unable to get DisabledUsersOU from configuration.'
            }

            $User | Disable-ADAccount
            $User | Move-ADObject -TargetPath $targetPath
        }
    }
    <#Disable = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $User
        )

        $User | Disable-ADAccount
    }
    DisableAndMove = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $User,

            [Parameter(Mandatory = $true)]
            [string] $target
        )

        $User | Disable-ADAccount
        $User | Move-ADObject -TargetPath $target
    }
    RemoveAllGroups = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $User
        )

        $User | Get-ADPrincipalGroupMembership | Remove-ADPrincipalGroupMembership -Confirm:$false
    }#>
)

return $Actions