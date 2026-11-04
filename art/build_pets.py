"""Run with Blender --background --python build_pets.py. Original Alien Resort art."""
import bpy, math, os
from mathutils import Vector

OUT = os.path.dirname(os.path.abspath(__file__))
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
colors = {'ink':'19233E','cream':'FFF6DE','teal':'42DDC1','coral':'FF8E7E','lilac':'B48FF7','gold':'FFD35D','lime':'99DF57','leaf':'409A63','coal':'423953','orange':'FF994C','pink':'F5B5F2'}
mats = {}
for name, h in colors.items():
    rgb = [int(h[i:i+2],16)/255 for i in (0,2,4)]
    m = bpy.data.materials.new(name); m.diffuse_color=(*rgb,1); m.use_nodes=True
    m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*rgb,1)
    m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.38
    mats[name]=m

groups={}
def orb(name, loc, scale, color):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, location=loc)
    o=bpy.context.object; o.name=name; o.scale=scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(mats[color])
    for f in o.data.polygons: f.use_smooth=True
    groups[current].append(o)
    return o

def face(z, front, spread=.5):
    for s in [-1,1]:
        orb('Eye', (s*spread,front,z),(.23,.12,.34),'ink')
        orb('Eye_glint',(s*spread-.055,front-.11,z+.12),(.065,.04,.085),'cream')
        orb('Blush',(s*(spread+.3),front+.04,z-.36),(.19,.07,.09),'coral')
    orb('Smile',(0,front-.02,z-.42),(.21,.075,.07),'ink')

for current in ['Pip','Juno','Sprout','Ember']:
    groups[current]=[]
    if current=='Pip':
        orb('Body',(0,0,1.8),(1.13,.95,1.35),'teal')
        orb('Belly',(0,-.84,1.5),(.68,.17,.76),'cream')
        orb('Explorer_pack',(0,.88,1.65),(.69,.38,.8),'coral')
        for s in [-1,1]:
            orb('Boot',(s*.6,-.1,.4),(.4,.55,.3),'lilac')
            orb('Mitten',(s*1.12,0,1.5),(.28,.38,.55),'teal')
            a=orb('Antenna',(s*.6,0,3.13),(.065,.065,.46),'ink'); a.rotation_euler[1]=s*.2
            orb('Antenna_light',(s*.69,0,3.57),(.18,.18,.18),'gold')
        orb('Badge',(.48,-1,1.25),(.16,.07,.16),'gold'); face(2.3,-.89,.45)
    elif current=='Juno':
        orb('Bell',(0,0,2.35),(1.4,1.1,1.15),'lilac')
        for i in range(8):
            a=i*math.tau/8
            orb('Scalloped_frill',(math.cos(a)*1.02,math.sin(a)*.8,1.62),(.44,.37,.32),'pink')
        for i in range(4):
            x=(i-1.5)*.52
            ribbon=orb('Ribbon',(x,0,.95),(.19,.2,.7),'lilac'); ribbon.rotation_euler[1]=math.sin(i)*.17
            orb('Ribbon_pearl',(x,0,.3),(.23,.23,.23),'pink')
        orb('Crown_moon',(.45,0,3.57),(.19,.19,.42),'gold')
        orb('Crown_pearl',(.78,0,3.85),(.14,.14,.14),'gold'); face(2.55,-1.03,.51)
    elif current=='Sprout':
        orb('Body',(0,0,1.45),(1.5,1.15,1.12),'lime')
        orb('Belly',(0,-1,1.15),(.8,.19,.45),'cream')
        for s in [-1,1]:
            orb('Mud_boot',(s*.65,-.1,.35),(.45,.55,.27),'coal')
            leaf=orb('Leaf',(s*.35,0,2.9),(.26,.13,.64),'leaf'); leaf.rotation_euler[1]=s*.6
        orb('Scarf',(0,-1.06,.95),(1,.14,.13),'coral')
        orb('Scarf_tail',(.9,-1.05,.66),(.16,.13,.4),'coral'); face(1.75,-1.05,.62)
    else:
        orb('Body',(0,0,1.4),(1.05,.92,1.1),'coal')
        orb('Head',(0,-.12,2.25),(1.23,.99,.94),'coal')
        orb('Warm_belly',(0,-.87,1.25),(.65,.18,.67),'orange')
        for s in [-1,1]:
            ear=orb('Flame_ear',(s*.88,0,3.12),(.27,.3,.65),'orange'); ear.rotation_euler[1]=s*.25
            orb('Paw',(s*.65,-.15,.35),(.4,.5,.28),'coal')
            wing=orb('Wing',(s*1.18,.28,1.75),(.28,.3,.76),'coral'); wing.rotation_euler[1]=s*.6
        for i in range(4): orb('Tail',(.3+i*.18,.9+i*.33,.9+i*.1),(.25,.32,.25),'coal')
        orb('Tail_flame',(.95,2.1,1.5),(.32,.32,.5),'gold'); face(2.45,-1.06,.51)
    bpy.ops.object.select_all(action='DESELECT')
    for o in groups[current]: o.select_set(True)
    bpy.context.view_layer.objects.active=groups[current][0]
    bpy.ops.export_scene.fbx(filepath=os.path.join(OUT,current+'.fbx'),use_selection=True,object_types={'MESH'},add_leaf_bones=False,axis_forward='-Z',axis_up='Y',bake_anim=False)
    # Gallery placement is applied only after each standalone origin-centred export.
    for o in groups[current]: o.location.x+=['Pip','Juno','Sprout','Ember'].index(current)*3.8-5.7

bpy.ops.mesh.primitive_plane_add(size=200)
floor=bpy.context.object; floor.name='Preview_floor'; floor.data.materials.append(mats['ink'])
world=bpy.context.scene.world; world.color=(.15,.15,.15)
for loc, power, size in [((0,-6,10),1800,8),((3,3,7),2200,7),((-7,-1,5),1000,5)]:
    bpy.ops.object.light_add(type='AREA',location=loc)
    o=bpy.context.object; o.data.energy=power; o.data.shape='DISK'; o.data.size=size
    o.rotation_euler=(Vector((0,0,1.5))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(7,-20,9))
cam=bpy.context.object; cam.rotation_euler=(Vector((0,0,1.8))-cam.location).to_track_quat('-Z','Y').to_euler()
cam.data.type='ORTHO'; cam.data.ortho_scale=16.4
s=bpy.context.scene; s.camera=cam; s.render.engine='CYCLES'; s.cycles.samples=32
s.render.resolution_x=1600; s.render.resolution_y=700; s.render.resolution_percentage=100
s.render.image_settings.file_format='PNG'; s.render.filepath=os.path.join(OUT,'Pet-lineup.png')
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'Alien-Resort-Pets.blend'))
bpy.ops.render.render(write_still=True)
print('ASSET_PACK_READY', {k:sum(len(o.data.polygons) for o in v) for k,v in groups.items()})
