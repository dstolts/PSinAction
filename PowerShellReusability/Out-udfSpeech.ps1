function Out-UdfSpeech  
{ 
 <#
     .DESCRIPTION
     This function uses the SAPI interface to speak.

     .PARAMETER $speakit
     The string to be spoken.

     .EXAMPLE
     Out-UdfSpeach 'Something to be said.'

#>
[CmdletBinding(SupportsShouldProcess)]
        param (
              [string]$speakit = 'What do you want me to say?'
              )

  #  Fun using SAPI - the text to speech thing....    

  Write-Verbose "You passed: $speakit to the function."

  if ($speakit.Length -lt 3) {
     Write-Debug "Warning: The string length is less than 3."
  }

  $speakit >> speechlog.txt

  $speaker = new-object -com SAPI.SpVoice

  $speaker.Speak($speakit, 1) | out-null

}

<#

Get-Help Out-UdfSpeech

Out-UdfSpeech 'Note the command let binding attribute and the pa ram  attribute in the above function.'

Out-UdfSpeech -Verbose

Out-UdfSpeech 'Hi' -Debug

# Safety parameters - must have SupportsShouldProcess of CmdletBinding

Out-UdfSpeech -Confirm  # Verify operation that can change system

Out-UdfSpeech -WhatIf   # Just tell me what it would do

#>