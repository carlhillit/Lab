$OU = 'OU=Users,OU=LAB,DC=breakdown,DC=lab'

$LockoutThreshold = 5 # number of bad password attempts set by GPO

$PercentToLock = 50 # locks 50% of user in $OU



$Users = Get-ADUser -Filter * -SearchBase $OU

$NumberRounded = [math]::Round($Users.Count * $PercentToLock/100)

$SelectedUsers = 1..$NumberRounded | ForEach-Object{
    Get-Random -InputObject $Users
}


foreach ($User in $SelectedUsers) {

    $username = "breakdown\$($User.SamAccountName)"
    $password = '9ijnht5%TGBHU*&YGVFR$4rfvgy7' | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

    1..$LockoutThreshold | ForEach-Object{
        Invoke-Command -ComputerName WIN101 -ScriptBlock {"hi"} -Credential $cred
    }

}

