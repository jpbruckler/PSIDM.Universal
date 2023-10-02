function Import-PSIDMConfig {
    [CmdletBinding()]
    param(
        [System.IO.FileInfo] $Path = (Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath 'conf\config.json'),
        [switch] $PassThru,
        [switch] $Force
    )

    process {
        if (-not ((Test-Path $Path) -or $Force)) {
            throw [System.IO.FileNotFoundException] "The configuration file '$Path' does not exist. Call with the -Force parameter to force initialization, or provide a different path."
        }

        if ($Force) {
            Initialize-PSIDMConfig -Force
        }

        $config = Get-Content $Path -Raw | ConvertFrom-Json -Depth 10
        $config = $config | ConvertTo-HashTable -Depth 10
        Set-Variable -Scope Script -Name 'PSIDM' -Value $config -Force

        if ($PassThru) {
            return $config
        }
    }
}