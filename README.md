# Alien Resort — Orbit & Oasis

**Current version: 0.14.0. Open `Alien Resort Tycoon.rbxl` in Roblox Studio and press Play.** This is the single canonical game file. Source in `src/` matches its embedded scripts. Islands are generated when the server starts.

New: 12 original Blender resort assets, clear roof/sign spacing, detailed furniture and robots, readable Commons equipment, colourful menus and a replayable 12-lesson TUTORIAL. See ART_REFINEMENT_STATUS.md for validation and art/review for actual game screenshots.

## New: Cosmic Commons

Claim your resort, then open **ADVENTURE** or use the gold Commons shuttle beside your terminal. Train your pet, help repair a stranded shuttle, excavate treasure with Pip, and earn Star Shards for evolution. Queue for Starcore Capture at the central arena. Return Home is available in the Adventure drawer. Read GAMEPLAY_STATUS.md for the exact prototype rules, pet jobs, and test limitations.

## Play

Each player is assigned one of four independent floating islands. Hold **E**, use the controller prompt, or tap/hold the touch prompt at your own terminal to claim it. Your free Pebble guest arrives by UFO and earns tokens. Build six upgrades in three stages, clean dirty rooms, and buy permanent amenities or timed boosts. The fifth player waits for a plot to become free.

The six-step opening guides you through your first earnings, cleaning, Moon Pod, Reception and cleaner robot. Completing the Observatory unlocks the floating Palace and VIP guests, who pay 20 extra tokens per payment. See OPENING_STATUS.md for the current test evidence.

Open **PETS** to buy Jelly (120 tokens), Slime (300), and Lava (700). Pebble is free. These are permanent, direct purchases using earned tokens: no Robux or random eggs. Equip one companion to follow your character. Owning a species adds it to your own guest rotation; Jelly/Slime/Lava guests pay an extra 2/5/10 tokens per payout. Owning pets does not add rooms or multiply every species' income.

## Saving and testing

- Press Play in the existing updated Studio session, or open the canonical `.rbxl` above.
- Studio progress deliberately resets on Stop. Live DataStores are used only in a published, non-Studio experience.
- Test claim → guest → first payout → construction stages → dirty room → manual cleaning → cleaner robot → shop and pet purchases.
- Use Studio's **Server & Clients** testing with four players. Confirm each has different ownership, rooms, token balances, pets, and cleaning state. Leaving must release only that player's plot. Test a fifth player waiting and receiving the freed plot.
- Live cloud saving, reconnects, and shutdown saves still require a published test experience. This development update has not been published to Roblox.

## Files and synchronization

`Alien Resort Tycoon.rbxl` contains the scene exported from the open Studio project, the new scripts, and `ServerStorage/Before_Multiplayer_2026_11_04` with the previous scripts. Existing geometry, old code archives, and the original empty terrain are retained. At runtime the old single resort is moved into ServerStorage; the new plots use the existing procedural architecture.

Do not use the earlier `Alien Resort Multiplayer.rbxlx` preview. Keep one current place file and commit matching source at major milestones. `SYNC_MANIFEST.json` records this saved file and source hashes. There is no background GitHub watcher: edits made later in Studio are not automatically pushed. Both collaborators must save/export, update source, verify, and commit together.

| Source | Studio location |
| --- | --- |
| `Bootstrap.server.luau` | ServerScriptService/AlienResort/Bootstrap (Script) |
| `GuidedHUD.client.luau` | StarterPlayer/StarterPlayerScripts/AlienResortHUD (LocalScript) |
| All other `src/*.luau` files | ServerScriptService/AlienResort/<filename without extension> (ModuleScript) |

Run `lune run tools/verify-sync.luau` from the repository root to compare every embedded active script to `src/`. Lune is only a development tool; the Roblox game does not depend on it. `tests/StudioSmoke.luau` runs isolated engine checks with a supplied module loader and test players; it is not a replacement for actual multi-client testing.

## Presentation and controls

The token wallet counts smoothly and celebrates earnings with a gold CHA-CHING banner, flying tokens, and a brief wallet pulse. FX Quiet reduces motion. Pet cards use actual animated 3D portraits of Pip, Juno, Sprout, and Ember; the same models appear in the world. Each has a personality, greeting, and different shape/accessories. Menus reflow for desktop, phone portrait, and short landscape screens.

Keyboard: **P** Pets, **B** Build, **M** Shop; **E** operates world prompts. Controller Y opens Pets and B closes menus. Visible buttons support touch and pointer input. Pet and shop purchases remain server validated.

Read `UI_UX_SPEC.md` for the art direction, color tokens, animation timings, and implementation rules. Read `PROJECT_STATUS.md` before changing shared code.

## 0.9.1 — Blender pets and review

The canonical place now embeds four Blender-authored MeshPart templates, shared by pets, guests, workers and collection portraits. Existing part animations and procedural fallback remain. First-open mesh preloading and bounded request/arena/landing-lock fixes are included. Read CODE_REVIEW.md for the all-source review, 174 imported-art checks, 77 fallback checks, validation limits and next priorities. Blender is only needed to edit art, not to run the game.

## 0.10.0 — smooth companions and polish

Read POLISH_STATUS.md for the implemented visual, UI and gameplay changes and their verification limits. Full assessment: GAME_ASSESSMENT.md.

## 0.10.1 — declutter and free props

Read DECLUTTER_STATUS.md for the stage-gated cafe, quieter world labels, Creator Store prop credits and compact icon HUD. art/WorldProps.rbxm is required for the curated props.

## 0.11.0 — Cosmic overhaul milestone

Read OVERHAUL_STATUS.md for implementation evidence and the outstanding acceptance gates from docs/OVERHAUL_BRIEF.md. The full overhaul remains in progress.

## 0.12.0 — alien biomes and floating hotel

ALIEN_WORLD_STATUS.md records the darker biome, alien plants/creatures, staged building silhouettes and unlockable Orbital Palace. Complete your Observatory to visit its sky deck.
