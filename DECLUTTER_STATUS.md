# 0.10.1 — declutter and Creator Store props

Implemented 2026-11-05 after the user's player-height screenshot exposed clutter and a floating cafe service interaction.

- Removed the separate CafeServing part. Serving is a prompt on the cafe's actual ServiceCounter and remains disabled until construction stage 3. Observatory clue prompts follow the same construction gate; stage reset disables them.
- Removed floating build billboards and hid unavailable build pads. One globally exclusive proximity prompt appears at a time. Room payout labels only appear nearby for occupied rooms; the next-step marker is smaller.
- Replaced the enormous entrance sign with a low, small name plaque. Moved shuttle to its own arrival-side location and shortened its nearby caption. Removed repeated luggage/bench/crystal clusters and most repeated palms/lamps.
- Added six curated static templates in ServerStorage/WorldProps, exported as art/WorldProps.rbxm: three natural-colour palms, a bush, chair and cafe table. Palm variation/rotation is deterministic; colours/materials are preserved. Fewer clusters leave open movement space.
- Cafe uses warm wood accents and roof trim; reception has an open facade. Commons no longer repeats the same four activity canopies.
- Cafe terrace tables and chairs sit on the ground beside the building, within the circular island and outside the cafe wall. Bedroom chairs use the same sourced furniture.
- HUD navigation is circular with drawn paw/hammer/bag/compass icons and labels. Wallet and objective are compact capsules with bold heading, instead of large rectangular panels. Gain popups now sit below the main view.
- Rebuild includes the prop bundle; verification checks attribution and static noncolliding templates. No new gameplay module, watcher or paid asset.

## Free asset credits

- [Low-Poly Palm Trees Asset Pack](https://create.roblox.com/store/asset/8556183988), Cliosow. Three variants retained; authored mesh colours preserved.
- [Cafe Furniture Pack I](https://create.roblox.com/store/asset/4454775652), ImaRaygun. Chair and square table retained, rescaled. Pack description permits use without credit and asks that users not claim authorship; credited here.
- [Low Poly Bush](https://create.roblox.com/store/asset/7191673673), ChickenNuggets2go.

All were returned as free Creator Store assets by Studio search. Imported to ServerStorage, inspected, then copied only selected static models. No scripts retained. Removed package/camera/constraint extras; seats disabled; all parts anchored and noncolliding/nontouching/nonqueryable. There are no runtime Creator Store downloads. Existing mesh dependencies must remain accessible to the published experience.

## Verification

- 183 isolated engine assertions passed, including prompt visibility/enabling at all four build stages.
- All 15 scripts compile and canonical place/source/template/prop verification passes.
- Live all-four-plot check: zero visible cafe parts before construction, no legacy floating CafeServing part, serving prompt disabled.
- Live staged purchase fixture: serving stays disabled through stage 2 and enables at stage 3.
- Imported scene preload: 130 content callbacks, zero failures in this Studio session.
- Actual cafe/arrival screenshots reviewed at player height. A visual check caught furniture at the rim, then a geometry check verified all six terrace models grounded at Y=5.35, inside radius 63 and clear of the cafe wall.
- HUD main-control overlap checks at 360x800, 800x360, 1280x720 and 1920x1080: no overlaps. These are simulated safe areas, not physical-device certification.
- Temporary test currency/buildings discarded on Stop; Studio left in Edit. No Roblox cloud publication.

Remaining gates from POLISH_STATUS.md still apply: actual multiplayer, published persistence and physical phone/controller/performance testing. This change resolves the reported clutter/stage bug and upgrades the prop/HUD treatment; it does not claim every building is finished art.
