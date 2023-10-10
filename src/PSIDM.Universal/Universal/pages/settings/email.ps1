New-UDPage -Url "/settings/email" -Name "Email Settings" -Content {
    $Session:Credentials = Get-PSUVariable | Where-Object { $_.Type -eq 'PSCredential' } | Select-Object Name, Id -Unique
    New-UDForm -Content {
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 3 -Content {
                #New-UDPaper -Content { "xs-3" } -Elevation 2
                New-UDCard -Title 'Email Configuration' -Content { 
                    New-UDTextbox -Label 'SMTP Server' -Id 'SMTPServer' -Icon (New-UDMaterialDesignIcon -Icon 'MdOutlineMail') -FullWidth
                    New-UDTextbox -Label 'SMTP Port' -Id 'SMTPPort' -Icon (New-UDMaterialDesignIcon -Icon 'Md123') -FullWidth
                    New-UDTextbox -Label 'Send From' -Id 'SMTPEmailFrom' -Icon (New-UDMaterialDesignIcon -Icon 'MdAlternateEmail') -FullWidth

                    
                    $Options = {
                        New-UDSelectOption -Name 'None' -Value 'None'
                        $Session:Credentials | ForEach-Object {
                            New-UDSelectOption -Name $_.Name -Value $_.Id
                        }
                    }
                    New-UDSelect -Label 'Email Credential' -Id 'SMTPCredential' -Option $Options -DefaultValue 'None' -Icon (New-UDMaterialDesignIcon -Icon 'MdPassword') -FullWidth
                    New-UDSwitch -Label 'Use SSL' -Id 'SMTPUseSSL' -LabelPlacement start
                }
            }
        }
    } -OnSubmit {
        $EventData | Export-Clixml D:\eventdata.xml -Force
        
        $SMTPSettings = [PSCustomObject]@{
            SMTPUseSSL     = $EventData.SMTPUseSSL
            SMTPServer     = $EventData.SMTPServer
            SMTPPort       = $EventData.SMTPPort
            SMTPEmailFrom  = $EventData.SMTPEmailFrom
            SMTPCredential = $Session:Credentials | Where-Object { $_.Id -eq $EventData.SMTPCredential } | Select-Object -ExpandProperty Name
        }
        $SMTPSettings | ConvertTo-Json | Out-File D:\test.jsonc
    }
}