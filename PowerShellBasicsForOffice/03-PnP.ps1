# Install-Module SharePointPnPPowerShellOnline -Scope CurrentUser
$spocred = Get-Credential admin@tenant.com
$url = 'https://your-tenant.sharepoint.com'

Connect-PnPOnline –Url $url –Credentials $spocred

Get-PnPList

$list = Get-PnPList /Lists/NewList
Set-PnPList –Identity $list –Hidden $true
