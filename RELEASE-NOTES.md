# Easier Parry - UE4SS — Pending changes

Fix held guard being lost after attacking as well as dodging. The stock block-input ability ended itself after an attack handoff, or on the next attack after release, while the physical guard input stayed held. That destroyed its guard listeners until guard was pressed again.

The native block ability now remains active until actual guard release or cancellation. Dodge uses the existing ability-owned suppression tag to lower guard for its lifetime and resume it afterward, including failed attempts. This replaces the previous Lua dodge-request restoration. Attack-release listeners that would accumulate under a persistent guard ability are bypassed; only three existing tasks remain active per held guard.

No added guard timer, input polling, global object search or Lua hook. The timing attribute checker and personal INI handling are preserved. Compiled stock bytecode reproduces both attack failure paths; patched source and container round-trip regressions cover repeated attacks, dodge suppression, release and cancellation. Live gameplay and frame-time checks remain pending.

**Vortex update:** close the game, disable the old Easier Parry entry and deploy. Replace/reinstall that entry from Easier-Parry-UE4SS.zip through the installer, select **Root (game folder)**, then enable and deploy. This replaces the older UE4SS mod type; redeployment alone retains its old layout. Keep one enabled entry. Controller Tweaks can remain enabled. The package replaces GA_Input_CombatBlock and GA_Dodge, so other replacements of those assets require a conflict choice.

**Configuration change:** native guard fixes are always active with the mod installed. The old dodgeInterruptsGuard setting and dodge console toggle are retired. Existing personal INI bytes are preserved; enabled and easierparry on/off now control only parry timing. Disable the complete mod in Vortex to restore stock guard behavior.

Version metadata remains 1.1.1. No new release or tag accompanies this development ZIP.
