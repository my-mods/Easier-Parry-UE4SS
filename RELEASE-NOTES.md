# Easier Parry - UE4SS 1.2.0 (prerelease)

- Replace optional Lua dodge interruption with native held-guard recovery after dodging. Normal attacks cancel guard until guard is released and pressed again.
- Retire dodgeInterruptsGuard and the dodge console toggle. Native guard changes remain active while installed; enabled and easierparry on/off now control only parry timing.
- Follow the active local player and attribute owner across save loads and possession changes; preserve the captured timing baseline during temporary unpossession and partial-write retries.
- Add bounded guard and timing diagnostics under debugLogging, off by default. Diagnostic workers stop when finished.
- Change installation to Root (game folder), including native guard/dodge assets and the Lua timing script. Disable the old entry and deploy, then reinstall the same entry through Vortex as Root and deploy again. Personal INI settings remain preserved.
- Native combat behavior and frame times still need in-game validation. Other mods replacing GA_Input_CombatBlock or GA_Dodge conflict; Controller Tweaks and Remap changes different assets.

Close the game, disable the old Vortex entry and deploy. Replace/reinstall that entry as **Root (game folder)**, then enable and deploy. Keep one enabled Easier Parry entry. Redeployment alone does not change the old installer layout. Copy custom legacy INI settings to the personal file before replacement if needed; existing personal settings are preserved.

Verify held-LT dodges, attack cancellation while LT remains held, attack/dodge overlap, release/repress LT recovery, save loading and respawning. Static checks do not establish live animations or frame times.
