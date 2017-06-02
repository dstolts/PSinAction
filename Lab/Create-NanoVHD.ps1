#Create Nano on Hyper-V
# Leverages Source: https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/deploy-containers-on-nano

Powershell as admin

$ExecutionPolicy = get-executionpolicy
$ExecutionPolicy
set-ExecutionPolicy RemoteSigned

# Mount Win2016 Iso
Mount-DiskImage -ImagePath "C:\_Hyper-V\en_windows_server_2016_x64_dvd_9718492.iso"
Mount-DiskImage -ImagePath "C:\_Hyper-V\en_windows_server_2016_x64_dvd_9718492.iso"

# Create folder c:\nano and copy files from nanoserver on DVD
Try {
  md c:\Techstravaganza -erroraction SilentlyContinue
} 
Catch {}
Copy-Item E:\NanoServer\NanoServerImageGenerator\NanoServerImageGenerator.psm1 c:\techstravaganza -Force
Copy-Item E:\NanoServer\NanoServerImageGenerator\Convert-WindowsImage.ps1 c:\techstravaganza -Force
Set-Location C:\Techstravaganza 
#import Nano Image Module to Powershell
import-module C:\Techstravaganza\NanoServerImageGenerator.psm1


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
mkdir C:\ServicingPackages\expanded\KB376936  -erroraction SilentlyContinue

Write-Host "Required KBs https://technet.microsoft.com/en-us/windows-server-docs/get-started/update-nano-server"

# Need to add some error trapping later
$WebClient = New-Object System.Net.WebClient 

# http://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB3192366
Write-Host "Download from... http://catalog.update.microsoft.com/v7/site/Search.aspx?q=KB3192366"
$url = "http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/09/windows10.0-kb3192366-x64_af96b0015c04f5dcb186b879f07a31c32cf2e494.msu"
$path = "C:\ServicingPackages\windows10.0-kb3192366-x64.msu"
Write-Host "Downloading" $Path -ForegroundColor Green   
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
copy-item C:\ServicingPackages\expanded\KB376936\Windows10.0-KB3176936-x64.cab C:\ServicingPackages\cabs
copy-item C:\ServicingPackages\expanded\KB3192366\Windows10.0-KB3192366-x64.cab C:\ServicingPackages\cabs
Dir C:\ServicingPackages\cabs

$WorkFolder = "C:\Techstravaganza\technano01"
$VHDPath = "$WorkFolder\technano01.vhd"
$SRV1 = "technano01"
Try{
   New-NanoServerImage -ServicingPackagePath 'C:\ServicingPackages\cabs\Windows10.0-KB3176936-x64.cab', 'C:\ServicingPackages\cabs\Windows10.0-KB3192366-x64.cab' -BasePath ".\Base" -TargetPath $VHDPath -MediaPath "E:\" -ComputerName $SRV1 -Package 'Microsoft-NanoServer-Compute-Package','Microsoft-NanoServer-OEM-Drivers-Package','Microsoft-NanoServer-Guest-Package','Microsoft-NanoServer-Storage-Package' -DeploymentType "Host" -Edition "Datacenter" -ErrorAction Stop
   Write-Host "Finished. Nano VHD is located at: $VHDPath" -foregroundColor Green
}
Catch { 
    Write-Host "Unable to create VHD-> $VHDPath " -ForegroundColor Red -NoNewline
    $error[0].exception 
}
