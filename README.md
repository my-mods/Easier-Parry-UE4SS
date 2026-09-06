# Easier Parry - UE4SS

![Easier Parry - UE4SS](Nexus/thumbnail.png)

Makes parrying more forgiving in *The Blood of Dawnwalker* by multiplying Coen's parry timing window.

- **2× timing window** by default, configurable from **0.1× to 50×**.
- Uses the game's current, difficulty-adjusted timing as its baseline.
- Caches the player and parry attribute; healthy checks do not scan game objects.
- Checks once per second by default and writes only when the value changes.
- Reacquires invalid player/attribute references after loading or recreation.
- Optional dodge interruption of active guard, enabled in the supplied INI.

## Installation

Requires a Dawnwalker-compatible **UE4SS 3.x** installation.

Download the mod ZIP from [Releases](https://github.com/my-mods/Easier-Parry-UE4SS/releases), install it through Vortex, then enable and deploy.

The ZIP includes Vortex metadata, the changelog, and release notes. Nexus listing materials are maintained separately in the repository’s [Nexus folder](Nexus/README.txt).

For updates, close the game and replace/reinstall the existing mod entry from the new ZIP, then deploy through Vortex. Use the UE4SS (Lua mods) type. Keep one enabled Easier Parry entry.

The ZIP includes the full EasierParryUE4SS.ini. Back up custom preferences before replacement and reapply them afterward; settings are not automatically merged. The default pollMilliseconds is 1000.

To uninstall, disable/remove the mod in Vortex, deploy, and restart the game.

## Configuration

Edit `EasierParryUE4SS/Scripts/EasierParryUE4SS.ini`:

```ini
[General]
enabled = true
factor = 2.0
pollMilliseconds = 1000
debugLogging = false
dodgeInterruptsGuard = true
```

The INI is read once when the game starts. Its factor stays selected until you change it through the console or exit the game. Death and save loading do not reload settings. Missing settings use their defaults; factor defaults to 2.0.

Console changes are saved to the same INI for the next game start. Factor and enabled are saved by the existing commands; dodge commands also save dodgeInterruptsGuard. Other settings and comments are preserved. If saving fails, the new selection remains active for the current session and the log reports the failure.

For direct INI edits, restart the game to load them. UTF-8 files with or without a BOM are supported.

## Dodge interrupts guard

Enable dodgeInterruptsGuard to release active guard just before a normal dodge attempt. The supplied INI enables it; if the setting is absent, it remains off. Use easierparry dodge on to enable it immediately, or set dodgeInterruptsGuard = true under [General] and restart. Use easierparry dodge off to restore vanilla behavior. The toggle is saved and does not change the parry factor. The master enabled setting controls both features.

The option drops guard; release and press guard again to raise it afterward. A dodge attempt still follows the game's normal eligibility, stamina and animation rules, so an unsuccessful attempt can also leave guard lowered. No keys are hardcoded, so the feature follows the game's dodge action with keyboard or remapped controller controls. Live gameplay validation is pending.

## Console commands

- `easierparry status` — show the selected factor, baseline, target timing and dodge option status.
- `easierparry 3` — select a 3× multiplier, enable the mod and save the selection.
- `easierparry off` / `easierparry on` — disable/enable the mod and save the selection.
- `easierparry dodge on` / `easierparry dodge off` — enable/disable and save guard interruption.

To check that the mod is active, load a save and look for `[EasierParryUE4SS] Applied` in `ue4ss/UE4SS.log`.

## Compatibility

Targets Steam build **25129649 / CL-257186**. Replaces no game assets; may conflict with other mods that alter guard/dodge behavior or change `ParryWindowMultiplier`.

Created by **oOCamilleOo**. [MIT license](LICENSE).
