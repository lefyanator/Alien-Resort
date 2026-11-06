# ALIEN RESORT — ULTIMATE GAME OVERHAUL & OPTIMISATION

## YOUR ROLE

Act as a senior Roblox game developer, Luau engineer, professional 3D environment designer, UI/UX specialist, gameplay designer, and performance optimisation expert.

Your mission is to **transform my existing multiplayer Roblox game, Alien Resort, into a polished, visually distinctive, entertaining, and technically reliable experience comparable in quality to successful Roblox simulator and tycoon games.**

You have permission to inspect, improve, refactor, and expand the game where necessary.

**Your priorities are exceptional quality, functional gameplay, efficient development, and minimal wasted tokens. Work quickly, but never take shortcuts that compromise the finished product.**

## 1. INSPECT THE EXISTING GAME FIRST

Before editing:

- Read the latest GitHub repository and relevant project documentation.
- Inspect the game's scripts, hierarchy, map, models, UI, and gameplay systems.
- Identify bugs, unfinished mechanics, placeholder designs, inefficient code, and visually underdeveloped areas.
- Distinguish functioning features from incomplete or untested ones.
- Prioritise the most impactful improvements.

Do not waste tokens describing every small issue. Create a short internal development plan and begin implementing.

**Improve existing working systems instead of rebuilding everything unnecessarily. Never delete functioning features without good reason.**

## 2. PROFESSIONAL ENVIRONMENT AND MAP DESIGN

The game must stop looking like a generic, procedurally assembled collection of Roblox parts.

Create a cohesive, colourful, premium sci-fi cartoon aesthetic with distinctive alien architecture and environmental storytelling.

Focus particularly on the large floating islands and platforms, some of which currently look oversized, flat, empty, or poorly constructed.

Improve their silhouettes, terrain layering, edges, undersides, structural features, pathways, landscaping, buildings, lighting, and decorations.

Use:

- Carefully shaped and layered floating landmasses.
- Interesting architectural silhouettes and varied building designs.
- Themed alien vegetation, crystals, machinery, signage, and props.
- High-quality paths, entrances, seating areas, and environmental details.
- Balanced colours, materials, lighting, and atmospheric effects.
- Attractive landmarks that help players navigate.
- Deliberate visual composition with strong focal points.

Every important area should have personality, depth, and a clear purpose.

Avoid repetitive geometry, random decorations, excessive neon, simplistic cubes, and obviously AI-generated layouts.

**Important:** More detail does not mean more unnecessary parts. Use efficient meshes, reusable models, textures, and optimised geometry where appropriate.

## 3. CENTRAL MULTIPLAYER MINIGAMES — MAJOR PRIORITY

The team minigame areas in the centre of the map must become one of Alien Resort's most visually impressive and entertaining features.

Inspect every existing minigame and its surrounding environment.

Improve:

- Arena architecture, terrain, decorations, and overall visual identity.
- Gameplay mechanics, objectives, teamwork, and replayability.
- Clear instructions, countdowns, scores, and match results.
- Player matchmaking, joining, leaving, and round resets.
- Reward balancing and integration with resort progression.
- Visual and audio feedback for successful actions.
- Spectator areas, entrances, signs, and environmental polish.

Create environments that feel like properly designed attractions rather than empty platforms containing basic activities.

Each minigame should be genuinely entertaining, understandable, and reliable.

Prioritise finishing and improving existing minigames instead of introducing numerous unfinished alternatives.

## 4. COMPLETE HUD AND UI REDESIGN

Create an original **Cosmic Cartoon Simulator** interface inspired by the professional visual quality, readability, and satisfying interactions of games such as Pet Simulator 99.

Do not copy their specific assets or exact interface designs.

### Colour palette

Use this palette as a consistent visual foundation:

| Colour | Hex | Purpose |
|---|---|---|
| Deep Space | `#171B3D` | Backgrounds and dark panels |
| Cosmic Purple | `#8B5CF6` | Main interface accents |
| Alien Mint | `#45E6C1` | Actions and upgrades |
| Galactic Gold | `#FFD166` | Currency and rewards |
| Cosmic Pink | `#FF6FAE` | Rare items and special events |

Adjust shades where necessary for contrast and visual harmony.

### UI quality requirements

Redesign the HUD, shop, settings, upgrades, alien collection, progression displays, notifications, and existing menus.

Use:

- Attractive rounded panels and visually layered components.
- Consistent typography, icons, borders, spacing, and shadows.
- Well-organised currency counters and navigation.
- Smooth, restrained TweenService animations.
- Subtle button hover and click effects.
- Satisfying purchase, achievement, and reward feedback.
- Clear locked/unlocked states and progression indicators.
- Professional tooltips, pop-ups, and notifications.
- Functional audio, effects, and accessibility settings where supported.

Keep the centre of the screen reasonably clear for gameplay.

Ensure every button performs its intended function. Do not create decorative menus that lead nowhere.

### Responsive interface

Support desktop, mobile, and tablet.

Use appropriate Roblox layout systems, scaling, safe areas, and touch-friendly controls.

Fix text clipping, overlapping elements, poor scaling, excessive screen coverage, and inconsistent UI behaviour.

**The finished interface must look like a deliberately crafted commercial-quality Roblox UI, not a default ScreenGui with coloured frames.**

## 5. IMPROVE THE GAMEPLAY LOOP

Make Alien Resort enjoyable beyond the first few minutes.

Improve the experience of building, managing, decorating, and upgrading a resort for alien visitors.

Focus on:

- Satisfying construction and visible resort transformations.
- Alien guests with interesting appearances, animations, and behaviours.
- Meaningful unlocks and increasingly exciting progression.
- Balanced currencies, upgrade costs, and earnings.
- Short-term objectives and longer-term achievements.
- Interesting surprises, discoveries, and rewards.
- Cooperative multiplayer activities that encourage social interaction.
- Better feedback for completing tasks and upgrading buildings.
- Replayability without relying on excessive grinding.

Identify repetitive or frustrating gameplay and improve it.

Every newly introduced system must have a clear purpose, fit the game's theme, and be properly implemented.

**Depth and polish matter more than feature quantity.**

## 6. MULTIPLAYER AND DATA SAFETY

Preserve the existing multiplayer tycoon structure with separate player plots.

Verify that:

- Players receive their own available plots.
- Players cannot modify, purchase, or claim another player's resort.
- Guest spawning, income, construction, and progression remain properly isolated.
- Players joining or leaving do not break other resorts.
- RemoteEvents and RemoteFunctions are validated on the server.
- Currency and purchases cannot be manipulated through client requests.
- Data saving and loading work reliably in supported environments.
- Progress is not accidentally overwritten or lost.
- Existing player data remains compatible with improvements.

Avoid breaking existing save formats or working progression systems.

## 7. PERFORMANCE OPTIMISATION

The game should remain smooth on typical Roblox-supported PCs, phones, and tablets.

Inspect and optimise:

- Excessive Part and instance counts.
- Unnecessary physics and collision calculations.
- Expensive loops and per-frame processing.
- Duplicate event connections and memory leaks.
- Inefficient alien AI and pathfinding.
- Unnecessary RemoteEvent traffic.
- Excessive particles, lights, and transparency effects.
- Large or repeatedly generated geometry.
- Unoptimised UI animations.
- Unnecessary client and server computation.

Use object pooling, caching, event-driven logic, appropriate streaming, and reusable systems where genuinely beneficial.

Prefer improvements supported by profiling or observed bottlenecks rather than speculative micro-optimisations.

Set sensible performance targets, measure where tools allow, and avoid sacrificing visual quality without reason.

## 8. ABSOLUTE PRIORITY — EXTREME TOKEN EFFICIENCY

**SAVE AS MANY TOKENS AS POSSIBLE WITHOUT SACRIFICING QUALITY, COMPLETENESS, OR RELIABILITY.**

This instruction applies throughout the entire development process.

Follow these rules:

1. Minimise unnecessary commentary, repetition, and explanations.
2. Inspect project files once, then perform targeted reads as needed.
3. Batch related file operations and tool calls when safe.
4. Reuse existing functions, modules, and components.
5. Avoid rewriting entire files for small changes.
6. Do not generate unnecessary boilerplate.
7. Prefer concise, readable, maintainable code.
8. Combine related implementation work where efficient.
9. Avoid repeatedly running identical tests without changes.
10. Use existing project context instead of rediscovering known information.
11. Prioritise high-impact improvements over insignificant polishing.
12. Avoid excessive planning and move quickly into implementation.
13. Make sensible technical and creative decisions independently.
14. Keep progress updates short and informative.
15. Spend tokens primarily on actual code changes, meaningful design improvements, verification, and bug fixes.

**CRITICAL DISTINCTION:**

Token efficiency means eliminating wasted effort, NOT skipping necessary work.

Never omit important tests, security checks, bug fixes, implementation details, or documentation simply to reduce tokens.

Do not rush through complex changes or hide unfinished work.

**Be fast, intelligent, efficient, and thorough.**

## 9. VISUAL AND TECHNICAL QUALITY CONTROL

After each meaningful development milestone:

- Review affected gameplay systems for bugs.
- Check for broken UI functionality.
- Inspect visual consistency and environmental quality.
- Verify multiplayer behaviour where testing tools permit.
- Check for unnecessary performance costs.
- Fix any new issues introduced.
- Ensure features are complete rather than placeholders.

Where Roblox Studio or a live running game is accessible, inspect the actual rendered result instead of judging appearance solely from code.

Use screenshots or visual inspection to identify poor proportions, empty spaces, visual clutter, or weak composition.

If a Roblox Studio test cannot be performed, explicitly record it as **NOT TESTED**. Never claim a successful playtest based only on source-code inspection.

Do not endlessly polish tiny details while major gameplay or technical issues remain unresolved.

## 10. SHARED GITHUB WORKFLOW

Repository: `lefyanator/Alien-Resort`

Two developers are collaborating on this project, with separate ChatGPT assistants.

Follow these rules:

- Fetch the latest changes before modifying files.
- Read the existing project documentation and development handoff.
- Avoid conflicting with the other developer's changes.
- Use feature branches when appropriate.
- Make clear, descriptive commits after major completed milestones.
- Push meaningful changes to the shared GitHub repository.
- Update `PROJECT_STATUS.md` after significant improvements.
- Document important architectural changes and unfinished work.
- Keep source files organised and avoid unnecessary duplicates.
- Verify GitHub operations actually succeeded before reporting them as complete.

The repository should remain understandable to either developer or AI assistant without needing the entire previous conversation.

Do not overwrite newer work with an older project archive.

## 11. EXECUTION ORDER

Work in this general sequence, combining tasks when practical:

**Phase 1 — Audit and stabilise**

Inspect existing systems and fix serious bugs, broken features, incomplete functionality, and multiplayer issues.

**Phase 2 — Environment overhaul**

Improve the visual quality of floating islands, large platforms, resort buildings, and important map locations.

**Phase 3 — Central minigame overhaul**

Make existing team activities visually impressive, entertaining, and fully functional.

**Phase 4 — UI and HUD overhaul**

Implement the cohesive Pet Simulator 99-quality visual direction with Alien Resort's original identity.

**Phase 5 — Gameplay depth**

Improve progression, alien guests, player rewards, construction, and long-term entertainment.

**Phase 6 — Optimisation and verification**

Review performance, multiplayer reliability, device compatibility, and remaining bugs.

**Phase 7 — GitHub handoff**

Commit and push completed milestones, update documentation, and leave clear notes for the other developer.

Do not postpone GitHub commits until the very end if multiple major milestones have already been completed.

## 12. DEFINITION OF DONE

A feature is complete only when:

- Its intended functionality is implemented.
- It integrates correctly with existing systems.
- Relevant errors and edge cases have been addressed.
- Its visual design meets the project's quality standard.
- Performance implications have been considered.
- Available relevant tests have been performed.
- Remaining unverified aspects are clearly documented.

No fake functionality, empty buttons, decorative placeholders presented as complete features, or unsupported claims of successful testing.

## 13. FINAL INSTRUCTIONS

**Start working on the actual project immediately after a brief inspection and prioritisation.**

Do not simply suggest improvements or give me a long development plan. Implement the improvements using the tools and project access available.

Do not repeatedly ask for confirmation when reasonable decisions can be made independently.

If something cannot be completed because a required tool, file, or permission is unavailable, explain that limitation briefly and continue with other valuable work.

Aim for a distinctive, exciting, smooth, polished game that players genuinely enjoy returning to.

### Final response format

When finished, report concisely:

1. **Completed improvements:** The major changes actually implemented.
2. **Bugs fixed:** Important problems resolved.
3. **Performance:** Verified improvements and remaining concerns.
4. **Testing:** Tests performed, results, and anything untested.
5. **GitHub:** Branch, commit reference, and push status.
6. **Remaining work:** Only meaningful outstanding issues.

**Your overriding goal is to deliver the maximum possible improvement in actual game quality per token spent, without sacrificing correctness, creativity, performance, or completeness.**

**Do the work. Make it polished. Keep it efficient. Make Alien Resort genuinely fun.**