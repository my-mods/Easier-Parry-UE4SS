# Easier Parry - UE4SS — Pending dodge restoration

Restore the exact native guard and dodge assets from the development build reported working for dodge and blocking, before attack-from-guard changes. Remove the attack-press/release handoff that caused regressions. Release guard before attacking.

Held guard is suppressed for the native dodge ability's lifetime and restored when suppression ends, unless guard was released or the guard ability was cancelled. Three fixed native listeners handle this; no Lua gameplay hook, recovery timer, global search or per-frame mod worker is added. Dodge executable bytecode remains unchanged, preserving the game's native attack interruption, stamina checks and animation rules.

Keep the corrected, bounded read-only diagnostic module and current player/attribute ownership fix. guardTraceLogging=true remains enabled; set false in the personal INI and restart to disable it. Diagnostic workers stop when idle. Timing maintenance checks the current owned attribute once per second by default without repeated global searches; native guard recovery itself has no periodic work.

Replace/reinstall the existing Vortex entry as **Root (game folder)** and deploy. Keep one enabled Easier Parry entry. Controller Tweaks can remain enabled. Personal settings are preserved.

Checks cover exact native rollback bytes, cooked-asset round trips, 1,000 guard/dodge lifecycles, three fixed tasks, overlapping suppression, real guard release/cancellation, no guard reassertion after releasing LT to attack, diagnostic idle/flood limits, and current player ownership across loading/possession. Builds and mocks do not establish live animation behavior or frame times.

In game, hold LT and dodge repeatedly, checking directional parrying afterward. Then release LT, attack, and dodge during the attack. Also test releasing LT during a dodge. Retain ue4ss/UE4SS.log before the next launch if anything fails.

Version stays 1.1.1. No release or tag is created.
