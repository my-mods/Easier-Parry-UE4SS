# Changes

## 1.0.9 — 2026-09-06

- Read the INI once at game startup and retain the selected multiplier for the session.
- Save console multiplier and on/off changes to the same INI, preserving other settings and comments.
- Keep the selected session value if saving fails, and report the failure in the log.
- Read UTF-8 INIs with or without a BOM and log the selected configuration path and factor.
- Direct INI edits now require a restart; the old reload command displays guidance without changing settings.
- Keep Nexus listing materials separate from the Vortex ZIP; retain the README, license, changelog, release notes and Vortex metadata.

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
