<#
.SYNOPSIS
Get-DNSCacheStack.ps1
Requires logparser.exe in path
Pulls frequency of DNSCache entries

This script expects files matching the *DNSCache.csv pattern to be in the
current working directory.

Simsay, Jason: Modified for LogParser output to CSV.
.NOTES
DATADIR DNSCache
#>


if (Get-Command logparser.exe) {
    $lpquery = @"
    SELECT
        COUNT(Entry) as ct,
        Entry
    FROM
        *DNSCache.csv
    GROUP BY
        Entry
    ORDER BY
        ct ASC
"@

    & logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}

