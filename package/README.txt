EASIER PARRY - UE4SS 1.0.1
==========================

Author: oOCamilleOo
Game: The Blood of Dawnwalker (PC)
Validated against Steam build 25129649 / Hotfix 1.0.3 / executable CL-257186.

DESCRIPTION
-----------
Easier Parry makes defensive timing more forgiving by multiplying Coen's live
parry-window attribute. The default is 2x, with a configurable range from 0.1x
to 50x.

The mod captures the value used by the running game, including any current
difficulty adjustment, and multiplies that baseline. It automatically applies
again when the player is recreated or the game recalculates the attribute.

REQUIREMENT
-----------
A working Dawnwalker-compatible UE4SS 3.x installation.

VORTEX INSTALLATION
-------------------
Install the ZIP through Vortex, then enable and deploy it.

MANUAL INSTALLATION
-------------------
Open the ZIP's Data folder and copy the EasierParryUE4SS folder into:

  The Blood of Dawnwalker\Dawnwalker\Binaries\Win64\ue4ss\Mods

The final script path should be:

  ...\ue4ss\Mods\EasierParryUE4SS\Scripts\main.lua

CONFIGURATION
-------------
Edit:

  EasierParryUE4SS\Scripts\EasierParryUE4SS.ini

Default settings:

  [General]
  enabled = true
  factor = 2.0
  pollMilliseconds = 500
  debugLogging = false

Examples:
  factor = 1.0    vanilla timing
  factor = 1.5    50 percent more time
  factor = 2.0    twice the timing window
  factor = 3.0    three times the timing window

Factor and enabled changes can be reloaded through the UE4SS console. Restart
the game after changing pollMilliseconds.

CONSOLE COMMANDS
----------------
  easierparry status     show the captured baseline and current target
  easierparry reload     reload the INI and reapply it
  easierparry off        restore the captured baseline for this session
  easierparry on         enable the mod for this session
  easierparry 3          use a 3x factor for this session without saving it

LOGGING
-------
The mod always writes one short message when its script loads and another when
it successfully applies to the player. These messages make installation issues
easy to identify without producing continuous log noise.

Additional diagnostic and reapply messages are optional and disabled by
default. Set debugLogging = true only when troubleshooting.

To confirm operation, load a save and open:

  The Blood of Dawnwalker\Dawnwalker\Binaries\Win64\ue4ss\UE4SS.log

Look for lines beginning with [EasierParryUE4SS], including:

  Applied x2.000: ParryWindowMultiplier 1.0000/1.0000 -> 2.0000/2.0000

COMPATIBILITY
-------------
Easier Parry replaces no packaged game assets and therefore creates no PAK or
IoStore file conflicts. It may conflict with another runtime mod that
continuously changes Coen's ParryWindowMultiplier.

UNINSTALLATION
--------------
Remove or disable Easier Parry - UE4SS through Vortex. For a manual installation,
delete only the EasierParryUE4SS folder from ue4ss\Mods. Restart the game after
uninstalling.

LICENSE
-------
MIT. See LICENSE.txt. The package contains original Lua code and no game assets.

VORTEX METADATA UPDATE 1.0.1
The ZIP now generates vortex_override_instructions.json from mod.manifest, so Vortex sets the display name, version, and description during installation. Runtime payloads and file destinations are unchanged.

Replace/reinstall the updated ZIP through Vortex using the existing mod entry, then deploy. Redeployment alone cannot read new archive metadata. This does not provide automatic update discovery or merge duplicate Vortex entries.

Archive filename: Easier-Parry-UE4SS-v1.0.0-Vortex.zip
