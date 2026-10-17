# Runoff task handoff — 2026-10-17

## User's current request

Continue work in the local GitHub Copilot application using this repository, not Titanfall-2-Vix. The latter must contain only the Vixine model-porting program.

The desired map has working water plus restored ground fog. Experimental light/glow sprites were the problematic part and must remain reverted. A variant without an additional shader DLL is required. Lagoon is a separate active task and must not be changed.

## Current local candidate

- Installed mod version: 0.3.5-rc.3, map mp_tf1_runoff.
- Both local Runoff profiles have the restored ground-fog script and PCF: 94 env_ground_fog_256_lite, 10 env_ground_fog_256, 23 env_ground_fog_far placements.
- Ground-fog script SHA256: 5e7c699d62694b2ccadf92fdc90918fb552948d1016a8bc3b837ac92968471c7.
- Ground-fog PCF SHA256: 02848b59d8c50d2cc7916e1bc30b797f8d88e96b5dccd9f4423f506d08bf4760.
- mp_tf1_runoff_fx.ent is restored to its 376-byte sun-only state. No experimental lamp/glow entities are installed.
- Water files match the saved local candidate; the shader runtime DLL is disabled.
- The combined current state has not yet passed a fresh game run.

## Important correction

The user's earlier visual acceptance of the water is valid, but a previous report calling that session DLL-free was incorrect: its startup log contained a plugin load. A ZIP without a DLL does not prove the running client did not load an existing plugin. Verify the fresh process and loaded modules.

Removing mismatched Basic shader overrides allowed menu startup but did not establish map stability. The last observed render crashes were materialsystem_dx11.dll + 0x32c1c before the map and + 0x30bbf on map load. Full Basic caches and split files must stay consistent; ordinary mod GAME paths and shader PLATFORM paths are different. A data-only VPK experiment exists locally but is not installed or runtime-verified.

## Next steps

1. Read the ignored local handoff document for exact source, backup, profile and evidence paths. Inspect actual files before making changes; another Copilot session is working on Lagoon.
2. Preserve restored fog, water assets and the absence of experimental light sprites.
3. Verify or fix loading the existing water/shader data without an additional DLL. Do not reinstall the DLL as a hidden dependency or claim the old no-DLL evidence is conclusive.
4. Verify actual Runoff gameplay, water above/below the surface and while crouching, submerged models/door bottoms, ground fog, and absence of new crashes.
5. Package a complete candidate only after verification. Keep published 0.3.4 release metadata unchanged until a deliberate release update.

The local machine-specific handoff is LOCAL_RUNOFF_HANDOFF.md (ignored). This repository clone contains the existing published sources; the newer installed candidate and porter source tree are external local inputs listed there. They were not automatically published by this handoff.
