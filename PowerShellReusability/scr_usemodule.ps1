#  Script to demonstrate how to use script modules...

<##################################################
#      Getting Information about  Modules         #
##################################################>     

Clear-Host

# List all available modules whether loaded or not...
Get-Module -ListAvailable 

# List only loaded modules...
Get-Module 

# Module properties...
Clear-Host
Get-Module | Get-Member -MemberType Property | Format-Table Name


Import-Module umd_module

Clear-Host

# List available functions...
(Get-Module -Name umd_module).ExportedFunctions.Values

# List available variables...
(Get-Module -Name umd_module).ExportedVariables.Values


<##################################################
#              Importing Modules                  #
##################################################>        

Clear-Host

# Import module with verbose messages...
Import-Module umd_module -Force -Verbose

Out-UdfSpeakFileContents   # Call module function

# Import module returning module information...
Import-Module umd_module -Force -PassThru -Prefix BC -Verbose



# Import module and convert it to a PsObject with
# variables as properties and functions as methods.
$myobject = Import-Module umd_module -Force -AsCustomObject

$myobject | Get-Member 

$myobject.ServerName 

$myobject.'Get-UdfFileName'()  # Need quotes due to the dash.