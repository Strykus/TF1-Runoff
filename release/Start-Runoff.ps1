param(
 [Parameter(Mandatory=$true)][string]$GameDirectory,
 [string]$Profile='R2Northstar',
 [switch]$Server,
 [int]$Port=37042,
 [string]$GameMode='aitdm',
 [int]$Width=0,
 [int]$Height=0
)
$ErrorActionPreference='Stop'
$game=(Resolve-Path -LiteralPath $GameDirectory).Path
if($Profile -notmatch '^[A-Za-z0-9_-]+$'){throw 'Invalid profile name'}
$mod=Join-Path $game "$Profile/mods/TF1.Runoff"
if(-not(Test-Path -LiteralPath "$mod/mod.json")){throw 'Install TF1.Runoff first'}
# Northstar executes this file again when loading a listen/dedicated server.
# Keep it in the stock cfg directory: a partial cfg directory in a higher
# priority mod hides the persistent-player-data wildcard lookup.
$stockServerCfg=Join-Path $game "$Profile/mods/Northstar.CustomServers/mod/cfg/autoexec_ns_server.cfg"
$localServerCfg=Join-Path $mod 'mod/cfg/autoexec_ns_server.cfg'
if(Test-Path -LiteralPath $localServerCfg){
 if(([IO.File]::ReadAllText($localServerCfg)).Contains('// Settings for the supplied local Runoff launcher.')){
  Remove-Item -LiteralPath $localServerCfg
 }
}
if(Test-Path -LiteralPath $stockServerCfg){
 $originalServerCfg=Join-Path $game "$Profile/runoff-original-autoexec_ns_server.cfg"
 if(-not(Test-Path -LiteralPath $originalServerCfg)){Copy-Item -LiteralPath $stockServerCfg -Destination $originalServerCfg}
 $localSettings="`n// Settings for the supplied local Runoff launcher.`nns_report_server_to_masterserver 0`nns_report_sp_server_to_masterserver 0`nns_auth_allow_insecure 1`nns_auth_allow_insecure_write 0`n"
 [IO.File]::WriteAllText($stockServerCfg,([IO.File]::ReadAllText($originalServerCfg)+$localSettings))
}
$arguments=@('-multiple',"-profile=$Profile",'-novid','+developer','0','+not_focus_sleep','0','+ns_auth_allow_insecure','1','+ns_auth_allow_insecure_write','0','+ns_report_server_to_masterserver','0','+ns_report_sp_server_to_masterserver','0')
if($Server){
 $arguments+=@('-dedicated','-port',"$Port",'+hostport',"$Port",'+setplaylist','private_match','+mp_gamemode',$GameMode,'+map','mp_tf1_runoff')
 $visibility='Hidden'
}else{
 # Use the active display resolution, rather than the earlier fixed 720p test size.
 if($Width -eq 0 -and $Height -eq 0){
  $display=Get-CimInstance Win32_VideoController | Where-Object {$_.CurrentHorizontalResolution -gt 0 -and $_.CurrentVerticalResolution -gt 0} | Select-Object -First 1
  if($display){$Width=$display.CurrentHorizontalResolution;$Height=$display.CurrentVerticalResolution}
 }
 if($Width -gt 0 -and $Height -gt 0){$arguments+=@('-w',"$Width",'-h',"$Height")}
 $arguments+=@('-windowed','-port','37041','+hostport','37041','+net_usesocketsforloopback','0')
 $visibility='Normal'
}
$process=Start-Process -FilePath "$game/NorthstarLauncher.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle $visibility -PassThru
if(-not $Server){
 $audioExe=Join-Path $mod 'audio/RunoffPipeAudio.exe'
 if(-not(Test-Path -LiteralPath $audioExe)){throw 'Runoff pipe audio component missing. Reinstall the complete release.'}
 $audioLogDir=Join-Path $game "$Profile/logs"
 $audioArguments=@('--pid',"$($process.Id)",'--log-dir',('"{0}"' -f $audioLogDir))
 Start-Process -FilePath $audioExe -ArgumentList $audioArguments -WindowStyle Hidden | Out-Null
}
Write-Output "PID: $($process.Id); profile: $Profile"
