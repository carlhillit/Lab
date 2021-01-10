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
    $OrganizationalUnit = 'OU=Users,OU=LAB,DC=breakdown,DC=lab'
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

    # create random password params
    Add-Type -AssemblyName 'System.Web'
    $pwLength = Get-Random -Minimum 25 -Maximum 30
    $spcChars = 5
    

    foreach ($User in $SelectedUsers) {

        $username = "$NetBiosName\$($User.SamAccountName)"
        $password = [System.Web.Security.Membership]::GeneratePassword($pwLength,$spcChars) | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

        1..$LockoutThreshold | ForEach-Object {

            Invoke-Command -ComputerName $env:COMPUTERNAME -ScriptBlock {"lockmeout"} -Credential $cred -ErrorAction SilentlyContinue
            
        }

    }


}

end {

    $SelectedUsers

}