Current gameplay version: 0.9.1. Read GAMEPLAY_STATUS.md before editing AdventureService or CaptureRules. Preserve separate plot state and server-owned reward checks.

# Alien Resort project bible

Cute space resort tycoon, branded **Orbit & Oasis**. Four personal floating islands, token income from alien guests, staged construction, cleaning, amenities, and permanent alien pets. The current visual pass is 0.8.0; follow UI_UX_SPEC.md for presentation and character rules.

Read `PROJECT_STATUS.md` for the current implementation, verification, and remaining work. `README.md` explains how to play and test. The old single-resort handoff is superseded.

## Rules

- One canonical game file: `Alien Resort Tycoon.rbxl`. Keep its active scripts identical to `src/` at every major GitHub update.
- Each player has separate ownership, construction, pet inventory, room occupancy, economy, cosmetics, and cleanup jobs. All gameplay authority stays on the server.
- Keep existing progress in DataStore `OrbitOasis_Progress_v1`, key `Player_<UserId>`. Studio is session-only. Never overwrite a failed profile load with default data.
- Pets are direct token purchases, not Robux or random eggs. Pebble is free; additional species must be bought. One pet companion can be equipped. Owned species become paying visitors to that owner's resort.
- Preserve the robot avatar, staged buildings, north promenade, guest arrivals, dirty rooms, cleaner and existing amenities.
- Both collaborators and their ChatGPTs read the latest GitHub handoff and coordinate before changing the same place. Commit significant milestones and keep validation claims honest.

Future work should prioritize actual multi-client and published persistence validation, mobile UI, guest animation and pathing, and progression depth. Extra features are not considered shipped until tested.

Current maintenance milestone: 0.9.1 (Blender templates and source review). Read CODE_REVIEW.md before overlapping edits. Preserve ReplicatedStorage/PetTemplates and art/PetTemplates.rbxm along with all 15 source files; shared pet mesh is rbxassetid://134081985420522. Obsidian is no longer part of the save workflow.
