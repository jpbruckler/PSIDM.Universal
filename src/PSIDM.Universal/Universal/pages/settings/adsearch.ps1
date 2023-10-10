New-UDPage -Url "/settings/search" -Name "Search Settings" -Content {
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 6 -Content {
            #New-UDPaper -Content { "xs-6" } -Elevation 2
            New-UDCard -Title 'Directory Search Configuration' -Content {
                New-UDCard -Title 'User Search' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDTextbox -Label 'User Search Root' -Id 'UserSearchRoot' -Icon (New-UDMaterialDesignIcon -Icon 'MdPersonSearch') -FullWidth
                        }
                    
                        # Empty spacer
                        New-UDGrid -Item -ExtraSmallSize 2 -Content {}

                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDTextbox -Label 'User Search Filter'-Id 'UserSearchFilter' -Icon (New-UDMaterialDesignIcon -Icon 'MdFilterListAlt') -FullWidth
                        }

                        New-UDGrid -Item -ExtraSmallSize 7 -Content {}
                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDSwitch -Id 'UserLdapFilter' -Label 'LDAP Filter Syntax' -LabelPlacement start
                        }
                    }
                } 
                
                New-UDCard -Title 'Group Search' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDTextbox -Label 'Group Search Root' -Id 'GroupSearchRoot' -Icon (New-UDMaterialDesignIcon -Icon 'MdSearch') -FullWidth

                        }

                        # Empty spacer
                        New-UDGrid -Item -ExtraSmallSize 2 -Content {}

                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDTextbox -Label 'Group Search Filter' -Id 'GroupSearchFilter' -Icon (New-UDMaterialDesignIcon -Icon 'MdFilterListAlt') -FullWidth
                        }

                        New-UDGrid -Item -ExtraSmallSize 7 -Content {}
                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDSwitch -Id 'GroupLdapFilter' -Label 'LDAP Filter Syntax' -LabelPlacement start
                        }
                    }
                }

                New-UDCard -Title 'Computer Search' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDTextbox -Label 'Computer Search Root' -Id 'ComputerSearchRoot' -Icon (New-UDMaterialDesignIcon -Icon 'MdScreenSearchDesktop') -FullWidth

                        }

                        # Empty spacer
                        New-UDGrid -Item -ExtraSmallSize 2 -Content {}

                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDTextbox -Label 'Computer Search Filter' -Id 'ComputerSearchFilter' -Icon (New-UDMaterialDesignIcon -Icon 'MdFilterListAlt') -FullWidth
                        }

                        New-UDGrid -Item -ExtraSmallSize 7 -Content {}
                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDSwitch -Id 'ComputerLdapFilter' -Label 'LDAP Filter Syntax' -LabelPlacement start
                        }
                    }
                }   
            }
        }
    }
}