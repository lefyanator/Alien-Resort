# Opening progression — 0.13.0 / 2026-11-05

The opening now teaches six steps: claim a free resort, receive the first payment, clean after checkout, complete the Moon Pod, complete Star Reception, and hire a cleaner. Affordable construction can start during the first stay. Dirty rooms take priority; returning owners with built rooms skip the introductory income/cleaning lesson. The guide shows progress, the current token cost, and a button opening the relevant existing menu.

Guests walk as their UFO takes off, instead of waiting for it to leave. Nearby reaction labels identify arrival, satisfaction and checkout. Room labels show payment countdowns and payments left. Payment banners distinguish normal income and VIP bonuses; construction fades and sound effects respect the existing motion/audio controls. Cleaner status shows travel and work, and purchasing it explicitly explains automation.

The Observatory now admits a VIP every third guest arrival. VIPs retain their species bonus and add 20 tokens per payment. Their labels and room status identify them. This uses the existing progression, currency and server-authoritative guest loop. Guest rotation resets when plot ownership changes. RoomsCleaned and GuestsServed now save as bounded, optional fields in schema3; legacy records default to zero.

## Verification

- `lune run tools/check-opening.luau`: 110 checks passed: 38 opening-policy/pacing checks, 31 capture-rule checks and 41 production persistence checks using a fake UpdateAsync backend. No live cloud writes.
- All 16 production sources compile and match the Edit model and rebuilt canonical place, including four Blender pet templates and six attributed Creator Store props.
- All 323 isolated engine assertions pass: 183 smoke, 30 art, 41 persistence, 31 capture and 38 opening checks. The engine tests used a temporary normal server Script created through Studio's script-editing tool; it was removed after testing.
- A fresh player completed claim, real guest payments, all three Moon Pod stages, manual cleaning, all three Reception stages and the cleaner purchase with earned tokens only. Build/Shop/Adventure guide buttons opened the correct menus. Insufficient shop funds were rejected. The bot cleaned a room and the next arrival resumed.
- A separate temporary fixture completed the Observatory through production purchase checks. A real VIP guest paid 50 tokens (30 upgraded base +20 VIP), and the three-room income display was 110. Fixture money and purchases were discarded on Stop.
- Live mute/reduced-motion clicks produced MUTED/REDUCED, audio-group volume zero and no construction effects. A client sample of 180 frames averaged 16.668 ms, p95 18.042 ms; this is one desktop client, not a mobile or populated-server benchmark.
- Tested guide/control bounds at 320x568, 390x844, 600x390, 844x390 and 1366x768. Fixed narrow modal headings, then confirmed all three headings fit at all five sizes in a fresh final-source run with zero tokens and no fixtures. These are simulated screen sizes, not physical-device certification.
- The timing/economy simulation assumes immediate purchases and prompt cleaning. It reaches first income at 22.7s, Moon Pod at 42.7s, first cleaning at 50.7s, Reception at 101.4s and cleaner at 177.8s. It models known travel durations and is not a retention, real-input or network benchmark.

Final Studio mode is Edit, with the temporary acceptance Script removed. Canonical rebuild/source/asset verification passes. Published persistence, physical devices, human pacing and a new multi-client regression pass remain release gates; this update does not publish to Roblox.
