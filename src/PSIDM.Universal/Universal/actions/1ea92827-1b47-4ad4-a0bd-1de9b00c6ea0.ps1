param($aduser)

Get-ADUser $aduser | Disable-ADAccount
