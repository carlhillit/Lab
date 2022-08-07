
$domain = "DC=blue,DC=breakdown,DC=lab"
$BaseOU = ="BDLAB"

$OUnames = @(
"Computers"
"Users"
"Admins"
"Servers")


New-ADOrganizationalUnit `
-Name "TFS Labs" -Path "DC=corp,DC=tfslabs,DC=com"
New-ADOrganizationalUnit `
-Name "TFS Servers" -Path "OU=TFS Labs,DC=corp,DC=tfslabs,DC=com"
New-ADOrganizationalUnit `
-Name "TFS Users" -Path "OU=TFS Labs,DC=corp,DC=tfslabs,DC=com"
New-ADOrganizationalUnit `
-Name "TFS Workstations" -Path "OU=TFS Labs,DC=corp,DC=tfslabs,DC=com"


New-ADOrganizationalUnit -Name $BaseOU -Path $domain -ProtectedFromAccidentalDeletion $true

$OUnames | ForEach-Object{
    New-ADOrganizationalUnit -Name $_ -Path "DC=$BaseOU,$domain" -ProtectedFromAccidentalDeletion $true
}