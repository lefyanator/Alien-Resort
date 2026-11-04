# Shared handoff — Alien Resort 0.7.0

Updated 4 November 2026 (Australia/Brisbane). Repository: https://github.com/lefyanator/Alien-Resort

## Current milestone

The user's existing open Studio project was updated directly. The canonical place is `Alien Resort Tycoon.rbxl`; no separate multiplayer place is required. All 12 active source scripts are synchronized with the saved binary and the open Studio Edit scripts. The source/binary verification script and SHA-256 manifest make this reviewable.

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

- All 12 scripts compiled with Luau 0.745.
- 53 isolated checks ran in the Roblox engine: all four plot origins/assignments, waiting/reuse, cross-owner rejection, stages/visual isolation, pet pricing/duplicates/equipment/rotation, legacy profile migration and invalid data, reset generation, and prompt event order/replay checks.
- Live Studio play: four generated islands, HUD and Pets menu initialized, real keyboard claim succeeded, guest checked in and paid 10 tokens, unused plot had no guests, and a real client BuyPet remote bought/equipped Jelly with a 120-token debit (1000 → 880). Temporary test money was confined to the Studio session.
- Scene exported through Roblox SerializationService; canonical place reassembled and round-tripped with Lune. All 12 active embedded script sources matched `src/`. Studio terrain cell count was zero; Lune warned about an unsupported empty Terrain metadata field while reading the old baseline.
- Computer Use could not access Studio's save dialog. The matching local place was saved through native scene export plus local serialization; the Studio session was updated, but no Roblox cloud publication was performed.

## Still needs testing / remaining gaps

- Four actual simultaneous clients, fifth-client queue, leave/rejoin during guest stays and cleaning, and heavy remote-spam tests. Isolated fake-player checks do not prove real multiplayer replication or performance.
- Published live DataStore acquisition, lease expiry, API outages, reconnects, and shutdown budgets. Existing cloud progress was not read or changed in Studio.
- Phone/tablet layout, controller interaction, and low-end performance. Layout uses scrolling menus but full device QA remains pending.
- Guests and cleaner use fixed tween routes, not dynamic obstacle avoidance. Alien species are procedural color/material/body-shape variants, not imported art or custom animations.
- No shared lobby/visitor travel, trading, rebirth, randomized eggs, Robux products, or monetization. Four plots are generated; set the experience player limit to four for launch unless waiting players are desired.

## Responsibilities for two collaborators and their ChatGPTs

1. Read this file, README, and the latest repository head before editing. Coordinate feature ownership and use separate branches for overlapping work.
2. Use the same canonical game filename. Only one collaborator edits the binary place at a time, or coordinate in Team Create. Never overwrite the other person's newer place with a stale ZIP.
3. Keep `src/` and Studio scripts identical, save/export the current place, run verification, regenerate the manifest, then commit major milestones with an updated handoff. No automatic background GitHub sync has been installed.
4. `ResortService` handles player lifecycle/routing; `PlotService` owns one island; `ResortExtras.New` closes over one plot; `PetService` owns catalogue/purchases/companions; `ProgressStore` owns persistence; `Interaction` owns prompt validation; Geometry/Expansion build visuals; HUD/Theme display state.
5. Never accept client prices, balances, plot owners, or pet ownership. Preserve server validation and per-plot coordinates in future changes.
6. Each collaborator uses their own accounts. GitHub collaborator access and Roblox Team Create permission are separate; the second collaborator's account/access has not been verified. ChatGPTs share context through committed files, not automatic shared memory.
