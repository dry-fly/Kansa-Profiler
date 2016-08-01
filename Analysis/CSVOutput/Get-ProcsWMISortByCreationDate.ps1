<#
.SYNOPSIS
Get-ProcsWMISortByStartTime.ps1

Returns process CreationDate, ProcessId, ParentProcessId, CommandLine

Requires:
Process data matching *ProcWMI.tsv in pwd
logparser.exe in path
.NOTES
DATADIR ProcsWMI
#>

if (Get-Command logparser.exe) {
    $lpquery = @"
    SELECT DISTINCT
        CreationDate,
        ProcessId,
        ParentProcessId,
        CommandLine,
        PSComputerName
    FROM
        *ProcsWMI.csv
    ORDER BY
        PSComputerName,
        CreationDate,
        ProcessId ASC
"@

    & logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
