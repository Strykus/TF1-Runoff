# Runoff for Northstar

Custom Runoff map package for Titanfall 2 / Northstar, version 0.3.0.

Download all three ZIP files from [the release](https://github.com/Strykus/TF1-Runoff/releases/tag/v0.3.0):

- `TF1.RunoffNative-0.3.0.zip`: map, models, collision, navigation and map scripts.
- `TF1.RunoffWorld-0.3.0.zip`: world textures and shader resources.
- `TF1.RunoffModels-0.3.0.zip`: model textures and shader resources.

Extract each ZIP into a folder with the corresponding mod name inside your Northstar profile's `mods` folder. Each mod's `mod.json` must be directly inside that folder. Keep all three mods at the same version.

For an existing dedicated server, stop it before installing. Download `Install-IntoExistingServer.ps1`, `Install-IntoExistingServer.cmd` and `archives.json` from this repository, place them next to the three ZIP files, and run the CMD file. It defaults to the `R2Northstar` profile; for another profile, run the PowerShell script with `-Profile YourProfileName`. Preserve your current server settings and change the map argument to `+map mp_tf1_runoff`.

For the custom automatic download manifest, add this launch argument to Northstar:

```text
-customverifiedurl=https://raw.githubusercontent.com/Strykus/TF1-Runoff/main/verified_mods.json
```

Restart Northstar after changing the launch argument. The server requires all three client mods. This is a custom manifest; this project has not been submitted to Northstar VerifiedMods.

For dedicated hosting, Titanfall 2 and Northstar must already be installed. Launch your prepared profile with:

```text
NorthstarLauncher.exe -dedicated -profile=RunoffPublic -port 37042 +hostport 37042 +ns_report_server_to_masterserver 1 +ns_auth_allow_insecure 0 +ns_server_name "TF1 Runoff | Navmesh Test" +setplaylist private_match +mp_gamemode aitdm +map mp_tf1_runoff
```

Allow UDP 37042 through the host firewall and forward it on the host network's router. Public internet hosting additionally requires a reachable public endpoint. The map package does not bypass provider NAT.

Seven native Atlas route tests passed in the local game, including both entrance ramps, canal movement, the centre hatch and the canal incline. Native collision surfaces were restored on the incline after navigation clearance clipping. Titan navigation is excluded only from the selected central building roofs; infantry and Reaper meshes remain available. The portable package also loaded in a separate Northstar profile without script errors. These checks do not establish internet reachability of any hosted server.

This is a testing release. Titanfall and its assets belong to their respective owners. Requires the user's installed Titanfall 2 game. The archives contain the custom map port and its client resources; the base game and Northstar executable are not included. Map conversion, navigation and packaging were assisted by AI.
