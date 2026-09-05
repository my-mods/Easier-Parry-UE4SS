# Easier Parry - UE4SS

![Easier Parry - UE4SS](Nexus%20Assets/Easier-Parry-UE4SS-Thumbnail.png)

A configurable UE4SS mod that makes parrying more forgiving in *The Blood of Dawnwalker* by multiplying Coen's live parry timing window.

Created by **oOCamilleOo**.

## Features

- 2x parry timing window by default.
- Configurable multiplier from 0.1x to 50x.
- Preserves the live vanilla or difficulty-adjusted baseline.
- Automatically reapplies after player or attribute recreation.
- No PAK replacements or IoStore file conflicts.
- Optional diagnostic logging, disabled by default.
- UE4SS console commands for status, reload, toggle, and quick testing.

## Requirements

- *The Blood of Dawnwalker* on PC.
- A working Dawnwalker-compatible UE4SS 3.x installation.

Validated against Steam build `25129649`, Hotfix 1.0.3, executable `CL-257186`.

## Installation

### Vortex

Download `Easier-Parry-UE4SS-v1.0.0-Vortex.zip` from [Releases](https://github.com/my-mods/Easier-Parry-UE4SS/releases), install it through Vortex, then enable and deploy it.

### Manual

Open the ZIP's `Data` folder and copy `EasierParryUE4SS` into:

```text
The Blood of Dawnwalker\Dawnwalker\Binaries\Win64\ue4ss\Mods
```

The final script path should be:

```text
...\ue4ss\Mods\EasierParryUE4SS\Scripts\main.lua
```

## Configuration

Edit `EasierParryUE4SS/Scripts/EasierParryUE4SS.ini`:

```ini
[General]
enabled = true
factor = 2.0
pollMilliseconds = 500
debugLogging = false
```

`factor = 1.0` is vanilla timing, `1.5` gives 50 percent more time, `2.0` doubles the window, and `3.0` triples it.

## Console commands

```text
easierparry status
easierparry reload
easierparry off
easierparry on
easierparry 3
```

## Logging

The mod writes one short `Loaded` message and an `Applied` confirmation. Continuous diagnostic logging is disabled by default. Set `debugLogging = true` only when troubleshooting.

After loading a save, check `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log` for an entry beginning with:

```text
[EasierParryUE4SS] Applied x2.000
```

## License

[MIT](LICENSE)
