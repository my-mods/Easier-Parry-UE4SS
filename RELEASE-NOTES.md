# Easier Parry - UE4SS v1.0.2

The maintenance loop previously searched for the player every 500 ms, even after the parry attribute was found. This update caches the player and CharDevAttributeSet. Healthy ticks only validate cached objects and check the value; global searches run only when the player cache is absent or invalid, and writes run only when needed. The default interval is now 1000 ms.

Repeated `easierparry on` commands also preserve the original baseline instead of multiplying an already modified value.

## Update through Vortex

Close the game, back up custom INI preferences, and replace/reinstall the existing Easier Parry entry using `Easier-Parry-UE4SS.zip`. Select **UE4SS (Lua mods)** if prompted, then deploy and restart. Keep one enabled entry; this version's `EasierParryUE4SS/Scripts/main.lua` and `EasierParryUE4SS.ini` must replace the previous files.

The archive includes a full INI with `factor = 2.0` and `pollMilliseconds = 1000`. Reapply personal preferences after replacement; it does not merge them automatically. If retaining an existing INI, set `pollMilliseconds = 1000` and restart to use the new interval. Caching also works with an existing 500 ms setting.

The unversioned ZIP name replaces the historical `Easier-Parry-UE4SS-v1.0.0-Vortex.zip` label. Display name, internal mod ID, and runtime paths remain unchanged. Use Vortex's replacement flow for the same entry.

Requires Dawnwalker-compatible UE4SS 3.x; no other mod is required. Mods that also modify `ParryWindowMultiplier` may conflict. To uninstall, disable/remove through Vortex, deploy, and restart.

## Validation

Lua 5.4 compilation and simulated regression checks cover steady ticks, value resets, startup without a player, delayed attributes, invalid objects during loading/player replacement, console controls, and queued game-thread work. Actual archive bytes, metadata, duplicate-file checks, and installer destination planning are checked against the installed Vortex extension. Two consecutive builds overwrite the same unversioned ZIP.

Published as a prerelease pending in-game validation. These tests do not measure frame times or prove the reported stutters are eliminated. Check normal gameplay, parrying, save loading, death/reload, and player transitions after updating. Game build target remains 25129649 / CL-257186.
