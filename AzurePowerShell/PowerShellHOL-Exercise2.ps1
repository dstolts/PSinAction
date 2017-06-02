#login to your azure account
Login-AzureRmAccount

#variable for WebApp creation
$id = [Guid]::NewGuid().ToString("n").SubString(0,8)
$resourceGroupName = $id + "-rg"
$location = "eastus"
$webAppName = $id + "-web"
$appServicePlanName = $id + "-plan"

#create a new resource group to use
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Create an App Service plan in Standard tier.
New-AzureRmAppServicePlan -Name $appServicePlanName -Location $location `
-ResourceGroupName $resourceGroupName -Tier Standard

# Create a web app.
New-AzureRmWebApp -Name $webAppName -Location $location `
-AppServicePlan $appServicePlanName -ResourceGroupName $resourceGroupName

# Get publishing profile for the web app
$xml = [xml](Get-AzureRmWebAppPublishingProfile -Name $webAppName `
-ResourceGroupName $resourceGroupName `
-OutputFile null)

# Extract connection information from publishing profile
$username = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userName").value
$password = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userPWD").value
$publishUrl = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@publishUrl").value

$packagePath = "C:\Users\Jason\Desktop\PSInAction\WebApp.zip"

# requires Web Deploy to be installed!
$msdeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe"
$computerName = "https://" + $webAppName + ".scm.azurewebsites.net:443/msdeploy.axd?site=" + $webAppName

$setParam = '-setParam:name="IIS', 'Web', 'Application', 'Name"'
$setParamValue += ',value="' + $webAppName + '"'
$setParamAndValue = "$setParam${setParamValue}"

& $msdeploy -source:package=$packagePath -verb=sync -dest:auto,computerName=$computerName,userName=$username,password=$password,authType=Basic $setParamAndValue -verbose

$webUrl = "https://" + $webAppName + ".azurewebsites.net"
Start-Process -FilePath $webUrl

# remove all resources in resource group
Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroupName