# Easier Parry - UE4SS — Pending investigation

The native held-guard correction from the previous development build did not resolve the reported failure in game. The deployed Lua and all three native container files were verified byte-for-byte against that build. Offline ability-flow tests did not establish runtime correctness.

Add a separate `guardTraceLogging` INI option, enabled in this diagnostic build. It observes guard setters, attack/dodge requests, block ability activation/end, input release and suppression callbacks. Snapshots record raw LT, Block/suppression tags, desired guard and blocking state. Hook registration failures and unavailable reads are explicit. No additional gameplay correction is claimed in this build; existing native assets are unchanged.

Diagnostics use bounded, event-driven work: at most one registration step per 100 ms, finite retries resumed by relevant construction, at most eight full snapshots and 32 captured events per 100 ms, a 64-record queue, at most eight queued lines per 200 ms flush, and a 2,048-record launch limit. Workers stop when idle. No searches run in combat callbacks. Diagnostic logging has not been benchmarked in game.

Replace/reinstall the existing Vortex entry as **Root (game folder)** and deploy. Keep one enabled entry and retain Controller Tweaks for this reproduction. Personal INI settings are preserved. `guardTraceLogging = true` enables this trace independently of timing; set false and restart to disable. The old dodgeInterruptsGuard option remains retired.

Load a save, keep LT held, attack or dodge until the stick moves the player instead of choosing parry direction, then release/repress LT once. Exit the game and retain `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log` before another launch. The trace will distinguish lost input, ability cancellation, missing native-patch behavior and guard state divergence.

Version stays 1.1.1. No release or tag is created. Live investigation remains open.
