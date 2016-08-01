<#
.SYNOPSIS

.USAGE

Run this script from the Kansa directory which contains your Baseline and Output directories.
.OUTPUT

#>

$dataDirs = get-childitem -directory | sort Name | where { $_.name -match '(Output|Baseline)_\d{14}$' }
for ($i=1;$i -le $dataDirs.count;$i++ ) { write-host $i":"($dataDirs[$i-1]).Name }
$baselineOutput = $dataDirs[(read-host 'Enter index for baseline directory')-1]
$comparisonOutput = $dataDirs[(read-host 'Enter index for comparison directory')-1]

$baselineGroups = get-childitem $baselineOutput -directory -filter '_Grouping' | get-childitem -directory 
$comparisonGroups = get-childitem $comparisonOutput -directory -filter '_Grouping' | get-childitem -directory 

$matchingProfiles = compare-object $baselineGroups $comparisonGroups -includeequal -passthru | where { $_.sideindicator -eq '==' }
$matchingProfiles.count
$matchingProfiles

for ($i=1;$i -le $matchingProfiles.count;$i++ ) { write-host $i":"($matchingProfiles[$i-1]).Name }
$analysisProfile = $matchingProfiles[(read-host 'Enter index for profile to analyze')-1]

$analysisProfile

$analysisProfile | get-childitem -directory -filter analysisReports
$baselineAnalysisFiles = $analysisProfile | get-childitem -directory -filter analysisReports | get-childitem -filter *.csv
$baselineAnalysisFiles.count
$comparisonGroups | where { $_.name -eq $analysisProfile.Name } |  get-childitem -directory -filter analysisReports
$comparisonAnalysisFiles = $comparisonGroups | where { $_.name -eq $analysisProfile.Name } |  get-childitem -directory -filter analysisReports | get-childitem -filter *.csv
$comparisonAnalysisFiles.count

$moduleAnalysis = compare-object $baselineAnalysisFiles $comparisonAnalysisFiles -includeequal -passthru | where { $_.sideindicator -eq '==' }
$moduleAnalysis.count
$moduleAnalysis

for ($i=1;$i -le $moduleAnalysis.count;$i++ ) { write-host $i":"($moduleAnalysis[$i-1]).Name }
$analysisItem = $moduleAnalysis[(read-host 'Enter index for module to analyze')-1]

write-host "AnalysisItem:"$analysisItem

$atBaseline = import-csv $analysisItem.fullName
$comparisonAnalysisFiles | where { $_.name -eq $analysisItem.Name }
$atNow = import-csv ($comparisonAnalysisFiles | where { $_.name -eq $analysisItem.Name }).fullName
$dataItemProperty = $atNow | gm | where { $_.MemberType -eq 'NoteProperty' -and $_.Name -ne 'ct' }
$dataItemProperty

compare-object $atBaseline.($dataItemProperty.Name) $atNow.($dataItemProperty.Name) -includeequal | where { $_.SideIndicator -ne '==' }

	
	
		