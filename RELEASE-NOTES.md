# Easier Parry - UE4SS 1.1.0

Dodge can now interrupt guard, and personal settings survive mod updates.

## What's new

- Dodge interruption is enabled by default. The game drops guard before attempting a dodge. Release and press guard again afterward; normal stamina and dodge restrictions still apply, and a failed attempt can also lower guard.
- The ZIP supplies EasierParryUE4SS.defaults.ini. Your overrides live separately at %LOCALAPPDATA%/Dawnwalker/Saved/Config/EasierParryUE4SS.ini and are never packaged or replaced by updates.
- Settings load once at startup. Console factor, on/off and dodge on/off commands save only their changed settings to your personal file, preserving comments and unrelated values. Restart after direct INI edits.
- UTF-8 INIs with or without a BOM are supported. Configuration errors are logged; unreadable personal files are not replaced.
- The Nexus description is shorter and links to the [GitHub source](https://github.com/my-mods/Easier-Parry-UE4SS). Listing materials stay outside the ZIP.

The default parry multiplier remains 2x, configurable from 0.1x to 50x. Set dodgeInterruptsGuard = false to disable guard interruption. The master enabled setting controls both features.

## Updating

Requires [UE4SS for Dawnwalker](https://www.nexusmods.com/thebloodofdawnwalker/mods/18); no previous Easier Parry version is required.

Before replacing an older Vortex entry, copy its Scripts/EasierParryUE4SS.ini to the personal path above if you have custom settings and no personal file exists. Vortex may remove the old packaged INI during replacement. If still present at first startup, it is copied automatically; an existing personal INI always wins. Later updates require no copying.

Close the game, replace/reinstall the existing entry from Easier-Parry-UE4SS.zip, select **UE4SS (Lua mods)** if prompted, then deploy and restart. Keep one enabled entry. The new main.lua and defaults INI must come from this version. Controller Tweaks is optional; HUDTweaks is not required.

Other mods changing parry timing or guard/dodge behavior may conflict. Uninstall through Vortex and deploy; your personal settings remain.

## Validation

Lua source/archive regressions, actual Windows configuration file tests, and Vortex installer planning passed. Two builds replace the same ZIP; archive contents match the source allowlist. No game or Vortex deployment was changed.

**Prerelease: live gameplay validation is pending.** Check guard-to-dodge on keyboard and controller, guard re-entry, low stamina, hit reactions, and death/save loading. The original reported reset and stutter causes are not claimed fixed by these tests. Native integration was inspected against build 25129649 / CL-257186; no newer-build compatibility claim is made.
