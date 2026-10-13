param(
 [Parameter(Mandatory=$true)][string]$GameDirectory,
 [string]$NorthstarProfile='R2Northstar',
 [string]$ClientProfile='RunoffClient',
 [string]$ServerProfile='RunoffServer'
)
$ErrorActionPreference='Stop'
$game=(Resolve-Path -LiteralPath $GameDirectory).Path
if(-not(Test-Path -LiteralPath (Join-Path $game 'NorthstarLauncher.exe'))){throw 'NorthstarLauncher.exe is missing from the selected game folder.'}
foreach($name in @($ClientProfile,$ServerProfile,$NorthstarProfile)){
 if($name -notmatch '^[A-Za-z0-9_-]+$'){throw 'Profile names may contain only letters, numbers, hyphens and underscores.'}
}
if($ClientProfile -eq $ServerProfile){throw 'Client and server profiles must have different names.'}
$client=Join-Path $game $ClientProfile
$server=Join-Path $game $ServerProfile
foreach($path in @($client,$server)){if(Test-Path -LiteralPath $path){throw "Preserving existing profile: $path. Choose different profile names."}}
$stock=Join-Path $game $NorthstarProfile
foreach($name in @('Northstar.Client','Northstar.Custom','Northstar.CustomServers')){
 if(-not(Test-Path -LiteralPath (Join-Path $stock "mods/$name/mod.json"))){throw "Installed Northstar mod is missing: $name"}
}
New-Item -ItemType Directory -Path "$client/mods" | Out-Null
foreach($dir in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'mods') -Directory){Copy-Item -LiteralPath $dir.FullName -Destination "$client/mods/$($dir.Name)" -Recurse}
foreach($name in @('Northstar.Client','Northstar.Custom','Northstar.CustomServers')){Copy-Item -LiteralPath (Join-Path $stock "mods/$name") -Destination "$client/mods/$name" -Recurse}
New-Item -ItemType Directory -Path "$server/mods" | Out-Null
$sharedExtensions=@('.bsp','.mdl','.vtf','.rpak','.starpak','.nm','.ain')
foreach($file in Get-ChildItem -LiteralPath "$client/mods" -File -Recurse){
 $relative=$file.FullName.Substring($client.Length+1)
 $target=Join-Path $server $relative
 New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
 if($file.Extension.ToLowerInvariant() -in $sharedExtensions){New-Item -ItemType HardLink -Path $target -Target $file.FullName | Out-Null}
 else{Copy-Item -LiteralPath $file.FullName -Destination $target}
}
foreach($role in @(@{Path=$client;Name=$ClientProfile},@{Path=$server;Name=$ServerProfile})){
 foreach($config in Get-ChildItem -LiteralPath "$($role.Path)/mods" -Filter rpak.json -File -Recurse){
  $text=(Get-Content -LiteralPath $config.FullName -Raw).Replace('RUNOFF_PROFILE',$role.Name).Replace('RunoffUpdated',$role.Name)
  Set-Content -LiteralPath $config.FullName -Value $text -Encoding utf8
 }
 $enabled=[ordered]@{Version=1}
 foreach($dir in Get-ChildItem -LiteralPath "$($role.Path)/mods" -Directory){
  $meta=Get-Content -LiteralPath "$($dir.FullName)/mod.json" -Raw | ConvertFrom-Json
  $enabled[$meta.Name]=@{$meta.Version=$true}
 }
 $enabled | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath "$($role.Path)/enabledmods.json" -Encoding utf8
 if(Test-Path -LiteralPath "$stock/Northstar.dll"){Copy-Item -LiteralPath "$stock/Northstar.dll" -Destination "$($role.Path)/Northstar.dll"}
 $config="$($role.Path)/mods/Northstar.CustomServers/mod/cfg/autoexec_ns_server.cfg"
 if(Test-Path -LiteralPath $config){
  $text=Get-Content -LiteralPath $config -Raw
  $text=[regex]::Replace($text,'(?m)^ns_auth_allow_insecure\s+.*$','ns_auth_allow_insecure 1')
  $text=[regex]::Replace($text,'(?m)^ns_report_server_to_masterserver\s+.*$','ns_report_server_to_masterserver 0')
  $text=[regex]::Replace($text,'(?m)^ns_report_sp_server_to_masterserver\s+.*$','ns_report_sp_server_to_masterserver 0')
  Set-Content -LiteralPath $config -Value $text -Encoding utf8
 }
}
if(Test-Path -LiteralPath (Join-Path $PSScriptRoot 'audio-helper')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'audio-helper') -Destination "$client/audio-helper" -Recurse}
Write-Output "Installed clean client: $client"
Write-Output "Installed clean server: $server"
