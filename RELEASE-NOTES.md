# Easier Parry - UE4SS v1.0.6

Fixes a reproduced lifecycle bug where a replaced player or parry attribute could be ignored while the previous objects remained valid. The mod now follows the local controller’s current pawn and attribute on every maintenance check, preserving the configured factor. Healthy checks still perform no global object searches or redundant writes.

The reported reset specifically to 2.0 has not been reproduced in-game. Mocked tests confirmed that the previous code could keep applying a custom factor to an obsolete attribute. The configuration path is now logged at startup to make INI selection easier to verify.

## Installation and updates

Requires Dawnwalker-compatible UE4SS 3.x. Close the game and replace/reinstall the existing Easier Parry entry from Easier-Parry-UE4SS.zip through Vortex. Use **UE4SS (Lua mods)** if prompted, then deploy and restart. Keep one enabled entry. This replaces the previous EasierParryUE4SS files; no older version is required.

The ZIP includes the full INI with factor = 2.0 and pollMilliseconds = 1000. Back up custom preferences and reapply them after replacement; settings are not automatically merged. Other mods modifying ParryWindowMultiplier may conflict. To uninstall, disable/remove through Vortex, deploy, and restart.

## Validation

Lua 5.4 compilation and mocked runtime tests cover custom INI factors, 600 healthy polls without searches or redundant writes, still-valid replaced attributes/pawns/controllers, unpossession, shared attributes, destruction/loading, recalculation, console controls, scalar values, and queued game-thread callbacks. The archived Lua is tested too.

The actual ZIP is checked against an explicit allowlist and canonical source bytes. Read-only installer planning against the installed Vortex extension verifies the Lua mod type, runtime destinations, and Vortex metadata. Two consecutive builds replace the same ZIP.

This is a prerelease pending in-game validation. Set your preferred INI factor, confirm the startup log reads it, then check parrying before and after death/reload and loading another save. Target build remains 25129649 / CL-257186; this release does not claim validation against a newer game patch.
