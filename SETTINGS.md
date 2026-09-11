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
