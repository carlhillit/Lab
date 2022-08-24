<#
.SYNOPSIS
    Locks randomly selected Active Directory accounts in bulk.
.DESCRIPTION
    Intentionally locks a specified number of Active Directory users selected at random, or locks a percentage of all Active Directory users chosen at random.
.NOTES
    Used to expiriment with large number of locked user accounts. It is intened for use in a testing environment.
.EXAMPLE
    RandomlyLockUsers.ps1 -NumbertoLock 10 -LockoutThreshold 3 -OrganizationalUnit 'OU=Users,OU=LAB,DC=breakdown,DC=lab'
    RandomlyLockUsers.ps1 -PercentToLock 20 -LockoutThreshold 3 -OrganizationalUnit 'OU=Users,OU=LAB,DC=breakdown,DC=lab'
#>

[CmdletBinding()]
param (

    # number of users to lock out
    [Parameter(ParameterSetName = 'NumberToLock')]
    [int]
    $NumberToLock,

    # Percentage of users in the OU/domain to lock out
    [Parameter(ParameterSetName = 'PercentToLock')]
    [int]
    $PercentToLock,

    # number of times allowed for failed logon attempts before lockout
    [Parameter(Mandatory)]
    [int]
    $LockoutThreshold,

    # Organizational Unit to search for users to lock out
    [Parameter()]
    [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
    $OrganizationalUnit
)


begin {
    $NetBiosName = (Get-ADDomain).NetBiosName

    $Users = Get-ADUser -Filter * -SearchBase $OrganizationalUnit

    if ($PercentToLock) {

        $NumberOfUsers = [math]::Round($Users.Count * $PercentToLock/100)

    }

    if ($NumberToLock) {

        $NumberOfUsers = $NumberToLock
    
    }

}

process {


    $SelectedUsers = 1..$NumberOfUsers | ForEach-Object{

        Get-Random -InputObject $Users
        
    }
   

    foreach ($User in $SelectedUsers) {

        $username = "$NetBiosName\$($User.SamAccountName)"
        $badPassword = 'BadPa$$w0rd' | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$badPassword

        1..$LockoutThreshold | ForEach-Object {

            Invoke-Command -ComputerName $env:COMPUTERNAME -ScriptBlock {"lockmeout"} -Credential $cred -ErrorAction SilentlyContinue
            
        }

    }


}

end {

    $SelectedUsers | Get-ADUser -Properties LockedOut

}
