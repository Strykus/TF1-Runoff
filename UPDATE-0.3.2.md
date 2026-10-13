# Runoff 0.3.2 — clean client/server profiles

This update removes map diagnostic tools and preserves the accepted collision fixes, both new Titan navigation connections, 11 supported modes, minimap, water, lighting, shadows, fog, sun and tube effects. Frontier Defense remains excluded. The user confirmed that Titans traverse both repaired passages.

The previous differential build omitted 1,957 effective map resources, including the color-correction LUT and baked material textures. These are restored from the original baseline archives. No collision inspector, jump/nav overlays, collision editor, mode tester, crash probe or squad monitor is installed. Normal Northstar logging remains available.

## Requirements and installation

Use installed Titanfall 2 with Northstar and Python 3.11+. The Northstar source patches were verified against the installed 1.31 distribution; modified stock scripts fail the source-hash check. Keep the three original 0.3.0 archives and your own extracted Titanfall 1 assets. `tf1-required-assets.json` lists the additional original asset paths and hashes.

Download these files from [0.3.2 Releases](https://github.com/Strykus/TF1-Runoff/releases/tag/v0.3.2):

- `Runoff-0.3.2-update.zip`
- `Apply-RunoffClean.py`
- `Install-RunoffClean.ps1`
- `Start-RunoffClient.ps1`
- `Start-RunoffCleanServer.ps1`

Place them together. Put `TF1.RunoffNative-0.3.0.zip`, `TF1.RunoffWorld-0.3.0.zip` and `TF1.RunoffModels-0.3.0.zip` into `baseline`. Close the old map clients/servers, then run:

```powershell
py -3 Apply-RunoffClean.py --archives .\baseline --tf1-assets "D:\ExtractedTitanfall1" --game "D:\Titanfall2"
```

The installer creates separate `RunoffClient` and `RunoffServer` profiles and copies the three stock Northstar mods from `R2Northstar`. Existing profiles are preserved; use `--client-profile` and `--server-profile` to choose unused names. `--northstar-profile` selects the installed stock profile. Repeat `--tf1-assets` for additional extraction roots. Use `--verify-only` to check all reconstructed files without installing.

## Launch through the menu

```powershell
.\Start-RunoffClient.ps1 -GameDirectory "D:\Titanfall2"
```

The client opens the main menu. Enter Northstar multiplayer, open a private lobby, choose a supported mode and `mp_tf1_runoff`, then start the match. It uses `net_usesocketsforloopback 0` for local play. This setting is also applied before the menu creates a private lobby. Map registration now uses the same initial order in UI, client and server.

Local Bounty Hunt loaded successfully through the private-lobby menu on 2026-10-13. The client log recorded a connected player on Runoff, with sun 0.40, exposure 0.55 and reflection scale 0.60. This avoids the observed crashing listen-server configuration; it is not a repair to the engine's model-cache implementation or proof that every possible transition and mode is stable.

For a separate local dedicated server/client pair:

```powershell
.\Start-RunoffCleanServer.ps1 -GameDirectory "D:\Titanfall2" -GameMode at
.\Start-RunoffClient.ps1 -GameDirectory "D:\Titanfall2" -Connect
```

`-Connect` enables loopback sockets for the separate-process connection and connects after UI initialization. The server defaults to UDP 37042 and the client to 37041. These scripts configure local testing with insecure authentication enabled and masterserver reporting disabled; they are not public-hosting settings. `-Listen -GameMode at` is an optional direct local map launch.

The optional spatial pipe audio helper uses the client-written state JSON, not process memory. Install `numpy` and `sounddevice` in the Python interpreter used by the launcher if needed. No audio-test commands or monitoring UI are installed.

## Verification and removal

All 2,840 reconstructed files passed SHA-256 verification, and the update ZIP passed its CRC check. Both clean profiles were installed separately. The accepted BSP hash is `048099c4d8ce86e58313e914001d628494443d10d789cdf6be7b2051792fa405`; the large Titan navmesh hash is `6a6f3521231a189d5f7129af787933f7e5b93dfcf8fda95c4c38f695b9ccad61`.

To uninstall, close the corresponding processes and remove only the newly created profile folders. Logs are inside each profile's `logs` folder. The existing automatic-download `verified_mods.json` still describes 0.3.0; it does not install this differential update.

Titanfall assets belong to Respawn/EA and must come from the user's existing copies. Northstar provides the runtime. Map conversion, scripts, navigation and packaging were developed with Codex assistance. No generated art or audio was added. No new license is granted for third-party assets. The repository's `runtime` directory contains selected editable mod sources; generated stock-script overrides are supplied as patches, and complete installed profiles are reconstructed by the installer.
