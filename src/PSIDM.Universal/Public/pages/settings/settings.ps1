New-UDPage -Url "/settings" -Name "Settings" -Content {
    <#New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDPaper -Content { "xs-12" } -Elevation 2
        }
        
        New-UDGrid -Item -ExtraSmallSize 6 -Content {
            New-UDPaper -Content { "xs-6" } -Elevation 2
        }
        
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            #New-UDPaper -Content { "xs-3" } -Elevation 2
            New-UDCard -Title 'Directory Configuration' -Content {
                New-UDTextbox -Label 'Log Directory' -Id 'LogFileDirectory' -Icon (New-UDMaterialDesignIcon -Icon 'MdOutlineFolder') -FullWidth
                New-UDTextBox -Label 'Job Pickup' -Id 'JobPickupLocation' -Icon (New-UDMaterialDesignIcon -Icon 'MdMoveToInbox') -FullWidth -OnValidate {New-UDAlert -Text "Validation"}
            }
        }
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content { "xs-3" } -Elevation 2
        }
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content { "xs-3" } -Elevation 2
        }
    }

    #>
}