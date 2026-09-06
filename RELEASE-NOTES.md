# Easier Parry - UE4SS — Pending changes

This development ZIP retains version 1.0.8 metadata. These changes have no release tag or published release.

Adds an optional setting that releases active guard when the player attempts a dodge, allowing the normal dodge activation path to run after guard is released.

## Persistent personal settings

The ZIP now contains EasierParryUE4SS.defaults.ini instead of an editable EasierParryUE4SS.ini. Personal overrides live at `%LOCALAPPDATA%/Dawnwalker/Saved/Config/EasierParryUE4SS.ini`, outside the mod folder and Vortex deployment. Defaults load first; personal keys win. Existing user files are untouched at startup. Only explicit console changes write the corresponding user keys, preserving comments and unrelated content.

If the user file is missing, first startup copies the old mod INI byte for byte when it is still present, otherwise creates a commented override reference. Windows no-replace creation protects a user file created concurrently. Unreadable personal files stop initialization rather than being replaced. The Saved/Config directory must exist.

Before replacing an older Vortex entry, copy its editable INI to the personal path if no user INI exists: Vortex may remove the old packaged file before the next startup. Later updates require no preference copying. The personal file is never in the release archive or installer copy plan.

## Enable the option

The shipped defaults contain `dodgeInterruptsGuard = true`. User overrides can disable it. Run `easierparry dodge on` in the UE4SS console to enable and save it, or set `dodgeInterruptsGuard = true` under `[General]` in the personal EasierParryUE4SS.ini and restart. `easierparry dodge off` disables and saves the option. `easierparry status` reports the option and hook status. The master `enabled` setting controls both features. The parry factor stays unchanged.

Guard is dropped for the dodge attempt; release and press guard again to raise it afterward. Normal dodge eligibility, stamina and animation checks still apply. An unsuccessful attempt can also lower guard. The feature follows the game's dodge action and uses no fixed keyboard/controller keys.

The v1.0.8 settings behavior is retained: startup loads the INI once, console selections are saved, and death/loading do not reread the file.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game, and replace/reinstall the existing Easier Parry entry with Easier-Parry-UE4SS.zip through Vortex. Use **UE4SS (Lua mods)** if prompted, deploy, and restart. Keep one enabled entry; no earlier version is required. Only the defaults INI is packaged; your separate personal INI wins over those defaults.

Other mods that alter guard/dodge behavior or ParryWindowMultiplier can conflict. This update replaces this mod's main.lua and defaults INI, and introduces no new shared payload files. Controller Tweaks is optional; no HUDTweaks dependency is added. Uninstall by disabling/removing in Vortex, deploying, and restarting.

## Validation

Defaults/user tests cover precedence, changed defaults with stable user bytes, targeted console writes, missing files, legacy migration, first-creation races, unreadable paths, and no configuration reads during healthy gameplay polls. Actual Windows file-I/O tests confirm migration, restart preservation, comments/BOM/CRLF, and that changing shipped defaults leaves explicit user values intact.

Lua 5.4 source and archive regressions cover the pre-dodge guard release, default/off/master-disable behavior, preserved native return values, NPC/remote/default-object exclusion, loading/death/possession transitions, failed calls, duplicate-hook prevention, persisted toggles and preservation of comments/unrelated settings. Existing startup-only settings and save round-trip tests also pass.

Two builds replace the same ZIP. The actual archive is checked against an exact allowlist and canonical source bytes, with read-only installer planning against the installed Vortex extension. Native integration was inspected against local build 25129649 / CL-257186; no new-build compatibility claim is made.

**Development build: live gameplay validation is still required.** Check guard-to-dodge with keyboard and controller, repeated dodges, guard re-entry, low stamina, hit reactions, and death/save loading. No installation, deployment or in-game test was performed for this update.
