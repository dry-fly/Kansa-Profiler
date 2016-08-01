<#
.SYNOPSIS

.USAGE

.OUTPUT

.PARAMETER Analysis
An optional switch that causes Kansa to run automated analysis based on
the contents of the Analysis\Analysis.conf file.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=13)]
        [Switch]$Analysis
)

. "c:\tools\kansa-master\kansaGet-Analysis.ps1"

$targets = import-csv .\_Profiles\profilingDatabase.csv
write-host "Targets available:"$targets.count
$groupOptions = $targets[0] | gm | where { $_.memberType -eq 'NoteProperty'}
$groupOptions
#$filterOptions = $groupOptions | where { $_.memberType -eq 'NoteProperty'}
for ($i=1;$i -le $groupOptions.count;$i++ ) { write-host $i":"($groupOptions[$i-1]).Name }
$groupLevels = @()

#<#
while ($index -ne 'quit') {
	$index = read-host "Enter grouping indexes one at a time ('quit' when done)"
	if ($index -ne 'quit' ) { $groupLevels += ($groupOptions[$index-1]).Name }
}
clear-variable index
##>
#$groupLevels = @(($groupOptions[5]).Name,($groupOptions[6]).Name,($groupOptions[3]).Name)

$groupLevelsValue = ($groupLevels -join ",") -replace ',$',''
#$filterScriptBlock = '$targets | select ' + $filterValue + ' | sort ' + $filterValue + ' | group ' + $filtervalue + ' | select count,name | ft -autosize '
$groupScriptBlock = '$targets | sort ' + $groupLevelsValue + ' | group ' + $groupLevelsvalue

write-host "Filter value:"$groupLevelsValue
#$targets | select $filters[0],$filters[1] | sort $filters[0],$filters[1] | group $filters[0],$filters[1] | select count,name | ft -autosize
$groupedTargets = invoke-expression -command "$groupScriptBlock"
for ($i=1;$i -le $groupedTargets.count;$i++ ) { write-host $i":"($groupedTargets[$i-1]).Name }
$filterSelection = @()

#<#
while ($index -ne 'quit') {
	$index = read-host "Enter filter indexes one at a time ('quit' when done)"
	if ($index -ne 'quit') { $filterSelection += ($index - 1) }
}
##>
#$filterSelection = @(3,4,8)
$filterSelection
$filterSelection | foreach { $filteredTargets = $filteredTargets + $groupedTargets[$_].Group }
write-host "Filtered targets:" $filteredTargets.count
$analyze = $filteredTargets.count
$filteredTargets | select computerName,canonicalPath,operatingsystem,osarchitecture,hwModel | ft -autosize
switch (read-host "Do you want to analyze this group?") {
	'Y' {}
	default { $analyze = 0 }
}
if ( $analyze -gt 0 ) {
	$filteredDirectoryName = '_Profiles\' + (read-host "Enter name for subdirectory of links to targetData Files")
	$filteredDirectoryName
	$dirReady = $false
	do {
		if (test-path -path $filteredDirectoryName	) {
			switch (read-host "The subdirectory already exists.  Overwrite files and directories?") {
				'Y' { get-childitem $filteredDirectoryName | remove-item -recurse -whatif; $dirReady = $true }
				default { $filteredDirectoryName = '_Profiles\' + (read-host "Enter name for subdirectory of links to target data files") }
			}
		}
		else { new-item -type directory $filteredDirectoryName | out-null; $dirReady = $true }
	}
	until ( $dirReady )


	$searchDirs = get-childitem -Directory | where {-not ($_.Name -like '_*' -or $_.Name -eq 'AnalysisReports') }
	#$searchDirs | foreach { get-childitem $_ | foreach { $_.fullName } }

	$searchDirs | foreach { 
	$matchedOutputFiles = @()
		$pruneModule = $_.Name
		new-item -itemtype directory -path ($filteredDirectoryName + '\' + $pruneModule)
		get-childitem $_ | foreach {
			$test = $_.name -replace ('-' + $pruneModule + '.*$'),''
			$index = $filteredTargets.computerName.indexof($test.toupper())
			if ($index -ne -1) { 
				write-host "matched host" $filteredTargets[$index].computerName "to file" $_.fullname
				cmd.exe /c mklink ($filteredDirectoryName + '\' + $pruneModule + '\' + $_.Name) $_.fullname
				$matchedOutputFiles += $filteredTargets[$index].ComputerName
				}
		} 
		$matchedOutputFiles.count
		compare-object $filteredTargets.computerName $matchedOutputFiles
	}
	# Are we running analysis scripts? #
	if ($Analysis) {
		
		$StartingPath = Get-Location | Select-Object -ExpandProperty Path
		$startingPath = $startingPath -replace '\\Output_\d{14}$',''
		Set-Variable -Name ErrorLog -Value ($filteredDirectoryName + "\Error.Log") -Scope Script
		Set-Variable -Name Encoding -Value "Unicode" -Scope Script
		$outputPath = (Get-location | select-object -expandproperty path) + '\' + $filteredDirectoryName

		get-analysis $outputPath $startingPath 


	}
	# Done running analysis #
}
	


