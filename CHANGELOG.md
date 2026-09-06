# Changes

## 1.0.6 � 2026-09-06

- Follow the local controller�s current pawn and parry attribute on each maintenance check, rather than waiting for old objects to become invalid.
- Preserve the configured factor across player, attribute, and controller replacements; avoid compounding when a new pawn shares the previous attribute.
- Avoid restoring a stale baseline over values already reset by the game during loading.
- Log the configuration file path at startup to help identify which INI was loaded.
- Retain the 2.0 default and all existing settings; gameplay validation of death/reload remains pending.

## 1.0.5 — 2026-09-06

- Keep Nexus thumbnail, description, attribution, and listing metadata in the repository’s Nexus folder, outside the Vortex ZIP.
- Preserve Vortex name/version/description metadata and runtime installation paths.
- Lua and INI payloads are unchanged from v1.0.4.

## 1.0.4 — 2026-09-06

- Replace the thumbnail with an official in-game sword-clash screenshot and a simple title overlay.
- Include screenshot source attribution. Lua and INI payloads are unchanged.

## 1.0.3 — 2026-09-05

- Include the full Nexus description, existing thumbnail, changelog, and release notes in the Vortex ZIP.
- Preserve Vortex name/version/description metadata and the existing runtime paths.
- Lua and INI payloads are unchanged from v1.0.2. The performance fix remains pending in-game validation.

## 1.0.2 — 2026-09-05

- Remove repeated global player searches and object-name resolution from healthy maintenance ticks by caching the player and CharDevAttributeSet.
- Reacquire references only when absent or invalid; preserve value repair without redundant writes.
- Increase the default maintenance interval from 500 ms to 1000 ms.
- Prevent repeated `easierparry on` commands from compounding the multiplier.
- Standardize the fixed output name to `Easier-Parry-UE4SS.zip`, removing the historical v1.0.0 filename label. Display name and internal mod ID are unchanged; replace the same Vortex entry.
- Lua regression and Vortex installer checks passed; in-game stutter validation is pending.

## 1.0.1 — 2026-09-05

- Generate Vortex display name, version, and description in the release archive.
- Preserve the existing ZIP filename and runtime payloads. Reinstall/replace through Vortex to read metadata.
