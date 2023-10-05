<#
.SYNOPSIS
    This file returns a hashtable of actions that can be used during PSIDM jobs.
.DESCRIPTION
    This file returns a hashtable of actions that can be used during PSIDM jobs.
    The hashtable is used by the PSIDM job scripts to determine which actions
    are available for the job.
#>
$Actions = @{
    Disable = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $user
        )

        $user | Disable-ADAccount
    }
    DisableAndMove = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $user,

            [Parameter(Mandatory = $true)]
            [string] $target
        )

        $user | Disable-ADAccount
        $user | Move-ADObject -TargetPath $target
    }
    RemoveAllGroups = [scriptblock]{
        param(
            [Parameter(Mandatory = $true)]
            [object] $user
        )

        $user | Get-ADPrincipalGroupMembership | Remove-ADPrincipalGroupMembership -Confirm:$false
    }
}

return $Actions