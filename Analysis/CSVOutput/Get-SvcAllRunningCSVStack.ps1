<#
.SYNOPSIS
Get-LocalAdminStack.ps1
Requires logparser.exe in path
Pulls frequency of local admin account entries

This script expects files matching the *SvcAll.tsv pattern to be in the
current working directory.
.NOTES
DATADIR SvcAll
#>


if (Get-Command logparser.exe) {
    $lpquery = @"
SELECT 
	COUNT([PSComputerName]) as CNT,
	[Name],
	[State],
	[StartMode]
FROM *-SvcAll.csv
WHERE StartMode = 'Auto' OR State = 'Running'
GROUP BY
	[Name],
	[State],
	[StartMode]
ORDER BY
	 CNT DESC

"@

#    & logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"
	& logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
