# TF1 Runoff

Latest release: **[0.3.4 — one complete ZIP](https://github.com/Strykus/TF1-Runoff/releases/tag/v0.3.4)** for both client and server. Earlier archives are not needed.

Download `TF1.Runoff-0.3.4.zip`, extract it completely, close the game/server, and run `Install-Runoff.cmd`. Select the Titanfall 2 installation containing Northstar mods **1.31.13**. Start the resulting `RunoffClient/Start-RunoffClient.cmd`; this also starts pipe audio. `RunoffServer/Start-RunoffServer.cmd` starts a local dedicated server.

- One merged `TF1.Runoff` mod, without diagnostic or capture mods.
- Accepted collision revision 7 for 20 model types; Runoff uses `mat_sky_scale 0.4` and restores the previous value on exit.
- Full texture mip chains and a map-specific `.stbsp` streaming database.
- Corrected normal decoding for 40 detail/layer materials and the original detail scales for all 23 detail-normal materials.
- Preserved lighting, shadows, water, effects, spatial pipe audio and repaired collision. Grapple attachment to the reported Treatment pipe works.
- Both Titan passages remain connected and were confirmed in game.
- Loading image, map-selection and private-lobby preview; standard maps remain available.
- Lossless LZHAM VPK compression for models and legacy materials; no texture resizing.

[English installation and limitations](release/README.md) · [Инструкция на русском](release/README.ru.md) · [Validation summary](release/VALIDATION.json) · [Changelog](release/CHANGELOG.md)

The complete binary payload is in the release ZIP. This repository contains the install/launch sources, map runtime scripts, small Northstar compatibility patches and payload hashes. Stock game and Northstar executables and diagnostic tools are not included. The installer preserves older Runoff mods and configurations in backups.

The bundled server launcher applies local authentication/reporting settings and saves the original server autoexec. Public internet hosting has not been validated. Previously reported intermittent `datacache.dll` transition crashes cannot be considered fully eliminated. Exact TF1/TF2 gloss/Fresnel response and additional detail normals on two-layer materials remain unverified or unsupported.

The older automatic-download manifest and root installers target legacy 0.3.0/0.3.2 packages; use the new complete ZIP and its installer for 0.3.4. [Legacy instructions](LEGACY-0.3.0.md).

Original Titanfall assets belong to Respawn Entertainment / Electronic Arts. Map adaptation, validation, packaging and limited cleanup of the loading capture were assisted by OpenAI Codex. No generated replacement map textures or audio are used.
