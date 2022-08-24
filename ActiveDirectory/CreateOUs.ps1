
$domain = "DC=karl,DC=lab"
$BaseOU = "HOMELAB"

$OUnames = @(
    "Computers"
    "Users"
    "Admins"
    "Servers"
    "Groups"
)

New-ADOrganizationalUnit -Name $BaseOU -Path $domain -ProtectedFromAccidentalDeletion $true

$OUnames | ForEach-Object{
    New-ADOrganizationalUnit -Name $_ -Path "OU=$BaseOU,$domain" -ProtectedFromAccidentalDeletion $true
}