Easier Parry - UE4SS

Makes parrying more forgiving in The Blood of Dawnwalker by multiplying Coen's parry timing window.

- 2× timing window by default, configurable from 0.1× to 50×.
- Uses the game's current, difficulty-adjusted timing as its baseline.
- Automatically reapplies when the player or parry attribute is recreated.

Installation

Requires a Dawnwalker-compatible UE4SS 3.x installation.

Download the mod ZIP from Releases: https://github.com/my-mods/Easier-Parry-UE4SS/releases, install it through Vortex, then enable and deploy.

To uninstall, disable/remove the mod in Vortex, deploy, and restart the game.

Configuration

Edit EasierParryUE4SS/Scripts/EasierParryUE4SS.ini:

[General]
enabled = true
factor = 2.0
pollMilliseconds = 500
debugLogging = false

factor = 1.0 gives vanilla timing; 2.0 doubles the window. Use easierparry reload in the UE4SS console after changing the factor or enabled setting. Restart the game after changing pollMilliseconds.

Console commands

- easierparry status — show the baseline and current timing.
- easierparry reload — reload the INI.
- easierparry off / easierparry on — toggle the mod for this session.
- easierparry 3 — use a 3× multiplier for this session without saving it.

To check that the mod is active, load a save and look for [EasierParryUE4SS] Applied in ue4ss/UE4SS.log.

Compatibility

Targets Steam build 25129649 / CL-257186. Replaces no game assets; may conflict with other mods that change ParryWindowMultiplier.

Created by oOCamilleOo. MIT license: LICENSE.txt.
