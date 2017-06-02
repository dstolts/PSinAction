<#

  Copied from:

  https://www.petri.com/display-memory-usage-powershell
#>

Function Test-MemoryUsage {
[cmdletbinding()]
Param()
 
   $os = Get-Ciminstance Win32_OperatingSystem
   $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
    
   if ($pctFree -ge 45) {
   $Status = "OK"
   }
   elseif ($pctFree -ge 15 ) {
   $Status = "Warning"
   }
   else {
   $Status = "Critical"
   }
    
   $os | Select @{Name = "Status";Expression = {$Status}},
   @{Name = "PctFree"; Expression = {$pctFree}},
   @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
   @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}
 
   Write-Verbose "Function Execution Complete"

}

Test-MemoryUsage -Verbose

$AvailResource = Test-MemoryUsage

$AvailResource.FreeGB  # Just get available memory
