# Full game assessment — 2026-11-05

Baseline: source commit 39dacab, v0.9.1; connected Studio place 134333458970364 in an existing one-player Play session. Assessment only: no gameplay changes, purchases, resets or publishing. The existing session was left running.

Evidence: reviewed GUI/theme/config, architecture, guest/cleaner/pet loops, activities/capture, persistence and the previous 15-script review; captured live character/island/Commons views; read runtime counts and sampled frame times. Confirmed below means observed in code or scene, not necessarily reproduced across devices. Suggestions are design judgments. Earlier 174/77 checks are regression evidence, not a fresh multiplayer or performance certification.

## Overall judgment

A working prototype with too many partially presented systems. The resort, pet adventure and capture arena need one clear progression path and a consistent visual language. Fix understanding, reliability and performance before adding another currency, district or monetization system.

## 1. First session and core loop — highest product priority

- The guide sends a player to the Commons after the first income if total pet bond is zero (PlotService objective). This interrupts the resort tutorial before construction/cleaning/automation are understood. Dirty rooms then override the guide. Teach claim → guest → payout → one staged build → clean → cleaner; introduce adventures afterward.
- The first payout requires landing, unloading, takeoff, several walking segments and a 10-second payment wait: roughly 30 seconds for the initial south room from loop start, longer for the north room or a queued landing. Make arrival engaging and show progress; time this with a new player before changing rates.
- All three rooms can become dirty and income stops until cleaning; the observed session had zero occupied rooms and three completed suites. Add a clear room-status overview and cleaner recommendation, plus guidance when away in the Commons.
- Construction is a fixed six-building chain with three payments each. Prices total 1,070 tokens; some purchases primarily increase income. Define meaningful milestones, varied services and a reason to use every finished building. Keep staged construction, but make each stage visibly distinct.
- Show active guest requests, checkpoint progress, rewards, prerequisites and cooldown timers persistently. Currently most information disappears in 3.5-second notices.
- Returning players still claim their reserved island. Make the restore/claim flow explicit and verify it does not feel like lost progress.

Pass: a new player can explain the loop and complete the first build/clean cycle without developer help; no unexplained wait or dead-income state. Measure first payout, first build, first cleaner and first adventure times.

## 2. GUI and controls — redesign, not more panels

- Current UI uses muted cream panels, thin borders and text-only navigation. It is softer than before but does not match the requested bright, chunky simulator reference. Use bold outlined icons/text, stronger coloured headers, layered button depth, restrained gradients and one consistent close button. Preserve readable prices and hierarchy.
- Wallet/guide/nav/Adventure are spread across the screen. Consolidate navigation and reduce the guide's footprint; keep the next action dominant. Phone layout currently stacks wallet, guide and navigation through ~242 pixels before the world.
- Build cards all close the menu and show a generic message; they do not select their own pad. A button labelled SHOW MY BUILD PAD must point to that specific building and explain locked prerequisites.
- Shop entries share a coin icon, so cleaner/foam/beacon/garden lack identity. Give each a recognizable item image, duration/owned state and visible benefit. Show boost timers on the HUD.
- Adventure drawer exposes ten small text actions, including locked jobs, without item-specific progression. Use contextual actions and readable pet/job/evolution cards. Show bond, shards, equipped/working state and evolution preview in Pets.
- Adventure drawer has no shared scrim and Button B closes only the collection modal. Unify modal opening, closing, input blocking and controller selection restoration; test every open/close route.
- Use text sizes/contrast suitable for phones; current labels reach 9–12 px, and save status is faint. Validate scrolling, text wrapping, device safe areas and touch movement overlap on portrait and landscape.
- Some adventure buttons immediately fire remotes with no pending/result treatment. Disable unavailable actions, debounce visually, and distinguish loading, rejection and success.

Pass: inspect 360×800, 800×360, 1280×720 and desktop layouts plus a real phone/controller. No clipped text, overlapping movement controls, ambiguous button outcome or trapped focus. No need to copy another creator's assets.

## 3. Models, environment and presentation

- Live Commons is a large flat white deck with coloured pads and six block covers: it reads as a test map. Create compact themed zones: training course, repair bay, evolution lab, garden and arena. Landmarks and paths should explain activity before signs are readable.
- Hotels, reception, cafe, lounge and observatory reuse a near-identical rectangular shell. Keep reusable construction pieces but give services distinct silhouettes, entrances, roofing, furniture and scale. Improve reception/cafe first; use them as the quality standard.
- North promenade is a sparse rectangle. Integrate it with the main island through paths, planting and finished railings; keep unfinished areas visibly under construction rather than accidentally empty.
- Decorations rely on primitive flowers/cups/ellipsoids. Build a small reusable prop kit: recognizable plants, luggage, service counter equipment, lamps, seats and cleaning tools. Add detail around points of interaction rather than everywhere.
- Imported pets have recognizable faces and colour, but faceted surfaces and many separate parts. Review smooth normals and consolidate static pieces without breaking blink/feet/accessory motion. Evolution currently adds a halo; provide a meaningful silhouette/material upgrade before presenting it as a major reward.
- Robot is rectangular shells fitted over the user's avatar dimensions. Use a consistent authored robot with tested proportions, clear face, shoulders/hands/feet and readable movement. Test supported avatar rigs, respawn and accessories.
- UFO orientation has an explicit upright root now; retain it. Improve shell, hatch, ramp, landing gear and engine presentation, then retest approach/landing/unloading at every plot.
- Bright white surfaces/neon dominate. Balance lighting, material values and accent colours; test interiors from normal camera height. Add intentional sky/ambient sound, purchase/cleaning/building cues and restrained particles; source currently contains little authored audio feedback.

Pass: identify each building/activity from a normal gameplay view without its label. Complete one polished island section before repeating it four times.

## 4. Smoothness and performance — investigate before increasing detail

Observed snapshot: 1 player, 1,818 workspace parts, 813 collidable parts, 34 MeshParts, 119 neon parts, 42 BillboardGuis; streaming enabled. Server groups: plots 1,698 parts, Commons 82, character 37 plus the baseplate. Counts vary with progression/streaming.

Five-second client sample: 75 frames, mean 66.66 ms (~15 FPS), p95 67.77 ms, max 68.28 ms. This is a warning signal, not proof of a game-code bottleneck: focus, Studio throttling, graphics setting and machine load were not controlled.

- Profile a focused client and a standalone published test, then worst-case four built plots with guests, companions, workers, cleaners and open portraits. Record CPU/GPU frame times, memory and replication traffic; optimize the measured bottleneck.
- Companions follow via server PivotTo at ~10 Hz; client part animations run up to 30 Hz. Guest/cleaner movement is also replicated through per-update model pivots. Check stutter and bandwidth before moving cosmetic interpolation to clients.
- V.Animate scans child parts and writes transforms/sizes repeatedly. Cache animation part lists/rest data and avoid unchanged writes if profiling supports it; keep distance/offscreen limits.
- Every player AttributeChanged refreshes the entire open card set and adventure status; arena seconds update frequently. Refresh only affected UI state if measurable.
- Decorative blocks default to collision/query/touch in several builders. Audit flags and collision groups. Merge static props where useful, reduce excessive transparency/lights/signs and avoid creating geometry that startup later destroys.
- One shared pet mesh reduces asset dependencies, but not the number of moving instances/draws. Four pet designs total 23,328 triangles before repeated instances.

Proposed targets: stable 60 FPS on the agreed desktop and 30 FPS on a representative lower-end phone in a populated scene; no growing memory/instance count after repeated joins, resets and menu cycles. Confirm target hardware before claiming success.

## 5. Concrete logic issues and technical risks

1. Training request validation still depends on mutable TrainingPet and an older CompletedTrainingAt (AdventureService lines ~78–84, 320). Code-path risk: accept a request for B, finish with A, then start B; the timestamp from A can be paired with B before B finishes. Store completed course pet/time together; add this regression case. Not reproduced live during this assessment.
2. Ability handling grants bond directly and reward() grants bond again for eligible non-Pip abilities. Decide whether double bond is intended; make rewards explicit and consistent.
3. JobGuestBonus is set by the activity loop without immediately refreshing advertised IncomePerTick. Show the correct rate when assigning/removing a job, not only after another resort event.
4. Arena starts as soon as two players are queued; 2v2 rarely forms unless four are present in the same poll. Add a clear queue count/countdown, fair ordering and deliberate 1v1/2v2 selection.
5. Respawn always sends characters to the island via ResortService, while capture membership persists and the arena loop sends participants back. Test/fix the spawn race, protection reset and carried-core cleanup together.
6. Training reward cooldown and other activity cooldowns are session-only. Decide whether rejoining should reset them; do not describe them as persistent timers.
7. Guest/cleaner paths are hardcoded and noncolliding models can pass through changed architecture. Keep authored route markers and validate routes after every building redesign.
8. Stage assignment is inferred from part names; arbitrary new model names default to final stage. Author explicit stage metadata for the Blender building kit.
9. Five or more players exceed four plots. Confirm max server size or provide a deliberate waiting/spectator flow, tested on release/disconnect.

Pass: reproduce/fix each confirmed logic defect with a focused check; do not rewrite working services wholesale.

## 6. Release gates, content and economy

- Published DataStore load/save/rejoin, overlapping session locks, failed API calls and shutdown remain untested. Studio explicitly disables persistence. Gate public release on evidence; preserve existing keys and progress.
- Run real 2/4/5-client tests: capture/tag line of sight, death, leave, simultaneous purchases/cleaning, reset ownership and queue recovery. Previous isolated checks do not cover network behaviour.
- Client-owned movement can reach interaction locations illegitimately; elapsed course time alone is not movement validation. Assess reward farming against actual payouts before adding competitive leaderboards or paid power.
- Economy is manually configured: 10-token base payout every 10 seconds while occupied, three payments per stay, substantial non-paying travel/cleaning time; pet unlocks 120/300/700; cleaner 80. Spreadsheet/simulate realistic cycles and observe players before changing prices.
- Garden/beacon powers mostly change a shared prop colour; training is five pads with holds. Give abilities useful, visible consequences and activities skill/choice, rather than more reward buttons.
- No durable long-term goal follows six buildings/four pets/evolutions yet. First make a satisfying initial session; then add one coherent extension such as resort rating and guest needs. Defer rebirth/more currencies until pacing is proven.
- Robux purchasing is not implemented in the reviewed code. Defer monetization; later use optional cosmetics/convenience, clear prices and reliable server receipt handling. Avoid disruptive repeated purchase popups.
- Add minimal playtest measurements: where players stop, tutorial milestones, activity use, purchase timing and errors. No analytics platform is currently wired in the reviewed source.

## Execution order

1. Correct request completion, modal/input inconsistencies and misleading Build actions; test persistence/multiplayer gates in parallel with manual profiling when available.
2. Finish one coherent tutorial and the bubbly GUI design; time a fresh first session.
3. Produce one polished reception/cafe/robot/prop kit; replace Commons test pads with readable themed activity spaces.
4. Profile the expanded scene and address measured bottlenecks; verify phone/controller layouts and movement.
5. Tune progression using playtests, strengthen pet abilities/evolution, then consider the next content tier and optional monetization.

Implement one small reviewable batch at a time, with before/after screenshots and targeted checks. Keep this audit and work in GitHub; do not resume Obsidian saving.
