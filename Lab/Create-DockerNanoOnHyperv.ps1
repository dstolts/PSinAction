#Create Nano on Hyper-V
# Leverages Source: https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/deploy-containers-on-nano

Powershell as admin

$mypolicy = get-executionpolicy
$mypolicy
set-ExecutionPolic RemoteSigned

# Mount Win2016 Iso
Mount-DiskImage -ImagePath "C:\_Hyper-V\en_windows_server_2016_x64_dvd_9718492.iso"
Mount-DiskImage -ImagePath "C:\_Hyper-V\en_windows_server_2016_x64_dvd_9718492.iso"

# Create folder c:\nano and copy files from nanoserver on DVD
Try {
  md c:\Techstravaganza -erroraction SilentlyContinue
} 
Catch {}
Copy-Item E:\NanoServer\NanoServerImageGenerator\NanoServerImageGenerator.psm1 c:\Techstravaganza -Force
Copy-Item E:\NanoServer\NanoServerImageGenerator\Convert-WindowsImage.ps1 c:\Techstravaganza -Force
Set-Location C:\Techstravaganza 
#import Nano Image Module to Powershell
import-module C:\nano\NanoServerImageGenerator.psm1
get-module


<#
import-module C:\nano\NanoServerImageGenerator.psm1
-erroractionsilentlycontinue
    New-NanoServerImage 
    [-DeploymentType] {Host | Guest} 
    [-Edition] {Standard | Datacenter} 
    -TargetPath <string> 
    -AdministratorPassword <securestring> 
    [-MediaPath <string>] 
    [-BasePath <string>] 
    [-MaxSize <uint64>] 
    [-Storage] 
    [-Compute] [-Defender] [-Clustering] 
    [-OEMDrivers] 
    [-Containers] [-SetupUI <string[]>] [-Package <string[]>] 
    [-ServicingPackagePath <string[]>] [-ComputerName <string>] [-UnattendPath <string>] [-DomainName <string>] 
    [-DomainBlobPath <string>] [-ReuseDomainNode] [-DriverPath <string[]>] [-InterfaceNameOrIndex <string>] 
    [-Ipv6Address <string>] [-Ipv6Dns <string[]>] [-Ipv4Address <string>] [-Ipv4SubnetMask <string>] [-Ipv4Gateway 
    <string>] [-Ipv4Dns <string[]>] [-DebugMethod {Serial | Net | 1394 | USB}] [-EnableEMS] [-EMSPort <byte>] 
    [-EMSBaudRate <uint32>] [-EnableRemoteManagementPort] [-CopyPath <Object>] [-SetupCompleteCommand <string[]>] 
    [-Development] [-LogPath <string>] [-OfflineScriptPath <string[]>] [-OfflineScriptArgument <hashtable>] 
    [-Internal <string>]  [<CommonParameters>]
#>

mkdir C:\ServicingPackages  -erroraction SilentlyContinue
mkdir C:\ServicingPackages\expanded\KB3176936  -erroraction SilentlyContinue
mkdir C:\ServicingPackages\expanded\KB3192366  -erroraction SilentlyContinue
mkdir C:\ServicingPackages\expanded\KB376936 -erroraction SilentlyContinue

Write-Host "Required KBs https://technet.microsoft.com/en-us/windows-server-docs/get-started/update-nano-server"

# Need to add some error trapping later
$WebClient = New-Object System.Net.WebClient 

# http://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB3192366
Write-Host "Download from... http://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB3192366"
$url = "http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/09/windows10.0-kb3192366-x64_af96b0015c04f5dcb186b879f07a31c32cf2e494.msu"
$path = "C:\ServicingPackages\windows10.0-kb3192366-x64.msu"
Write-Host "Downloading" $Path from $URL -ForegroundColor Green   
$WebClient.DownloadFile( $url, $path )

# http://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB3176936
Write-host "Downloading KB... http://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB3176936"
Write-Host "Windows Server 2016" 
$url = "http://download.windowsupdate.com/c/msdownload/update/software/crup/2016/09/windows10.0-kb3176936-x64_5cff7cd74d68a8c7f07711b800008888b0fa8e81.msu"
$path = "C:\ServicingPackages\windows10.0-kb3176936-x64.msu"
Write-Host "Downloading" $Path -ForegroundColor Green   
$WebClient.DownloadFile( $url, $path )
Write-Host "Windows 10 x86"
$Url = "http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/08/windows10.0-kb3176936-x86_1a65d59f938f00a666e7d2de6cd291a5e1d477ae.msu" 
$Path = "C:\ServicingPackages\windows10.0-kb3176936-x86.msu"
Write-Host "Downloading" $Path -ForegroundColor Green     
$WebClient.DownloadFile( $url, $path ) 
Write-Host "Windows 10 x64"
$Url = "http://download.windowsupdate.com/c/msdownload/update/software/crup/2016/08/windows10.0-kb3176936-x64_795777f8a7f8cd1a4c96ee030848f9f888490555.msu" 
$Path = "C:\ServicingPackages\windows10.0-kb3176936-x64.msu"
Write-Host "Downloading" $Path -ForegroundColor Green 
$WebClient.DownloadFile( $url, $path ) 

Write-Host "Extracting Files..."
Expand C:\ServicingPackages\windows10.0-kb3192366-x64.msu -F:*   C:\ServicingPackages\expanded\KB3192366 
Dir C:\ServicingPackages\expanded\KB3192366
Expand  C:\ServicingPackages\windows10.0-kb3176936-x64.msu -F:*  C:\ServicingPackages\expanded\KB376936 
Dir C:\ServicingPackages\expanded\KB376936

mkdir C:\ServicingPackages\cabs  -erroraction SilentlyContinue
Copy-Item C:\ServicingPackages\expanded\KB376936\Windows10.0-KB3176936-x64.cab C:\ServicingPackages\cabs
Copy-Item C:\ServicingPackages\expanded\KB3192366\Windows10.0-KB3192366-x64.cab C:\ServicingPackages\cabs
Dir C:\ServicingPackages\cabs

################################
### build the Nano Image #######
################################\Techstravaganza\NanoTech"
$WorkFolder = "C:\Techstravaganza"
mkdir $WorkFolder -erroraction SilentlyContinue
$VHDPath = "$WorkFolder\NanoTech02.vhd"
$SRV1 = "NanoTech02"
New-NanoServerImage -ServicingPackagePath 'C:\ServicingPackages\cabs\Windows10.0-KB3176936-x64.cab', 'C:\ServicingPackages\cabs\Windows10.0-KB3192366-x64.cab' -BasePath ".\Base" -TargetPath $VHDPath -MediaPath "E:\" -ComputerName $SRV1 -Package 'Microsoft-NanoServer-Compute-Package','Microsoft-NanoServer-OEM-Drivers-Package','Microsoft-NanoServer-Guest-Package','Microsoft-NanoServer-Storage-Package' -DeploymentType "Host" -Edition "Datacenter" 
<#this is the same as the above New-NanoServerImage but cut so you can see it all
New-NanoServerImage 
-ServicingPackagePath 'C:\ServicingPackages\cabs\Windows10.0-KB3176936-x64.cab', 'C:\ServicingPackages\cabs\Windows10.0-KB3192366-x64.cab' 
-BasePath ".\Base" -TargetPath $VHDPath -MediaPath "E:\" 
-ComputerName $SRV1 
-Packages 
'Microsoft-NanoServer-Compute-Package',
'Microsoft-NanoServer-OEM-Drivers-Package',
'Microsoft-NanoServer-Guest-Package',
'Microsoft-NanoServer-Storage-Package' 
-DeploymentType "Host" 
-Edition "Datacenter" 

#-Language en_us
#> 

#region Create a new Hyper-V VM with hard drive, memory & network resources configured using the new VHD.
# Variables go here...
# Create Virtual Machines
$MyNewVM = New-VM –Name $Srv1 –MemoryStartupBytes 1GB –VHDPath $VHDpath
Add-VMNetworkAdapter -VMName $SRV1 -SwitchName "Wireless"
#  or get it after the fact with... $MyNewVM = Get-VM -Name $SRV1
$MyNewVMName = $MyNewVM.Name
#$MyNewVM = Get-VM -VMName $MyNewVMName
#$MyNewVMName = $MyNewVM.Name
$MyNewVM.Name
restart-VM $MyNewVM 
#endregion

#region PowerShell Side Demo Window
#Connect to machine
Write-Host "To learn more on container host deployment on Nano Server see: https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/deploy-containers-on-nano"
start "https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/deploy-containers-on-nano"

$VHDPath = "$WorkFolder\NanoTech01.vhd"
$SRV1 = "NanoTech01"
$MyNewVMName = $SRV1
$MyNewVM = Get-VM -VMName $MyNewVMName
$MyNewVM 
$VMIpAddresses = Get-VM | ?{$_.VMName -eq $MyNewVM.Name} |?{$_.ReplicationMode -ne “Replica”} | Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status
$VMIpAddresses
# Grab the IP Address you will use to connect to this NanoServer
Write-Host "From the list above, you can type in a response or copy and paste..." -ForegroundColor Yellow
Write-Host " What IP Address would you like to use to connect to your Nano server? " -ForegroundColor Yellow
$MyVmIp = Read-Host 
$MyVmIp
Write-host "You can get Remote Management Tools for Win 10 from: https://www.microsoft.com/en-us/download/details.aspx?id=45520" -foregroundcolor green
start "https://www.microsoft.com/en-us/download/details.aspx?id=45520"

#endregion PowerShell Side Demo Window

#region List the IP addresses of all VMs have user select one to use
$VMIpAddresses = Get-VM | ?{$_.VMName -eq $MyNewVM.Name} |?{$_.ReplicationMode -ne “Replica”} | Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status
$VMIpAddresses
# Grab the IP Address you will use to connect to this NanoServer
Write-Host "From the list above, you can type in a response or copy and paste..." -ForegroundColor Yellow
Write-Host " What IP Address would you like to use to connect to your Nano server? " -ForegroundColor Yellow
$MyVmIp = Read-Host "Nano server IP? " 
$MyVmIp 
Enter-PSSession -VMName $MyNewVMName -Credential "$MyNewVMName\Administrator"
hostname
#endregion

#region Start the WinRM Service And authorize connection to server
net start WinRM     
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$MyVmIp"  # servername or IP
$MyVmIP
#endregion

#region Connect to Nano
Enter-PSSession -VMName $MyNewVMName -Credential "$MyNewVMName\Administrator"
hostname
#endregion

#region Install Windows Updates
$sess = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession
Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates
Restart-Computer
Exit-pssession
sleep(10)
#endregion

#region Connect to Nano
Enter-PSSession -VMName $MyNewVMName -Credential "$MyNewVMName\Administrator"
hostname
#endregion

#region Install Docker Provider
#First we'll install the OneGet PowerShell module
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Get-PackageSource
Install-Package -Name DockerMsftProvider 
Restart-Computer -Force   #
sleep(10)
Enter-PSSession -VMName $MyNewVMName -Credential "$MyNewVMName\Administrator"
hostname
#endregion

#region Install Docker on Nano  You could also do this with container service
dir
Invoke-WebRequest https://get.docker.com/builds/Windows/x86_64/docker-1.13.0.zip -UseBasicParsing -OutFile docker.zip
dir
Expand-Archive docker.zip -DestinationPath $Env:ProgramFiles
dir $Env:ProgramFiles
dir "$Env:ProgramFiles\docker"

Remove-Item -Force docker.zip
cd $Env:ProgramFiles\docker
$DockerPath = Get-Location
dir
write-host "The following command will error because docker is not yet registered." -ForegroundColor Green
Get-Service -Name docker  # will error becuase it is not registered yet.
.\dockerd.exe --register-service
Start-Service docker
Get-Service -Name docker
#endregion

#region Set Path to include Docker
# For quick use, does not require shell to be restarted.
$($Env:PATH).Split(';')
$env:path += ";$DockerPath"
# For persistent use, will apply after a reboot. 
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $env:path
docker info
$($Env:PATH).Split(';')
Restart-Computer -Force   #
sleep(10)
#endregion

#region Connect to Nano
#Connect to Nano
Enter-PSSession -VMName $MyNewVMName -Credential "$MyNewVMName\Administrator"
hostname
$($Env:PATH).Split(';')
#endregion

#region Confirm Docker is running
#Now we can access the remote docker machine even after a reboot
docker info
#endregion

#region Install (pull) Base Container Images
# Nano
docker pull microsoft/nanoserver
# Server Core
# docker pull microsoft/windowsservercore  
docker ps   # no running containers yet
docker images
Write-Host "we can start a -dt background container but NOT -it Interactive" -foregroundcolor green
docker run -dt microsoft/nanoserver

#endregion

#region List Local Machine IP Addresses
# 
Write-Host "List Local Machine IP Addresses" -ForegroundColor Green
$AdminIpAddresses = get-NetIpAddress -AddressFamily IPv4 | format-table interfacealias, IPAddress, AddressState 
$AdminIpAddresses
# Grab the IP Address you will use to connect to NanoServer
Write-Host "From the list above, you can type in a response or copy and paste..." -ForegroundColor Yellow
Write-Host " What IP Address would you like to use to connect to your Nano server? " -ForegroundColor Yellow
$AdminIp = Read-Host  
"Selected: $AdminIp"
#> #List Local Machine IP Addresses
#endregion 


#region Prepare Host for container connectivity (Firewall And Config)
#Create a firewall rule on the container host for the Docker connection. This will be port 2375 for an unsecure connection
netsh advfirewall firewall add rule name="Docker daemon" dir=in action=allow protocol=TCP localport=2375                 # Allow Docker
#netsh advfirewall firewall set rule Name=FPS-ICMP4-ERQ-In -Enabled Yes
#netsh advfirewall firewall set rule name=FPS-ICMP4-ERQ-Out -Enabled True
Get-NetFirewallRule -name FPS-ICMP4-ERQ-In -Enabled True
Get-NetFirewallRule FPS-ICMP4-ERQ-Out

Write-host "You need to make sure that you have both machines on the same network for connectivity;)"
Write-Host "See https://docs.docker.com/engine/security/https/ for securing connection" -foregroundcolor Red
new-item -Type File c:\ProgramData\docker\config\daemon.json
Add-Content 'c:\programdata\docker\config\daemon.json' '{ "hosts": ["tcp://0.0.0.0:2375", "npipe://"] }'
type "c:\ProgramData\docker\config\daemon.json"
Restart-Service docker
Sleep(10)
#endregion

#region show Docker containers and IP addresses
docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $( docker ps -aq) 
#endregion

#region Start Container and Show the new container Name and IP
$CID = (docker run  -dt --restart=always microsoft/nanoserver)  # Run docker with --restart
Write-Host "Container ID: $CID"
# You could also expose a port when you run with ... docker run -p 80:80 mycontainer
$ContainerIP = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CID
$ContainerIP  # Display the IP address of the container
$ContainerName = docker inspect -f '{{.Name}}' $CID
$ContainerName # Display the name of the container
Restart-Service docker   # Restart docker which will stop all containers

docker ps -a          # microsoft/nanoserver will always start when docker starts
"Notice that the container automatically started with restart of docker service"
docker container ls
#docker stop af910f8d8741   # Stop a container
#docker rm af910f8d8741     # Delete a container
#endregion

#region Exit Nano
"exiting out of nano"
Exit-pssession
hostname   # you should now be back on your administrative workstation
#endregion
