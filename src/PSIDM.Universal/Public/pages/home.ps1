New-UDPage -Url "/home" -Name "Home" -Content {
    $ADDomain = Get-ADDomain
    $NumUserAccounts = (Get-ADUser -Filter '*').Count
    $NumGroups = (Get-ADGroup -Filter '*').Count
    $NumComputers = (Get-ADComputer -Filter '*').Count
    $PSIDMModule = Get-Module -Name 'PSIDM-Core'
    New-UDLayout -Columns 2 -Content {
        New-UDColumn -Content {
            $Header = New-UDCardHeader -Title $AdDomain.DNSRoot -SubHeader (Get-Date) 
            $Body = New-UDCardBody -Content {
                New-UDList -Children {
                    New-UDListItem -Label 'User Count' -SubTitle $NumUserAccounts -Icon (New-UDMaterialDesignIcon -Icon 'MdPeopleOutline')
                    New-UDListItem -Label 'Group Count' -SubTitle $NumGroups -Icon (New-UDMaterialDesignIcon -Icon 'MdOutlineGroups2')
                    New-UDListItem -Label 'Computer Count' -SubTitle $NumComputers -Icon (New-UDMaterialDesignIcon -Icon 'MdComputer')
                }
            }
            New-UDCard -Header $Header -Body $Body 
        }
        New-UDColumn -Content {
            $Header = New-UDCardHeader -Title 'PSIDM Module Info'
            $Body = New-UDCardBody -Content {
                New-UDList -Children {
                    New-UDListItem -Label 'Version' -SubTitle $PSIDMModule.Version
                }
            }
            New-UDCard -Header $Header -Body $Body
        }
    }
} -OnLoading { 'Loading Domain Information...' }