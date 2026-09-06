# Easier Parry - UE4SS 1.1.1

This update removes the invalid attribute lookup identified in a UE4SS crash traceback.

## Changes

- Read parry attribute structs and reflected objects directly. Only the dodge hook parameter is unwrapped with get().
- Reject attribute reads and writes when the owning object is invalid. Skip maintenance writes if the current attribute cannot be read.
- Keep the same one-second default interval and cached player/attribute references. Healthy checks add no searches, name lookups, writes, or logging.
- Preserve the parry multiplier, guard/dodge options, and personal settings introduced in 1.1.0.

## Updating

Requires [UE4SS for Dawnwalker](https://www.nexusmods.com/thebloodofdawnwalker/mods/18). No previous Easier Parry version is required.

Close the game, replace/reinstall the existing entry from Easier-Parry-UE4SS.zip, select **UE4SS (Lua mods)** if prompted, enable and deploy, then restart. Keep one enabled Easier Parry entry and let the new main.lua win over an older copy. An existing personal INI in %LOCALAPPDATA%/Dawnwalker/Saved/Config remains untouched.

If upgrading from 1.0.3 or earlier with custom settings and no personal INI, back up the old Scripts/EasierParryUE4SS.ini and copy it to the personal path before replacement. The new package supplies defaults separately; it does not merge or overwrite your personal settings.

## Validation

Lua 5.4 checks reproduce the invalid reflected lookup in 1.1.0 and confirm its removal in the fixed source and ZIP. Tests cover struct/scalar access, reflection and direct writes, unreadable/dead owners, queued invalidation, player replacement, guard behavior, and personal settings.

Across 600 healthy mock ticks, protected Lua calls drop from 5,400 to 4,200. The extra owner validity check is offset by removing failed wrapper probes. This measures operation counts, not in-game frame rate or latency.

**Prerelease: confirmation in game is pending.** Repeat death/save loading and guard-to-dodge checks after installing. The crash path is addressed; native runtime correctness cannot be established by mocked tests. Inspected against Dawnwalker CL-257186 and the installed compatible UE4SS build.
