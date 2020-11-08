<#
    .SYNOPSIS
        Validate whether the user exists or not.
    
    .DESCRIPTION  
        Checks every folder in the userhome and validate wether the user of the folder exists or not.
    .NOTES
        Version 1.0
    .COMPONENT
        Requires Module ActiveDirectory
    .LINK
        GITHUBLINK #TODO
    .Parameter Path
        Specifies the path for the userhome folder
        [sr-de] Pfad für den Userhome Ordner
    .Parameter ComputerName
        Remote computer name where the userhome folder exists
        [sr-de] Computer Name wo die Userhome Ordner vorhanden sind        
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory, HelpMessage='Please enter remote computer name')]
    [ValidateNotNullorEmpty()]
    [String]$ComputerName,
    [Parameter(Mandatory, HelpMessage='Please enter path to user userhome folder')]
    [string]$Path
)

BEGIN{
    Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
    Import-Module ActiveDirectory
    $Result = @()
} #BEGIN

PROCESS{
    Write-Verbose "[PROCESS] Opening remote connection to $($ComputerName.ToUpper())"
    $UserProfiles = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
        Get-ChildItem -Path $using:Path -Directory
    }
    foreach ($User in $UserProfiles.Name) {
        try {
            Write-Verbose "[PROCESS] Checking wether the User: $User exists in AD or not"
            $null = Get-ADUser $User
        } #try
        catch {
            Write-Verbose "[PROCESS] User $User not exists"
            $Result += "$User not exists, but home directory is still present"
        } #catch
    } #foreach
} #PROCESS

END{
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    $Result | Out-Host
} #END