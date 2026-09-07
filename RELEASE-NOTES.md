# Easier Parry - UE4SS — Pending attack cancels guard

A normal attack press now ends guard immediately, even while LT stays held. Guard stays off until LT is released and pressed again. Attack release does not restore guard, so it cannot cut off the attack animation through the previous recovery path.

The change redirects the existing light-attack listener to the stock guard teardown callback. It adds no listener, timer, object search, or per-frame work. The separate native attack input ability handles the attack normally; the guard ability no longer queues an additional attack. Three listeners remain per guard hold and all are removed by teardown.

Dodge behavior is preserved: a dodge while guarding restores held guard after native suppression ends, unless an attack or actual guard release has ended guarding. Dodge executable assets, eligibility, stamina and native attack interruption are unchanged. Current timing ownership fixes and bounded diagnostics are retained; the single debugLogging setting controls guard tracing and timing diagnostics, both off by default.

Replace/reinstall the existing Vortex entry as **Root (game folder)** and deploy. Keep one enabled Easier Parry entry. Controller Tweaks can remain enabled. Personal INI settings are preserved.

Offline checks cover cooked-asset round trips, 1,000 guard/dodge cycles, 1,000 attack cancellations with LT held, attack/dodge overlap, fresh guard presses, fixed task counts, diagnostic idle/flood limits, and the current timing ownership code. These do not establish live animations or frame times.

Test holding LT and dodging, then holding LT and attacking. Guard should drop on attack and stay off after the attack button is released, including after a subsequent dodge. Release and press LT again to guard. Retain ue4ss/UE4SS.log before another launch if anything fails.

Version remains 1.1.1. No release or tag is created.
