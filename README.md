# Easier Parry - UE4SS

![Easier Parry - UE4SS](Nexus/thumbnail.png)

Makes parrying more forgiving in *The Blood of Dawnwalker* by multiplying Coen's parry timing window.

- **2× timing window** by default, configurable from **0.1× to 50×**.
- Uses the game's current, difficulty-adjusted timing as its baseline.
- Caches the player and parry attribute; healthy checks do not scan game objects.
- Checks once per second by default and writes only when the value changes.
- Reacquires invalid player/attribute references after loading or recreation.

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
```

`factor = 1.0` gives vanilla timing; `2.0` doubles the window. Use `easierparry reload` in the UE4SS console after changing the factor or enabled setting. Restart the game after changing `pollMilliseconds`.

The INI beside main.lua is loaded at startup and on the explicit easierparry reload command. Keep a valid numeric factor under [General]. UTF-8 files with or without a BOM are supported. Failed reloads keep the last working settings; restart remains required for polling interval changes. The startup log identifies the selected file and factor.

## Console commands

- `easierparry status` — show the baseline and current timing.
- `easierparry reload` — reload the INI.
- `easierparry off` / `easierparry on` — toggle the mod for this session.
- `easierparry 3` — use a 3× multiplier for this session without saving it.

To check that the mod is active, load a save and look for `[EasierParryUE4SS] Applied` in `ue4ss/UE4SS.log`.

## Compatibility

Targets Steam build **25129649 / CL-257186**. Replaces no game assets; may conflict with other mods that change `ParryWindowMultiplier`.

Created by **oOCamilleOo**. [MIT license](LICENSE).
