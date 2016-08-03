<#
.SYNOPSIS
The script references an existing Kansa target list file to build a database of host properties 
from various sources including data collected by Kansa and Active Directory.  We import any Kansa 
data to be used in the database to a Powershell object and also search Active Directory to retrieve 
properties from the target computers to include in the database.
.USAGE
Update the $kansaPath variable for your environment.
Update the $kansaHosts variable for your environment.  
This will be the same file specified for the targetList parameter when Kansa was run.  
If you ran Kansa against your entire AD environment, then you will need to create the file.
Run this script from within the Kansa Output directory for which you want to profile systems.
PowerShell Active Directory module is required and must be loaded.
.OUTPUT
A subdirectory _Profiles is created and the metabase information is exported to profilingDatabase.csv.
#>

# Set the below variables for your environment
$kansaPath = "c:\tools\Kansa-master"
$kansaHosts = gc $kansaPath\hostlist.txt

# Populate Powershelll objects with system properties from CSV target data output files
$operatingSystemInfo = get-childitem WMIOperatingSystem -filter *.csv | select fullname -expandproperty fullname | import-csv
$computerSystemInfo = get-childitem WMIComputerSystem -filter *.csv | select fullname -expandproperty fullname | import-csv

# Loop through each target host
$kansaHosts| foreach { 
	# Find computer in Active Directory
	$adcomputer = get-adcomputer $_ -property ipv4address,canonicalName
	# Establish host system property item
	$hostDataProperties = [ordered]@{
		computerName=$adcomputer.name
		# Prune host name from canonicalName
		canonicalPath=($adcomputer.canonicalName -replace '/[^/]*$','')
		ipv4address=$adcomputer.ipv4address
		
		# Acquire systetm properties from PowerShell objects using IndexOf property
		operatingSystem=$operatingSystemInfo[$operatingSystemInfo.psComputerName.indexof($adcomputer.name)].caption
		osarchitecture=$operatingSystemInfo[$operatingSystemInfo.psComputerName.indexof($adcomputer.name)].osarchitecture
		hwmanufacturer=$computerSystemInfo[$computerSystemInfo.psComputerName.indexof($adcomputer.name)].manufacturer
		hwmodel=$computerSystemInfo[$computerSystemInfo.psComputerName.indexof($adcomputer.name)].model
	}
	$targetsData += @(New-Object pscustomobject -property $hostDataProperties)
}

# Create _Profiles directory and export data to CSV
new-item -type directory _Profiles
$targetsData | export-csv _Profiles\profilingDatabase.csv
