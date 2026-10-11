param([string]$GameDirectory)
$ErrorActionPreference='Stop'
if(-not $GameDirectory){$GameDirectory=Read-Host 'Full path to Titanfall 2 with Northstar installed'}
$taskGame=(Resolve-Path -LiteralPath $GameDirectory).Path
if(-not (Test-Path -LiteralPath (Join-Path $taskGame 'NorthstarLauncher.exe'))){throw 'Install Northstar into this Titanfall 2 directory first.'}
$taskBase=Join-Path $taskGame 'R2Northstar'
if(-not (Test-Path -LiteralPath (Join-Path $taskBase 'Northstar.dll'))){throw 'Standard R2Northstar profile was not found. Update/install Northstar first.'}
$taskProfile=Join-Path $taskGame 'RunoffPublic'
if(Test-Path -LiteralPath $taskProfile){throw 'RunoffPublic already exists. Rename it to preserve the previous installation, then run this installer again.'}
New-Item -ItemType Directory -Path (Join-Path $taskProfile 'mods') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $taskBase 'Northstar.dll') -Destination $taskProfile
foreach($taskName in @('Northstar.Client','Northstar.Custom','Northstar.CustomServers')){
 $taskSource=Join-Path $taskBase ('mods\'+$taskName)
 if(-not (Test-Path -LiteralPath $taskSource)){throw "Missing standard mod: $taskName"}
 Copy-Item -LiteralPath $taskSource -Destination (Join-Path $taskProfile 'mods') -Recurse
}
$taskManifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'archives.json') -Raw | ConvertFrom-Json
foreach($taskEntry in $taskManifest){
 $taskZip=Join-Path $PSScriptRoot ([IO.Path]::GetFileName($taskEntry.archive))
 if((Get-FileHash -LiteralPath $taskZip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $taskEntry.sha256){throw "Checksum mismatch: $taskZip"}
 Expand-Archive -LiteralPath $taskZip -DestinationPath (Join-Path $taskProfile ('mods\'+$taskEntry.name))
}
@{GameDirectory=$taskGame;Profile=$taskProfile;Port=37042} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'installation.json')
Write-Host "Installed into $taskProfile"
Write-Host 'Run Start-RunoffServer.cmd. Forward UDP 37042 on this computer''s router for internet access.'
