# Easier Parry - UE4SS

Makes parrying more forgiving in *The Blood of Dawnwalker* and preserves held guard through attacks and dodges.

- **2× parry timing window** by default, configurable from **0.1× to 50×**, using the game's difficulty-adjusted baseline.
- Keeps the guard input ability alive while guard is held. Attacking no longer discards that held input.
- Temporarily lowers guard for a dodge and resumes when the game's combat rules allow it. Actual guard release and ability cancellation still end guarding.
- Native guard handling uses gameplay events, with no added polling, Lua hooks, object searches or recovery timers.
- The timing checker caches the player and attribute, checks once per second by default and writes only when needed.

## Installation

Requires a Dawnwalker-compatible **UE4SS 3.x** installation. Import `Easier-Parry-UE4SS.zip` into Vortex, select **Root (game folder)**, then enable and deploy. Keep one enabled Easier Parry entry.

The package contains both native game assets and the UE4SS timing script. Both are required. `Data` contains only an installer layout note; the payload uses explicit paths under `Dawnwalker`.

For updates, close the game, disable the old entry and deploy, then replace/reinstall that entry through the installer using **Root (game folder)** and deploy again. Reinstalling is necessary when changing from the older UE4SS mod type; redeploying its stored layout alone is insufficient.

Your personal INI remains outside Vortex deployment and is not replaced. If upgrading from an old editable INI inside the mod, copy your custom settings to the personal path below before replacement if no personal file exists.

To uninstall, disable/remove the entry in Vortex, deploy and restart the game. Personal settings remain available for reinstalling.

## Configuration

Personal settings: `%LOCALAPPDATA%/Dawnwalker/Saved/Config/EasierParryUE4SS.ini`

The mod reads `EasierParryUE4SS.defaults.ini` first, then personal overrides. Omitted or commented keys inherit the shipped defaults. A missing personal file is created with commented examples; an existing one is not rewritten at startup. UTF-8 files with or without a BOM are supported.

```ini
[General]
factor = 3.0
```

Defaults are `enabled = true`, `factor = 2.0`, `pollMilliseconds = 1000` and `debugLogging = false`. Restart after direct INI edits. Loading saves and respawning do not reread configuration. Invalid numeric overrides retain inherited values. An unreadable personal file stops script initialization and logs the path without overwriting preferences.

**The native guard fixes are always active while the mod is installed.** `enabled` and the console on/off commands control only the timing multiplier. The former `dodgeInterruptsGuard` option is retired and ignored; its existing INI entry is preserved. Disable the complete mod in Vortex to restore stock guard behavior.

Console commands apply immediately and save only the selected timing settings, preserving comments and unrelated keys:

- `easierparry status` — show timing settings and native guard information.
- `easierparry 3` — select a 3× multiplier and enable timing changes.
- `easierparry off` / `easierparry on` — disable/enable timing changes.

A failed save retains the selection for the session and logs the error. Shipped defaults are never written by the script. Look for `[EasierParryUE4SS] Applied` in `ue4ss/UE4SS.log` to confirm timing application; that message does not verify native asset loading.

## Compatibility

Native assets are based on Steam build **25129649 / CL-257186**. Updates to these game assets require compatibility review. The mod replaces:

- `/Game/_Dawnwalker/Player/Abilities/Input/GA_Input_CombatBlock`
- `/Game/_Dawnwalker/Combat/Abilities/Dodge/GA_Dodge`

Controller Tweaks and Remap changes different assets and can remain enabled. Other mods replacing either ability or modifying `ParryWindowMultiplier` may conflict. Do not assume differently named containers avoid asset conflicts; select one implementation of each ability.

The guard correction targets guard held before an attack or dodge. Normal stamina, dodge animation and combat eligibility logic are retained. Compiled ability-flow regressions and package checks pass; in-game combat and frame-time validation remain pending.

Created by **oOCamilleOo**. Original mod code is under the MIT license; underlying game assets remain the property of their respective rights holders. Nexus listing materials are maintained separately in the repository Nexus folder.
