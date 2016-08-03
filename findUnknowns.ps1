<#
.SYNOPSIS
The script will identify items unique to either the current or baseline collection and not present 
in both.  The user specifies the location of the current and previously collected baseline data set.   
The script will look for matching profile directories within the data sets.
.USAGE
You must have previously created common profiles in the Baseline and current Output directories.
Run this script from the Kansa directory which contains your Baseline and Output directories.
User will identify which available AnalysisResults items to compare.
.OUTPUT
Output identifies data items unique to either the baseline or comparison analysis results.

#>

# Display available Output directories and acquire user input for baseline output and output for comparison
$dataDirs = get-childitem -directory | sort Name | where { $_.name -match '(Output|Baseline)_\d{14}$' }
for ($i=1;$i -le $dataDirs.count;$i++ ) { write-host $i":"($dataDirs[$i-1]).Name }
$baselineOutput = $dataDirs[(read-host 'Enter index for baseline directory')-1]
$comparisonOutput = $dataDirs[(read-host 'Enter index for comparison directory')-1]

# Get previously created profile directories within the _Profiles directory
$baselineGroups = get-childitem $baselineOutput -directory -filter '_Profiles' | get-childitem -directory 
$comparisonGroups = get-childitem $comparisonOutput -directory -filter '_Profiles' | get-childitem -directory 

# Identify previously created profile directories common to the baseline and comparison output directories
$matchingProfiles = compare-object $baselineGroups $comparisonGroups -includeequal -passthru | where { $_.sideindicator -eq '==' }
$matchingProfiles.count
$matchingProfiles

# Display available common profiles for analysisResults comparison and acquire user input for profile to perform comparative analysis
for ($i=1;$i -le $matchingProfiles.count;$i++ ) { write-host $i":"($matchingProfiles[$i-1]).Name }
$analysisProfile = $matchingProfiles[(read-host 'Enter index for profile to analyze')-1]

# Don't think the output of analysisProfile is needed
#$analysisProfile
#$analysisProfile | get-childitem -directory -filter analysisReports

# Get analysis files for profile that are present in baseline output
$baselineAnalysisFiles = $analysisProfile | get-childitem -directory -filter analysisReports | get-childitem -filter *.csv
$baselineAnalysisFiles.count

# Get analysis files for profile that are present in the comparison output
$comparisonGroups | where { $_.name -eq $analysisProfile.Name } |  get-childitem -directory -filter analysisReports
$comparisonAnalysisFiles = $comparisonGroups | where { $_.name -eq $analysisProfile.Name } |  get-childitem -directory -filter analysisReports | get-childitem -filter *.csv
$comparisonAnalysisFiles.count

# Get analysis files common to baseline and comparison output
$moduleAnalysis = compare-object $baselineAnalysisFiles $comparisonAnalysisFiles -includeequal -passthru | where { $_.sideindicator -eq '==' }
$moduleAnalysis.count
$moduleAnalysis

# Display and acquire user selection of analysis outputs to compare
for ($i=1;$i -le $moduleAnalysis.count;$i++ ) { write-host $i":"($moduleAnalysis[$i-1]).Name }
$analysisItem = $moduleAnalysis[(read-host 'Enter index for module to analyze')-1]
write-host "AnalysisItem:"$analysisItem

# Load analysis result CSV files to PowerShell objects for comparison
$atBaseline = import-csv $analysisItem.fullName
$comparisonAnalysisFiles | where { $_.name -eq $analysisItem.Name }
$atNow = import-csv ($comparisonAnalysisFiles | where { $_.name -eq $analysisItem.Name }).fullName
$dataItemProperty = $atNow | gm | where { $_.MemberType -eq 'NoteProperty' -and $_.Name -ne 'ct' }
$dataItemProperty

# Compare PowerShell objects, showing items that are unique to either the baseline or comparison data set
compare-object $atBaseline.($dataItemProperty.Name) $atNow.($dataItemProperty.Name) -includeequal | where { $_.SideIndicator -ne '==' }

	
	
		