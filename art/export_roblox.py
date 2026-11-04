"""Blender --background Alien-Resort-Pets.blend --python export_roblox.py.
Export authored transforms/materials and the shared UV-sphere geometry to Studio.
No scene edits, cloud credentials or Roblox API calls are used here.
"""
import bpy, json, math, os
from mathutils import Matrix, Vector

out = os.path.dirname(os.path.abspath(__file__))
axis = Matrix(((1, 0, 0), (0, 0, 1), (0, 1, 0)))
characters = [('Pip', 'Pebble'), ('Juno', 'Jelly'), ('Sprout', 'Slime'), ('Ember', 'Lava')]
scene = bpy.context.scene
# The gallery is the author's ordered mesh creation list, followed by its floor.
objects = [o for o in scene.objects if o.type == 'MESH' and o.name != 'Preview_floor']
names = {'Explorer_pack':'ExplorerPack','Antenna_light':'AntennaTip','Badge':'StarBadge',
         'Bell':'Body','Scalloped_frill':'BellFrill','Ribbon_pearl':'RibbonTip',
         'Crown_moon':'MoonCrown','Crown_pearl':'CrownStar','Mud_boot':'MudBoot',
         'Scarf_tail':'ScarfTail','Warm_belly':'EmberBelly','Flame_ear':'FlameEar',
         'Tail_flame':'TailFlame','Eye_glint':'EyeShine','Blush':'Cheek'}
motions = {'Body':'Breath','Eye':'Blink','EyeShine':'Blink','Boot':'Foot','MudBoot':'Foot',
           'Mitten':'Foot','Paw':'Foot','Antenna':'SwayL','AntennaTip':'Float',
           'BellFrill':'Float','Ribbon':'SwayL','RibbonTip':'Float','MoonCrown':'SwayR',
           'CrownStar':'Float','Leaf':'SwayL','ScarfTail':'SwayR','FlameEar':'SwayL',
           'Wing':'SwayR','Tail':'SwayR','TailFlame':'Float'}
# Group by authoring order, not nearest gallery position (tails cross midpoints).
groups=[]
for o in objects:
    base=o.name.split('.')[0]
    if base in ('Body','Bell') and len(groups)<4:
        groups.append([])
    groups[-1].append(o)
assert len(groups)==4
first=groups[0][0]
def normalized(mesh):
    lower=Vector([min(v.co[i] for v in mesh.vertices) for i in range(3)])
    upper=Vector([max(v.co[i] for v in mesh.vertices) for i in range(3)])
    centre=(lower+upper)/2; size=upper-lower
    return [axis @ Vector([(v.co[i]-centre[i])/size[i] for i in range(3)]) for v in mesh.vertices], centre, size
verts,_,_=normalized(first.data)
first.data.calc_loop_triangles()
faces=[[t.vertices[0]+1,t.vertices[2]+1,t.vertices[1]+1] for t in first.data.loop_triangles]
payload={'Version':1,'Vertices':[[round(n,7) for n in v] for v in verts],'Triangles':faces,'Pets':{}}
for i,(character,species) in enumerate(characters):
    group=groups[i]
    bottom=min((o.matrix_world @ Vector(c)).z for o in group for c in o.bound_box)
    top=max((o.matrix_world @ Vector(c)).z for o in group for c in o.bound_box)
    factor=4.6/(top-bottom)
    pivot=Vector((i*3.8-5.7,0,(bottom+top)/2))
    result=[]
    for o in group:
        vs,centre,size=normalized(o.data)
        assert len(vs)==len(verts) and all((a-b).length<.0001 for a,b in zip(vs,verts)), o.name
        pos=axis @ ((o.matrix_world @ centre)-pivot)*factor
        rot=axis @ o.matrix_world.to_3x3().normalized() @ axis.inverted()
        dimensions=axis @ size * factor
        color=o.data.materials[0].diffuse_color
        name=names.get(o.name.split('.')[0],o.name.split('.')[0])
        result.append({'Name':name,'Position':list(pos),'Rotation':[v for row in rot for v in row],
                       'Size':list(dimensions),'Color':[round(c*255) for c in color[:3]],
                       'Motion':('Jelly' if species in ('Jelly','Slime') else 'Breath') if name=='Body' else motions.get(name)})
    payload['Pets'][species]={'Character':character,'Parts':result}
with open(os.path.join(out,'roblox-pets.json'),'w',encoding='utf-8') as f:
    json.dump(payload,f,separators=(',',':'))
with open(os.path.join(out,'PetSurface.obj'),'w',encoding='utf-8') as f:
    f.write('# Shared Blender UV sphere, normalized to one stud\no PetSurface\n')
    for vertex in payload['Vertices']:
        f.write('v '+' '.join(map(str,vertex))+'\n')
    for face in faces:
        f.write('f '+' '.join(map(str,face))+'\n')
print('ROBLOX_EXPORT', {s:len(v['Parts']) for s,v in payload['Pets'].items()},len(verts),len(faces))
