# Orbit & Oasis — UI and character direction

Current implementation: 0.8.0. Treat these as concrete instructions for future collaborators, not as permission to bypass server validation.

## Reference and identity

Reference the polished collectible presentation of [BIG Games' Pet Simulator games](https://www.biggames.io/games) and the character-focused world of [Uplift's Adopt Me](https://www.uplift.games/about). These are inspiration references. The following layout, characters, and timings are Orbit & Oasis design decisions, not claims about those games' internal UI specifications. Do not copy their assets or exact screens.

Aim for a small, welcoming space holiday: cream panels, deep navy text, mint teal, soft lilac, warm gold, and coral. Prioritize legibility and meaningful feedback over covering the screen with reward prompts.

## Design tokens

| Role | RGB | Usage |
| --- | --- | --- |
| Ink | 31,40,65 | Wallet, headings, active tab |
| Cream | 252,247,235 | Main modal surface |
| White | 255,255,255 | Cards and legible text on dark surfaces |
| Muted | 112,124,147 | Secondary descriptions |
| Teal | 59,208,181 | Equipped, completion, progress |
| Lilac | 177,147,239 | Pets navigation and gentle accents |
| Gold | 255,210,94 | Earned tokens and purchase action |
| Coral | 248,143,125 | Character accessories and warm accents |
| Soft | 240,243,250 | Inactive/insufficient-funds surfaces |

Use GothamBold for interface copy. Major headings 18–23 px, character names 18–22 px, actions 13 px, supporting text 11–12 px. Keep micro labels brief; don't convey locked/owned states by color alone. Panels use 14 px rounding; buttons 11 px; outlines 1 px with subtle contrast.

## Token wallet and earnings

- Upper-left wallet: at most 244×88 px; drawn token icon, RESORT TOKENS label, formatted total, occupied-room count and income per interval. On narrow screens reserve room for the FX button.
- Count from the displayed total to the authoritative token value over 0.35 seconds with Quad Out easing. Never animate by changing server money.
- Positive earned balance changes show **CHA-CHING! +N** in a gold banner. Keep it visible for 0.85 seconds, then fade over 0.3 seconds.
- Animate 4–8 drawn token chips along quadratic curves toward the wallet. Each flight lasts 0.7 seconds, staggered by 35 ms. Pulse the wallet from 1.06 scale back to 1 over 0.38 seconds.
- A quiet-effects toggle removes flying coins and wallet bounce and makes totals update immediately. Do not introduce camera shake or full-screen flashing. Keep the textual gain feedback.
- No guessed third-party sound IDs. The current cha-ching feedback is visual; approved sound design can be added later.

## Navigation and menus

- Keep the next-step guide visible during normal play. Show precise instructions and a cost-progress bar when there is a next purchase.
- One menu layer with Pets, Build, and Shop tabs. Dim the world behind it. Close by X, outside click, or controller B. Desktop shortcuts: P / B / M; controller Y opens Pets.
- Desktop uses a left navigation stack and up to four pet columns. Phone portrait uses a top navigation row and two pet columns where space permits. Menus scroll vertically.
- Short landscape screens use a compressed header and 184 px pet cards. Keep the character, name, benefit, and 44 px action visible; hide the biography in this compact view.
- Use CoreUISafeInsets and clip to the device safe area, preserving both device cutouts and Roblox core controls. Do not place navigation over mobile movement/jump controls.
- Interactive targets are at least 44×44 px. Hover/selection scales buttons to 1.025 over 0.12 seconds; press scales to 0.97 over 0.07 seconds.
- Pet states: unowned price, insufficient funds, owned/equip, equipped, claim-first, and pending. Shop states: price, owned, active countdown, claim-first, and pending. Clear pending state on server notice or a timeout.
- World build pads remain the authority for construction; the Build menu explains stage/prerequisite/cost and directs the player to the marker.

## The characters

| Character | Identity and silhouette | Personality and motion |
| --- | --- | --- |
| Pip / Pebble | Teal upright pebble, cream belly, gold antenna tips, lilac boots, coral explorer pack and badge | Curious and loyal. Blinks, breathes, swings small feet, wiggles antennae. “Adventure? I packed extra snacks!” |
| Juno / Jelly | Translucent lilac bell, glowing inner core, scalloped frill, hanging ribbons, little moon crown, round wonder-mouth | Gentle dreamer. Bell squashes lightly, ribbons sway, companion floats. “Every star has a wish. What is yours?” |
| Sprout / Slime | Wide lime blob, sprouting leaves, mud boots, coral scarf, leaf tail, cheeky grin | Playful and proudly muddy. Squashes, sways leaves, and bounces while following. “I found a puddle. Best day ever!” |
| Ember / Lava | Charcoal cub, warm belly, pointed flame ears, small wings, tiny tooth, curled tail with glowing tip | Brave and warm-hearted. Breathes, blinks, swings feet and tail. “Small paws. Big courage. Let us go!” |

Use the same `PetVisuals.Create` model for viewport portraits and in-world guests/companions. Never use an unrelated thumbnail that promises different art. Preserve recognizable silhouettes at companion scale. All character parts are noncolliding and nonqueryable.

Client-side expression/gait animation is cosmetic. Cap character construction at 36 direct children, animate world characters at 30 Hz only within 190 studs of the camera, and clean up preview models when rebuilding menu cards. The invisible gameplay pivot must not move during expression animation. Server-owned companion following is separate.

## Acceptance and remaining QA

Done: desktop collection and reward effect reviewed; iPhone 17 Pro landscape and portrait reviewed in Studio; compact landscape purchase button bounds checked; 69 engine checks passed; menu shortcuts validated; final console had no runtime errors. Studio returned to its default viewport.

Still required: physical phone touch behavior, gamepad focus/selection on console, tablet layouts, longer performance sessions, color/contrast accessibility review, and four simultaneous real clients. Do not describe a Studio simulator check as hardware certification. Keep the canonical place/source verification passing after any visual change.
