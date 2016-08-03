# Kansa-Profiler
A overlay to Kansa to facilitate filtering and analysis of systems by profile

Frequency analysis of data collected from across an environment is an effective 
means of discovering anomalous artifacts.  During incident response preparation, 
the system baselining use case will desire the ability to group systems based on 
their role in the environment.  Servers and desktops and front line and back shop 
user endpoints have significantly different system configuration states.  Varying 
hardware and operating systems will present different system states.  By grouping 
and filtering based on the variables that define the system profile, and then 
analyzing the subset, we can get a more concise baseline for systems of that profile.

The respository includes three scripts to facilitate analysis of system profiles 
based on filtering systems by properties.  createProfilingDatbase.ps1 will create a CSV
file of system properties to be used for grouping and filtering the targets of a
Kansa data collection.  createProfileDirectory.ps1 permits the user to group the
target systems and then filter on the grouping properties to isolate systems with
the profile of interest in a single directory.  Symbolic links are established back
to the Kansa module output files.  kansaGet-Analysis.ps1 is an adaptation of the Kansa
Get-Analysis function such that we can perform the same analysis against the isolated
profile directory.  Additional Kansa modules are provided to collect system properties
from target systems.  A modified set of analysis scripts are also included that output
to CSV rather than TSV files.  Lastly, the repository includes synchronized modules.conf
and analysis.conf files that should work in most environments.
 