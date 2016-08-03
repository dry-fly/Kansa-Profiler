<#
.SYNOPSIS
The script loads the profilingDatabase.csv created by createProfilingDatabase.ps1 into a
PowerShell object.  The user can then select the fields from database to group the target
hosts by.  After grouping, the user selects the groups that increasingly limit the systems
to be isolated for the profile.  Finally, user confirms the resulting group and chooses 
whether to continue.  Continuing will establishing a directory for the profile within the _Profiles
directory and create symbolic links to the Kansa module data output files for systems that 
meet the criteria of the profile.
.USAGE
Run this script from within the Kansa Output directory for which you want to profile systems.
.OUTPUT
A subdirectory within the _Profiles directory and symbolic links to data files of those systems
that match the profile criteria.
.PARAMETER Analysis
An optional switch that causes Kansa to run automated analysis based on
the contents of the Analysis\Analysis.conf file.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=13)]
        [Switch]$Analysis
)

# Source the function script containing the Get-Analysis and dependent functions
. "c:\tools\kansa-master\kansaGet-Analysis.ps1"

# Load the profilingDatabase that supports grouping and filtering of target hosts
$targets = import-csv .\_Profiles\profilingDatabase.csv
write-host "Targets available:"$targets.count

# Display the database fields present for grouping systems 
$groupOptions = $targets[0] | gm | where { $_.memberType -eq 'NoteProperty'}
#$groupOptions
for ($i=1;$i -le $groupOptions.count;$i++ ) { write-host $i":"($groupOptions[$i-1]).Name }
$groupLevels = @()

# Acquire user input for grouping options
while ($index -ne 'quit') {
	$index = read-host "Enter grouping indexes one at a time ('quit' when done)"
	if ($index -ne 'quit' ) { $groupLevels += ($groupOptions[$index-1]).Name }
}
clear-variable index

# Create text from variables for sorting and grouping
$groupLevelsValue = ($groupLevels -join ",") -replace ',$',''

# Establish scriptblock based on variables to be used with invoke expression
$groupScriptBlock = '$targets | sort ' + $groupLevelsValue + ' | group ' + $groupLevelsvalue

# Display chosen grouping levels and group targets accordingly
write-host "Filter value:"$groupLevelsValue
$groupedTargets = invoke-expression -command "$groupScriptBlock"

# Output the groups available to be filtered for profile isolation
for ($i=1;$i -le $groupedTargets.count;$i++ ) { write-host $i":"($groupedTargets[$i-1]).Name }
$filterSelection = @()

# Acquire user input for host groupings to include in profile
while ($index -ne 'quit') {
	$index = read-host "Enter filter indexes one at a time ('quit' when done)"
	if ($index -ne 'quit') { $filterSelection += ($index - 1) }
}
# Display filter selection and add host groupings to filteredSelection
$filterSelection
$filterSelection | foreach { $filteredTargets = $filteredTargets + $groupedTargets[$_].Group }
write-host "Filtered targets:" $filteredTargets.count

# Validate remaining hosts for profile and acquire user input to continue with establishing a directory for the profile
$analyze = $filteredTargets.count
$filteredTargets | select computerName,canonicalPath,operatingsystem,osarchitecture,hwModel | ft -autosize
switch (read-host "Do you want to analyze this group?") {
	'Y' {}
	default { $analyze = 0 }
}

# If user elects to continue and filtered targets includes at least one system
if ( $analyze -gt 0 ) {
	
	# Prompt user for profile subdirectory name
	$filteredDirectoryName = '_Profiles\' + (read-host "Enter name for subdirectory of links to targetData Files")
	$filteredDirectoryName
	
	# Create directory if it does not already exist, prompt user for ok to overwrite if does exist or get new directory name
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

	# Get the Kansa module output directories to be searched for data files for hosts meeting profile criteria
	$searchDirs = get-childitem -Directory | where {-not ($_.Name -like '_*' -or $_.Name -eq 'AnalysisReports') }

	# Search each output directory for files matching hosts meeting the profile criteria
	$searchDirs | foreach { 
	$matchedOutputFiles = @()
		$pruneModule = $_.Name
		# Create module output directory
		new-item -itemtype directory -path ($filteredDirectoryName + '\' + $pruneModule)
		
		# Get all child files, if file matches a host meeting the profile, create symbolic link to Kansa module data for host in module directory
		get-childitem $_ | foreach {
			$test = $_.name -replace ('-' + $pruneModule + '.*$'),''
			$index = $filteredTargets.computerName.indexof($test.toupper())
			if ($index -ne -1) { 
				write-host "matched host" $filteredTargets[$index].computerName "to file" $_.fullname
				cmd.exe /c mklink ($filteredDirectoryName + '\' + $pruneModule + '\' + $_.Name) $_.fullname
				$matchedOutputFiles += $filteredTargets[$index].ComputerName
				}
		} 
		
		# Display count of matched files and display profile hosts for which no data files were found
		$matchedOutputFiles.count
		compare-object $filteredTargets.computerName $matchedOutputFiles
	}
	# Are we running analysis scripts? #
	if ($Analysis) {
		
		# Define variables for calling Get-Analysis function
		$StartingPath = Get-Location | Select-Object -ExpandProperty Path
		$startingPath = $startingPath -replace '\\Output_\d{14}$',''
		Set-Variable -Name ErrorLog -Value ($filteredDirectoryName + "\Error.Log") -Scope Script
		Set-Variable -Name Encoding -Value "Unicode" -Scope Script
		$outputPath = (Get-location | select-object -expandproperty path) + '\' + $filteredDirectoryName

		get-analysis $outputPath $startingPath 
	}
	# Done running analysis #
}
	


