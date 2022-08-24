# untested

$Domain = 'karl.lab'
$UsersCsv = Import-Csv -Path .\50CommonNames-EN.csv
$UsersOU = "OU=Users,OU=HOMELAB,DC=karl,DC=lab"
$GroupsOU = "OU=Groups,OU=HOMELAB,DC=karl,DC=lab"

$DefaultUserPassword = Read-Host -AsSecureString -Prompt 'Enter the default user password'

foreach ($user in $UsersCsv) {
    $splat = @{
        Name = ($user.SurName)+', '+($user.GivenName)
        UserPrincipalName = ($user.GivenName)+'.'+($user.SurName)+'@'+$Domain
        SamAccountName = ($user.GivenName)+'.'+($user.SurName)
        Path = $UsersOu
        GivenName = $user.GivenName
        Surname = $user.Surname
        Description = $user.Role
        Enabled = $true
        AccountPassword = $DefaultUserPassword
    }
    New-ADUser @splat
}

# create Groups
$departments = $UsersCsv.Department | Get-Unique
foreach ($department in $departments) {
    New-ADGroup -Name $departments -Path $GroupsOU -GroupCategory Security -GroupScope Universal
}

# add users to groups
foreach ($user in $UsersCsv) {
	Add-ADGroupMember -Identity $user.Department -Members "$($user.GivenName).$($user.SurName)"
}