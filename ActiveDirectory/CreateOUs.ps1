
$domain = "DC=blue,DC=karl,DC=lab"
$BaseOU = "HOMELAB"

$OUnames = @(
    "Computers"
    "Users"
    "Admins"
    "Servers"
)

New-ADOrganizationalUnit -Name $BaseOU -Path $domain -ProtectedFromAccidentalDeletion $true

$OUnames | ForEach-Object{
    New-ADOrganizationalUnit -Name $_ -Path "DC=$BaseOU,$domain" -ProtectedFromAccidentalDeletion $true
}