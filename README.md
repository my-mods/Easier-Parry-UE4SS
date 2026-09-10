# Easier Parry - UE4SS

![Easier Parry - UE4SS](Nexus/thumbnail.png)

Makes parrying more forgiving in *The Blood of Dawnwalker*. Includes native guard recovery after dodging. Attack inputs retain the base game’s guard behavior.

- **2× parry timing window** by default, configurable from **0.1× to 50×**, using the game's difficulty-adjusted baseline.
- Keeps held guard available after a dodge, using the game's native ability lifecycle. Attack inputs retain the base game’s guard behavior.
- Temporarily lowers guard for a dodge and resumes when the game's combat rules allow it. Actual guard release and ability cancellation still end guarding.
- Held guard resumes when a forward dodge leaves the dodge state. Failed or cancelled attempts release their input suppression.
- Native guard handling uses gameplay events. Optional Lua diagnostics observe transitions without changing guard or bindings.
- The timing checker follows the current local player and attribute owner, checks once per second by default and writes only when needed. Save loading uses no global player-object searches.

## Installation

Requires a Dawnwalker-compatible **UE4SS 3.x** installation. Import `Easier-Parry-UE4SS.zip` into Vortex, select **Root (game folder)**, then enable and deploy. Keep one enabled Easier Parry entry.

The package contains the native dodge asset and the UE4SS timing script. Both are required. `Data` contains only an installer layout note; the payload uses explicit paths under `Dawnwalker`.

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

## Held-guard diagnostics

Set `debugLogging = true` under `[General]` to capture guard tracing together with timing diagnostics. Both are off by default. The session commands `easierparry debug on/off` control both; turning off stops trace reads and queued output. Previously installed hooks remain dormant until logging is enabled again. The retired `guardTraceLogging` key is ignored. Diagnostics also work with timing changes disabled.

Close the game, replace/reinstall the Vortex entry as **Root (game folder)** and deploy. Start the game, load a save, keep LT held, dodge repeatedly and check directional parrying afterward. Separately, test a single attack and a repeated attack while LT stays held, then dodge. If a stock attack transition ends guard, release and repress LT to restore it. If it fails, release and repress LT once. Exit the game before another launch overwrites `ue4ss/UE4SS.log`.

Search that log for `GuardTrace`. The trace includes hook readiness/errors, ability identity and endings, suppression counts, guard intent, blocking state, the Block tag and raw LT. LT is a diagnostic read of the physical left trigger, not a binding change. `?` means a read was unavailable; `dropped` or `snapshot=rate_limited` identifies omitted burst data. Hook coverage is reported explicitly; ordinary timing application does not prove native assets loaded.

Trace output is buffered and bounded to 2,048 records per launch. It adds no input polling or continuous discovery. Registration retries stop, and buffered output workers stop when empty. The trace has no guard setters or input mutations. Logging is temporary diagnostic work; its frame-time cost has not been measured in game.

## Compatibility

Native assets are based on Steam build **25129649 / CL-257186**. Updates to these game assets require compatibility review. The mod replaces:

- `/Game/_Dawnwalker/Combat/Abilities/Dodge/GA_Dodge`

Controller Tweaks and Remap changes different assets and can remain enabled. Other mods replacing the dodge ability or modifying `ParryWindowMultiplier` may conflict. Do not assume differently named containers avoid asset conflicts; select one implementation of each ability.

The guard correction targets guard held before a dodge. The base game controls attack/combo handoffs and guard cancellation without an overridden guard ability. Dodge retains the game's native attack-interruption, stamina, animation and combat eligibility logic. If a stock attack transition ends guard, dodge completion cannot reactivate it; release and press guard again.

Created by **oOCamilleOo**. Original mod code is under the [MIT license](LICENSE); underlying game assets remain the property of their respective rights holders. Nexus listing materials are maintained separately in [Nexus](Nexus/README.txt).

## Timing performance diagnostics

Debug logging is off by default. Use `easierparry debug on` to start a session capture, `easierparry debug status` to print totals, and `easierparry debug off` to stop. These commands do not save settings. To capture startup and save loading from launch, set `debugLogging = true` in the personal INI and restart.

`PERF` lines report timing-worker average and maximum duration, the phase with the largest sample, checks taking at least 5 ms, maximum queue delay, attachment/repair/wait counts and failures. Queue delay is time waiting for the game thread, not time spent executing this mod. When enabled from launch, the first sample covers bootstrap; automatic summaries follow every 30 seconds, or at most every 5 seconds when checks are slow, stopping after 120 automatic reports. Manual status remains available. No extra timer or object search is created.

Timing uses Windows `os.clock`, with millisecond granularity. A zero measurement means below clock resolution. Measurements include calls made by the timing worker, but exclude its performance-summary logging, GuardTrace diagnostics (reported separately from PERF durations), native guard abilities and whole-game/GPU frame time. Compare equivalent gameplay runs with other diagnostic logging disabled. With debug logging off, no performance clock is sampled and no PERF summary is emitted.
