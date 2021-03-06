<#
.SYNOPSIS
Get-NetstatStack.ps1
Requires logparser.exe in path
Pulls stack rank of Netstat connections
based on local and foreign address (no
ports) and processes.

You may want to customize this a bit for
your environment. If you're running web 
servers, for example, stacking them may be
meaningless if they are meant to accept 
connections from any host in the world, or
maybe you just remove the web server process
from the query...

!! YOU WILL LIKELY WANT TO ADJUST THIS QUERY !!

This script exepcts files matching the pattern 
*netstat.csv to be in the current working
directory

Simsay, Jason: Modified for LogParser output to CSV.
.NOTES
DATADIR Netstat
#>

if (Get-Command logparser.exe) {

    $lpquery = @"
    SELECT
        COUNT(Protocol,
        LocalAddress,
        ForeignAddress,
        State,
        ConPId,
        Component,
        Process) as ct,
        Protocol,
        LocalAddress,
        ForeignAddress,
        State,
        ConPid,
        Component,
        Process
    FROM
        *netstat.csv
    WHERE
        ConPid not in ('0'; '4') and
        ForeignAddress not like '10.%' and
        ForeignAddress not like '169.254%' and
        ForeignAddress not in ('*'; '0.0.0.0'; 
            '127.0.0.1'; '[::]'; '[::1]')
    GROUP BY
        Protocol,
        LocalAddress,
        ForeignAddress,
        State,
        ConPid,
        Component,
        Process
    ORDER BY
        Process,
        ct desc
"@

    & logparser -stats:off -i:csv -dtlines:0 -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
