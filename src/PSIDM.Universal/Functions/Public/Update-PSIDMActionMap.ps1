function Update-PSIDMActionMap {
    <#
    .SYNOPSIS
        Updates the action map with new or existing action information.

    .DESCRIPTION
        The Update-PSIDMActionMap function updates the action map file with new
        or existing action information. It can accept action information either
        as a custom object or as separate ID and Name parameters.

    .PARAMETER ActionInfo
        A custom object containing the action ID and name. Mandatory when using
        the 'ActionInfo' parameter set.

    .PARAMETER Id
        The GUID of the action. Mandatory when using the 'Relationship' parameter
        set.

    .PARAMETER Name
        The name of the action. Mandatory when using the 'Relationship' parameter
        set.

    .EXAMPLE
        Update-PSIDMActionMap -ActionInfo $ActionInfo

        Updates the action map with the information contained in the $ActionInfo
        object.

    .EXAMPLE
        $Id = [guid]::NewGuid().guid
        $Name = 'MyAction'
        Update-PSIDMActionMap -Id $Id -Name $Name -Force

        Updates the action map with the specified ID and Name, overwriting any
        existing action with the same Id.

    .LINK
        Related functions:
            - Get-PSIDMConfig
            - Get-PSIDMAction
            - Invoke-PSIDMAction
            - New-PSIDMAction
            - Remove-PSIDMAction
    #>
    [CmdletBinding(DefaultParameterSetName = 'ActionInfo')]
    param (
        [Parameter( Mandatory = $true,
                    ParameterSetName = 'ActionInfo')]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$ActionInfo,

        [Parameter( Mandatory = $true,
                    ValueFromPipelineByPropertyName = $true,
                    ParameterSetName = 'Relationship')]
        [ValidateNotNullOrEmpty()]
        [guid] $Id,

        [Parameter( Mandatory = $true,
                    ValueFromPipelineByPropertyName = $true,
                    ParameterSetName = 'Relationship')]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [switch] $Force
        # TODO: Add -Remove switch
    )

    begin {
        $configRoot = Get-PSIDMConfig -path Module.Paths.ConfigRoot
        $actionMapPath = Join-Path $configRoot -ChildPath 'actionmap.json'
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Relationship') {
            $ActionInfo = [pscustomobject]@{
                id = $Id
                name = $Name
            }
        }

        try {
            # Add the new action to the action map file
            if ($null -eq $actionMap) {
                Write-Debug "Action map file is empty. Initializing action map with new action."
                $actionMap = @()
            }
            else {
                $actionMap = @($actionMap)
            }

            $check = Get-PSIDMAction -Id $ActionInfo.id -ErrorAction SilentlyContinue
            if (-not $check -or $Force) {
                Write-Verbose "Updating action map with new action."
                Write-Debug "Updating action map file at '$actionMapPath' with new action '$($ActionInfo.Name)'"
                $actionMap += $ActionInfo | Select-Object id, name
                $actionMap | ConvertTo-Json | Set-Content -Path $actionMapPath -Encoding UTF8 -Force

                return $ActionInfo
            }
            else {
                throw [System.ArgumentException] "Action '$($ActionInfo.Name)' already exists. Use -Force to overwrite."
            }
        }
        catch {
            throw "Unable to update action map file at '$actionMapPath'. Error: $_"
        }
    }
}
New-Alias -Name 'Set-PSIDMActionMap' -Value 'Update-PSIDMActionMap'