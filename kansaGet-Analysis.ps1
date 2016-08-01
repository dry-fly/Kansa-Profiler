function Get-Analysis {
<#
.SYNOPSIS
Runs analysis scripts as specified in .\Analyais\Analysis.conf
Saves output to AnalysisReports folder under the output path
Fails silently, but logs errors to Error.log file
#>
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$OutputPath,
    [Parameter(Mandatory=$True,Position=1)]
        [String]$StartingPath
)
    Write-Debug "Entering $($MyInvocation.MyCommand)"
    $Error.Clear()

    if (Get-Command -Name Logparser.exe) {
        $AnalysisScripts = @()
		$AnalysisScripts = Get-Content "$StartingPath\Analysis\Analysis.conf" | Foreach-Object { $_.Trim() } | ? { $_ -gt 0 -and (!($_.StartsWith("#"))) }
        $AnalysisOutPath = $OutputPath + "\AnalysisReports\"
		write-host "AnalysisOutPath:"$AnalysisOutPath
        [void] (New-Item -Path $AnalysisOutPath -ItemType Directory -Force)
		
        # Get our DATADIR directive
        $DirectivesHash  = @{}
        $AnalysisScripts | Foreach-Object { $AnalysisScript = $_
            write-host "AnalysisScript:"$AnalysisScript
			$DirectivesHash = Get-Directives $AnalysisScript -AnalysisPath
            $DataDir = $($DirectivesHash.Get_Item("DATADIR"))
            write-host "OutputPathDataDir:"$OutputPath$DataDir
			if ($DataDir) {
                if (Test-Path "$OutputPath\$DataDir") {
					Push-Location
                    Set-Location "$OutputPath\$DataDir"
                    Write-Verbose "Running analysis script: ${AnalysisScript}"
                    $AnalysisFile = ((((($AnalysisScript -split "\\")[1]) -split "Get-")[1]) -split ".ps1")[0]
                    # GCIH - Converted analysis outputs to CSV
                    & "$StartingPath\Analysis\${AnalysisScript}" | Set-Content -Encoding $Encoding ($AnalysisOutPath + $AnalysisFile + ".csv")
					Pop-Location

                } else {
                    "WARNING: Analysis: No data found for ${AnalysisScript}." | Add-Content -Encoding $Encoding $ErrorLog
                    Continue
                }
            } else {
                "WARNING: Analysis script, .\Analysis\${AnalysisScript}, missing # DATADIR directive, skipping analysis." | Add-Content -Encoding $Encoding $ErrorLog
                Continue
            }        
        }
    } else {
        "Kansa could not find logparser.exe in path. Skipping Analysis." | Add-Content -Encoding $Encoding -$ErrorLog
    }
    # Non-terminating errors can be checked via
    if ($Error) {
        # Write the $Error to the $Errorlog
        $Error | Add-Content -Encoding $Encoding $ErrorLog
        $Error.Clear()
    }
    Write-Debug "Exiting $($MyInvocation.MyCommand)"    
} # End Get-Analysis

function Get-Directives {
<#
.SYNOPSIS
Returns a hashtable of directives found in the script
Directives are used for two things:
1) The BINDEP directive tells Kansa that a module depends on some 
binary and what the name of the binary is. If Kansa is called with 
-PushBin, the script will look in Modules\bin\ for the binary and 
attempt to copy it to targets.
2) The DATADIR directive tells Kansa what the output path is for
the given module's data so that if it is called with the -Analysis
flag, the analysis scripts can find the data.
TK Some collector output paths are dynamically generated based on
arguments, so this breaks for analysis. Solve.
#>
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$Module,
    [Parameter(Mandatory=$False,Position=1)]
        [Switch]$AnalysisPath
)
    Write-Debug "Entering $($MyInvocation.MyCommand)"
    $Error.Clear()
    if ($AnalysisPath) {
        #GCIH - Had to use '..' instead of '.'
		$Module = "..\Analysis\" + $Module
    }

    if (Test-Path($Module)) {
        
        $DirectiveHash = @{}

        Get-Content $Module | Select-String -CaseSensitive -Pattern "BINDEP|DATADIR" | Foreach-Object { $Directive = $_
            if ( $Directive -match "(^BINDEP|^# BINDEP) (.*)" ) {
                $DirectiveHash.Add("BINDEP", $($matches[2]))
            }
            if ( $Directive -match "(^DATADIR|^# DATADIR) (.*)" ) {
                $DirectiveHash.Add("DATADIR", $($matches[2])) 
            }
        }
        $DirectiveHash
    } else {
        "WARNING: Get-Directives was passed invalid module $Module." | Add-Content -Encoding $Encoding $ErrorLog
    }
}
