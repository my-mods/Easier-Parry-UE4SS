# Native held guard

These are modified cooked ability snapshots for Steam build 25129649 / CL-257186. Original snapshots and their provenance are in `upstream/guard`.

`GA_Input_CombatBlock` represents the lifetime of held guard input. Stock bytecode ends it after a successful light-attack handoff. A separate attack-release listener also creates a listener that ends it on the next attack press. Both paths destroy the guard tasks while `Player.Input.Block` remains present, leaving no new input edge to reactivate guarding.

The modified graph keeps this input ability alive and lowers desired guard before the stock attack handoff. The native combat state machine rejects entering attack from block while guard intent is true. Attack release now reconciles guard instead of creating a next-press termination listener. Initial activation, attack release and suppression-count changes all raise guard only when both `Player.Input.LightAttack` and `Player.Input.BlockTagAbilities` are absent. This prevents either action ending from overriding the other. There are four fixed tasks per hold: block release, suppression count, attack press and attack release. Actual block release and ability cancellation retain stock teardown. The untouched direction-selection helper still controls initial direction.

`GA_Dodge` adds `Player.Input.BlockTagAbilities` to its `ActivationOwnedTags`. The engine owns this suppression for the ability's lifetime and removes it on end or cancellation. The block task lowers desired guard while the count is nonzero and restores it when both suppression and attack input have ended, provided the input ability remains active. Dodge executable exports, stamina checks and animation logic are unchanged.

The block bytecode replacements preserve runtime instruction offsets and existing entry points. The dodge edit changes only its default-object properties and adds the existing tag name. No Lua hooks, timers, retained Lua object references or object searches implement guard recovery.

This changes the two whole cooked assets and therefore conflicts with other replacements of either asset. Offline bytecode-flow and container round-trip tests do not establish live game behavior or frame-time performance.
