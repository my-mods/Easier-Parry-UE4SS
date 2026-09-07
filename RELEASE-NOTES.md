# Easier Parry - UE4SS — Pending attack correction

The player reports dodge and blocking now working, but attacks could not start while holding parry. Live diagnostics show attack requests reaching combat code while desired guard stays true. The native state machine rejects entering attack from block with guard intent raised. The previous correction preserved the input ability without releasing that intent for the attack handoff.

The updated block graph lowers guard before the stock attack handoff and restores it on attack release only when dodge suppression has also ended. The held-input ability stays alive until actual guard release or cancellation. Attack and dodge may overlap in either order without prematurely restoring guard. Four fixed native listeners handle these transitions; there is no Lua gameplay polling, forced attack, or change to stamina and animation checks.

GuardTrace diagnostics remain enabled through `guardTraceLogging = true`. Its setup and output workers now use one-shot delayed callbacks: the previous repeating-timer API ignored callback return values and kept idle setup running. Logs are bounded to 2,048 records per launch, eight snapshots and 32 captured events per 100 ms, a 64-record buffer and eight queued lines per 200 ms flush. Combat callbacks perform no object searches. Registered Blueprint hooks were not observed firing in the prior live trace; native combat hooks supplied the evidence above.

Replace/reinstall the existing Vortex entry as **Root (game folder)** and deploy. Keep one enabled entry; Controller Tweaks and Remap can remain enabled. Personal INI settings are preserved. Set guardTraceLogging=false in the personal INI and restart to disable diagnostics.

Offline tests cover 1,000 attack press/release handoffs, guard lowered before queuing, attack/dodge overlap in both orders, actual LT release, cancellation, fixed task counts, cooked-asset round trips, configuration preservation and 600 seconds of zero idle diagnostic work. These checks do not establish live combat behavior or frame times.

After replacement, keep LT held and test single attacks, repeated attacks, attack/dodge overlaps and directional parrying after each action, including after loading a save. Retain `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log` before another launch if anything fails. In-game validation remains pending.

Version stays 1.1.1. No release or tag is created.
