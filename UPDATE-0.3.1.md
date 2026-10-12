# Runoff 0.3.1: map runtime update

Download `Runoff-0.3.1-update.zip` from the [0.3.1 release](https://github.com/Strykus/TF1-Runoff/releases/tag/v0.3.1).

This is a differential update. It reconstructs the tested map from the three published 0.3.0 archives and the user's own Titanfall 1 assets. It does not contain Titanfall executables, Northstar executables, collision editors, the inspector, navigation editors or test probes.

## Included changes

- Preserve both repaired Titan navigation connections. Large navigation mesh SHA-256: `6a6f3521231a189d5f7129af787933f7e5b93dfcf8fda95c4c38f695b9ccad61`.
- Restore the accepted model flags and retain accepted collision fixes. Remove the later NO_DRAW/NO_SHADOW experiment. BSP SHA-256: `048099c4d8ce86e58313e914001d628494443d10d789cdf6be7b2051792fa405`.
- Include map objectives and native Titanfall 2 game modes, lobby map compatibility, radar, water and accepted material changes. Frontier Defense is excluded.
- Consolidate soft lighting, original sun and ground fog into `TF1.RunoffVisuals`. Keep tube particles, spatial pipe audio, atmosphere and water as separate runtime components.
- Reapers default to enabled in modes other than Attrition; the mode still determines whether AI is spawned.

## Installation

Requirements: installed Titanfall 2 / Northstar, Python 3.11+, the original three 0.3.0 ZIPs, and extracted assets from the user's Titanfall 1 installation. `tf1-required-assets.json` lists the exact additional asset paths and hashes. Extraction must preserve the raw VPK audio bytes; some extractors decrypt audio, which produces a different source hash. Existing profiles are preserved. The installer refuses to overwrite a profile.

Place the update ZIP and `Apply-RunoffUpdate.py` together. Put the three 0.3.0 ZIPs in `baseline`. Run:

```powershell
py -3 Apply-RunoffUpdate.py --archives .\baseline --tf1-assets "D:\ExtractedTitanfall1" --game "D:\Titanfall2" --profile RunoffUpdated
```

`--tf1-assets` can be repeated for multiple extraction roots. `--northstar-profile` defaults to `R2Northstar`; choose the profile containing the installed stock Northstar mods if necessary. A source hash mismatch stops installation. Use `--verify-only` to reconstruct and verify the update without installing a profile.

To remove the update, remove only the newly created `RunoffUpdated` profile after closing its client/server. Do not mix this profile with older diagnostic mods.

Use a separate dedicated server and client. Example local test:

```powershell
.\NorthstarLauncher.exe -dedicated -profile=RunoffUpdated -port 37042 +hostport 37042 +ns_report_server_to_masterserver 0 +ns_auth_allow_insecure 1 +setplaylist private_match +mp_gamemode at +map mp_tf1_runoff
.\NorthstarLauncher.exe -profile=RunoffUpdated -port 37041 +connect 127.0.0.1:37042
```

The optional pipe sound runtime is installed under `RunoffUpdated/mods/audio-helper`. Install `numpy` and `sounddevice` for the Python interpreter running it, then run this for the actual client PID:

```powershell
py -3 -m pip install numpy sounddevice
py -3 .\RunoffUpdated\mods\audio-helper\pipe_spatial_audio.py --pid 12345 --log-dir .\RunoffUpdated\logs
```

Replace `12345` with the running client PID. This reads the client-written audio state file; it does not inspect game memory.

## Verification and limitations

The consolidated visual scripts compiled in a separate client/dedicated-server Bounty Hunt run: 94 ground fog emitters, three banks and eight AI units were reported. The mode adaptation was previously checked across 11 modes. The update reconstructs every packaged file and verifies its SHA-256.

Native Titan traversal across the two newest connections remains unverified. The native listen-server/private-lobby crash at `datacache.dll + 0x5b10e` is still unresolved; restoring model flags does not establish a fix. Use a separate dedicated server and client for testing. Logs are in the selected profile's `logs` folder.

The existing `verified_mods.json` continues to describe the complete 0.3.0 release. It does not automatically install this differential update.

## Credits

Titanfall assets belong to Respawn/EA. Asset patches require the user's existing copies. Northstar provides the mod runtime. Map conversion, navigation, scripts and packaging were developed with Codex assistance. No generated artwork or audio was added in this update. No new license is granted for third-party game assets.
