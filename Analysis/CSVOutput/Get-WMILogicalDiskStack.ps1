<#
.SYNOPSIS
Get-WMILogicalDiskStack.ps1
Requires logparser.exe in path
Pulls frequency of local admin account entries

This script expects files matching the *WMILogicalDisk.csv pattern to be in the
current working directory.
.NOTES
DATADIR WMILogicalDisk
#>

if (Get-Command logparser.exe) {
    $lpquery = @"
SELECT 
	COUNT([PSComputerName]) as CNT,
	[Caption],
	[Description]
FROM *-WMILogicalDisk.csv
GROUP BY
	[Caption],
	[Description]
ORDER BY
	 CNT DESC
"@

#    & logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"
	& logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
