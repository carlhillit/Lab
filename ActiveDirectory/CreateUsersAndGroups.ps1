$Domain = 'karl.lab'
$UsersCsv = Import-Csv -Path .\50CommonNames-EN.csv
$UsersOU = "OU=Users,OU=HOMELAB,DC=karl,DC=lab"
$GroupsOU = "OU=Groups,OU=HOMELAB,DC=karl,DC=lab"

$DefaultUserPassword = Read-Host -Prompt 'Enter the default user password' | ConvertTo-SecureString -AsPlainText -Force

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
$roles = $UsersCsv.Role | Get-Unique
foreach ($role in $roles){
    New-ADGroup -Name $role -Path $GroupsOU -GroupCategory Security -GroupScope Universal
}

# add users to groups
foreach ($role in $roles) {
    Get-ADUser -Filter { Description -like $role } -Properties Description | 
        ForEach-Object { Add-ADGroupMember $role -Members $_.SamAccountName }
}

# create 5 example groups
1..5 | ForEach-Object { New-ADGroup -Name "ExampleGroup$_" -GroupCategory Security -GroupScope Global -Path $GroupsOU }

# randomly add users to example groups
$Users = Get-ADUser -Filter * -SearchBase $UsersOU

foreach ($user in $Users) {
    $rdm = Get-Random -Minimum 1 -Maximum 5
    $rdmgrp = "ExampleGroup$rdm"
    Add-ADGroupMember -Identity $rdmgrp -Members $user
}