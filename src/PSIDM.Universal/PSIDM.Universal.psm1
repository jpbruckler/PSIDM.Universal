[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
[CmdletBinding()]
param()

# this psm1 is for local testing and development use only

# dot source the parent import for local development variables
. $PSScriptRoot\Imports.ps1

# discover all ps1 file(s) in Public and Private paths

$itemSplat = @{
    Filter      = '*.ps1'
    Recurse     = $false
    ErrorAction = 'Stop'
}

try {
    $public     = @(Get-ChildItem -Path "$PSScriptRoot\Functions\Public" @itemSplat -Verbose)
    $private    = @(Get-ChildItem -Path "$PSScriptRoot\Functions\Private" @itemSplat -Verbose)
}
catch {
    Write-Error $_
    throw "Unable to get get file information from Public & Private src."
}

# dot source all .ps1 file(s) found
foreach ($file in @($public + $private)) {
    try {
        Write-Verbose "Dot sourcing $($file.FullName)"
        . $file.FullName
    }
    catch {
        throw "Unable to dot source [$($file.FullName)]"
    }
}

# Import configuration and setup script-scoped variables.
# This makes configuration available via Get-PSIDMConfig.
try {
    Import-PSIDMConfig
}
catch [System.IO.FileNotFoundException] {
    Write-Warning 'Configuration file not found. Initializing with default values.'
    Initialize-PSIDMConfig -Force
    Write-Error "Error encountered: $_"
}


$export = $public + $private

# export all public functions
Export-ModuleMember -Function $export.BaseName