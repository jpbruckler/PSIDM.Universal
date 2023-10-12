function Get-PSIDMAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                    ParameterSetName = 'Name')]
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
        $actionMap = Get-Content -Path $actionMapPath -Raw | ConvertFrom-Json

        # Get the action info. If the action is not found, throw an error.
        # Action information from the map will consist of the action name and
        # the action ID (guid). The guid corresponds to the filename of the
        # action scriptblock.
        if ($PSCmdlet.ParameterSetName -eq 'Name') {
            $actionInfo = $actionMap | Where-Object { $_.name -eq $Action }
        }
        else {
            $actionInfo = $actionMap | Where-Object { $_.id -eq $Id }
        }

        if ($null -eq $actionInfo) {
            throw [System.ArgumentException] "Action '$Action' not found."
        }

        $actionFile = Join-Path $actionRoot -ChildPath "$($actionInfo.Id).ps1"
        if (-not (Test-Path -Path $actionFile -PathType Leaf)) {
            throw [System.IO.FileNotFoundException] "Action file not found at '$actionFile'."
        }

        $content = Get-Content -Path $actionFile -Raw
        return [scriptblock]::Create($content)
    }
}