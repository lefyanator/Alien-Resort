# Alien Resort — Orbit & Oasis

**Current version: 0.7.0. Open `Alien Resort Tycoon.rbxl` in Roblox Studio and press Play.** This is the single canonical game file. Source in `src/` matches its embedded scripts. Islands are generated when the server starts.

## Play

Each player is assigned one of four independent floating islands. Hold **E**, use the controller prompt, or tap/hold the touch prompt at your own terminal to claim it. Your free Pebble guest arrives by UFO and earns tokens. Build six upgrades in three stages, clean dirty rooms, and buy permanent amenities or timed boosts. The fifth player waits for a plot to become free.

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

Read `PROJECT_STATUS.md` before changing shared code.
