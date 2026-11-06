# Cosmic overhaul — milestone 0.11.0 (2026-11-05)

Full requested scope is preserved in docs/OVERHAUL_BRIEF.md. This milestone advances it; it is not a claim that the entire commercial-quality overhaul is complete.

## Implemented

- Read latest remote history and handoff before edits; branch codex/cosmic-overhaul starts from 742b1c9 (the v0.10.1 feature branch). Main was 85648c9 at fetch. Existing unmerged work is preserved.
- Central Commons has chamfered layered terraces, a rock underside, stadium gateway/scoreboard, distinct team goals, outside-bound spectator tiers and paths. Resorts gain asteroid roots, rounded promenade ends, an A-frame Aurora, open lounge and observatory ring. Existing plot footprints, interaction locations and guest routes remain.
- Removed obsolete room/guest builders and geometry constructed only to be destroyed. Shared assets and all existing activities are retained.
- Arena rules are explicit testable transitions in the existing CaptureRules module: countdown, take/drop/reset/capture, tagging protection/cooldowns and contribution-based results. No new gameplay service/file or reward remote.
- Queue is ordered by join time, checks a live character, fills 1v1/2v2 after the existing grace period, reports countdown and allows leaving. Rounds have a three-second ready phase, replicated scores/timer, a world scoreboard and personal HUD/instructions/results. Short/idle rounds do not pay. Eight seconds separate rounds.
- Actual two-client testing exposed a runner's own TagRunner prompt taking global prompt priority. Local presentation now hides own/teammate tag prompts and hides irrelevant home-core/base prompts. Server distance, hold, ownership, match membership and line-of-sight checks remain authoritative.
- Profile writes reuse a stable WriteId across retries; committed releases with lost responses can be confirmed. Unsupported future schemas/corrupt records are refused without replacement. Failed loads cannot become ready. Serialized save/release snapshots and shutdown scheduling are covered by tests. DataStore/key names and schema3 fields remain.
- UI uses the requested palette, themed window bands, restrained transitions, pet bond/evolution meters, resort rating/next milestone, locked-job requirements, tooltips and dedicated round results.
- Functional local Settings: interface audio mute, reduced motion and room-label visibility. Audio: free Creator Store Chat Progress / ClicheChloe, https://create.roblox.com/store/asset/1293433423 (verified preload, low-volume/throttled). Existing prop credits remain in DECLUTTER_STATUS.md.
- Fewer broad UI refreshes and safer streaming/plot lookups. No speculative pooling or new runtime dependencies.

## Verification evidence

- Studio: all15 scripts compile; 183 existing isolated engine checks pass.
- 31 actual CaptureRules transition tests: countdown, own/enemy flags, replay/cooldown, protection, team tags, contributions, draw, departure.
- 37 production ProgressStore-path tests with fake UpdateAsync: migration, lease conflict/expiry/loss, future/corrupt records, load/save outages, lost committed responses, late departure and overlapping autosave/release. Also passed under Lune. These are backend simulations, not live cloud tests.
- Real local server with TWO network clients: assigned separate Plot1/Plot2; claimed independently; both queued through the validated remote; countdown/team assignment replicated; coral runner took blue core with actual engine prompt-hold events, returned home and captured; 0:1 score replicated; opponent left via remote; contributing winner received30 tokens/4 shards and match attributes cleared while both resorts remained owned.
- First idle round ended0:0 with no rewards. A temporary local equivalent of the prompt-visibility patch was used during the second network test; final production HUD then received the fix. Full network regression of the final combined HUD and tag input remains pending.
- Native test session ended; server+two client processes closed. Only original Studio remains. Temporary scripts/money were confined to test DataModels and discarded.
- Settings actual UI clicks: REDUCED, MUTED, HIDDEN and SoundGroup volume0; Back closed panel/scrim.
- Arena/Settings control overlap checks passed at360x800,800x360,1280x720,1920x1080 simulated safe-area sizes. Physical touch/controller coverage is not implied.
- Render inspection caught rotated asteroid roots protruding through the arena. Bounds clamp fixed Commons, resort and promenade roots. Engine check of16 root pieces reported maximum topY0.8007, below the deck.
- Current one-client sample:180 frames/~3seconds, mean16.664ms, p9517.721ms;1873 parts,415 collidable,257 meshes in that streamed view. Not a controlled hardware benchmark or fully populated four-plot test.
- Same-engine one-plot assembly comparison:499→451 explicit Instance.new calls; final instances528→539. Single timings13.60→10.98ms are illustrative, not a reliable speedup claim. Extra retained instances are the new terrain/architecture.
- Canonical place/source/template/prop verification passes. No Roblox publication.

## Full-scope acceptance tracker

| Brief requirement | Current evidence | Still required |
|---|---|---|
| Audit/stabilise | Remote/handoff/source review; save and prompt bugs fixed; tests above | Further final-build integration coverage |
| Environment quality | New silhouettes/understructure/stadium; rendered inspection and root-bound fix | Wider final visual review, finished hero architecture/landscaping; human quality assessment |
| Existing central minigames | Capture gameplay/state/HUD strengthened; real1v1 capture/leave/reward | Final-build tag/death/disconnect regression; real2v2, fairness, rescue teamwork and human replayability tests |
| Complete UI/HUD | Functional Settings, menus/meters/results/palette; responsive checks | Final result modal rendered and Back/contextual prompts verified; physical phone/tablet/controller and text-fit sweep |
| Gameplay depth | Existing features retained; clear resort rating/next milestone, pet progress | Human first-session pacing/economy tests; meaningful long-term achievement/content tier |
| Multiplayer/data safety | Existing plot isolation suite + actual two plots;37 data-path tests | Four/fifth-client cases and live published load/rejoin/outage/shutdown budgets |
| Performance | Constructor reduction, refresh reduction, one-client frame sample | Fully built populated4plots, low-end phone/tablet CPU/GPU/memory/traffic and soak tests |
| Shared GitHub | Isolated branch, source/binary verification, this handoff | Keep milestones pushed; do not mark entire brief done before remaining acceptance checks |

## Next work

1. Final-build tag/death/disconnect and2v2 tests; results/modal and contextual prompt filtering were verified in a fresh run.
2. Improve training/rescue interaction depth and resort guest milestones, with timing and playtest evidence.
3. Continue visual polish at actual player height, especially building interiors, service equipment and traversal composition.
4. Published persistence and physical-device tests require appropriate environment/device access; record NOT TESTED until actually run.

Original broad goal remains active. No paid products, Obsidian saving, destructive archive replacement or hidden live data writes.
