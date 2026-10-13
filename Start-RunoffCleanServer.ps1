param([Parameter(Mandatory=$true)][string]$GameDirectory,[string]$Profile='RunoffServer',[ValidateSet('aitdm','cp','ctf','lts','tdm','ps','ffa','mfd','ttdm','speedball','at')][string]$GameMode='aitdm',[int]$Port=37042)
$ErrorActionPreference='Stop'
$game=(Resolve-Path -LiteralPath $GameDirectory).Path
if(-not(Test-Path -LiteralPath "$game/$Profile/enabledmods.json")){throw 'Install the clean server profile first.'}
$running=Get-CimInstance Win32_Process -Filter "Name='NorthstarLauncher.exe'" | Where-Object { $_.CommandLine -like "*-dedicated*" -and $_.CommandLine -like "*-profile=$Profile*" }
if($running){throw "Server profile is already running (PID $($running.ProcessId -join ', '))."}
$arguments=@('-multiple','-dedicated',"-profile=$Profile",'-port',"$Port",'+hostport',"$Port",'+developer','0','+sv_cheats','0','+ns_auth_allow_insecure','1','+ns_auth_allow_insecure_write','0','+ns_report_server_to_masterserver','0','+ns_report_sp_server_to_masterserver','0','+setplaylist','private_match','+mp_gamemode',$GameMode,'+map','mp_tf1_runoff')
$server=Start-Process -FilePath "$game/NorthstarLauncher.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
Write-Output "Server PID: $($server.Id); UDP port: $Port"
