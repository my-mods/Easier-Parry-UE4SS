# Easier Parry - UE4SS v1.0.7

This update fixes verified configuration-loading defects and removes the broader controller-tracking and baseline-restoration changes from v1.0.6. Runtime player lookup and attribute application are back to v1.0.5 behavior.

## What changed

- A failed explicit `easierparry reload` now keeps the last working settings and applied value. Previously, it reset the factor to 2.0 before attempting to read the file.
- A UTF-8 BOM immediately before `[General]` is accepted. Previously, that header was ignored and a custom factor could be missed.
- The loader uses the INI beside main.lua, without falling through to unrelated files in the working directory. It logs the selected path and effective factor.
- A valid numeric factor under `[General]` is required before new settings are accepted. Startup retains the 2.0 default if no valid configuration is available and logs a warning.

## Reported death/reload issue

A reset specifically to 2.0 after death has not been reproduced in-game. The mod does not read the INI or reset its configured factor on ordinary save loading. Regression tests retain a custom 3.5 factor across player destruction/recreation without reopening the file.

The earlier v1.0.6 tests simulated old objects remaining valid after replacement; they did not establish that Dawnwalker follows that sequence during death/reload. That broader change is removed rather than presented as a confirmed fix for the report. Existing player-cache limitations remain; this release addresses INI loading only.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game, replace/reinstall the existing Easier Parry entry with Easier-Parry-UE4SS.zip through Vortex, then deploy and restart. Use **UE4SS (Lua mods)** if prompted. Keep one enabled entry; no earlier version is required.

The archive includes the full INI, unchanged from v1.0.5: factor = 2.0 and pollMilliseconds = 1000. Back up your preferences and reapply them after replacement; settings are not automatically merged. Other mods changing ParryWindowMultiplier may conflict. Disable/remove in Vortex and deploy to uninstall.

## Validation

Lua 5.4 compilation and source/archive regression tests cover valid and failed configuration reloads, UTF-8 BOMs, comments, CRLF, factor clamping, session overrides, disabled state, ordinary player destruction/loading, and 600 maintenance polls without file reads, global object searches, or redundant writes. Runtime code outside the configuration loader and manual reload branch matches v1.0.5.

Two builds overwrite the same ZIP. Archive allowlist/source bytes and read-only installer planning against the installed Vortex extension are verified. This remains a prerelease; live death/reload behavior is unverified. Target build remains 25129649 / CL-257186 without a new compatibility claim.
