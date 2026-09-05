# Easier Parry - UE4SS v1.0.5

Nexus listing materials now live in the repository's Nexus folder, separately from the Vortex ZIP: thumbnail.png, description.bbcode.txt, metadata.json, image attribution, and upload guidance. The archive retains the mod manifest, README, license, changelog, release notes, Vortex metadata, and runtime payloads. Lua and INI bytes are unchanged from v1.0.4.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game and replace/reinstall the existing Easier Parry entry from Easier-Parry-UE4SS.zip through Vortex. Use **UE4SS (Lua mods)** if prompted, then deploy and restart. Keep one enabled entry; this version replaces the previous EasierParryUE4SS files.

The ZIP includes the full INI with factor = 2.0 and pollMilliseconds = 1000. Back up custom preferences and reapply them after replacement; settings are not automatically merged. Other mods modifying ParryWindowMultiplier may conflict. To uninstall, disable/remove through Vortex, deploy, and restart.

## Validation

The actual ZIP is checked against an explicit allowlist and canonical source bytes. Read-only installer planning against the installed Vortex extension verifies the Lua mod type, runtime destinations, and Vortex metadata. Two consecutive builds replace the same ZIP. All runtime payloads match published v1.0.4.

This remains a prerelease because the existing v1.0.2 performance fix still needs in-game validation. This packaging update makes no gameplay changes. Check normal gameplay, parrying, save loading, death/reload, and player transitions. Game build target remains 25129649 / CL-257186.
