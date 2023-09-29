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

function New-PSIDMUniversalApp {
    $Navigation = {
        New-UDListItem -Label 'Home' -Icon (New-UDMaterialDesignIcon -Icon 'MdHome') -Href '/home'
        New-UDListItem -Label 'Settings' -Icon (New-UDMaterialDesignIcon -Icon 'MdSettings') -Href '/settings' -Children {
            New-UDListItem -Label 'AD Search' -Icon (New-UDMaterialDesignIcon -Icon 'MdManageSearch') -Href '/settings/search' -Nested
            New-UDListItem -Label 'Email' -Icon (New-UDMaterialDesignIcon -Icon 'MdOutgoingMail') -Href '/settings/email' -Nested
        }
    }

    $Pages =  @(
        . "$PSScriptRoot\Public\pages\home.ps1"
    )

    Get-ChildItem -Path (Join-Path $PSScriptRoot -ChildPath 'Public\pages\settings') -Filter *.ps1 | ForEach-Object {
        $Pages += . $_.FullName
    }


    New-UDDashboard -Title 'PSIDM Universal' -Pages $Pages -NavigationLayout Permanent -LoadNavigation $Navigation -DefaultTheme Dark
}

# export all public functions
Export-ModuleMember -Function New-PSIDMUniversalApp