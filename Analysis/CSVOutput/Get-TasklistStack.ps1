<#
.SYNOPSIS
Get-LocalAdminStack.ps1
Requires logparser.exe in path
Pulls frequency of local admin account entries

This script expects files matching the *SCVAll.csv pattern to be in the
current working directory.

Simsay, Jason: Modified for LogParser output to CSV.
.NOTES
DATADIR Tasklistv
#>

if (Get-Command logparser.exe) {
    $lpquery = @"
SELECT
        COUNT([PSComputerName]) as CNT,
        [ImageName],
        [SessionName]
FROM *-Tasklistv.csv
GROUP BY
        [ImageName],
        [SessionName]
ORDER BY
         CNT DESC

"@

#    & logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"
#	& logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery
& logparser -stats:off -i:csv -dtlines:0 -o:csv "$lpquery"

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
