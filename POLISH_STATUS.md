# 0.10.0 — polish and smooth companions

Implemented 2026-11-05 after GAME_ASSESSMENT.md. This is a broad playable improvement pass, not release certification.

## Changed

- Companions render a frame-rate-independent exponential follow on each client. Independent interpolation state avoids using the coarse replicated position as the next rendered starting point. Server updates only when the target is over eight studs away, checked every half-second; long teleports snap locally. No reward/ownership authority moved to clients.
- Buildings retain their footprints and guest routes but have distinct curved hotel/lounge roofs, an observatory dome with an external scope, an open-front cafe and reception tower. Interior lamps/luggage, palm planters, flowers and proper pedestal chairs share a small prop kit. Curved props reuse the already-uploaded Blender sphere surface, with primitive fallback; no new paid assets.
- Commons now has coloured covered activity stations, training arches, paths, a covered repair bay, evolution pavilion, planted garden, treasure markers and cylindrical arena cover/court markings. Nearby labels replace overlapping long-distance checkpoint signs.
- Robot armour/head are rounded over the existing rig. This is still a suit, not a newly authored R15 character.
- GUI has brighter simulator colours, thick outlines, button shading, rounded controls and a coloured outlined title header. Shop item symbols, boost timers and adventure progress improve feedback. Build cards select their specific pad; previews preserve actual part/mesh geometry.
- Collection and Adventure share a scrim and Back/close behaviour. Adventure buttons have a client tap throttle and locked pet-job feedback. Mobile Adventure button no longer overlaps the wallet.
- Intro introduces adventures after reception and cleaning automation. Manual cleaning introduces the cleaner purchase. Requests/checkpoints and ability cooldown appear in Adventure.
- Request completion pairs the completed pet with its timestamp, so starting another course cannot reuse the old pet result. Added a pure shared predicate and regression checks.
- Removed unintended extra bond grants on non-Pip powers. Sprout cleans a room (all dirty rooms when evolved); Ember activates a temporary resort arrival beacon (longer when evolved). Job bonuses refresh the advertised income immediately.
- Capture queue waits eight seconds for additional players, starts immediately at four, and reports queue size. Arena respawn restores the participant to their team base with protection; ordinary resort respawn no longer fights that placement.
- Decorative props disable collision/query/touch, geometry disables unused touch events, and bloom is reduced.

## Evidence

- 179 isolated engine assertions passed, including frame-rate-independent following, teleport snap, wrong-pet/old-course rejection, all existing ownership/stage/profile checks and Blender-template checks. These are not real network clients.
- All 15 sources compile. Canonical place/source/template verification and git diff checks pass.
- Live one-player fixture built all six buildings through all three stages and purchased cleaner/garden/tables. World, robot, Commons and collection screenshots inspected. Fixtures and test money were discarded on Stop.
- Live pet follow: character moved 23.20 studs over 151 frames; pet finished within 0.001 studs of the follow target. Maximum per-frame step was 2.17 studs including initial turning; this is not a latency benchmark.
- Live full-build desktop sample: 180 frames in about three seconds, mean 16.66 ms (~60 FPS), 2,585 workspace parts / 722 collidable parts in that streamed scene. Earlier audit's ~15 FPS used uncontrolled focus/throttling: do not claim a fourfold optimization from these samples.
- Simulated safe-area sizes 360×800, 800×360, 1280×720 and 1920×1080: no overlap among wallet/guide/main nav/Adventure/FX, and collection bounds fit. This does not test physical touch, controller navigation or mobile performance.
- Actual Build card click selected Room2's pad and closed the modal. Adventure scrim and controller Back verified. An initial fixture encountered an already-claimed reservation and an initial simulated click missed; the subsequent direct UI click verified the marker.
- No new background watcher, currency, dependency, runtime service or gameplay source file. Shared renderer and existing services are reused.

## Remaining acceptance gates

- Published DataStore failure/rejoin/shutdown/lease tests. Studio disables persistence; no cloud publication performed.
- Real 2/4/5-client tests for death/disconnect, queue recovery, tag/capture, simultaneous interactions and replication under latency.
- Physical phone/controller tests and focused low-end profiling with four populated resorts. Added art still increases rendering cost; one desktop sample cannot certify it.
- Human first-session pacing tests and economy tuning. Existing prices/rewards retained apart from clearer/useful powers.
- More distinctive evolved art, fully authored robot rig, custom building meshes, richer audio and the next progression tier remain future art/content work. Current props/buildings are a reusable mesh/primitive kit, not a finished Blender architecture pack.
- Session-only activity cooldowns are still session-only. Existing session-lock/DataStore keys remain intact. Keep public launch and monetization gated on reliability and playtesting.

See GAME_ASSESSMENT.md for the full original backlog; this file records what is actually implemented.
