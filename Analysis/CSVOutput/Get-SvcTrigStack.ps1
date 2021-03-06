<#
.SYNOPSIS
Get-SvcTrigStack.ps1
Requires logparser.exe in path
Pulls stack rank of Service Triggers from acquired Service Trigger data

This script expects files matching the pattern *svctrigs.csv to be in 
the current working directory.

Simsay, Jason: Modified for LogParser output to CSV.
.NOTES
DATADIR SvcTrigs
#>

if (Get-Command logparser.exe) {

    $lpquery = @"
    SELECT
        COUNT(Type, Subtype, Data) as ct, 
        ServiceName, 
        Action, 
        Type,
        Subtype, 
        Data 
    FROM
        *svctrigs.csv
    GROUP BY
        ServiceName, 
        Action, 
        Type,
        Subtype, 
        Data 
    ORDER BY
        ct ASC
"@

    & logparser  -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
