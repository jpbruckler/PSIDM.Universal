function New-PSIDMUniversalApp {
    $Navigation = {
        New-UDListItem -Label 'Home' -Icon (New-UDMaterialDesignIcon -Icon 'MdHome') -Href '/home'
        New-UDListItem -Label 'Settings' -Icon (New-UDMaterialDesignIcon -Icon 'MdSettings') -Href '/settings' -Children {
            New-UDListItem -Label 'AD Search' -Icon (New-UDMaterialDesignIcon -Icon 'MdManageSearch') -Href '/settings/search' -Nested
            New-UDListItem -Label 'Email' -Icon (New-UDMaterialDesignIcon -Icon 'MdOutgoingMail') -Href '/settings/email' -Nested
        }
    }

    $Pages =  @(
        . (Join-Path $Global:PSIDM.Paths.PageRoot -ChildPath 'home.ps1')
    )

    Get-ChildItem -Path (Join-Path $Global:PSIDM.Paths.PageRoot -ChildPath 'settings') -Filter *.ps1 | ForEach-Object {
        $Pages += . $_.FullName
    }


    New-UDDashboard -Title 'PSIDM Universal' -Pages $Pages -NavigationLayout Permanent -LoadNavigation $Navigation -DefaultTheme Dark
}