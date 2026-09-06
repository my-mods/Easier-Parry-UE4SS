# Easier Parry - UE4SS — Pending changes

This development ZIP retains version 1.0.8 metadata. These changes have no release tag or published release.

Adds an optional setting that releases active guard when the player attempts a dodge, allowing the normal dodge activation path to run after guard is released.

## Enable the option

The supplied INI now contains `dodgeInterruptsGuard = true`. An absent setting still defaults to off. Run `easierparry dodge on` in the UE4SS console to enable and save it, or set `dodgeInterruptsGuard = true` under `[General]` in EasierParryUE4SS.ini and restart. `easierparry dodge off` disables and saves the option. `easierparry status` reports the option and hook status. The master `enabled` setting controls both features. The parry factor stays unchanged.

Guard is dropped for the dodge attempt; release and press guard again to raise it afterward. Normal dodge eligibility, stamina and animation checks still apply. An unsuccessful attempt can also lower guard. The feature follows the game's dodge action and uses no fixed keyboard/controller keys.

The v1.0.8 settings behavior is retained: startup loads the INI once, console selections are saved, and death/loading do not reread the file.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game, back up custom INI preferences, and replace/reinstall the existing Easier Parry entry with Easier-Parry-UE4SS.zip through Vortex. Use **UE4SS (Lua mods)** if prompted, deploy, and restart. Keep one enabled entry; no earlier version is required. The ZIP includes a full default INI and does not merge existing preferences.

Other mods that alter guard/dodge behavior or ParryWindowMultiplier can conflict. This update replaces this mod's main.lua and INI, and introduces no new shared payload files. Controller Tweaks is optional; no HUDTweaks dependency is added. Uninstall by disabling/removing in Vortex, deploying, and restarting.

## Validation

Lua 5.4 source and archive regressions cover the pre-dodge guard release, default/off/master-disable behavior, preserved native return values, NPC/remote/default-object exclusion, loading/death/possession transitions, failed calls, duplicate-hook prevention, persisted toggles and preservation of comments/unrelated settings. Existing startup-only settings and save round-trip tests also pass.

Two builds replace the same ZIP. The actual archive is checked against an exact allowlist and canonical source bytes, with read-only installer planning against the installed Vortex extension. Native integration was inspected against local build 25129649 / CL-257186; no new-build compatibility claim is made.

**Development build: live gameplay validation is still required.** Check guard-to-dodge with keyboard and controller, repeated dodges, guard re-entry, low stamina, hit reactions, and death/save loading. No installation, deployment or in-game test was performed for this update.
