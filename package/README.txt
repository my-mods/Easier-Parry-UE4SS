# Easier Parry and Dodge While Blocking

![Easier Parry and Dodge While Blocking](Nexus/thumbnail.jpg)

Makes parrying more forgiving in *The Blood of Dawnwalker*. Includes native guard recovery after dodging. Attack inputs retain the base game’s guard behavior.

- **200% parry timing window** by default (2 times normal), adjustable from **10% to 5,000%** of the game's difficulty-adjusted baseline. Choose from 20 percentages with closer spacing at low values and wider gaps at high values.
- Keeps held guard available after a dodge, using the game's native ability lifecycle. Attack inputs retain the base game’s guard behavior.
- Temporarily lowers guard for a dodge and resumes when the game's combat rules allow it. Actual guard release and ability cancellation still end guarding.
- **Dodge while blocking** can be turned Off in Mod Settings independently of parry timing. It defaults to On; Off blocks the player's dodge ability while block is held.
- Forward dodges use native state-change and timed completion to restore held guard. Failed or cancelled attempts release their input suppression.
- Native guard handling uses gameplay events. Optional Lua diagnostics observe transitions without changing guard or bindings.
- Parry timing loads a fresh settings snapshot after save loading. There is no recurring timing checker.

## Installation

Requires a Dawnwalker-compatible **UE4SS 3.x** installation. Import `Easier-Parry-and-Dodge-While-Blocking.zip` into Vortex, select **Root (game folder)**, then enable and deploy. Keep one enabled Easier Parry entry.

The package contains the native dodge asset and the UE4SS timing script. Both are required. `Data` contains only an installer layout note; the payload uses explicit paths under `Dawnwalker`.

For updates, close the game, disable the old entry and deploy, then replace/reinstall that entry through the installer using **Root (game folder)** and deploy again. Reinstalling is necessary when changing from the older UE4SS mod type; redeploying its stored layout alone is insufficient.

Back up your legacy personal INI before replacing an older version. After first use of this version, back up the generated `settings.ini` beside the mod’s `mod_settings.ini` before uninstalling or reinstalling. See SETTINGS.md for migration and restoration.

To uninstall, disable/remove the entry in Vortex, deploy and restart the game. Restore your settings backup before launching after a reinstall.

## Settings

Use [Mod Setting Menu 1.0.5 or later](https://www.nexusmods.com/thebloodofdawnwalker/mods/271) from the main menu. Press Apply, then load a save. See [SETTINGS.md](SETTINGS.md) for all controls, first-use import and preference backups. Console settings commands are retired.

## Compatibility

Native assets are based on Steam build **25129649 / CL-257186**. Updates to these game assets require compatibility review. The mod replaces:

- `/Game/_Dawnwalker/Combat/Abilities/Dodge/GA_Dodge`

Controller Tweaks and Remap changes different assets and can remain enabled. Other mods replacing the dodge ability or modifying `ParryWindowMultiplier` may conflict. Do not assume differently named containers avoid asset conflicts; select one implementation of each ability.

The guard correction targets guard held before a dodge. The base game controls attack/combo handoffs and guard cancellation without an overridden guard ability. Dodge retains the game's native attack-interruption, stamina, animation and combat eligibility logic. If a stock attack transition ends guard, dodge completion cannot reactivate it; release and press guard again.

Created by **oOCamilleOo**. Original mod code is under the [MIT license](LICENSE); underlying game assets remain the property of their respective rights holders. Nexus listing materials are maintained separately in [Nexus](Nexus/README.txt).

# Settings

Install [Mod Setting Menu 1.0.5 or later](https://www.nexusmods.com/thebloodofdawnwalker/mods/271) and UE4SS through Vortex. On first use, load a save once to initialize the settings file, then return to Main Menu > Mod Settings > All Mods. Select this mod, change settings and press Apply. **Load a save after Apply.** Restore discards unapplied changes; Reset selects this mod’s defaults.

The stable menu ID is `oOCamilleOo_EasierParryAndDodgeWhileBlocking`. The mod generates `settings.ini` beside `mod_settings.ini` in its UE4SS mod folder. This generated file is the authoritative settings store and is not shipped in the ZIP. Existing supported preferences are imported on first use. After the new settings are saved and verified, the successfully imported legacy files are deleted if their contents are unchanged. Migration or save failures retain the originals. Cleanup failures are logged and do not prevent using the new settings. Files left by an earlier migration are not deleted automatically. Back up `settings.ini` before removing/reinstalling the mod or moving its folder. Restore that backup into the same runtime folder before launching. Do not restore an old INI over it.

Missing, duplicate or invalid settings stop configuration loading and are reported in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. Preserve the file before correcting it. If a menu save fails, preserve its temporary/backup files and follow the menu’s recovery instructions. Settings are read only when a save loads. Waiting at the main menu performs no settings work; travel and possession events use the current snapshot. Settings are never polled. `debugLogging` controls additional diagnostic logging; it defaults to Off.

| Group | Setting | Choices or range |
| --- | --- | --- |
| General | Parry timing adjustment | Off, On |
| Parry | Parry window | 20 percentage choices from 10% to 5,000% |
| Dodge | Dodge while blocking | Off, On (default) |
| Diagnostics | Logging | Off, On |

**Parry window presets:** 10%, 25%, 50%, 75%, 100%, 125%, 150%, 175%, 200%, 250%, 300%, 400%, 500%, 750%, 1,000%, 1,500%, 2,000%, 3,000%, 4,000%, and 5,000%. The spacing keeps smaller adjustments close together and reaches large windows quickly.

**100%** is the normal difficulty-adjusted window; **200%** is twice as long and remains the default. **10%** is one tenth as long; **5,000%** is 50 times as long. This changes the window for a successful parry, not animation speed.

Reset restores the 200% default. For manual INI edits, `parryWindowPercent` accepts values from 10 to 5000. Gameplay accepts values between the menu choices; opening the menu page requires one of the listed values.

When upgrading from multiplier settings, load a save once before opening this page. Existing multipliers are converted to percentages without changing the window. Values between the menu choices retain their precision. The original menu settings are retained as `settings.ini.before-percentages`, including unrelated text and comments. If conversion fails, keep the original and any `.before-percentages.new` transaction file for recovery. No settings file is replaced with defaults during this conversion.

**Dodge while blocking:** On keeps the mod's dodge and guard recovery behavior. Off blocks the player's dodge ability while the block input is held. Release block to dodge. This control remains available when Parry timing adjustment is Off. Press Apply, then load a save. It uses the game's native ability activation check; it does not poll inputs or settings.

When upgrading existing menu settings, the first save load adds `dodgeWhileBlocking = 1` while preserving saved preferences and unrelated text. The original file is retained as `settings.ini.before-dodge-setting`. If this upgrade fails, preserve that backup and any `.before-dodge-setting.new` transaction file for recovery. Older timing multiplier conversion still keeps its separate `.before-percentages` backup.

Console commands are not used to change settings.

Conditional rows and groups show relevant controls as you edit. Hidden options keep their saved values; hiding an option does not reset it. The interface uses toggles and labeled percentage choices; the numeric representation in settings.ini is an implementation detail.

**Logging** is the final menu setting and the only diagnostic control. Leave it Off for normal play; On writes troubleshooting details to `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.


Bundled library

This mod includes the MIT-licensed ue4ss-common Lua helpers (https://github.com/my-mods/ue4ss-common). No separate library installation is required. Its license is included in LICENSES/EasierParryUE4SS-ue4ss-common.txt.
