# TF1 Runoff

This repository is the Runoff map port, its runtime scripts, installers and release metadata. It is separate from Strykus/Titanfall-2-Vix, which contains the Vixine model-porting program. Do not change that repository for map tasks.

Read docs/COPILOT_HANDOFF.md before continuing the current task. When working on the user's Windows computer, LOCAL_RUNOFF_HANDOFF.md is an ignored local document with installed-profile paths and detailed diagnostic evidence.

Current user requirements: preserve working water appearance and restored ground fog; do not restore experimental lamp/glow sprites; produce a variant without an additional shader DLL. Do not treat that last requirement as already runtime-verified. Do not modify Lagoon profiles or stop unrelated game processes.

Preserve originals and back up installed files before changes. Verify client/server file symmetry where relevant. Separate file/hash/build checks from actual game verification. Never call a release verified or published based only on a local ZIP. Do not commit extracted game binaries, personal logs, credentials, or machine-specific configuration.

The published 0.3.4 release and local 0.3.5-rc.3 candidate are distinct. Do not silently overwrite published-release manifests with partially tested candidate contents. Respond in the user's latest language.
