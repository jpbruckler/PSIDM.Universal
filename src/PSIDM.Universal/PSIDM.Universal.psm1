[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
param()
# this psm1 is for local testing and development use only

# dot source the parent import for local development variables
. $PSScriptRoot\Imports.ps1

# discover all ps1 file(s) in Public and Private paths

$itemSplat = @{
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'Stop'
}
try {
    $public = @(Get-ChildItem -Path "$PSScriptRoot\Public" @itemSplat)
    $private = @(Get-ChildItem -Path "$PSScriptRoot\Private" @itemSplat)
}
catch {
    Write-Error $_
    throw "Unable to get get file information from Public & Private src."
}

# dot source all .ps1 file(s) found
foreach ($file in @($public + $private)) {
    try {
        . $file.FullName
    }
    catch {
        throw "Unable to dot source [$($file.FullName)]"
    }
}

if (Test-Path (Join-Path $PSScriptRoot -ChildPath 'conf\config.json')) {
    Import-PSIDMConfig -ConfigName 'Module'
}
else {
    Write-Warning 'Configuration file not found. Initializing with default values.'
    Initialize-PSIDMConfig -Force
}

# export all public functions
Export-ModuleMember -Function $public.BaseName