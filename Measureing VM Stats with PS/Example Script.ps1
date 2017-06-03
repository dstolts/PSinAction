pause
######################
##      GET-VM      ##
######################
# View VM Status
cls; Get-VM -ComputerName localhost

#View Status of a single VM
Get-VM -ComputerName localhost -Name "Lab1"

#View VM Status for Running VMs Only
Get-VM -ComputerName localhost | Where { $_.State –eq ‘Running’ }



######################
##  START/STOP VMs  ##
######################

# Start all VMs
Start-VM -ComputerName localhost -Name *

# Stop all VMs
Stop-VM -ComputerName localhost -Name *
# Stop only running VMs
Get-VM | Where { $_.State –eq ‘Running’ }  | Stop-VM


######################
##    MEASURE-VM    ##
######################

# Enable VM Resource Metering for all VMs on Host
get-vm -ComputerName localhost | enable-VMResourceMetering


Measure-VM -ComputerName localhost -Name "Lab1"
Measure-VM -ComputerName localhost -Name *


# Reset VM Resource Metering for all VMs on Host
Reset-VMResourceMetering -vmname * -computername localhost


######################
##  BRING TOGETHER  ##
######################
Get-VM | Where { $_.State –eq ‘Running’ }  | Measure-VM 



######################
##  SEND IT TO CSV  ##
######################

# WRITE VM INFO TO CSV
$file_info_current = 'C:\VM-Info_current.csv'
del $file_info_current  # Deletes previous copy of CSV #
Get-VM -ComputerName localhost | select name , processorcount, MemoryAssigned, ReplicationHealth, Uptime, ComputerName, State, VMID | export-csv -NoTypeInformation $file_info_current
start $file_info_current


# WRITE VM USAGE TO CSV
$file_usage_current='C:\VM-Usage_current.csv'
del $file_usage_current  # Deletes previous copy of CSV #
get-vm -ComputerName localhost | Measure-VM | export-csv -NoTypeInformation $file_usage_current
start $file_usage_current




######################
##   VIEW VM IOPS   ##
######################

$VMHosts=localhost
cls

# ** Measure IOPS on All VMs ** #
$a = @{Expression={$_.vmname};Label="VM Name";width=25},
@{Expression={$_.AggregatedAverageNormalizedIOPS};Label="VM IOPS";width=8},
@{Expression={$_.avgcpu};Label="Avg CPU";width=10}

get-vm -computer $VMHosts |  where {$_.state -eq 'running'} | measure-VM | Format-Table $a
