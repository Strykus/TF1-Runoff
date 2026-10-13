param([Parameter(Mandatory=$true)][string]$GameDirectory,[string]$Profile='RunoffClient',[string]$Address='127.0.0.1:37042',[switch]$Listen,[switch]$Menu,[switch]$Connect,[ValidateSet('aitdm','cp','ctf','lts','tdm','ps','ffa','mfd','ttdm','speedball','at')][string]$GameMode='aitdm')
$ErrorActionPreference='Stop'
$game=(Resolve-Path -LiteralPath $GameDirectory).Path
if(-not(Test-Path -LiteralPath "$game/$Profile/enabledmods.json")){throw 'Install the clean client profile first.'}
$arguments=@('-multiple',"-profile=$Profile",'-novid','-windowed','-w','1280','-h','720','-port','37041','+hostport','37041','+not_focus_sleep','0','+developer','0','+ns_print_played_sounds','0','+mileslog_enable','0','+ns_auth_allow_insecure','1','+ns_auth_allow_insecure_write','0','+ns_report_server_to_masterserver','0','+ns_report_sp_server_to_masterserver','0')
if($Listen){$arguments+=@('+net_usesocketsforloopback','0','+setplaylist',$GameMode,'+mp_gamemode',$GameMode,'+map','mp_tf1_runoff')}
elseif($Connect){$arguments+=@('+net_usesocketsforloopback','1','-runoff-connect','+runoff_server_address',$Address)}
else{$arguments+=@('+net_usesocketsforloopback','0')}
$client=Start-Process -FilePath "$game/NorthstarLauncher.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Normal -PassThru
$helper="$game/$Profile/audio-helper/pipe_spatial_audio.py"
if(Test-Path -LiteralPath $helper){
 $python=Get-Command python.exe -ErrorAction SilentlyContinue
 if($python){
  & $python.Source -c 'import sys;sys.path.insert(0,sys.argv[1]);import numpy, sounddevice' "$game/$Profile/audio-helper/audio-runtime" 2>$null
  if($LASTEXITCODE -eq 0){
   New-Item -ItemType Directory -Path "$game/$Profile/audio-helper/runoff-playback" -Force | Out-Null
   Start-Process -FilePath $python.Source -ArgumentList @('"'+$helper+'"','--pid',$client.Id,'--log-dir','"'+$game+'/'+$Profile+'/logs"') -WindowStyle Hidden | Out-Null
  }
 }
}
Write-Output "Client PID: $($client.Id)"
