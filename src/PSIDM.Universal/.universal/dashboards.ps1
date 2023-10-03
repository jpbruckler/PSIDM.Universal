#New-PSUDashboard -Name 'Active Directory' -BaseUrl '/active-directory' -Module 'Universal.Apps.ActiveDirectory' -Command 'New-UDActiveDirectoryApp' -Authenticated -Role @("Administrator", "AD Admin", "AD Users", "AD Groups")
New-PSUApp -Name 'PSIDM.Universal' -BaseUrl '/psidm' -Module 'PSIDM.Universal' -Command 'New-PSIDMUniversalApp'