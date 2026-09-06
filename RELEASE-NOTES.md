# Easier Parry - UE4SS v1.0.9

The INI is loaded once when the game starts. The chosen multiplier remains selected until you change it through the console or exit the game. Console multiplier and on/off commands save the selection to the same INI for the next startup, preserving other settings and comments. If saving fails, the current session keeps the chosen value and the log reports the failure.

UTF-8 INIs with or without a BOM are supported. Restart after direct INI edits; the old reload command now displays guidance without rereading settings. Default settings remain factor = 2.0 and pollMilliseconds = 1000.

The ZIP retains the README, license, changelog, release notes and Vortex metadata. Nexus listing assets are kept separately. Runtime installation paths are unchanged from Nexus v1.0.3.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game, back up your custom INI, and replace/reinstall the existing Easier Parry entry using Easier-Parry-UE4SS.zip through Vortex. Select **UE4SS (Lua mods)** if prompted, deploy, and reapply your preferences. Keep one enabled entry. The ZIP replaces the full INI; installation does not automatically merge settings. No older Easier Parry version is required.

Other mods changing ParryWindowMultiplier may conflict. To uninstall, disable/remove the entry in Vortex, deploy, and restart.

## Validation

Lua tests cover startup loading, saved console settings, fresh-session round trips, simulated player destruction/recreation, and healthy polling. Actual Windows file-I/O tests preserve comments, line endings, BOMs and unrelated settings. Archive byte checks and read-only Vortex installer planning pass.

Live death/reload behavior remains unverified. This update does not claim to establish or fix the cause of the earlier reported loss of effect. Runtime player lookup and parry attribute application are unchanged from Nexus v1.0.3. Target build remains 25129649 / CL-257186; no new compatibility claim is made.
