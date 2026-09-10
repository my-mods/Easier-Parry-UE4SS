# Native dodge guard recovery

The snapshots target Steam build 25129649 / CL-257186. Original assets and hashes are in `upstream/guard`.

Only `GA_Dodge` is shipped in the native container. It adds the existing `Player.Input.BlockTagAbilities` tag to `ActivationOwnedTags`. The engine owns this suppression for the dodge ability’s lifetime and removes it on end or cancellation. The forward-dodge branch ends the ability after applying its existing forward-dodge effect. Previously it returned without ending or registering the side/back completion listener, leaving the added suppression tag active. Stamina checks, animation selection, effect application and side/back completion logic are unchanged.

`GA_Input_CombatBlock.json` is an unmodified stock reference, excluded from the container. The game’s own guard ability listens for suppression-count changes: it lowers desired guard while the count is nonzero and restores it when the count reaches zero, provided the ability is still active.

Stock attacks retain both original paths: a successful combo handoff ends guard immediately; an attack release arms a listener that ends guard on the next attack press. The release listener fires immediately if attack is absent when guard starts, so guard-first input also arms cancellation for the first attack. If attack is already held when guard starts and its combo handoff fails, guard remains active until a subsequent release/press or another stock cancellation. Actual guard release and ability cancellation retain stock teardown. Once guard has ended, dodge completion cannot restart it without a fresh guard input.

The forward completion change redirects one existing jump to the existing ability-end path. It adds no guard bytecode, Lua hooks, timers or object searches. It leaves stock guard listener lifetimes intact. It conflicts with other replacements of `GA_Dodge`; a separate mod replacing guard input can change its response to the suppression tag.

To reproduce the native payload, convert `src/guard/GA_Dodge.json` to a UE5.5 legacy asset using UAssetAPI-compatible JSON conversion, preserve its `/Game/_Dawnwalker/Combat/Abilities/Dodge/GA_Dodge` package path, and convert it to an UE5.5 IoStore container with retoc and the matching game script-object metadata. Do not include the stock guard reference in that container.
