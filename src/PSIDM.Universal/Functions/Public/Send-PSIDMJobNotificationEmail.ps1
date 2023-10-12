using module Send-MailKitMessage;
function Send-PSIDMJobNotificationEmail {
    <#
    .SYNOPSIS
        Sends email notifications for PSIDM job statuses.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateScript({
                if ([string]::IsNullOrEmpty($_.Trim())) {
                    throw "SMTPServer cannot be null or empty."
                }
                else {
                    $true
                }
            })]
        [string] $SMTPServer = (Get-PSIDMConfig -Path SMTP.Server),

        [Parameter(Mandatory = $false)]
        [int] $SMTPPort = (Get-PSIDMConfig -Path SMTP.Port),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [MimeKit.MailboxAddress] $From = (Get-PSIDMConfig -Path SMTP.From),

        [Parameter(Mandatory = $true)]
        [string[]] $To,

        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if ([string]::IsNullOrEmpty($_.Trim())) {
                    throw 'Email subject cannot be null or empty.'
                }
                else {
                    $true
                }
            })]
        [string] $Subject,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]] $InputObject,
        [pscredential] $Credential,

        [Parameter(Mandatory = $false)]
        [string[]] $Attachments,
        [switch] $UseSSL
    )

    begin {
        $templateRoot   = Join-Path (Get-PSIDMConfig -Path Module.Paths.NotifyRoot) -ChildPath 'templates'
        $assetsRoot     = Join-Path (Get-PSIDMConfig -Path Module.Paths.NotifyRoot) -ChildPath 'assets'
    }

    process {
        $attachmentList = [System.Collections.Generic.List[string]]::new()
        $recipientList  = [MimeKit.InternetAddressList]::new()
        $emailHeader    = Get-Content -Path (Join-Path $templateRoot -ChildPath 'header.html') -Raw
        $emailFooter    = Get-Content -Path (Join-Path $templateRoot -ChildPath 'footer.html') -Raw
        $emailBody      = Get-Content -Path (Join-Path $templateRoot -ChildPath 'body.html') -Raw
        $bodyFrgmnt     = $InputObject | ConvertTo-Html -Fragment
        $emailBody      = $emailHeader + $emailBody + $emailFooter
        $replContext    = [PSCustomObject]@{
            bodycontent = $bodyFrgmnt
            job = 'Job Name'
            servername = $env:COMPUTERNAME
            datetime = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        }

        $emailBody = Expand-PSIDMTemplate -Template $emailBody -Context $replContext

        # Build attachment list
        $attachmentList.Add((Join-Path $assetsRoot -ChildPath 'logo.png'))

        if ($PSBoundParameters.ContainsKey('Attachments')) {
            $Attachments | ForEach-Object {
                $attachmentList.Add($_)
            }
        }

        # Build recipient list
        $To | ForEach-Object {
            $recipientList.Add([MimeKit.MailboxAddress]::new($_))
        }

        # Figure out if we're using SSL or not
        If ($PSBoundParameters.ContainsKey('UseSSL')) {
            $useSecureConnectionIfAvailable = $UseSSL
        }
        elseif ($null -ne (Get-PSIDMConfig -Path SMTP.UseSSL)) {
            $useSecureConnectionIfAvailable = Get-PSIDMConfig -Path SMTP.UseSSL
        }
        else {
            $useSecureConnectionIfAvailable = $false
        }

        $mailParams = @{
            SMTPServer = $SMTPServer
            Port = $SMTPPort
            From = $From
            Subject = $Subject
            HTMLBody = $emailBody
            RecipientList = $recipientList
            UseSecureConnectionIfAvailable = $useSecureConnectionIfAvailable
            AttachmentList = $attachmentList
        }

        if ($PSBoundParameters.ContainsKey('Credential')) {
            $mailParams.Add('Credential', $Credential)
        }
        Send-MailKitMessage @mailParams
    }
}