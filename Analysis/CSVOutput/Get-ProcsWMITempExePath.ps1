<#
.SYNOPSIS
Get-ProcsWMITempExePath.ps1

Returns DISTINCT process CreationDate, ProcessId, ParentProcessId, CommandLine, 
PSComputerName for any processes with ExecutablePaths containing Temp, Tmp or 
AppData\Local, common temporary folders

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
        ExecutablePath,
        CommandLine,
        PSComputerName
    FROM
        *ProcsWMI.csv
    WHERE
        ExecutablePath LIKE '%Temp%' or
        ExecutablePath LIKE '%Tmp%' or
        ExecutablePath LIKE '%AppData\\Local%'
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
