# Alien Resort Tycoon (Orbit & Oasis)

Open `Alien Resort Tycoon.rbxl` in Roblox Studio and press Play. Hold **E** (or the touch prompt) at the glowing terminal to claim the free resort. Follow the guide: guests arrive by UFO, occupied rooms pay **tokens**, rooms get dirty, then buy staged buildings and shop items.

This is a **single shared prototype resort**. Progress is **session-only in Studio**. Cloud saving exists in code but only runs on a **published live place** (`GameId ~= 0` and not Studio).

## Current loop (v0.6 source)

- Currency: Tokens (leaderstats).
- Free starter room funds early construction.
- Six buildings, each with Foundation / Structure / Furnish & open (20% / 30% / 50% of the listed total).
- Totals: Moon Pod 30, Star Reception 60, Cosmic Snacks 100, Aurora Suite 180, Stargazer Lounge 280, Observatory 420.
- Occupied rooms pay every 10 seconds. Snacks +5, lounge +5, observatory +10, garden +2, cafe terrace +3.
- After a stay, rooms are dirty until cleaned (hold prompt, +3 tokens). Cleaner robot automates this.
- Shop: cleaner, turbo, foam, guest beacon, moon garden, cafe terrace.
- Collection book: Pebble alien only. Players appear as a simple robot suit.

## Source of truth

Editable Luau is in `src/`. After changing it, paste/sync the matching ModuleScripts and LocalScript into Studio and save the place (`Ctrl+S`). Disk `.rbxl` does not auto-update from `src/`.

| File | Studio location |
| --- | --- |
| `src/Config.luau` | ServerScriptService/AlienResort/Config |
| `src/Bootstrap.server.luau` | ServerScriptService/AlienResort/Bootstrap |
| `src/Geometry.luau` | ServerScriptService/AlienResort/Geometry |
| `src/Expansion.luau` | ServerScriptService/AlienResort/Expansion |
| `src/ResortService.luau` | ServerScriptService/AlienResort/ResortService |
| `src/ResortExtras.luau` | ServerScriptService/AlienResort/ResortExtras |
| `src/ProgressStore.luau` | ServerScriptService/AlienResort/ProgressStore |
| `src/SimulatorTheme.luau` | ServerScriptService/AlienResort/SimulatorTheme (cloned to ReplicatedStorage) |
| `src/GuidedHUD.client.luau` | StarterPlayer/StarterPlayerScripts/AlienResortHUD |

`archive/` holds the old v0.1 HUD and one-off Python patchers. Do not run those scripts. Versioned places stay in `backups/`.

## Limitations (do not treat as shipped)

One plot per server; first claimer owns it until they leave. No four-plot multiplayer, no extra species, no Robux products, no Forge meshes, no phone-device playtest. Guest and cleaner motion are waypoint tweens, not pathfinding.

## Friend / other ChatGPT

Send `HANDOFF/Alien-Resort-Handoff.zip` plus `PROJECT_BIBLE.md`. Two ChatGPT accounts cannot talk to each other. Collaborate with **Team Create** on the Roblox experience you own; do not share account passwords.
