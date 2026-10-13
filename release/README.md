# TF1 Runoff 0.3.3

Complete Runoff port for Titanfall 2 / Northstar, delivered as **one mod and one ZIP**. This is a full package; the earlier 0.3.0 and 0.3.2 archives are not required.

- Native world and model materials, full texture mip chains and a Runoff-specific `.stbsp` streaming database.
- Preserved collision repairs and both tested Titan navigation connections.
- Lighting, shadows, water, fog, skybox, pipe effects and spatial pipe audio.
- Corrected loading image, map selection preview and private-lobby preview. Map title: **TF1 Runoff**. Standard maps remain available.
- Lossless Titanfall-compatible LZHAM VPK compression for models and legacy materials. No texture resizing or asset pruning.
- No inspection, collision-debug, jump-debug, capture or navmesh-debug mods. Frontier Defense remains excluded.

## Requirements and installation

Requires an installed Windows 64-bit Titanfall 2 game and **Northstar mods 1.31.13**. Neither the game nor Northstar binaries are included. The installer and pipe audio component are standalone executables; installing Python is unnecessary.

1. Extract the complete ZIP to a folder. Stop the client and server before updating their profiles.
2. Run `Install-Runoff.cmd` and select the Titanfall 2 folder. This installs `RunoffClient` and `RunoffServer`, using the installed `R2Northstar` profile as the Northstar baseline.
3. Start `RunoffClient/Start-RunoffClient.cmd`. Select TF1 Runoff in the private lobby and start the desired supported mode.
4. For a local dedicated server, start `RunoffServer/Start-RunoffServer.cmd`.

For custom profiles or a different baseline:

```powershell
.\Install-Runoff.exe --game "D:\Games\Titanfall2" --base-profile R2Northstar --profiles MyClient MyServer
```

The installer verifies payload SHA-256 hashes before installing. It preserves and disables older separate Runoff mods, backs up an existing merged mod and enabled-mod configuration, and reconstructs the small Northstar menu/script changes from your installed baseline. Do not run the merged mod together with older Runoff components. Reused identical binary assets can be hard-linked to save disk space.

Use the supplied client launcher for pipe audio: it automatically starts `RunoffPipeAudio.exe`, which stops when the client exits. Directly launching Northstar without this launcher does not start the pipe audio companion. Other game audio remains native.

The supplied server launcher is for local testing: port 37042, insecure local authentication, and master-server reporting disabled. It backs up the profile server autoexec as `runoff-original-autoexec_ns_server.cfg` and applies local settings in the existing Northstar.CustomServers cfg directory. For public hosting, restore that backup to `mods/Northstar.CustomServers/mod/cfg/autoexec_ns_server.cfg` and use your own launcher, authentication, reporting and network settings. Full public internet hosting has not been validated.

## Checks and limitations

All 1,856 original DDS texture records were audited against their source images and packed mip data. Dimensions were preserved. The 374 existing full-XYZ normal conversions were checked across all original mip levels. Source NMC decoding was corrected for 23 detail-normal materials and 16 two-layer materials; another two-layer material now uses full XYZ decoding. All 23 detail-normal UV scales match the source values (4, 6 or 8). The corrected 160 shader permutations passed D3D11 creation checks.

The large wavy floor highlights shown in the reported screenshot were removed in the local game. Full original-versus-port visual equivalence is not claimed: TF1/TF2 gloss and fresnel response and extra detail normals on two-layer materials still differ or remain unverified. Pipe grapple attachment and pipe sound were confirmed by the author. See `VALIDATION.json` for packaged checks.

The native STBSP file resolves all 526 listed materials. Its estimates are derived from world UV density and conservative geometry bounds, without an occlusion bake. This preserves texture detail but can retain more texture data than the original game's compiler would.

Previously reported intermittent `datacache.dll` crashes during match/lobby transitions have not been established as fully resolved. This release does not claim to eliminate every engine crash. Preserve the profile's `logs` folder if a crash occurs.

To remove the map, disable `TF1.Runoff` or remove its mod folder while the game is closed. Older files and configurations are retained under the profile's `runoff-backups` folder when replaced. The installed stock Northstar mods are preserved.

## Credits

Titanfall and the original map, models, textures and audio belong to Respawn Entertainment / Electronic Arts. This package contains the Runoff port and required map resources, not the base game. Northstar is provided by the R2Northstar project; this is an independent map release.

Map adaptation, fixes, streaming estimates and packaging were assisted by OpenAI Codex. Loading/menu artwork is an in-game capture selected by the author; AI-assisted cleanup was limited to the unwanted narrow edge of that capture. The bundled audio component uses Python, NumPy, CFFI, sounddevice / PortAudio and PyInstaller; their notices are in `licenses`. No generated replacement map textures or audio are used.

Older releases remain at <https://github.com/Strykus/TF1-Runoff/releases>.
