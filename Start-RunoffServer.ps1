$ErrorActionPreference='Stop'
$taskInstall=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'installation.json') -Raw | ConvertFrom-Json
$taskExe=Join-Path $taskInstall.GameDirectory 'NorthstarLauncher.exe'
$taskArgs=@('-multiple','-dedicated','-profile=RunoffPublic','-port','37042','+hostport','37042','+ns_auth_allow_insecure','0','+ns_report_server_to_masterserver','1','+ns_server_name','"TF1 Runoff | Navmesh Test"','+ns_server_desc','"Runoff 0.3.0 custom map"','+setplaylist','private_match','+mp_gamemode','aitdm','+sv_cheats','0','+map','mp_tf1_runoff')
$taskServer=Start-Process -FilePath $taskExe -WorkingDirectory $taskInstall.GameDirectory -ArgumentList $taskArgs -WindowStyle Hidden -PassThru
Write-Host "Server PID: $($taskServer.Id)"
Write-Host "Logs: $($taskInstall.Profile)\logs"
Write-Host 'Client launcher flag: -customverifiedurl=https://raw.githubusercontent.com/Strykus/TF1-Runoff/main/verified_mods.json'
Write-Host 'A successful local launch alone does not prove that the server is reachable from the internet.'
