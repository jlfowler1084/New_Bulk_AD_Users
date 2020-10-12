
function New-BulkADUser {
<#
.SYNOPSIS
Creates Active Directory user accounts in Bulk

.DESCRIPTION
This command uses the "new-aduser" CMDLET to create Active Directory user accounts in Bulk.
The "Users" value allows you to enter multiple strings to create the first part of the user ID. 
For instance, if we wanted to create a user account of "AttorneyDC01", you would enter a users value of 
AttorneyDC. The ID is the 2 digit number associated with that account, so you would enter an ID of "01". 
If you wanted to create 5 AttorneyDC accounts, you would enter the ID values of 01,02,03,04,05. The function
allows for multiple User values and ID values, so entering User values of AttorneyDC, AttorneyBA, AttorneyLA, along with 
ID's of 01,02,03,04,05,06,07,08,09,10, 30 user accounts will be created 
(AttorneyBA01 - 10, AttorneyDC02 - 10, and AttorneyLA01 - 10).

.PARAMETER Users
The user account name without the numbering, i.e., AttorneyBA01 would have a users value of AttorneyBA. 
Multiple Users values are supported

.PARAMETER IDs
The 2-digit number associated with the User Account, i.e., AttorneyBA01 would have an IDs value of 01.
Multiple IDs are supported. Only 2-digit values are supported

.PARAMETER OU
The distinguished name of the OU the accounts should be created in.
For Example:
New-BulkADUser -OU "OU=,OU=,DC=e,DC=com"

.PARAMETER Description
This fills out the Description Attribute of the Active Directory User Account

.PARAMETER Password
The Active Directory User Account Password

.PARAMETER CannotChangePassword
This is a Boolean Operator. If you want to set the account so the user cannot change the password, run the command
with -CannotChangePassword:$True. The Active Directory account will default to $False
For Example:
New-BulkADUser -CannotChangePassword:$True

.PARAMETER ChangePasswordAtLogon
This is a Boolean Operator. If you want to set the account so a password change will be forced at logon, run the command
with -ChangePasswordatLogon:$True. The Active Directory account will default to $False
For Example:
New-BulkADUser -ChangePasswordatLogon:$True

.PARAMETER Enabled
This is a Boolean Operator. If you want to set the account to enabled, run the command
with -enabled:$True. The Active Directory account will be disabled by default
For Example:
New-BulkADUser -enabled:$True

.PARAMETER PasswordNeverExpires
This is a Boolean Operator. If you want to set the account so the password never expires, run the command
with -PasswordNeverExpires:$True. The Active Directory account password will need to be changed after 90 days by default
For Example:
New-BulkADUser -ChangePasswordatLogon:$True

 .EXAMPLE
 New-BulkADUser -Users AttorneyBA,AttorneyDC -IDs 01,02,03
 This example creates User accounts for AttorneyBA01 - 03 and AttorneyDC01 - 03. 
 You will be prompted to enter the OU, description, and account password.

 .EXAMPLE
  New-BulkADUser -enabled:$False -ChangePasswordAtLogon:$False
  The example will set whatever accounts are created to "Enabled" and will not
  force the users to have to change their password at next logon. You will be
  prompted to enter the Users, IDs, Description, OU, and Password, as displayed below

  PS C:\Users\Administrator> New-BulkADUser -Enabled:$false -ChangePasswordatLogon:$false
cmdlet New-BulkADUser at command pipeline position 1
Supply values for the following parameters:
(Type !? for Help.)
Users[0]: AttorneyDC
Users[1]: AttorneyBA
Users[2]: AttorneyLA
Users[3]: 
IDs[0]: 01
IDs[1]: 02
IDs[2]: 03
IDs[3]: 04
IDs[4]: 05
IDs[5]: 
OU: OU=,OU=,DC=,DC=com
Description: Contract Attorneys
Password: 


#>

    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory=$true,
                   ValuefromPipeline=$true,
                   Position=0,
                   HelpMessage='Enter Name Here Without Integer',
                   ValuefromPipelineByPropertyName=$true)]
        [string[]]$Users,
    
        [Parameter(Mandatory=$true,
                   ValuefromPipeline=$true,
                   Position=1,
                   HelpMessage='Enter Integers here in format of 01, 02, 03, etc...',
                   ValuefromPipelineByPropertyName=$false)]
                   [ValidateLength(2,2)]
        [string[]]$IDs,

        [Parameter(Mandatory=$true,
                   ValuefromPipeline=$true,
                   Position=2,
                   HelpMessage='Enter The Organizational Unit Here',
                   ValuefromPipelineByPropertyName=$false)]
        [string]$OU,

        [Parameter(Mandatory=$true,
                   ValuefromPipeline=$true,
                   Position=3,
                   HelpMessage='Enter The Description Here',
                   ValuefromPipelineByPropertyName=$false)]
        [string]$Description,

        [Parameter(Mandatory=$true,
                   ValuefromPipeline=$true,
                   Position=4,
                   HelpMessage='Enter The Users Password')]
        [string]$Password, 
        
        [bool]$CannotChangePassword,
        [bool]$ChangePasswordatLogon,
        [bool]$Enabled,
        [bool]$PasswordNeverExpires
        
    )


    $fullAccounts = @(foreach ($user in $users) {
        foreach ($id in $IDs) {
            $user + $id
        }
    })

    foreach ($account in $fullAccounts) {
        $Attributes = @{Path = $OU;
            UserPrincipalName = "$Account@Venable.com";
            Name = $Account;
            samAccountName = $account;
            Description = $Description;
            DisplayName = $Account;
            CannotChangePassword = $CannotChangePassword;
            ChangePasswordatLogon = $ChangePasswordatLogon;
            AccountPassword = (ConvertTo-SecureString $password -AsPlainText -Force);
            Enabled = $Enabled;
            PasswordNeverExpires = $PasswordNeverExpires
            }               
        
if ($pscmdlet.ShouldProcess("The Following Accounts will be Created in $OU $fullAccounts")) {         
New-ADUser @Attributes }

    }
}

