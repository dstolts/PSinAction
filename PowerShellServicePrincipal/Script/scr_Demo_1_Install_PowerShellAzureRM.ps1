<#

   Installing and Configuring the PowerShell Azure Module.

   https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-3.7.0


   **** You MUST Start PowerShell with Elevated Permissions!!!  ****

#>

# Check if you have the right PowerShellGet version.
Get-Module PowerShellGet -list | Select-Object Name,Version,Path

# Install the PowerShell Azure Module...
# Must run this with elevated privileges.
# Import the module...
Import-Module AzureRM -Force -Verbose 

# Verify the Azure Module Installation...
Get-Module -FullyQualifiedName AzureRM 

# Get list of Azure cmdlets...
Get-Command -Module AzureRM  | Out-GridView

# Get list with synopsis of Azxre cmdlets...
Get-Command -Module AzureRM | Get-Help | Select-Object -Property Name, Synopsis | Format-List


<#    
         Exploring Azure...
#>

# Log into an account
Login-AzureAsAccount 

Get-AzureRmVM

Get-AzureRmBillingInvoice

#Get-AzureBatchJob


