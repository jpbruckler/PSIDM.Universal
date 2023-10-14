function Get-PSIDMAction {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(Mandatory = $true,
                    ParameterSetName = 'Name')]
        [Alias('Name')]
        [string] $Action,

        [Parameter(Mandatory = $true,
                    ParameterSetName = 'GUID')]
        [guid] $Id
    )

    begin {
        $configRoot = Get-PSIDMConfig -path Module.Paths.ConfigRoot
        $actionRoot = Get-PSIDMConfig -path Module.Paths.ActionRoot
        $actionMapPath = Join-Path $configRoot -ChildPath 'actionmap.json'

        Write-Debug "Config root: $configRoot"
        Write-Debug "Action root: $actionRoot"
        Write-Debug "Action map path: $actionMapPath"

        if (-not (Test-Path -Path $actionMapPath -PathType Leaf)) {
            throw "Action map file not found at '$actionMapPath'."
        }
    }

    process {
        Write-Debug "Reading action map from '$actionMapPath'.."
        $actionMap = Get-Content -Path $actionMapPath -Raw | ConvertFrom-Json

        if ($null -eq $actionMap) {
            Write-Warning "Action map file at '$actionMapPath' is empty."
            return $null
        }

        # Get the action info. If the action is not found, throw an error.
        # Action information from the map will consist of the action name and
        # the action ID (guid). The guid corresponds to the filename of the
        # action scriptblock.
        if ($PSCmdlet.ParameterSetName -eq 'Name') {
            $actionIdentity = $Name
            $actionInfo = $actionMap | Where-Object { $_.name -eq $Action }
        }
        else {
            $actionIdentity = $Id
            $actionInfo = $actionMap | Where-Object { $_.id -eq $Id }
        }

        # If $actionInfo is null, the action was not found in the map. Return
        # null to the caller and write a warning.
        if ($null -eq $actionInfo) {
            Write-Warning "Action '$actionIdentity' not found."
            return $null
        }
        else {
            Write-Debug "Action info: $actionInfo"
            Write-Debug "Checking for action file '$($actionInfo.Id).ps1' in '$actionRoot'"
            $actionFile = Join-Path $actionRoot -ChildPath "$($actionInfo.Id).ps1"

            if (-not (Test-Path -Path $actionFile -PathType Leaf)) {
                throw [System.IO.FileNotFoundException] "Action with id $($actionInfo.id) found in action map, but corresponding file not found in '$actionRoot'."
            }
            else {
                Write-Debug "Action file found at '$actionFile'."
                $actionScriptBlock = Get-Content -Path $actionFile -Raw
                Write-Debug "Action scriptblock: $actionScriptBlock"
                return [scriptblock]::Create($actionScriptBlock)
            }
        }
    }
}