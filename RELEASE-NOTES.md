# Easier Parry - UE4SS v1.0.8

Settings follow one rule: load the INI once at game startup, then retain the selection until a console command changes it or the game exits. Console changes are saved to the same INI for the next game start.

## Commands and settings

- `easierparry 3` selects a 3x multiplier, enables the mod and saves factor/enabled.
- `easierparry on` and `easierparry off` save the enabled state alongside the selected factor.
- `easierparry status` displays the current selection, baseline and target.
- The former `easierparry reload` command displays guidance without rereading settings. Restart after direct INI edits.

Saving preserves comments, line endings, UTF-8 BOMs and unrelated settings. If the INI is missing, a new one is created on a console change. If saving fails, the selection stays active for that session and the log reports that it was not saved. Startup uses defaults for missing settings; factor defaults to 2.0.

Death and save loading do not reread or reset the selected settings. Player lookup and parry attribute application are unchanged; this release does not claim to establish the cause of the earlier reported death/reload effect.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game, replace/reinstall the existing Easier Parry entry with Easier-Parry-UE4SS.zip through Vortex, then deploy and restart. Use **UE4SS (Lua mods)** if prompted. Keep one enabled entry; no earlier version is required.

The archive includes the full INI with factor = 2.0 and pollMilliseconds = 1000. Back up your preferences and reapply them after replacement; settings are not automatically merged. Other mods changing ParryWindowMultiplier may conflict. Disable/remove in Vortex and deploy to uninstall.

## Validation

Lua 5.4 source/archive regression tests cover startup-only loading, saved console selections, restart round trips, simulated player destruction/recreation, unchanged settings through the old reload command, on/off persistence, failed saves, missing files/keys, invalid input, and 600 healthy polls without file reads or redundant writes. Actual Windows file-I/O tests preserve BOMs, CRLF, comments and unrelated keys; a fresh Lua session reads back the saved factor and enabled state.

Two builds overwrite the stable ZIP. Archive allowlist/source bytes and read-only installer planning against the installed Vortex extension are verified. This remains a prerelease pending live gameplay validation. Target build remains 25129649 / CL-257186 without a new compatibility claim.
