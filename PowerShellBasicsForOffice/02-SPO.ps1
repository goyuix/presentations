# Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
$email = 'you@tenant.com’
$url = 'https://tenant-admin.sharepoint.com'
$spocred = Get-Credential $email

# just omit Credential parameter if your tenant / account uses MFA
Connect-SPOService -Url $url -Credential $spocred

Get-SPOSite
