<#
.SYNOPSIS
The script references an existing Kansa target list file to build a metabase of host properties 
from various sources including data collected by Kansa and Active Directory.  We import any Kansa 
data to be used in the metabase to a Powershell object and also search Active Directory to retrieve 
properties from the target computers to include in the metabase.
.USAGE
Update the $kansaPath variable for your environment.
Update the $kansaHosts variable for your environment.  
This will be the same file specified for the targetList parameter when Kansa was run.  
If you ran Kansa against your entire AD environment, then you will need to create the file.
Run this script from within the Kansa Output directory for which you want to profile systems.
.OUTPUT
A subdirectory _Profiles is created and the metabase information is exported to profilingDatabase.csv.
#>

#Set the below variables for your environment
$kansaPath = "c:\tools\Kansa-master"
$kansaHosts = gc $kansaPath\hostlist.txt

#get-childitem $kansaPath\ -filter Output_* | select name,lastwritetime
#$kansaOutput = read-host 'Enter output directory' 
#$kansaOutput = (get-childitem $kansaPath\ -filter Output_* | sort lastwritetime | select -last 1).name
#$kansaOutput = $kansaPath + '\' + $kansaOutput
$operatingSystemInfo = get-childitem WMIOperatingSystem -filter *.csv | select fullname -expandproperty fullname | import-csv
$computerSystemInfo = get-childitem WMIComputerSystem -filter *.csv | select fullname -expandproperty fullname | import-csv
$kansaHosts| foreach { 
	$adcomputer = get-adcomputer $_ -property ipv4address,canonicalName
	$metaProperties = [ordered]@{
		computerName=$adcomputer.name
		canonicalPath=($adcomputer.canonicalName -replace '/[^/]*$','')
		ipv4address=$adcomputer.ipv4address
		operatingSystem=$operatingSystemInfo[$operatingSystemInfo.psComputerName.indexof($adcomputer.name)].caption
		osarchitecture=$operatingSystemInfo[$operatingSystemInfo.psComputerName.indexof($adcomputer.name)].osarchitecture
		hwmanufacturer=$computerSystemInfo[$computerSystemInfo.psComputerName.indexof($adcomputer.name)].manufacturer
		hwmodel=$computerSystemInfo[$computerSystemInfo.psComputerName.indexof($adcomputer.name)].model
	}
	$targetsMeta += @(New-Object pscustomobject -property $metaProperties)
}
new-item -type directory _Profiles
$targetsMeta | export-csv _Profiles\profilingDatabase.csv
