########################################################
##                   Hyper-V                          ##
########################################################

# Start/Stop a Hyper-V VM
    Start-VM –ComputerName localhost –Name “Audit PC 1”
    Stop-VM –ComputerName localhost –Name “Audit PC 1”

    # Start all VMs
    Start-VM -ComputerName localhost -Name *

    # Stop all VMs
    Stop-VM -ComputerName localhost -Name *

# View Status of a single VM
Measure-VM -ComputerName localhost -Name "Lab1"

#View Status of all VMs on multiple Hyper-V Hosts
Get-VM -ComputerName localhost,bostonhost1,bostonhost2

# View Running VMs
Get-VM | Where { $_.State –eq ‘Running’ } 

# View VM IP Addresses
Get-VM | Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status


########################################################
##                    Azure                           ##
########################################################

#Install Azure PowerShell
Install-Module AzureRM
Import-Module AzureRM


#Login to Azure Account
Login-AzureRmAccount

#Start/Stop Azure VMs
Stop-AzureRmVM -ResourceGroupName "PowerShell-in-Action-Boston" -Name PSinActionVM1
Start-AzureRmVM -ResourceGroupName "PowerShell-in-Action-Boston" -Name PSinActionVM1

#List VMs in an Azure Resource Group
Get-AzureRmVM -ResourceGroupName PowerShell-in-Action-Boston

#View Status of Azure VMs
Get-AzureRmVM -Status


#Display IP Addresses of Azure VMs (by Rhoderick Milne of MSFT)
    $vms = get-azurermvm
    $nics = get-azurermnetworkinterface | where VirtualMachine -NE $null #skip Nics with no VM

    foreach($nic in $nics)
    {
        $vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
        $prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
        $alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
        Write-Output "$($vm.Name) : $prv , $alloc"
    }

#