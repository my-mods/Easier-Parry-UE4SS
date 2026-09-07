# Native held guard

These are modified cooked ability snapshots for Steam build 25129649 / CL-257186. Original snapshots and their provenance are in `upstream/guard`.

`GA_Input_CombatBlock` represents the lifetime of held guard input. Stock bytecode ends it after a successful light-attack handoff. A separate attack-release listener also creates a listener that ends it on the next attack press. Both paths destroy the guard tasks while `Player.Input.Block` remains present, leaving no new input edge to reactivate guarding.

The modified graph keeps this input ability alive through dodges. It skips the successful handoff's `K2_EndAbility` and the attack-release listener chain. The existing light-attack listener now invokes the same stock teardown callback as guard release, ending the ability immediately without queuing a second attack. It remains alongside the existing block-release listener and `Player.Input.BlockTagAbilities` count listener: three tasks per hold. Actual block release and ability cancellation retain stock teardown. The untouched direction-selection helper still controls initial direction.

`GA_Dodge` adds `Player.Input.BlockTagAbilities` to its `ActivationOwnedTags`. The engine owns this suppression for the ability's lifetime and removes it on end or cancellation. The existing block task lowers desired guard while the count is nonzero and raises it when suppression ends, provided the input ability remains active. Dodge executable exports, stamina checks and animation logic are unchanged.

The block bytecode replacements preserve runtime instruction offsets and existing entry points. The dodge edit changes only its default-object properties and adds the existing tag name. No Lua hooks, timers, retained Lua object references or object searches implement guard recovery.

This changes the two whole cooked assets and therefore conflicts with other replacements of either asset. Offline bytecode-flow and container round-trip tests do not establish live game behavior or frame-time performance.

A normal attack press ends guard even if LT remains held. Attack release and dodge completion cannot restore an ended guard ability; release and press guard again to restore it. Dodge uses the original native attack-interruption and eligibility path; no mod timer or forced animation cancellation is added.
