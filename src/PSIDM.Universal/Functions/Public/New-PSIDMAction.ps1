function New-PSIDMAction {
    <#
    .SYNOPSIS
        Creates a new PSIDM action.

    .DESCRIPTION
        The New-PSIDMAction function creates a new action for the PSIDM module.
        It generates a unique GUID for the action and updates the stored action
        map.

    .PARAMETER Action
        The scriptblock that defines the action.

    .PARAMETER Name
        The name of the action.

    .EXAMPLE
        New-PSIDMAction -Action { Write-Host "Hello, World!" } -Name "Greet"

        This example creates a new action named "Greet" that writes "Hello, World!" to the host.

    .NOTES
        File Name      : New-PSIDMAction.ps1
        Author         : Your Name
        Prerequisite   : PowerShell v7.3
        Copyright 2023 : Your Company

    .LINK
        Related functions:
            - Get-PSIDMConfig
            - Get-PSIDMAction
            - Invoke-PSIDMAction
            - Remove-PSIDMAction
            - Update-PSIDMActionMap
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $false)]
        [Alias('Script','ScriptBlock')]
        [scriptblock] $ActionScript
    )

    begin {
        $configRoot = Get-PSIDMConfig -path Module.Paths.ConfigRoot
        $actionRoot = Get-PSIDMConfig -path Module.Paths.ActionRoot
        $actionMapPath = Join-Path $configRoot -ChildPath 'actionmap.json'
        if (-not (Test-Path $actionRoot)) {
            Write-Verbose "Creating action root directory at '$actionRoot'"
            try {
                New-Item -Path $actionRoot -ItemType Directory -ErrorAction Stop | Out-Null
            }
            catch {
                throw "Unable to create action root directory at '$actionRoot'. Error: $_"
            }
        }
    }

    process {
        if (-not (Test-Path -Path $actionMapPath -PathType Leaf)) {
            throw "Action map file not found at '$actionMapPath'."
        }

        # Generate a new GUID for the action
        $guid = [guid]::NewGuid().guid
        $actionFilePath = Join-Path $actionRoot -ChildPath "$guid.ps1"

        $actionMap = Get-Content -Path $actionMapPath -Raw | ConvertFrom-Json
        try {
            Write-Debug "Checking for name collision with '$Name'"
            # Check if the action name already exists in the map
            $actionMap = Get-PSIDMAction -Action $Name
            if ($actionMap) {
                $oldName = $Name
                $Name = "$Name-$guid"
                Write-Debug "Name collision detected. New name: $Name"
                Write-Warning "Action '$oldName' already exists. A new action will be created with a unique name."
                Write-Warning "New action name: $Name"
            }
        }
        catch [System.IO.FileNotFoundException] {
            # If the action name does not exist in the map, the exception will
            # be caught here. This is expected behavior.
            Write-Debug "Name collision not detected."
        }
        catch {
            throw "Unable to check for name collision. Error: $_"
        }

        Write-Verbose "Creating new action file at '$actionFilePath'"
        if ($null -eq $ActionScript) {
            $ActionScript = [scriptblock]::Create("# It all starts with a single line of code...")
        }
        $output = [PSCustomObject]@{
            name    = $Name
            id      = $guid
            file    = $actionFilePath
            content = $ActionScript.ToString()
        }

        try {
            $output.content | Set-Content -Path $actionFilePath -Encoding UTF8 -Force -ErrorAction Stop
        }
        catch {
            throw "Unable to create action file at '$actionFilePath'. Error: $_"
        }

        try {
            Update-PSIDMActionMap -ActionInfo $output -ErrorAction Stop
        }
        catch {
            throw "Unable to update action map file at '$actionMapPath'. Error: $_"
        }
    }
}