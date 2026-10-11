param([string]$GameDirectory,[string]$Profile='R2Northstar')
$ErrorActionPreference='Stop'
if(-not $GameDirectory){$GameDirectory=Read-Host 'Full path to Titanfall 2'}
$taskGame=(Resolve-Path -LiteralPath $GameDirectory).Path
$taskProfile=Join-Path $taskGame $Profile
if(-not (Test-Path -LiteralPath (Join-Path $taskProfile 'Northstar.dll'))){throw "Northstar profile not found: $taskProfile"}
Write-Host 'Stop your existing dedicated server before installing the map.'
$taskAnswer=Read-Host 'Server stopped? Type YES to continue'
if($taskAnswer -ne 'YES'){throw 'Installation cancelled; no files changed.'}
$taskRows=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'archives.json') -Raw | ConvertFrom-Json
foreach($taskRow in $taskRows){
 $taskZip=Join-Path $PSScriptRoot ([IO.Path]::GetFileName($taskRow.archive))
 if((Get-FileHash -LiteralPath $taskZip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $taskRow.sha256){throw "Checksum mismatch: $taskZip"}
 if(Test-Path -LiteralPath (Join-Path $taskProfile ('mods\'+$taskRow.name))){throw "Mod already exists: $($taskRow.name). Preserve it outside mods before installing this version."}
}
foreach($taskRow in $taskRows){
 $taskZip=Join-Path $PSScriptRoot ([IO.Path]::GetFileName($taskRow.archive))
 Expand-Archive -LiteralPath $taskZip -DestinationPath (Join-Path $taskProfile ('mods\'+$taskRow.name))
}
Write-Host 'Map installed. Keep your existing server settings and change its map argument to: +map mp_tf1_runoff'
Write-Host 'Clients need: -customverifiedurl=https://raw.githubusercontent.com/Strykus/TF1-Runoff/main/verified_mods.json'
