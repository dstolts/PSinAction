<#   
================================================================================ 
Name: RegistryStorage.ps1
Author: Dan Stolts – dstolts&&microsoft.com - http://ITProGuru.com 
Purpose: Create Storage Account to be used as Registry for container images (Docker/ACS)

   See Also: Download From Public URL https://gallery.technet.microsoft.com/Downloading-Files-from-dcaaf44c 
   See also: Create Azure Storage https://gallery.technet.microsoft.com/Create-Azure-Storage-f6943b67 
   See Also: Working with Azure Storage: https://gallery.technet.microsoft.com/Working-with-Azure-Storage-6d09ef2b 
 
NOTE: To connect to Azure, See  
   Accounts:    https://gallery.technet.microsoft.com/Azure-Accounts-with-c1cc7763 
          OR 
   Subscriptions: https://gallery.technet.microsoft.com/Azure-Subscriptions-with-be76827a 
 
  Syntax/Execution: Copy portion of script you want to use and paste into PowerShell (or ISE)  
  Disclaimer: Use at your own Risk!  See details at http://ITProGuru.com/privacy  
  Limitations:  
    * Must Run PowerShell (or ISE)  
    * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
    * Requires PowerShell Azure Module (see http://itproguru.com/AzurePowerShell) 
 video of Script will be uploaded to https://channel9.msdn.com/Series/GuruPowerShell 
 More scripts from Dan Stolts "ITProGuru" at http://ITProGuru.com/Scripts 
See Also: Download From Public URL https://gallery.technet.microsoft.com/Downloading-Files-from-dcaaf44c 
 ================================================================================ 
#> 

# Remove accounts from Powershell Cache
#Get-AzureAccount | ForEach-Object { Remove-AzureAccount $_.ID -Force } 

# Sign-in with Azure account credentials
Add-AzureAccount
Login-AzureRmAccount

# Select Azure Subscription
$subscriptionId = 
    (Get-AzureRmSubscription |
     Out-GridView `
        -Title "Select an Azure Subscription …" `
        -PassThru).SubscriptionId

Select-AzureRmSubscription `
    -SubscriptionId $subscriptionId

# Select Azure Resource Group 
$myRG = (Get-AzureRmResourceGroup |
     Out-GridView `
        -Title "Select an Azure Resource Group …" `
        -PassThru)
$rgName = $myRG.ResourceGroupName  # Grab the ResourceGroupName
$myLocation = $myRG.Location       # Grab the ResourceGroupLocation (region)


# or Create a new resource group...
# Select Azure regions
$regions = Get-AzureLocation  
$myLocation =  $regions.Name | 
     Out-GridView `
        -Title "Select Azure Datacenter Region …" `
        -PassThru
$rgName = "TestRGDan"
New-AzureRmResourceGroup -Name $rgName -location $myLocation 
Get-AzureRmResourceGroup -Name $rgName 


#$mySubName = "Internal Consumption" 
#$myLocation = "East US" 
Set-AzureSubscription -SubscriptionID $subscriptionId 
$myContainer = "registry"
$myStoreName = "iqss2016k"  #Storage account names must be between 3 and 24 characters in length and use numbers and lower-case letters only 

If (!(Test-AzureName -Name $myStoreName -Storage)) { 
    Write-host "StorageAccountName $myStoreName Passed" 
    If (!(Test-AzureName -Name $myStoreName -Service)) {  
        Write-host "Test-AzureName $myStoreName -Service Passed"
        Write-Host "Creating Storage Account $myStoreName ..." -ForegroundColor Green  
        New-AzureRMStorageAccount -Location $myLocation -StorageAccountName $myStoreName -ResourceGroupName $rgName -SkuName "Standard_LRS"
        #Start-Sleep -Milliseconds 1000
        Write-Host "Creating Container... " $myContainer  -ForegroundColor Green 
         
        $myStorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $rgName -StorageAccountName $myStoreName).Value[0]
        Write-Host "Storage Key: $myStorageAccountKey"  -ForegroundColor Green  
        $myStoreContext = New-AzureStorageContext -StorageAccountName $myStoreName -StorageAccountKey $myStorageAccountKey 
        Write-Host "Set Default Store ..." $myStoreName  -ForegroundColor Green  
        #Set-AzureSubscription –SubscriptionId $subscriptionId -CurrentStorageAccount $myStoreName 
        #creates the container in your storage account.  
        #I am not checking if container already exists.  # you can check by get-storagecontainer and check for errors. 
        New-AzureStorageContainer $myContainer -Permission Container -Context $myStoreContext 
        $myStorageBlob = $myStoreContext.BlobEndPoint 
        $myStorageBlob 
        # Copy file to new container...
        # Create temp file - A list of running services.
        $fileName = "TestRun.txt"
        $service = Get-Service | where {$_.status -eq "Running" } 
        $service | Format-Table name, status -auto | Out-File $fileName
        $dir = Get-Location
        $fqFileName = "$dir\$filename"
        Write-host "Testing Upload of $fqFileName"
        Set-AzureStorageBlobContent -Blob $fileName -Container $myContainer -File $fqFileName -Context $myStoreContext -Force  
              
    } Else {write-host "Storage Service Name $myStoreName is already used or invalid. Please choose a different name!" -ForegroundColor Red}  
} Else {Write-Host "Azure Service Name $myStoreName is already used. Please choose a different name!" -ForegroundColor Red} 



<#
# Instead of creating... Open Storage  
$myStoreName = (Get-AzureRmStorageAccount | Out-GridView -Title "Select Azure Storage Account …" -PassThru).StorageAccountName
$StorageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $rgName -StorageAccountName $myStoreName).Value[0] # Get the primary Key 
$StorageContext = New-AzureStorageContext -StorageAccountKey $StorageKey -StorageAccountName $myStoreName # Get the Context 
$StorageAccount = Get-AzureRmStorageAccount -StorageAccountName $myStoreName  -ResourceGroupName $rgName # Get the Storage Account 
$StorageAccount
#>
