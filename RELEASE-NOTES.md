# Easier Parry - UE4SS v1.0.1

The ZIP now generates vortex_override_instructions.json from mod.manifest, so Vortex sets the display name, version, and description during installation. Runtime payloads and file destinations are unchanged.

Replace/reinstall the updated ZIP through Vortex using the existing mod entry, then deploy. Redeployment alone cannot read new archive metadata. This does not provide automatic update discovery or merge duplicate Vortex entries.

Archive filename: Easier-Parry-UE4SS-v1.0.0-Vortex.zip

Validation: ZIP allowlist, manifest/attribute agreement, UTF-8 without BOM, installed Vortex attribute merge, and installer destination planning. Lua and INI hashes match the previous local release. 

No live Vortex installation/deployment or in-game test is performed for this packaging update. Confirm the displayed name, version, and description after reinstalling. Previous in-game acceptance checks remain applicable.

Requires Dawnwalker-compatible UE4SS 3.x. Use UE4SS (Lua mods). This package includes the full EasierParryUE4SS.ini: back up custom settings before replacement; preferences are not automatically merged. Disable/remove this mod and deploy through Vortex to uninstall. The historical v1.0.0 string in the fixed ZIP filename is retained as requested; Vortex reads the current version from archive metadata.

Verified local archive: 7560 bytes; SHA-256 `410D731F7DCEAE754934D66D4D0DF7361F25CC4856D83A3BD4240E88D0C8B6DB`.
