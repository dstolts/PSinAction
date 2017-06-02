Import-Module umd_azure -Force

# Add-AzureRmAccount

Clear-Host

$ApplicationDisplayName = "demobpcapp"
$ResourceGroupName = 'demobpcRG'
 
#  Returns the Application object...
$myapp = New-udfAzureServicePrincipal -ApplicationDisplayName $ApplicationDisplayName `
 -Password ('somesstuff?' + (Get-Random).ToString()) -Verbose  


# Log in with the Service Principal...
Clear-Host

New-udfAzureRmVMLoginServicePrincipal -ApplicationDisplayName $ApplicationDisplayName -Verbose    
 
Get-AzureRmVM  # Uses Service Principal


<#
$myapp.ApplicationID

Add-AzureRmAccount -Credential $creds -ServicePrincipal -TenantId $tenantid

Stop-AzureRmVM -Name 'Demo3VM' -ResourceGroupName "Demo3RG" -Force

#>
