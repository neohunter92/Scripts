<#
    .SYNOPSIS
        Setting up autoreply messages for multiple users.
    
    .DESCRIPTION  
        Setting up internal and external autoreply messages for multiple users
    .NOTES
        Version 1.0
    .COMPONENT
        Requires Module ActiveDirectory
    .LINK
        GITHUBLINK #TODO
    .Parameter ConnectionUri
        Specifies the link for the exchange server.
        [sr-de] Exchange Verbindungslink.
    .Parameter Identity
        Specifies the users.
        [sr-de] Parameter für die User.
    .Parameter AutoReplyState
        Specifies the state of the autoreply message.
        [sr-de] Definiert die Autoreply.
    .Parameter InternalMessage
        Specifies the state the internal message.
        [sr-de] Definiert die interne Nachricht.
    .Parameter ExternalMessage
        Specifies the state the external message.
        [sr-de] Definiert die externe Nachricht.    
    .Parameter StartTime
        Specifies the start time for the scheduled autoreply.
        [sr-de] Definiert die start Datum für die autoreply.
    .Parameter EndTime
        Specifies the end time for the scheduled autoreply.
        [sr-de] Definiert die end Datum für die autoreply.
    .EXAMPLE
        PS C:\ScriptPath> $Message = @"
        <html><head></head><body><p>Sehr geehrte Damen und Herren,
        </br>
        </br>Ich bin zurzeit nicht erreichbar.
        </br>
        </br>Mit freundlichen Grüßen,
        </br>$($User.Givenname) $($User.Surname)</p></body></html>
        "@
        PS C:\ScriptPath> .\SetAutoReplyForMoreUsers.ps1 -ConnectionUri http://Mail.contoso.com/powershell -Identity UserName1, UserName2 -AutoReplyState Scheduled -StartTime 11.07.2020 11:00 -EndTime 11.21.2020 13:00 -InternalMessage $Message -ExternalMessage $Message

        Setting scheduled autoreply between 11.07.2020 11:00 and 11.21.2020 13:00 for the UserName1 and Username2 with the text from the variable message.
    
        .EXAMPLE
        PS C:\ScriptPath> $Message = @"
        <html><head></head><body><p>Sehr geehrte Damen und Herren,
        </br>
        </br>Ich bin zurzeit nicht erreichbar.
        </br>
        </br>Mit freundlichen Grüßen,
        </br>$($User.Givenname) $($User.Surname)</p></body></html>
        "@
        PS C:\ScriptPath> .\SetAutoReplyForMoreUsers.ps1 -ConnectionUri http://Mail.contoso.com/powershell -Identity UserName1, UserName2 -AutoReplyState Enabled -InternalMessage $Message -ExternalMessage $Message

        Setting unlimited autoreply time for the UserName1 and Username2 with the text from the variable message.

        .EXAMPLE
        PS C:\ScriptPath> .\SetAutoReplyForMoreUsers.ps1 -ConnectionUri http://Mail.contoso.com/powershell -Identity UserName1, UserName2 -AutoReplyState Disabled

        Disabling autoreply message for the users.
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory)]
    [ValidateNotNullorEmpty()]
    [string]$ConnectionUri,
    [Parameter(Position = 1, Mandatory)]
    [String[]]$Identity,
    [Parameter(Position = 2, Mandatory)]
    [ValidateSet('Enabled', 'Disabled', 'Scheduled')]
    [string]$AutoReplyState,
    [string]$InternalMessage,
    [string]$ExternalMessage,
    [string]$StartTime,
    [string]$EndTime
) #param

BEGIN {
    Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
    Import-Module ActiveDirectory
    $Result = @()
    $Users = @()
} #BEGIN

PROCESS {
    Write-Verbose "[PROCESS] Opening remote connection to the exchange server"
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri
    foreach ($item in $Identity) {
        $Users += Get-ADUser -Identity $Item -Properties DisplayName
    }
    switch ($AutoReplyState) {
        Enabled {
            foreach ($User in $Users) {
                Write-Verbose "[PROCESS] Enabling autoreply for $($User.DisplayName)"
                $null = Invoke-Command -Session $Session -ScriptBlock {
                    Set-MailboxAutoReplyConfiguration -Identity $using:User.SamAccountName -AutoReplyState Enabled -InternalMessage $using:InternalMessage -ExternalMessage $using:ExternalMessage
                }
                $Result += "Autoreply for $($User.DisplayName) is actived."
            }
        }
        Disabled {
            foreach ($User in $Users) {
                Write-Verbose "[PROCESS] Disabling autoreply for $($User.DisplayName)"
                $null = Invoke-Command -Session $Session -ScriptBlock {
                    Set-MailboxAutoReplyConfiguration -Identity $using:User.SamAccountName -AutoReplyState Disabled
                }
                $Result += "Autoreply for $($User.DisplayName) is deactivated."
            }
            
        }
        Scheduled {
            foreach ($User in $Users) {
                Write-Verbose "[PROCESS] Scheduling autoreply for $($User.DisplayName) between $StartTime and $EndTime"
                $null = Invoke-Command -Session $Session -ScriptBlock {
                    Set-MailboxAutoReplyConfiguration -Identity $using:User.SamAccountName -AutoReplyState Scheduled -StartTime $using:StartTime -EndTime $using:EndTime -InternalMessage $using:InternalMessage -ExternalMessage $using:ExternalMessage
                }
                $Result += "Autoreply for $($User.DisplayName) is actived between $StartTime and $EndTime."
            }
        }
    }
    Write-Verbose "[PROCESS] Closing connection to the exchange server"
    Remove-PSSession -Session $Session
} #PROCESS

END {
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    $Result | Out-Host
} #END