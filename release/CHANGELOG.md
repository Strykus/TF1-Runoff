# 0.3.3

- Consolidated twelve Runoff runtime components into one `TF1.Runoff` mod and one complete archive.
- Added the Runoff-specific STBSP v8.0 streaming database; preserved all texture resolutions and mip chains.
- Packed 2,759 model/material files into lossless LZHAM VPKs: 1,147,619,102 bytes became 625,054,677 bytes. Source hashes and decompressed hashes match.
- Preserved accepted collision repairs and both tested Titan navigation connections.
- Included final loading/menu artwork with corrected colour conversion and working private-lobby preview.
- Preserved map lighting, shadows, water, skybox, fog and pipe effects.
- Added a bundled standalone spatial pipe audio component, started by the client launcher.
- Added a standalone installer with payload verification, backups, profile-path rebasing and small installed-Northstar patches.
- Excluded diagnostic tools, private test scripts and capture/debug assets.

This release does not establish that all intermittent datacache transition crashes are resolved.

- Correct source NMC normal decode for 40 detail/layer materials; restore all 23 authored detail UV scales.
- Preserve full XYZ normal blending on the concrete cracks two-layer material.
- Repair grapple surface classification for the curved Treatment pipe.
- Keep local server autoexec in its original cfg directory, preserving persistent-player-data lookup.
