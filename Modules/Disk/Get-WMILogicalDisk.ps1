<#
.SYNOPSIS
Get-WMILogicalDisk.ps1 returns information from the win32_logicalDisk class to summarize local drive info.
.NOTES
The following line is required by Kansa.ps1, which uses it to determine
how to handle the output from this script.
OUTPUT tsv
#>
Get-WmiObject win32_logicalDisk | select Caption,Description,DriveType,FileSystem,MediatType,Size,FreeSpace,VolumeName,VolumeSerialNumber