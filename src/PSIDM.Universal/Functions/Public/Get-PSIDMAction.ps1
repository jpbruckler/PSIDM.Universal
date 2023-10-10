function Get-PSIDMAction {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Action
    )

    $ModRoot = Get-PSIDMConfig -Path Module.Paths.ModuleRoot
    $actionMap = . "$ModRoot\Private\resources\ActionMap.ps1"
    if ($actionMap.ContainsKey($Action) -eq $false) {
        throw "Action '$Action' is not defined in the action map."
    }

    return $actionMap[$Action]
}