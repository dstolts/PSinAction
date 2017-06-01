<#

   Modified from the code at the blog:
   http://sqlmag.com/powershell/powershell-lets-you-back-sql-server-your-way

   !!! SQL Server Account Must Have Write Permission to the Destination!!!

#>

$server = "(local)"
$db = "Development"
$dt = Get-Date -format yyyyMMddHHmmss
$backuppath = $env:HOMEDRIVE + $env:HOMEPATH + "\Documents\Backup\$($db)_db_$($dt).bak"

Backup-SqlDatabase -ServerInstance $server -Database $db -BackupFile $backuppath

Import-Module “sqlps” -DisableNameChecking -Force

<#    
      Select the database to back up from a list...
#>

set-location SQLSERVER:\SQL\DESKTOP-TG2VLSU\DEFAULT\Databases\

Clear-Host

$DBToBackup = Get-ChildItem | Out-Gridview -Title "Select a Database" -PassThru 
$DBToBackup.Name
$backuppath = $env:HOMEDRIVE + $env:HOMEPATH + "\Documents\Backup\$($DBToBackup.Name)_db_$($dt).bak"

Backup-SqlDatabase -ServerInstance $server -Database $DBToBackup.Name -BackupFile $backuppath
