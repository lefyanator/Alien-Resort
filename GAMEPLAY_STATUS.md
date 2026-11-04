# Cosmic Commons — gameplay prototype 0.9.0

Promise: **Build your alien's dream resort, discover its abilities, and adventure together to evolve it.** This milestone implements the first playable version of that loop in the existing Studio project. It does not establish that the game is fun or production ready.

## Play and rewards

Claim your plot. Use its gold shuttle or the ADVENTURE drawer to travel to Cosmic Commons. The drawer also has Return Home, Use Pet Ability, Evolve at Lab, request/delivery, and pet job controls. World activities use hold prompts. All rewards and interactions are server validated.

| Activity | Current rules and purpose |
| --- | --- |
| Training | Visit checkpoints 1–5 in order with the same pet. Minimum course time 10 seconds. Awards 15 tokens and 2 shards; reward cooldown 90 seconds. |
| Cooperative rescue | Repair three different consoles on the stranded shuttle. Multiple players can contribute; one player can also finish all three. Eligible contributors receive 20 tokens and 3 shards. Rescue cycle and reward cooldown 90 seconds. |
| Pip's treasure | Equip Pebble and use its scan station to highlight deposits. Excavate each deposit for 8 tokens and 1 shard, with a separate 180-second cooldown per deposit. Evolved Pip doubles treasure tokens. |
| Guest request | Finish reception, accept at your own terminal using the drawer, finish a training run with the requested pet, and return to deliver. Awards 12 tokens and 1 shard. |
| Cafe service | Finish the cafe and interact with the serving counter on your own plot. Awards 8 tokens and 1 shard, with a 90-second cooldown. This is a simple serving interaction, not a complete cooking minigame. |
| Observatory | Completed observatory provides a clue pointing to the Commons treasure deposits. It is a clue interaction, not a separate expedition map. |

Pet abilities operate at matching Commons stations, with a 12-second ability cooldown. They are disabled inside capture matches for fairness in this first prototype. Pip highlights treasure; Juno creates a temporary launch pad; Sprout restores the garden; Ember lights the beacon. Non-Pip ability token/shard rewards have a separate 90-second cooldown. Evolution adds a star halo and a stronger launch or activity reward; it does not improve capture combat.

Bonding advances through activities and jobs. Evolution costs 20 Star Shards plus 30 bonding with the equipped pet, and must happen at the Evolution Lab. Evolution is permanent per species. There are no hunger/neglect penalties, random eggs, Robux costs, or exclusive PvP-only evolutions.

## Jobs

Own another pet, equip a different companion, and use its WORK / REST button. Only one job assignment is active. Equipping the worker clears its assignment. Jobs spawn a visible pet worker at the relevant facility; the assignment is session-only, while earned bond/progress is saved.

- Pip: requires reception; earns small luggage/tip-job rewards.
- Juno: requires lounge; earns job rewards and adds 2 tokens per guest payout while assigned.
- Sprout: requires purchased garden; periodically cleans one dirty room and earns job rewards.
- Ember: requires cafe; earns job rewards and adds 3 tokens per guest payout while assigned.

Jobs run every 60 seconds for 3 tokens and 1 bond point. These are an early server-timed job implementation, not full pathfinding work routines, guest-performance animations, or a detailed luggage system.

## Starcore Capture prototype

Join/leave at the arena queue pad. Two queued players start 1v1; four queued together start 2v2. Players can train/rescue while waiting. Rounds last 180 seconds. Take the enemy Starcore and use the home base prompt to capture it; your own core must be home. Carried cores visibly follow runners. Returned/dropped cores and captures are server-owned.

Tag enemies with the close-range tag prompt. Server checks distance and line of sight. Tagged players return to base with four seconds of protection. There are no weapons, long stuns, or paid power advantages; Turbo and pet abilities cannot improve arena movement. Dropped cores return after 15 seconds. Captures have a 12-second global cooldown. Death, out-of-bounds movement, leaving, team disconnects, and round timeout have cleanup paths.

Only players with contributions in a round lasting at least 45 seconds receive rewards. Winners receive 30 tokens and 4 shards; eligible other participants receive 15 tokens and 2 shards. Ties use participation rewards. These are prototype anti-idle/rapid-capture checks, not a complete anti-exploit system. A single player gets a queue message and can play solo activities instead of being forced to wait.

## Technical and save handoff

- AdventureService owns Commons geometry, server interaction state, cooldowns, jobs, rescue, queue, and arena lifecycle. CaptureRules centralizes pure capture invariants. PlotService still owns each private resort.
- Plot spacing is now 360 studs to leave space for the shared central island. Shuttles connect plots rather than physical bridges through buildings.
- ProgressStore retains the existing DataStore/key names and migrates to schema version 3: StarShards, per-species Bond and Evolved fields. Old profiles default these safely. No live cloud data was accessed in Studio.
- The UI drawer reads server attributes; it cannot set reward amounts or ownership. All token changes continue to use the existing wallet feedback.
- Native Studio scene export was used to save the same canonical place file. Source and binary verification must stay passing. No background GitHub sync or Roblox live publication is implied.

## Validation and remaining work

Completed: 77 isolated Roblox-engine checks, including plot isolation, existing systems, character budget/pivots, capture eligibility invariants, and adventure save defaults/migration. All 15 source files compiled. Live single-player Studio checks confirmed claiming, Commons travel, ordered checkpoint progression (15 tokens/2 shards), cooperative rescue completed solo (20 tokens/3 shards), Pip scan, insufficient-progress evolution rejection, and successful evolution with temporary Studio-only fixture progress (20-shard debit and halo).

Training checks used scripted repositioning to exercise prompt and reward logic. They do not prove the traversal course feels good. Multi-player rescue contribution replication, actual 1v1/2v2 matches, tag interactions, team departures, balance, job timing, all four abilities on real devices, and published save/rejoin/shutdown need additional playtests. No human playtest has established retention or fun.

The Commons is a simple original-parts prototype with landmarks, shuttle, training pads, arena cover, and readable entrances. Next priorities: real two-player arena QA and fixes; physical traversal playtest; tighter objective feedback; a deeper rescue/serving activity; then final scenery, sound, animation, and mobile control QA. Pet combat abilities in capture, dynamic pathfinding jobs, hidden paths, and larger expedition maps remain future work. Do not describe those as finished.
