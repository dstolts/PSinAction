function Invoke-UdfSQLAgentJob 
{

 [CmdletBinding()]
        param (
                 [string]$sqlserverpath,
                 [string]$jobfilter     = '*'                 
               )

  Import-Module "sqlps" -Force -DisableNameChecking -ErrorAction Ignore

  # Set where you are in SQL Server...
  set-location $sqlserverpath

  while ($true) 
  {

   $jobname = $null

   $jobname = Get-ChildItem |
              Select-Object -Property Name, Description, LastRunDate, LastRunOutcome | 
              Where-Object {$_.name -like "$jobfilter*"} |
              Out-GridView -Title "Select a Job to Run" -OutputMode Single 
   
   If (!$jobname) { Break }

   $jobobject = Get-ChildItem | where-object {$_.name -eq $jobname.Name}
   
   $jobobject.start()

   Write-Host "Job $($jobobject.Name) submitted."
  
  }

}
<#  Example call...

Invoke-UdfSQLAgentJob -sqlserverpath 'SQLSERVER:\SQL\DESKTOP-TG2VLSU\DEFAULT\JobServer\Jobs\'

#>
