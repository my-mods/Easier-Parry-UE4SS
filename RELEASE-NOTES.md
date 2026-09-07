# Easier Parry - UE4SS 1.2.0

- Restore held guard after dodging. Normal attacks cancel guard until guard is released and pressed again.
- Replace optional Lua dodge interruption with native guard handling. Retire dodgeInterruptsGuard and the dodge console toggle; enabled and easierparry on/off now control only parry timing.
- Follow the active local player and attribute owner across save loads and possession changes. Preserve the captured timing baseline during temporary unpossession and partial-write retries.
- Add bounded guard and timing diagnostics under debugLogging, off by default. Diagnostic workers stop when finished.
