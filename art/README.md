# Blender pet art — first pass

Open Alien-Resort-Pets.blend in Blender. The gallery contains Pip (Pebble), Juno (Jelly), Sprout (Slime), and Ember (Lava), with separate named mesh parts and coloured materials. Each FBX contains only its pet, centred at the origin, exported before gallery placement. build_pets.py reproduces the scene and exports using Blender 5.2.

These are static concept meshes, not rigged or imported Roblox assets. Material colours have not been verified through Roblox's importer. There are no texture atlases, animation clips, or Roblox asset IDs yet. The existing game and its procedural animated pets remain the current playable version.

Integration handoff: import one FBX into the existing Studio place, verify dimensions/forward direction/material colours, set noncolliding anchored visuals, and preserve SpeciesId and the CharacterRoot pivot. PetVisuals.Create must clone imported templates for both world pets and menu portraits. Existing RestOffset/RestSize/Motion attributes must be mapped onto imported parts before PetVisuals.Animate can animate them. Preserve the procedural fallback until all four imports pass desktop/mobile checks. Store templates in ReplicatedStorage; do not replace runtime Workspace pets directly because the game regenerates them.

Next art work: texture atlas and mesh consolidation, articulation/animation preparation, evolved variants, UFO and Commons landmark redesign, then two-player performance/plot isolation testing. Blender source changes do not automatically sync into Studio or GitHub.
