<#
.SYNOPSIS
Get-PrefetchListingStack.ps1
Requires logparser.exe in path
Pulls stack rank of prefetch files based
on collected Get-PrefetchListing data.

This script exepcts files matching the pattern 
*PrefetchListing.csv (CORRECTION, was '.tsv') to be in the current working
directory

Simsay, Jason: Modified for LogParser output to CSV.
.NOTES
DATADIR PrefetchListing
#>

if (Get-Command logparser.exe) {

    $lpquery = @"
    SELECT
        COUNT(FullName) as CT,
        FullName
    FROM
        *PrefetchListing.csv
    GROUP BY
        FullName
    ORDER BY
        ct
"@

#    & logparser -stats:off -i:tsv -fixedsep:on -dtlines:0 -rtp:-1 $lpquery
& logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
