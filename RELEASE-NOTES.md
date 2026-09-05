# Easier Parry - UE4SS v1.0.4

The thumbnail now uses an official in-game sword-clash screenshot with a simple title overlay. Screenshot attribution is included in `Nexus Assets/THUMBNAIL-SOURCE.md`. Lua and INI payloads are unchanged from v1.0.3. This is a promotional-image update; installing it does not change gameplay.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game and replace/reinstall the existing Easier Parry entry from `Easier-Parry-UE4SS.zip` through Vortex. Use **UE4SS (Lua mods)** if prompted, then deploy and restart. Keep one enabled entry and let this version replace the previous EasierParryUE4SS files.

The ZIP includes the full INI with `factor = 2.0` and `pollMilliseconds = 1000`. Back up custom preferences and reapply them after replacement; settings are not automatically merged. If retaining an older INI, set `pollMilliseconds = 1000` and restart for the new default interval.

No other mod is required. Mods modifying `ParryWindowMultiplier` may conflict. To uninstall, disable/remove through Vortex, deploy, and restart.

## Validation

The actual ZIP is checked against an explicit file allowlist and canonical source bytes, including the full description and thumbnail. Installer planning against the installed Vortex extension verifies the Lua mod type, unchanged runtime destinations, and that release materials are not deployed into the game. Two consecutive builds overwrite the same ZIP filename. Runtime payload hashes match v1.0.2.

This remains a prerelease because the v1.0.2 performance fix has not yet been validated in-game. Lua regression checks passed for v1.0.2; packaging checks do not establish that stutters are eliminated. Check normal gameplay, parrying, save loading, death/reload, and player transitions after updating. Game build target remains 25129649 / CL-257186.
