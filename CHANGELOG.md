# Changes

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
