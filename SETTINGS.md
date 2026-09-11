# Settings

Install [Mod Setting Menu 1.0.5 or later](https://www.nexusmods.com/thebloodofdawnwalker/mods/271) and UE4SS through Vortex. On first use, load a save once to initialize the settings file, then return to Main Menu > Mod Settings > All Mods. Select this mod, change settings and press Apply. **Load a save after Apply.** Restore discards unapplied changes; Reset selects this mod’s defaults.

The stable menu ID is `oOCamilleOo_EasierParryAndDodgeWhileBlocking`. The mod generates `settings.ini` beside `mod_settings.ini` in its UE4SS mod folder. This generated file is the authoritative settings store and is not shipped in the ZIP. Existing supported preferences are imported on first use. After the new settings are saved and verified, the successfully imported legacy files are deleted if their contents are unchanged. Migration or save failures retain the originals. Cleanup failures are logged and do not prevent using the new settings. Files left by an earlier migration are not deleted automatically. Back up `settings.ini` before removing/reinstalling the mod or moving its folder. Restore that backup into the same runtime folder before launching. Do not restore an old INI over it.

Missing, duplicate or invalid settings stop configuration loading and are reported in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. Preserve the file before correcting it. If a menu save fails, preserve its temporary/backup files and follow the menu’s recovery instructions. Settings are read only when a save loads. Waiting at the main menu performs no settings work; travel and possession events use the current snapshot. Settings are never polled. `debugLogging` controls additional diagnostic logging; it defaults to Off.

| Group | Setting | Choices or range |
| --- | --- | --- |
| General | Parry timing adjustment | Off, On |
| Parry | Parry window | 20 percentage choices from 10% to 5,000% |
| Diagnostics | Logging | Off, On |

**Parry window presets:** 10%, 25%, 50%, 75%, 100%, 125%, 150%, 175%, 200%, 250%, 300%, 400%, 500%, 750%, 1,000%, 1,500%, 2,000%, 3,000%, 4,000%, and 5,000%. The spacing keeps smaller adjustments close together and reaches large windows quickly.

**100%** is the normal difficulty-adjusted window; **200%** is twice as long and remains the default. **10%** is one tenth as long; **5,000%** is 50 times as long. This changes the window for a successful parry, not animation speed.

Reset restores the 200% default. For manual INI edits, `parryWindowPercent` accepts values from 10 to 5000. Gameplay accepts values between the menu choices; opening the menu page requires one of the listed values.

When upgrading from multiplier settings, load a save once before opening this page. Existing multipliers are converted to percentages without changing the window. Values between the menu choices retain their precision. The original menu settings are retained as `settings.ini.before-percentages`, including unrelated text and comments. If conversion fails, keep the original and any `.before-percentages.new` transaction file for recovery. No settings file is replaced with defaults during this conversion.

Console commands are not used to change settings.

Conditional rows and groups show relevant controls as you edit. Hidden options keep their saved values; hiding an option does not reset it. The interface uses toggles and labeled percentage choices; the numeric representation in settings.ini is an implementation detail.

**Logging** is the final menu setting and the only diagnostic control. Leave it Off for normal play; On writes troubleshooting details to `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.
