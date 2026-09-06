# Easier Parry - UE4SS — Pending changes

Fix held guard remaining lowered after a dodge attempt. Keep holding parry to resume guarding when the game allows it; failed dodge attempts restore held intent as well. Releasing guard or changing the controlled player cancels recovery.

Guard recovery adds no timer, input polling or global object searches. It uses references only during the current dodge request, checks ownership before restoring, and preserves the existing parry attribute checker.

Close the game, replace/reinstall the existing Easier Parry entry in Vortex using Easier-Parry-UE4SS.zip, deploy, and restart. Use **UE4SS (Lua mods)** and keep one enabled entry. Personal INI overrides are preserved. Controller Tweaks requires no change. Keep `dodgeInterruptsGuard = true` to use the fix; if previously disabled for diagnosis, run `easierparry dodge on` after updating.

Version metadata remains 1.1.1. No new release or tag accompanies this development ZIP.
