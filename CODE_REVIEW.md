# Blender integration and code review — 0.9.1

Reviewed all 15 active Luau files on 2026-11-05. This branch integrates the existing authored pets and fixes bounded defects; it does not add more gameplay systems.

## Changes completed

- Four Blender pet templates now live in ReplicatedStorage/PetTemplates and art/PetTemplates.rbxm. World pets, visitors, workers and menu portraits share PetVisuals.Create. The procedural renderer remains a fallback if templates are absent.
- art/export_roblox.py reads the editable Blender scene, validates shared topology, exports exact part positions/rotations/colours/motion tags, normalizes height to 4.6 studs, and writes roblox-pets.json plus PetSurface.obj. All four authored pets are built from the same UV-sphere topology, so one persistent uploaded mesh is reused rather than creating 81 unique dependencies.
- Shared mesh: rbxassetid://134081985420522 (288 triangles). Templates have 20/27/16/22 direct children including the invisible CharacterRoot. Materials are deliberately simple authored part colours; this is not a baked texture atlas or a skeletal animation rig.
- Existing blink, breathe, sway, floating and foot animations operate on the imported parts. RestOffset/RestSize and gameplay pivot are retained at companion scale.
- Portrait mesh preloading fixes the initially blank collection cards. Studio's ShowDecompositionGeometry setting was enabled during inspection and was disabled for visual review; it was showing debug collision colours and suppressing mesh portraits. This is a local Studio debugging setting, not a game-script change.
- New guest requests clear stale completion, and too-fast training no longer sets a valid completion timestamp.
- Capture exits clear ArenaTeam, ArenaSeconds, carried-core and tag-prompt state together.
- A failed guest loop only clears its own landing ticket.
- Already-present characters receive the robot suit when server setup runs.

## Code review scope

| Files | Result |
| --- | --- |
| Bootstrap, Config | Reviewed initialization and shared data. Version bumped; existing startup preserved. |
| Geometry, Expansion | Reviewed procedural scene/offsets/stages. Architecture remains a prototype; legacy intermediate geometry could later be removed to reduce startup work. |
| ResortService, PlotService | Reviewed assignment, ownership, claim, income, reset and guest jobs. Fixed landing-lock cleanup and existing-character appearance. |
| ResortExtras, Interaction | Reviewed shop validation, cleaning holds, bonuses, robot and cleaner lifecycle. Preserved generation checks and server authority. |
| PetService, PetVisuals | Reviewed purchases/equipment/guest rotation/following. Integrated authored templates and preserved procedural fallback. |
| ProgressStore | Reviewed schema/normalization, session locks, write IDs, late load and shutdown handling. Live outages, lease expiry and reconnect budgets still need published testing. |
| AdventureService, CaptureRules | Reviewed activities/rewards, jobs, requests, evolution, queue and capture cleanup. Fixed stale request and arena UI state. |
| GuidedHUD, SimulatorTheme | Reviewed layout, menus, pending state, quiet effects, portraits and render loop. Added first-open mesh preloading. |

## Verification

- 174 isolated Roblox-engine checks passed with imported templates (the previous gameplay checks plus mesh dimensions, noncollision and animation metadata). These use test players, not four actual network clients.
- The same suite passed its 77 procedural-fallback checks with templates temporarily absent.
- All 15 active scripts compiled in Studio.
- Live Studio: all four coloured pets rendered in world and collection cards; first-open portraits worked after the preload fix.
- Live scripted traversal and real E-key holds exercised checkpoints 1–5. With test-only shortened reward cooldown/minimum duration, training awarded 15 tokens/2 shards. Replacing the completed guest request then trying to deliver immediately was rejected without shards. Fixtures were discarded on Stop. An initial diagnostic used the command environment's separate module cache and failed to find runtime state; the actual gameplay checks used the server Script environment.
- Native Studio instances were exported through SerializationService and rebuilt locally with Lune. verify-sync checks all active embedded source plus the four templates and persistent mesh dependency. Source line endings are pinned to LF; verification tolerates CRLF from older Windows checkouts. No Roblox place publication was performed.

## Highest-value remaining work

1. Real two-player capture, then 4/5-player reservation and disconnect tests. Isolated tests do not prove replication, balance or fun.
2. Published save/rejoin/shutdown and failed-API/lease tests with the existing DataStore keys.
3. Physical phone/controller input and low-end performance. The four pet shapes total 23,328 triangles before repeated guests/companions; the mesh is shared but draw/animation cost still grows with instance count.
4. Improve training traversal and activity feedback with a human playtest. A 2v2 queue currently needs four players present before the immediate 1v1 start; consider a short queue grace period after real testing.
5. Art: smooth normals/mesh consolidation where useful, evolved visual variants, UFO and Commons landmarks. Current motion is part-based, not a rigged FBX clip system.

## Save and collaboration

Use Alien Resort Tycoon.rbxl as the canonical file. Run lune run tools/verify-sync.luau before commits. tools/rebuild-place.luau can rebuild it from current source/templates, optionally incorporating a native Studio snapshot. Only the development tools need Blender/Lune; players do not. No Obsidian updates, background watcher, live economic data changes or paid products were added.
