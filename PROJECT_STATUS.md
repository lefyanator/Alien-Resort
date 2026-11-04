# Latest: 0.13.0 — guided opening and VIP bookings

Read OPENING_STATUS.md for the six-step opening, guest/construction feedback, persistent counters, Observatory VIPs, 323 engine checks and the successful fresh-player loop. Physical-device, published persistence and multi-client release gates remain.

# Previous: 0.12.0 — alien biomes and Orbital Palace

Read ALIEN_WORLD_STATUS.md for the five-point art pass, progression-gated floating hotel, elevated alien habitat and 30 additional art checks. Previous overhaul gates remain in OVERHAUL_STATUS.md.

# Previous: 0.11.0 — Cosmic overhaul milestone

Read OVERHAUL_STATUS.md for the full-scope acceptance tracker, real two-client capture/reward evidence, 183+31+37 checks, revised map/UI and remaining work. Full brief: docs/OVERHAUL_BRIEF.md. This is an ongoing overhaul, not a release-ready claim.

# Previous: 0.10.1 — declutter and Creator Store props

Read DECLUTTER_STATUS.md for the screenshot-driven fixes, free asset credits, construction-gated cafe interaction and 183 engine checks. Previous results below are historical.

# Previous: 0.10.0 — smooth companions and polish

Read POLISH_STATUS.md for implemented art/GUI/gameplay changes, 179 engine checks, desktop and layout evidence, and remaining release gates. Previous milestones below are historical.

# Previous: 0.9.1 — Blender integration and code review

Read CODE_REVIEW.md for current results and remaining work. The four templates are integrated and verified; the first-pass art notes below are historical.

# Blender art first pass — 4 November 2026

The art/ folder contains an editable Blender scene, four static pet FBX exports and a reproducible build script. These are original concept meshes for Pip, Juno, Sprout and Ember. They are NOT imported into Roblox yet and have no rigs or animation clips. See art/README.md for the integration contract and remaining work. The canonical playable game is still the verified 0.9.0 milestone below; no game scripts or gameplay were changed by this art pass.

# Adventure milestone 0.9.0 — 4 November 2026

The same open Studio project now includes Cosmic Commons, shuttles, a solo/cooperative activity loop, pet abilities/jobs, bonding, evolution, and a Starcore Capture prototype. Read GAMEPLAY_STATUS.md for exact controls, rewards, limitations and validation. Previous visual milestone: e39ce19dff4e5f1a24aeeca0e108a56f3101e0fd. Before_Adventure_0_9 preserves previous scripts in ServerStorage.

All 15 active embedded scripts match src/ and the saved canonical Alien Resort Tycoon.rbxl. 77 engine assertions passed and all 15 files compiled. This supersedes the older counts and future-feature lists below. No Roblox cloud publication was performed. Arena rounds still require a real two/four-player test, and the Commons is a functional prototype rather than final scenery.

# Shared handoff — Alien Resort 0.9.0

Updated 4 November 2026 (Australia/Brisbane). Repository: https://github.com/lefyanator/Alien-Resort

## Visual milestone 0.8

Multiplayer/pet milestone preserved in GitHub commit `413e8d8bfb46bd2387a9d7f463abdd839fe63fa9`. This pass replaces the HUD and theme and adds shared PetVisuals. A `Before_Visual_0_8` script backup remains inside ServerStorage.

- Clear token wallet with comma formatting, animated totals, CHA-CHING gain banner, flying coin arcs, wallet pulse, and FX Quiet.
- A single modal with Pets/Build/Shop tabs, loading/pending/owned/equipped/affordability states, real 3D portraits, 44-pixel minimum touch targets, keyboard shortcuts, and core/device safe insets.
- Pip, Juno, Sprout, and Ember have distinct procedural silhouettes, faces, accessories, biographies, equipment greetings, name labels, and idle/blink/gait animations. Jelly floats; Slime bounces. Visuals are shared by menu portraits, pets, and guests.
- UI screenshots reviewed on desktop and iPhone 17 Pro landscape and portrait. Compact landscape cards were corrected so the first row's purchase buttons fit. Studio returned to default viewport. No runtime errors in final console output.
- In live Studio, P/B/M opened the matching menu and a token gain produced the CHA-CHING effect. The final engine suite passed 69 checks, including per-character appearance features, part-count budget, and scaled-animation pivot stability.
- See UI_UX_SPEC.md for concrete design instructions. Tablet, hardware touch/controller behavior, and extended accessibility QA still need testing.

## Current milestone

The user's existing open Studio project was updated directly. The canonical place is `Alien Resort Tycoon.rbxl`; no separate multiplayer place is required. All 13 active source scripts are synchronized with the saved binary and the open Studio Edit scripts. The source/binary verification script and SHA-256 manifest make this reviewable.

Previous GitHub baseline: `ccdab7081812e6dc86e20fc276557ed768ac76dd`. The previous script folder and HUD remain in `ServerStorage/Before_Multiplayer_2026_11_04` inside the game file. The old scene, other code archives, and other exported root instances were preserved. The source ZIP did not contain a multiplayer implementation; `Orbit-Oasis-Multiplayer.zip` was unavailable. This milestone implements separate plots from the supplied source.

## Implemented

- Four independently reserved plots, one per player. Separate owner, stages, guests, landing lock, cleaner, cosmetics, and income state. A fifth player waits and receives a vacancy when another leaves.
- Server checks ownership, live character distance, prerequisites, affordability, loaded profile, and prompt hold timing. Shop and pet remotes route only to the caller's own claimed plot and are rate limited.
- Pebble companion free; Jelly 120 / Slime 300 / Lava 700 tokens. Permanent ownership, one equipped follower, direct purchases, duplicate prevention, and species-specific guest payout bonuses. Newly owned species enter only that owner's guest rotation.
- Existing construction, guest stays, cleaning, boosts, garden, terrace, robot avatar, and visual architecture retained. Client HUD selects only its assigned plot and includes a pet purchase/equip menu.
- Profile normalization migrates existing tokens, stages, and amenities in `OrbitOasis_Progress_v1` and adds pet ownership/equipment without renaming player keys. Timed boosts remain session-only.

## Important fixes

- Removed global mutable plot and Extras state; removed duplicate remote listeners per plot.
- Applied profile values before marking the profile ready. Late loads after a player leaves release the loaded snapshot rather than saving blank attributes.
- Save writes verify their own write identifier; malformed values and invalid equipped pets are normalized. NaN/infinity are rejected.
- Plot release invalidates guest jobs before yielding to saves. Old guest jobs cannot dirty a new owner's room. Cleaner jobs and UFO landing locks cannot clear a new job's state after reset.
- Failed guest jobs clean up their own models and retry only for the same owner/generation.
- Fixed prompt event ordering: Roblox can send HoldEnded immediately before Triggered. Valid completed holds work while short, absent, and replayed holds are rejected.

## Validation completed

- All 13 scripts compiled with Luau 0.745.
- 69 isolated checks ran in the Roblox engine: all four plot origins/assignments, waiting/reuse, cross-owner rejection, stages/visual isolation, pet pricing/duplicates/equipment/rotation, legacy profile migration and invalid data, reset generation, and prompt event order/replay checks.
- Live Studio play: four generated islands, HUD and Pets menu initialized, real keyboard claim succeeded, guest checked in and paid 10 tokens, unused plot had no guests, and a real client BuyPet remote bought/equipped Jelly with a 120-token debit (1000 → 880). Temporary test money was confined to the Studio session.
- Scene exported through Roblox SerializationService; canonical place reassembled and round-tripped with Lune. All 13 active embedded script sources matched `src/`. Studio terrain cell count was zero; Lune warned about an unsupported empty Terrain metadata field while reading the old baseline.
- Computer Use could not access Studio's save dialog. The matching local place was saved through native scene export plus local serialization; the Studio session was updated, but no Roblox cloud publication was performed.

## Still needs testing / remaining gaps

- Four actual simultaneous clients, fifth-client queue, leave/rejoin during guest stays and cleaning, and heavy remote-spam tests. Isolated fake-player checks do not prove real multiplayer replication or performance.
- Published live DataStore acquisition, lease expiry, API outages, reconnects, and shutdown budgets. Existing cloud progress was not read or changed in Studio.
- Tablet, hardware touch/controller behavior, and low-end performance. Phone portrait/landscape were checked in Studio simulation, not on physical hardware.
- Guests and cleaner use fixed tween routes, not dynamic obstacle avoidance. Alien species now have distinct procedural character models and part-based idle animations; there are no imported mesh assets or skeletal animation clips.
- No shared lobby/visitor travel, trading, rebirth, randomized eggs, Robux products, or monetization. Four plots are generated; set the experience player limit to four for launch unless waiting players are desired.

## Responsibilities for two collaborators and their ChatGPTs

1. Read this file, README, and the latest repository head before editing. Coordinate feature ownership and use separate branches for overlapping work.
2. Use the same canonical game filename. Only one collaborator edits the binary place at a time, or coordinate in Team Create. Never overwrite the other person's newer place with a stale ZIP.
3. Keep `src/` and Studio scripts identical, save/export the current place, run verification, regenerate the manifest, then commit major milestones with an updated handoff. No automatic background GitHub sync has been installed.
4. `ResortService` handles player lifecycle/routing; `PlotService` owns one island; `ResortExtras.New` closes over one plot; `PetService` owns catalogue/purchases/companions; `ProgressStore` owns persistence; `Interaction` owns prompt validation; Geometry/Expansion build visuals; HUD/Theme display state.
5. Never accept client prices, balances, plot owners, or pet ownership. Preserve server validation and per-plot coordinates in future changes.
6. Each collaborator uses their own accounts. GitHub collaborator access and Roblox Team Create permission are separate; the second collaborator's account/access has not been verified. ChatGPTs share context through committed files, not automatic shared memory.

# Integration milestone 0.9.1 — 5 November 2026

Blender pet templates are integrated, including original transforms, colours, motion metadata and first-open portraits. All active source and templates are saved in the canonical place. CODE_REVIEW.md records the full source review, bounded gameplay fixes, 174 imported-template engine checks and 77 procedural-fallback checks. Live cloud/multi-client testing remains outstanding. Saving is now to this GitHub repository; Obsidian is no longer used.
