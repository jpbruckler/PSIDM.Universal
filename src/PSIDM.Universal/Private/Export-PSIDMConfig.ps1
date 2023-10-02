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

    .PARAMETER Path
        The path where the configuration JSON file will be saved. Defaults to
        'conf\config.json' in the parent directory of the script.

    .PARAMETER UpdateSession
        If this switch is provided, the function will update the current session's
        configuration using Import-PSIDMConfig.

    .EXAMPLE
        Export-PSIDMConfig -UpdateSession

        This example exports the current $Script:PSIDM configuration to the
        default path and updates the session.

    .EXAMPLE
        Export-PSIDMConfig -Path 'C:\CustomPath\config.json'

        This example exports the current $Script:PSIDM configuration to a custom
        path.

    .NOTES
        If the specified path does not exist, the function will attempt to create
        it.

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [Alias('Config')]
        [System.Collections.Hashtable] $InputObject = $Script:PSIDM,

        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $Path = (Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath 'conf\config.json'),

        [switch] $UpdateSession
    )

    process {
        if (-not $InputObject) {
            Write-Error 'No configuration available. Please provide a configuration object or ensure the script has a valid configuration.'
            return
        }

        if (-not (Test-Path (Split-Path $Path))) {
            New-Item -ItemType Directory -Path (Split-Path $Path) -Force
        }

        try {
            $InputObject | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Force -ErrorAction Stop

            if ($UpdateSession) {
                Import-PSIDMConfig -Path $Path
            }
        }
        catch {
            Write-Error "Unable to export configuration to file '$Path'. Error: $($_.Exception.Message)"
        }
    }
}
