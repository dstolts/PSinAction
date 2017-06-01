<#   From the following link:

     https://blogs.technet.microsoft.com/heyscriptingguy/2010/11/04/use-powershell-to-script-sql-database-objects/

     Reformated, made an advanced function, and added path parm
#>

function Export-udfDatabaseObjectScript
{
[CmdletBinding(SupportsShouldProcess)]
        param (
              [string]$server,
              [string]$dbname,
              [string]$outpath
              )

    [System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SqlServer.SMO”) | out-null

    $SMOserver = New-Object (‘Microsoft.SqlServer.Management.Smo.Server’) -argumentlist $server

    $db = $SMOserver.databases[$dbname]

    $Objects = $db.Tables
    $Objects += $db.Views
    $Objects += $db.StoredProcedures
    $Objects += $db.UserDefinedFunctions


   # Build this portion of the directory structure out here
   # in case scripting takes more than one minute.
   $SavePath = $outpath + $($dbname)
   Write-Verbose "Writing scripts to: $SavePath"
   
   $DateFolder = get-date -format yyyyMMddHHmm
   
   New-Item -type directory -name “$DateFolder”-path “$SavePath” -Force

   #Need to Add Some mkDirs for the different $Fldr=$ScriptThis.GetType().Name
   $scriptr = New-Object (‘Microsoft.SqlServer.Management.Smo.Scripter’) ($SMOserver)
   $scriptr.Options.AppendToFile = $True
   $scriptr.Options.AllowSystemObjects = $False
   $scriptr.Options.ClusteredIndexes = $True
   $scriptr.Options.DriAll = $True
   $scriptr.Options.ScriptDrops = $False
   $scriptr.Options.IncludeHeaders = $True
   $scriptr.Options.ToFileOnly = $True
   $scriptr.Options.Indexes = $True
   $scriptr.Options.Permissions = $True
   $scriptr.Options.WithDependencies = $False

   <#Script the Drop too#>
   $ScriptDrop = new-object (‘Microsoft.SqlServer.Management.Smo.Scripter’) ($SMOserver)
   $ScriptDrop.Options.AppendToFile = $True
   $ScriptDrop.Options.AllowSystemObjects = $False
   $ScriptDrop.Options.ClusteredIndexes = $True
   $ScriptDrop.Options.DriAll = $True
   $ScriptDrop.Options.ScriptDrops = $True
   $ScriptDrop.Options.IncludeHeaders = $True
   $ScriptDrop.Options.ToFileOnly = $True
   $ScriptDrop.Options.Indexes = $True
   $ScriptDrop.Options.WithDependencies = $False

   Write-Verbose "Object Scripting Options: " 
   Write-Verbose $scriptr.Options
   Write-Verbose "______________"
   Write-Verbose " "
   Write-Verbose "Drop Scripting Options: " 
   Write-Verbose $ScriptDrop.Options
   
   foreach ($ScriptThis in $Objects | where {!($_.IsSystemObject)}) 
   {

      ###
  

      <#This section builds folder structures.  
      Remove the date folder if you want to overwrite#>
      
      $TypeFolder=$ScriptThis.GetType().Name
      
      if ((Test-Path -Path “$SavePath\$DateFolder\$TypeFolder”) -eq “true”) `
              {
                “Scripting Out $TypeFolder $ScriptThis”
              } `
           else 
              {
                 New-Item -type directory -name “$TypeFolder”-path “$SavePath\$DateFolder”
              }
      
      $ScriptFile = $ScriptThis -replace “\[|\]”
      
      $ScriptDrop.Options.FileName = “” + $($SavePath) + “\” + $($DateFolder) + “\” + $($TypeFolder) + “\” + $($ScriptFile) + “.SQL”
      $scriptr.Options.FileName = “$SavePath\$DateFolder\$TypeFolder\$ScriptFile.SQL”
      
      #This is where each object actually gets scripted one at a time.
      
      $ScriptDrop.Script($ScriptThis)
      $scriptr.Script($ScriptThis)
      
   } #This ends the loop

} 

$outpath = $env:HOMEDRIVE + $env:HOMEPATH + "\Documents\DatabaseScript\"

Export-udfDatabaseObjectScript "(local)" "Development" $Outpath -Verbose