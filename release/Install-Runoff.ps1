param([string]$GameDirectory,[string[]]$Profiles=@('RunoffClient','RunoffServer'),[string]$BaseProfile='R2Northstar')
$ErrorActionPreference='Stop'
if(-not $GameDirectory){
 Add-Type -AssemblyName System.Windows.Forms
 $picker=New-Object System.Windows.Forms.FolderBrowserDialog
 $picker.Description='Select the Titanfall 2 folder containing NorthstarLauncher.exe'
 if($picker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK){exit}
 $GameDirectory=$picker.SelectedPath
}
if(-not(Test-Path -LiteralPath (Join-Path $GameDirectory 'NorthstarLauncher.exe'))){throw 'NorthstarLauncher.exe is missing from the selected folder'}
& (Join-Path $PSScriptRoot 'Install-Runoff.exe') --game $GameDirectory --base-profile $BaseProfile --profiles $Profiles
if($LASTEXITCODE -ne 0){throw 'Installation failed. Read the error above.'}
Write-Host 'Launch Start-RunoffClient.cmd or Start-RunoffServer.cmd in the installed profile.'
