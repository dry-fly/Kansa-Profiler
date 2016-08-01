<#
.SYNOPSIS
Get-WMIComputerSystem.ps1 returns information from the win32_computersystem class to aid in profiling systems based on hardware platform.
.NOTES
The following line is required by Kansa.ps1, which uses it to determine
how to handle the output from this script.
OUTPUT tsv
#>
Get-WmiObject win32_computersystem | select manufacturer,model,systemtype,TotalPhysicalMemory,Domain,NumberofLogicalProcessors,NumberofProcessors,UserName