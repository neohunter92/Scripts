function Test-GroupDescription {
    <#
    .SYNOPSIS
        Testet die Gruppenbeschreibungen mit den angegegebenen Pattern.

    .DESCRIPTION
        Testet die Gruppenbeschreibungen mit den angegegebenen Pattern, wenn der Match Parameter angegeben wird, werden die Gruppen aufgelistet wo die Pattern übereinstimmen.
        Wenn der Match Parameter nicht mitgegeben wird, dann werden alle Gruppen ausgegeben, welche nicht übereinstimmen.
        Die Angabe von Searchbase, Pattern und Filter Parameter sind zwingend erforderlich.

    .COMPONENT
        Benötigt ActiveDirectory Modul.

    .Parameter Searchbase
        Definiert die Searchbase, wo das Skript im AD nach die Objekte suchen muss.

    .Parameter Pattern
        Definiert die regular Expression.

    .Parameter Filter
        Definiert die Filter für die AD Objekte.

    .Parameter Match
        Definiert ob die Ergebnis mit der Regular Expression übereinstimmen muss oder nicht.

    .EXAMPLE
        PS C:\>Test-GroupDescription -Searchbase "OU=Users, DC=Contoso, DC=COM" -Pattern "([A-Z])\w+" -Filter * -Match

        Testet die übereinstimmenden Gruppenbeschreibungen mit den angegegebenen Pattern. 
    .EXAMPLE
        PS C:\>Test-GroupDescription -Searchbase "OU=Users, DC=Contoso, DC=COM" -Pattern "([A-Z])\w+" -Filter *

        Testet die nicht übereinstimmenden Gruppenbeschreibungen mit den angegegebenen Pattern.

    .LINK
        https://github.com/neohunter92/Scripts

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='Bitte Distinguished Name der OU eingeben')][string]$Searchbase,
        [Parameter(Mandatory=$true,HelpMessage='Regular Expresssion eingeben')][string]$Pattern,
        [Parameter(Mandatory=$true)][string]$Filter,
        [switch]$Match
    )
    BEGIN{
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
        Write-Verbose "[BEGIN  ] Importing Module: ActiveDirectory"
        Import-Module ActiveDirectory
        $Result = @()
    } #BEGIN

    PROCESS{
        Write-Verbose "[PROCESS] Getting ADGroups from AD"
        $Groups = Get-ADGroup -SearchBase $Searchbase -Filter $Filter -Properties Name, Description
        if ($Match) {
            foreach ($Group in $Groups) {
                if ($Group.Description -match $Pattern) {
                    Write-Verbose "[PROCESS] Adding group $Group to the result variable, because the pattern matches"
                    $Result += $Group
                } #if
            } #foreach   
        } else {
            foreach ($Group in $Groups) {
                if ($Group.Description -notmatch $Pattern) {
                    Write-Verbose "[PROCESS] Adding group $Group to the result variable, because the pattern not matches"
                    $Result += $Group
                } #if
            } #foreach
        } #if
    } #PROCESS

    END{
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
        $Result | Out-Host
    } #END
} #Function
