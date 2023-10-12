function Invoke-PSIDMAction {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Action,

        [Parameter(Mandatory = $true)]
        [object] $ADObject,

        [Parameter(Mandatory = $true)]
        [object] $JobInfo
    )

    begin {
        $actionRoot = Get-PSIDMConfig -path Module.Paths.ActionRoot
    }

    process {
        $actionSB = Get-PSIDMAction -Action $Action
    }
}