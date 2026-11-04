# Blender pet art — integrated 0.9.1

Open Alien-Resort-Pets.blend in Blender. The gallery contains Pip (Pebble), Juno (Jelly), Sprout (Slime), and Ember (Lava), with separate named mesh parts and coloured materials. Each FBX contains only its pet, centred at the origin, exported before gallery placement. build_pets.py reproduces the scene and exports using Blender 5.2.

Next art work: texture atlas and mesh consolidation, articulation/animation preparation, evolved variants, UFO and Commons landmark redesign, then two-player performance/plot isolation testing. Blender source changes do not automatically sync into Studio or GitHub.

## Integrated 0.9.1

The four authored Blender shapes are now installed as animated MeshPart templates in ReplicatedStorage/PetTemplates and exported to art/PetTemplates.rbxm. PetVisuals uses them for world pets, visitors, jobs and portraits, with the previous procedural models as fallback. No skeletal rigs or FBX clips were added: the existing part animations drive blink, breathing, feet and accessories.

Reproduce with Blender --background art/Alien-Resort-Pets.blend --python art/export_roblox.py. This writes roblox-pets.json and a one-stud PetSurface.obj. The script verifies that every authored part shares that sphere topology before reusing it. The imported shared mesh is rbxassetid://134081985420522, uploaded by the current Studio owner (9396921181). Each pet is normalized to 4.6 studs high, faces -Z, and has a world-upright invisible CharacterRoot. Colours are assigned from authored Blender materials because FBX material colours were not retained by the importer.

The .rbxm is the portable, already-installed template bundle. tools/install-blender-pets.luau documents the edit-time installer. If importing into a different owner's experience, validate mesh permissions using that owner's Studio account before publishing. Keep procedural fallback while doing that. No runtime EditableMesh API or private credential is required.

See CODE_REVIEW.md for checks and remaining art/QA work. The original FBX files remain concept exports; the normalized shared-mesh path above is the integrated game version.
