# Easier Parry and Dodge While Blocking

![Easier Parry and Dodge While Blocking](Nexus/thumbnail.jpg)

Makes parrying more forgiving in *The Blood of Dawnwalker*. Includes native guard recovery after dodging. Attack inputs retain the base game’s guard behavior.

- **2× parry timing window** by default, configurable from **0.1× to 50×**, using the game's difficulty-adjusted baseline.
- Keeps held guard available after a dodge, using the game's native ability lifecycle. Attack inputs retain the base game’s guard behavior.
- Temporarily lowers guard for a dodge and resumes when the game's combat rules allow it. Actual guard release and ability cancellation still end guarding.
- Forward dodges use native state-change and timed completion to restore held guard. Failed or cancelled attempts release their input suppression.
- Native guard handling uses gameplay events. Optional Lua diagnostics observe transitions without changing guard or bindings.
- Parry timing loads menu settings once at startup and reapplies that snapshot after save loading. There is no recurring timing checker.

## Installation

Requires a Dawnwalker-compatible **UE4SS 3.x** installation. Import `Easier-Parry-and-Dodge-While-Blocking.zip` into Vortex, select **Root (game folder)**, then enable and deploy. Keep one enabled Easier Parry entry.

The package contains the native dodge asset and the UE4SS timing script. Both are required. `Data` contains only an installer layout note; the payload uses explicit paths under `Dawnwalker`.

For updates, close the game, disable the old entry and deploy, then replace/reinstall that entry through the installer using **Root (game folder)** and deploy again. Reinstalling is necessary when changing from the older UE4SS mod type; redeploying its stored layout alone is insufficient.

Back up your legacy personal INI before replacing an older version. After first use of this version, back up the generated `settings.ini` beside the mod’s `mod_settings.ini` before uninstalling or reinstalling. See SETTINGS.md for migration and restoration.

To uninstall, disable/remove the entry in Vortex, deploy and restart the game. Restore your settings backup before launching after a reinstall.

## Settings

Use [Mod Setting Menu 1.0.5 or later](https://www.nexusmods.com/thebloodofdawnwalker/mods/271) from the main menu. Press Apply, then fully restart the game. See [SETTINGS.md](SETTINGS.md) for all controls, first-use import and preference backups. Console settings commands are retired.

## Compatibility

Native assets are based on Steam build **25129649 / CL-257186**. Updates to these game assets require compatibility review. The mod replaces:

- `/Game/_Dawnwalker/Combat/Abilities/Dodge/GA_Dodge`

Controller Tweaks and Remap changes different assets and can remain enabled. Other mods replacing the dodge ability or modifying `ParryWindowMultiplier` may conflict. Do not assume differently named containers avoid asset conflicts; select one implementation of each ability.

The guard correction targets guard held before a dodge. The base game controls attack/combo handoffs and guard cancellation without an overridden guard ability. Dodge retains the game's native attack-interruption, stamina, animation and combat eligibility logic. If a stock attack transition ends guard, dodge completion cannot reactivate it; release and press guard again.

Created by **oOCamilleOo**. Original mod code is under the [MIT license](LICENSE); underlying game assets remain the property of their respective rights holders. Nexus listing materials are maintained separately in [Nexus](Nexus/README.txt).

# Settings

Install [Mod Setting Menu 1.0.5 or later](https://www.nexusmods.com/thebloodofdawnwalker/mods/271) and UE4SS through Vortex. Start the game once, then open Main Menu > Mod Settings > All Mods. Select this mod, change settings and press Apply. **Fully close and restart the game after Apply.** Restore discards unapplied changes; Reset selects this mod’s defaults.

The stable menu ID is `oOCamilleOo_EasierParryAndDodgeWhileBlocking`. The mod generates `settings.ini` beside `mod_settings.ini` in its UE4SS mod folder. This generated file is the authoritative settings store and is not shipped in the ZIP. Existing supported preferences are imported on first use; legacy files are left intact and are no longer synchronized. Back up `settings.ini` before removing/reinstalling the mod or moving its folder. Restore that backup into the same runtime folder before launching. Do not restore an old INI over it.

Missing, duplicate or invalid settings stop configuration loading and are reported in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. Preserve the file before correcting it. If a menu save fails, preserve its temporary/backup files and follow the menu’s recovery instructions. Settings are never polled. `debugLogging` controls additional diagnostic logging; it defaults to Off.

| Group | Setting | Choices or range |
| --- | --- | --- |
| General | Parry timing multiplier | Off, On |
| Parry | Parry window multiplier | 0.1 to 50 |
| Diagnostics | Debug logging | Off, On |

Console commands are not used to change settings.

Conditional rows and groups show relevant controls as you edit. Hidden options keep their saved values; hiding an option does not reset it. The interface uses toggles, labeled choices and sliders; the numeric representation in settings.ini is an implementation detail.
