# Alien world art pass — 0.12.0 / 2026-11-05

Addresses the user's five specific art criticisms. This completes this focused visual request, not the broader release gates tracked in OVERHAUL_STATUS.md.

| Criticism | Implemented change |
|---|---|
| Empty, flat pale map | Deep purple terrain, three raised habitat mounds per plot, a walkable elevated Spore Lookout with steps/rails, dark metal paths and the floating hotel introduce foreground/midground/sky layers. Guest routes and building footprints remain clear. |
| Colours blend together | Plum hulls and purple ground contrast with orange seams, roofs, plants and machinery; dark metal paths replace broad pale walkways. Mint remains a limited glass/light accent. Lighting is less washed out. |
| Weak alien theme | Mushroom-crown spore trees, curved tendrils with alien buds, bobbing sky rays and a floating mothership hotel. The existing guest UFO landing/unloading loop remains. |
| No aspirational centrepiece | One persistent 108-stud-wide Orbital Palace UFO hotel above the shared Commons. Completing the existing Observatory unlocks boarding to its elevated observation deck. No new currency or arbitrary extra grind. Ground and sky return lifts are server validated. Spawn/home orientation and first camera view face the landmark. |
| Generic rectangular buildings | Curved plum starter-pod hull, split levitating Moon Pod roof with orange maglev bands, living reception arches, lounge tendrils, retained A-frame Aurora and observatory ring. A bobbing holographic welcome sign complements building signs. |

Shared sphere/prop assets are reused; no paid assets, new external dependencies or new gameplay service. Cosmetic hover is client-side, distance-capped at 180 studs and respects reduced-motion settings. Added scenery pivots translate correctly with every plot. Temporary fixture purchases and test money were discarded on Stop.

## Verification

- All 15 active sources compile. Existing 183 engine checks + 31 capture-rule checks + 37 data-path checks pass (251 existing checks).
- 30 new art checks pass: palette/path material, playable lookout, distinct pod roofs, plot-relative animated pivots, landmark width/instance budget, elevated deck/lift destinations, persistence and tangent rails.
- Live real prompt holds: locked boarding refused at ground height; all six buildings bought through the production server API; completed Observatory allowed boarding to Y 71.47; return lift brought the player back to Y 8.85.
- Actual rendered review at fresh spawn, player height, island overview and hotel hero view. Caught radial hotel rail placement and corrected it to a curved circumference before final save.
- Client checked 37 animated model pivots; nearby SkyRay moved 0.098 studs over 0.4 seconds. An initial far-away animation sample was culled as designed; nearby movement was then checked directly.
- Current one-client desktop sample 181 frames/~3seconds: mean 16.657 ms, p95 18.080 ms. This is not a low-end/mobile or populated multiplayer benchmark.
- Native testing reset to Test mode, not Server & Clients. Only original Studio remains; final mode Edit.
- Canonical source/template/prop verifier and git diff checks pass. No Roblox publication.
- Final static layout review moved the east habitat mound from Z25 to Z32: its nearest edge is now Z25, one stud beyond the crosswalk's Z24 edge. This small placement correction was rebuilt and source-verified after Studio disconnected; it was not live retested.

Broader remaining checks: physical devices, final tag/death/2v2 regressions, human pacing and published persistence remain documented in OVERHAUL_STATUS.md.
