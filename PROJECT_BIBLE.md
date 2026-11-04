# PROJECT BIBLE — Alien Resort Tycoon

Paste this file into another ChatGPT/Codex session before editing. Do not dump the whole Obsidian vault unless asked.

## Pitch

Cute space-motel tycoon. Brand: **Orbit & Oasis**. Player claims a floating island, aliens visit, occupied rooms pay **tokens**, visible upgrades grow the resort. Style: toy sci-fi, teal / lilac / cream / coral, Fredoka UI. Mobile-first later; prototype is Studio/desktop.

Working place: `Alien Resort Tycoon.rbxl`  
Owner notes: `Documents/Obsidian Vault/Alien Resort Tycoon/`  
Editable code: `src/` (source of truth). Studio place must be saved after code paste.

## Loop that is implemented

claim → UFO / Pebble guest → occupancy payout (10s) → 18 construction stages on 6 buildings → dirty rooms → clean or cleaner bot → shop boosts/amenities → robot avatar.

First-island design still **planned** but not built: four personal plots, slime/jelly/lava species, goo pool / float lounge / thermal spa as species unlocks, Robux shop, published DataStore playtests.

## Authority

Server owns tokens, stages, shop grants, occupancy, dirty state, and saves. Clients request shop buys via `ReplicatedStorage.ResortShop` and only display pads/HUD. Never trust the client for prices.

`ProgressStore`: DataStore `OrbitOasis_Progress_v1` **only when published and not Studio**. Studio shows `TEST SESSION - progress resets`. Load uses a short lock; failed load/save kicks rather than writing a blank profile.

## Config (do not scatter prices)

See `src/Config.luau`. Stage prices: 20% / 30% / remainder of each upgrade total. Shop: Cleaner 80, Turbo 15/60s, Foam 15/90s, Beacon 25/90s, Garden 70 (+2 payout), Tables 90 (+3 payout). Boosts cannot stack while active; permanents cannot be bought twice (restore path may re-apply cosmetics).

## Files to edit

- `Config.luau` — numbers and copy
- `Geometry.luau` / `Expansion.luau` — island and buildings
- `ResortService.luau` — claim, guests, income, build pads
- `ResortExtras.luau` — stages, cleaning, shop, robot, cleaner hop
- `ProgressStore.luau` — load/save
- `GuidedHUD.client.luau` + `SimulatorTheme.luau` — UI
- `Bootstrap.server.luau` — start

Do not revive `archive/HUD.client.luau` or `archive/spent-patches/*.py`.

## Current prototype rules

- One shared island. First nearby claimer is owner until they leave (`S.Reset`).
- Claim requires `ProfileReady` and distance to the terminal.
- Buildings stay hidden until their stage; rooms do not operate until Furnish & open (stage 3).
- North rooms walk around the landing pad (z > 50).
- Currency copy is **tokens**, never credits.

## Do / don't for a second ChatGPT

Do: keep server validation, keep Studio vs live save distinction, sync `src/` into Studio, version the `.rbxl` before large edits.  
Don't: add Robux product IDs until the owner creates them; don't spend Forge credits without asking; don't implement rebirth/PvP/trading; don't log into the owner's Roblox account; don't assume two AIs share a live chat.

## Roblox collaboration

The place owner adds the friend under **Team Create** / experience permissions. The friend opens that place in Studio. Share this bible + `src/` + current `.rbxl`. Passwords and cookies are never part of the workflow.

## Sensible next work (priority)

1. Paste updated `src/` into an open Studio session and Ctrl+S.
2. User playtest of claim → first payout → first stage → dirty room.
3. Independent plots (design Phase 2) only after that playtest.
4. Extra species after plots/saving feel right.
