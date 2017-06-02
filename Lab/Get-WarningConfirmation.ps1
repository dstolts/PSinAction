# modified from Original Source: http://www.genelaisne.com/
$Warning = @"                                                                       
██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗                           
██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝                           
██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗                          
██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║                          
╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝                          
 ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝                           
                                                                                    
You are about to delete all users in Contoso.com!                                   
                                                               
Enter CANCEL at the prompt to cancel request
                     
If you want to do this, you must type the following text EXACTLY  as it appears:    
                                                                                    
I WANT TO DELETE ALL USERS IN CONTOSO.COM                                                                                                                                        
"@
$Warning -split "`n" | % {
  Write-Host -Foreground Red -Background Black $_ 
}

$ControlString = "I WANT TO DELETE ALL USERS IN CONTOSO.COM"
$Confirmed = $false
$string = [string]::Emtpy
While ((-Not ($string -cmatch $ControlString)) -AND (!$Confirmed))
{
    $string = read-host -prompt ":"
  
    if ($string -eq $ControlString -AND ($string -cmatch $ControlString))
    {
        Write-host -fore red -BackgroundColor black "Request Confirmed!"
        $Confirmed = $true
    }
    elseif (($string.ToUpper() -eq "CANCEL") -or ($string.ToUpper() -eq "EXIT")) {
        Write-host "Request cancelled!"
        break
    }
    else { 
       Write-host -ForegroundColor Red -BackgroundColor Black $ControlString
       Write-host -fore red -BackgroundColor black " Enter the phrase (EXACTLY as it appears above) to continue or type CANCEL to abort"
    }
    
 }

if ($confirmed) {
   Write-host "deleting all users!"
}

#$Warning