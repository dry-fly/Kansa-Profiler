<#
.SYNOPSIS
Get-ProcsWMICmdLineStack.ps1

Pulls frequency of processes based on path CommandLine

Requires:
Process data matching *ProcWMI.csv in pwd
logparser.exe in path

Simsay, Jason: Modified for LogParser output to CSV.
.NOTES
DATADIR ProcsWMI
#>

if (Get-Command logparser.exe) {
    $lpquery = @"
    SELECT
        COUNT(CommandLine) as ct,
        CommandLine
    FROM
        *ProcsWMI.csv
    GROUP BY
        CommandLine
    ORDER BY
        ct ASC
"@

    & logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
