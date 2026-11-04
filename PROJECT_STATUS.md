# Alien Resort — shared project handoff

Updated: 4 November 2026 (Australia/Brisbane).

## Imported baseline

Repository: https://github.com/lefyanator/Alien-Resort

This milestone imports all 13 files from the user-supplied `Alien-Resort-Handoff (1).zip`, including the binary `Alien Resort Tycoon.rbxl`, nine editable Luau scripts, README, project bible, and sharing notes. Game files are preserved byte for byte. This is an upload milestone, not a completed bug-fix or gameplay audit milestone.

The repository previously contained only a short README. The imported README replaces that placeholder. Original Git history remains intact.

## Actual game state

The supplied source implements one shared resort per server, not separate multiplayer plots. It includes claiming, guest arrivals, income, staged construction, dirty rooms, cleaning, shop boosts, amenities, a robot avatar, and a Pebble alien collection entry. See README.md for source locations and controls.

`Orbit-Oasis-Multiplayer.zip` was not supplied or found. Do not replace any newer multiplayer implementation with this baseline. Compare and merge it first when it becomes available, preserving independent ownership, guests, economy, cleaning, and progression for each plot.

The supplied .rbxl is preserved as received. Its embedded scripts have not been verified against src/. An earlier inspection of the connected Studio showed older scripts and no ProgressStore module; that open Studio session was not modified. Do not assume the open Studio, binary place, and editable source are synchronized.

## Two collaborators and their ChatGPTs

- Both collaborators use this repository as shared history and read this file plus PROJECT_BIBLE.md before editing.
- Pull/read the latest branch before changes. Use separate feature branches and review overlapping work before merging. Do not overwrite another collaborator's newer files.
- Coordinate who edits scripts and who edits the binary place. Binary .rbxl files cannot be merged like text; avoid simultaneous independent edits to the same place file.
- Commit and push major milestones with descriptive messages; update this handoff with changed files, validation, known gaps, and the next task.
- After source edits, sync the scripts to the Studio locations listed in README.md, save the place, and commit the corresponding binary when appropriate.
- Each person uses their own GitHub and Roblox account. Repository access and Roblox Team Create access are separate. The second collaborator's username/access has not been verified. The owner manages GitHub access at https://github.com/lefyanator/Alien-Resort/settings/access and Roblox collaboration permissions in Studio/Creator Dashboard.
- ChatGPTs share context through committed files; they do not automatically share chat history.

## Open and test

1. Download the repository ZIP from GitHub (Code → Download ZIP), extract it, and open `Alien Resort Tycoon.rbxl` in Roblox Studio.
2. Before using the editable source as the baseline, copy all nine files to their matching Script/ModuleScript/LocalScript locations in README.md. Create ProgressStore as a ModuleScript if missing. Save a separate place copy first.
3. Press Play. Claim the terminal, wait for a guest and token payout, buy all three construction stages for a building, clean a dirty room, and test permanent items and timed boosts. Check Output for errors.
4. Stop and play again: this source deliberately resets progress in Studio. Cloud DataStore load/save must be tested separately in a published live test experience.
5. Use Studio's local server/client testing with multiple players to verify that non-owners cannot build, buy, or clean the owner's resort, and that leaving releases the resort. Separate personal plots are not implemented in this supplied version.

## Validation and remaining work

- ZIP extracted and all 13 supplied files inventoried; binary and source uploaded without rewriting their contents.
- GitHub upload must be verified against the resulting commit's file tree and Git blob hashes.
- No Studio gameplay, four-player plot isolation, mobile layout, or live persistence tests were run for this import. The previous audit was stopped before any fixes were made.
- Review profile load/readiness and leave-during-load handling, save lock lifecycle, prompt hold validation, guest-loop error recovery, UI on phones, and synchronization between source and place before treating the game as production ready.
- Additional species, personal plots, Robux products, and deeper progression remain future work; do not describe them as shipped.
