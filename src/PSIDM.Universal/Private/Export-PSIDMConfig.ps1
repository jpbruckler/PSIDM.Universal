function Export-PSIDMConfig {
    <#
    .SYNOPSIS
        Exports the PSIDM configuration to a JSON file.

    .DESCRIPTION
        The Export-PSIDMConfig function exports the PSIDM configuration stored
        in a PSCustomObject to a JSON file.  If the UpdateSession switch is
        provided, the function will also update the current session's configuration,
        defined in $Script:PSIDM and accessible through Get-PSIDMConfig.

    .PARAMETER InputObject
        The configuration object to be exported. Defaults to the script-scoped
        variable $Script:PSIDM.

    .PARAMETER UpdateSession
        If this switch is provided, the function will update the current session's
        configuration using Import-PSIDMConfig.

    .EXAMPLE
        Export-PSIDMConfig -UpdateSession

        This example exports the current $Script:PSIDM configuration to the
        default path and updates the session.

    .NOTES
        If the specified path does not exist, the function will attempt to create
        it.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [Alias('Config')]
        [System.Collections.Hashtable] $InputObject = $Script:PSIDM,

        [switch] $UpdateSession
    )

    begin {
        $configFileMap = Get-ConfigFileMap
    }
    process {
        Write-Debug "InputObject: $($InputObject | ConvertTo-Json -Depth 10)"
        if (-not $InputObject) {
            Write-Debug 'No InputObject was passed, and $Script:PSIDM is null.'
            throw [System.ArgumentNullException] 'No configuration available. Please provide a configuration object or ensure the script has a valid configuration.'
        }

        $configFileMap.GetEnumerator() | ForEach-Object {
            $configName = $_.Key
            $configPath = $_.Value

            Write-Debug "Config name: $configName"
            Write-Debug "Config path: $configPath"

            if ($null -eq $InputObject.$configName) {
                Write-Debug "Configuration '$configName' is null. Skipping."
                continue
            }
            else {
                Write-Debug "Exporting configuration '$configName' to '$configPath'."
                Write-Verbose "Exporting configuration '$configName' to '$configPath'."
                $InputObject.$configName | ConvertTo-Json -Depth 10 | Out-File -FilePath $configPath -Encoding UTF8 -Force

                Write-Debug "Checking if we need to update the session..."
                if ($UpdateSession) {
                    if (-not(Get-Variable -Name PSIDM -ErrorAction SilentlyContinue -Scope Script)) {
                        Write-Debug "Session configuration does not exist. Creating..."
                        $Script:PSIDM = @{
                            'Module'    = @{ }
                            'Navigator' = @{ }
                        }
                    }
                    Write-Verbose "Updating session configuration with '$configName'..."
                    $Script:PSIDM[$configName] = $InputObject.$configName
                }
            }
        }
    }
}
