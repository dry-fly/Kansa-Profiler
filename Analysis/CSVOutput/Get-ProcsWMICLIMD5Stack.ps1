<#
.SYNOPSIS
Get-ProcsWMICLIStack.ps1

Returns frequency of "CommandLine," which is
ExecutablePath and command line arguments and hash
of file on disk

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
        COUNT(CommandLine) as Cnt,
        CommandLine,
        Hash
    FROM
        *ProcsWMI.csv
    GROUP BY
        CommandLine,
        Hash
    ORDER BY
        Cnt ASC
"@

    & logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
