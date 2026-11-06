"""Original Alien Resort exterior kit. Blender 5.2 --background --python this-file.
Dimensions are studs. Blender Z up, front -Y; FBX maps that front to Roblox -Z.
"""
import bpy, math, os, json
from mathutils import Vector
OUT=os.path.dirname(os.path.abspath(__file__))
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
palette={'ink':'22293F','plum':'613E94','orange':'F09A42','mint':'65E3BA','cream':'F9E4B6','pink':'E986C2','steel':'71849D','soil':'39334C'}
mats={}
for key,h in palette.items():
    m=bpy.data.materials.new(key); m.diffuse_color=tuple(int(h[i:i+2],16)/255 for i in (0,2,4))+(1,)
    m.use_nodes=True; bs=m.node_tree.nodes['Principled BSDF']; bs.inputs['Base Color'].default_value=m.diffuse_color; bs.inputs['Roughness'].default_value=.33
    mats[key]=m
groups={}; origins={}; current=''; origin=Vector((0,0,0))
def start(name,x,y):
    global current,origin
    current=name; origin=Vector((x,y,0)); origins[name]=list(origin); groups[name]=[]
def finish(o,name,color):
    o.name=name; o.location+=origin; o.data.materials.append(mats[color]); groups[current].append(o); return o
def mesh(name,verts,faces,color,smooth=False):
    me=bpy.data.meshes.new(name); me.from_pydata(verts,[],faces); me.update()
    o=bpy.data.objects.new(name,me); bpy.context.collection.objects.link(o)
    for p in me.polygons:p.use_smooth=smooth
    return finish(o,name,color)
def box(name,pos,size,color,bevel=.12):
    bpy.ops.object.select_all(action='DESELECT')
    bpy.ops.mesh.primitive_cube_add(size=1,location=pos); o=bpy.context.object; o.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        mod=o.modifiers.new('Soft manufactured edge','BEVEL'); mod.width=bevel; mod.segments=2
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return finish(o,name,color)
def tube(name,points,radius,color,closed=False):
    bpy.ops.object.select_all(action='DESELECT')
    c=bpy.data.curves.new(name,'CURVE'); c.dimensions='3D'; c.resolution_u=4; c.bevel_depth=radius; c.bevel_resolution=1
    s=c.splines.new('BEZIER'); s.bezier_points.add(len(points)-1); s.use_cyclic_u=closed
    for p,co in zip(s.bezier_points,points):p.co=co; p.handle_left_type='AUTO'; p.handle_right_type='AUTO'
    o=bpy.data.objects.new(name,c); bpy.context.collection.objects.link(o); bpy.context.view_layer.objects.active=o; o.select_set(True)
    bpy.ops.object.convert(target='MESH')
    for p in o.data.polygons:p.use_smooth=True
    return finish(o,name,color)
def surface(name,point,nu,nv,color,thickness=.16):
    verts=[point(u/nu,v/nv) for u in range(nu+1) for v in range(nv+1)]; faces=[]
    for u in range(nu):
        for v in range(nv):a=u*(nv+1)+v; faces.append((a,a+nv+1,a+nv+2,a+1))
    # Mirrored roof panels must keep upward-facing tops before solidifying inward.
    du=Vector(point(.51,.5))-Vector(point(.5,.5)); dv=Vector(point(.5,.51))-Vector(point(.5,.5))
    if du.cross(dv).z<-.000001:faces=[tuple(reversed(f)) for f in faces]
    o=mesh(name,verts,faces,color,True)
    if thickness:
        bpy.ops.object.select_all(action='DESELECT'); o.select_set(True); bpy.context.view_layer.objects.active=o
        mod=o.modifiers.new('Engineered shell thickness','SOLIDIFY'); mod.thickness=thickness; mod.offset=-1
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return o
def gem(name,pos,scale,color):
    bpy.ops.object.select_all(action='DESELECT'); bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1,location=pos)
    o=bpy.context.object; o.scale=scale; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return finish(o,name,color)

# Two independently supported roof lobes. A central light slot makes the silhouette legible.
start('MoonRoof',0,0)
def roof_z(x,y):return .5+3.1*math.sqrt(max(0,1-(x/12)**2))*math.sqrt(max(0,1-(y/13)**2))
for side in [-1,1]:
    def point(u,v):
        x=side*(.55+11.35*u); y=-10.85+21.7*v
        return (x,y,roof_z(x,y))
    surface('Curved floating shell',point,10,12,'plum',.24)
    for edge in [0,1]:
        points=[point(edge,t/8) for t in range(9)]; tube('Outer flight lip',points,.12,'orange')
    for front in [0,1]:tube('Front and rear lip',[point(t/8,front) for t in range(9)],.12,'cream')
    for u in [.25,.55,.8]:
        tube('Roof panel seam',[(point(u,t/6)[0],point(u,t/6)[1],point(u,t/6)[2]+.035) for t in range(7)],.045,'ink')
    for y in [-7,7]:
        box('Maglev mount',(side*8,y,.3),(2,2.2,.6),'ink',.18)
        box('Maglev accent',(side*8,y,.65),(1.6,1.8,.12),'mint',.05)

# Twin sculpted arch ribs span a real doorway; all low geometry remains outside x=+-5.
start('ReceptionPortico',32,0)
arch=[(-6.35,0,.25),(-6.35,0,4.6),(-5.7,0,8),(-3.2,0,10.7),(0,0,11.35),(3.2,0,10.7),(5.7,0,8),(6.35,0,4.6),(6.35,0,.25)]
for y in [-1.05,1.05]:
    tube('Curved welcome rib',[(x,y,z) for x,_,z in arch],.52,'plum')
    tube('Illuminated arch inset',[(x,y-.48,z) for x,_,z in arch],.075,'mint')
for side in [-1,1]:
    box('Portico foot',(side*6.35,0,.3),(2,3,.6),'ink',.2)
    box('Foot trim',(side*6.35,-1.1,.65),(1.6,.35,.32),'orange',.08)
    tube('Structural brace',[(side*6.25,-1,5),(side*6.5,0,6),(side*6.25,1,5)],.16,'steel')
for x in [-4,-2,0,2,4]:
    z=11.35-.65*(abs(x)/3.2)**1.4
    tube('Vaulted canopy batten',[(x,-1.05,z),(x,0,z+.15),(x,1.05,z)],.13,'cream')
surface('Crescent canopy',lambda u,v:(-5+10*u,-1.05+2.1*v,11.35-2.4*abs(2*u-1)**2+.12*math.sin(v*math.pi)),16,4,'orange',.12)
box('Welcome crest',(0,-1.35,10.7),(2.3,.28,1.15),'ink',.2)
gem('Four point star',(0,-1.55,10.7),(.5,.12,.5),'cream')

# A curved segmented cafe canopy with a scalloped front edge and rolled side brackets.
start('CafeAwning',0,29)
def awning_z(y):return .6+1.15*math.sin((y+2.5)/5*math.pi*.72)
for i in range(10):
    x0=-12+i*2.4
    surface('Awning stripe',lambda u,v,x0=x0:(x0+2.4*u,-2.5+5*v,awning_z(-2.5+5*v)),2,10,'cream' if i%2 else 'orange',.12)
    surface('Scalloped valance',lambda u,v,x0=x0:(x0+2.4*u,-2.5,.65-v*(.3+.22*math.sin(u*math.pi))),8,1,'cream' if i%2 else 'orange',.1)
tube('Rear canopy rail',[(-12,2.5,awning_z(2.5)),(0,2.5,awning_z(2.5)),(12,2.5,awning_z(2.5))],.12,'ink')
for x in [-10.5,10.5]:tube('Curled canopy bracket',[(x,2.3,.4),(x,1,.12),(x,-.4,.15),(x,-1.2,.6)],.16,'plum')

# Lid is clearly open; dark inner liner, metal hoops, lock, coins and gems tell its purpose.
start('TreasureChest',33,24)
box('Chest floor',(0,0,.28),(3.8,2.7,.5),'ink',.18)
for x in [-1.75,1.75]:box('Side panel',(x,0,.9),(.3,2.7,1.5),'plum',.1)
for y in [-1.2,1.2]:box('Front back panel',(0,y,.9),(3.5,.3,1.5),'plum',.12)
for x in [-1.2,1.2]:
    box('Front metal band',(x,-1.38,.9),(.28,.12,1.55),'orange',.04)
    box('Side lid hinge',(x,1.35,1.55),(.5,.35,.3),'steel',.08)
box('Lock surround',(0,-1.43,1.05),(.65,.18,.65),'orange',.1)
box('Keyhole',(0,-1.54,1.1),(.14,.04,.3),'ink',.045)
# Lid panel plane rotates away from the player around the back hinge.
angle=math.radians(64)
def lid_point(x,d,h=0):return (x,1.25+d*math.cos(angle)-h*math.sin(angle),1.55+d*math.sin(angle)+h*math.cos(angle))
o=box('Open reinforced lid',lid_point(0,.7), (3.8,1.6,.28),'plum',.15); o.rotation_euler.x=angle
for x in [-1.2,1.2]:
    o=box('Lid metal band',lid_point(x,.7,.17),(.28,1.6,.12),'orange',.04); o.rotation_euler.x=angle
o=box('Lid embossed insert',lid_point(0,.7,.2),(1.6,1.1,.1),'mint',.12); o.rotation_euler.x=angle
for x,y,z,s in [(-.8,-.25,1.45,.55),(.45,.1,1.6,.65),(1,-.45,1.25,.4)]:gem('Star shard',(x,y,z),(.5*s,.45*s,1*s),'mint' if x<0 else 'pink')
for x,y in [(-1,-.7),(-.2,-.8),(.6,-.65),(.2,.3)]:
    bpy.ops.object.select_all(action='DESELECT'); bpy.ops.mesh.primitive_cylinder_add(vertices=16,radius=.24,depth=.08,location=(x,y,1.4)); finish(bpy.context.object,'Gold coin','orange')

start('TrainingGate',48,23)
gate=[(-4.5,0,.2),(-4.5,0,3.8),(-3.4,0,5.8),(0,0,6.4),(3.4,0,5.8),(4.5,0,3.8),(4.5,0,.2)]
tube('Training arch',gate,.38,'ink')
tube('Training bright rim',[(x,-.32,z) for x,_,z in gate],.11,'orange')
for x in [-4.5,4.5]:
    box('Gate foot',(x,0,.2),(1.35,2,.4),'plum',.2)
    for z in [1.6,2.5,3.4]:box('Track light',(x,-.39,z),(.25,.12,.4),'mint',.08)
box('Number plate',(0,-.15,6.5),(2.6,.5,.9),'plum',.25)

# Export merged colour components. Origins remain explicitly recorded for Studio installation.
manifest={}
for name,objects in groups.items():
    merged=[]; by_color={c:[o for o in objects if o.data.materials[0].name==c] for c in palette}
    for color,chosen in by_color.items():
        if not chosen:continue
        bpy.ops.object.select_all(action='DESELECT')
        for o in chosen:o.select_set(True)
        bpy.context.view_layer.objects.active=chosen[0]
        if len(chosen)>1:bpy.ops.object.join()
        o=bpy.context.object; o.name=name+'__'+color
        bpy.ops.object.transform_apply(location=True,rotation=True,scale=True); merged.append(o)
    groups[name]=merged
    count=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in merged)
    assert count<=8000,(name,count)
    verts=[v.co for o in merged for v in o.data.vertices]
    lo=[min(v[i] for v in verts)-origins[name][i] for i in range(3)]; hi=[max(v[i] for v in verts)-origins[name][i] for i in range(3)]
    manifest[name]={'origin':origins[name],'objects':[o.name for o in merged],'triangles':count,'localBounds':[lo,hi]}
bpy.ops.object.select_all(action='DESELECT')
for objects in groups.values():
    for o in objects:o.select_set(True)
bpy.ops.export_scene.fbx(filepath=os.path.join(OUT,'Architecture.fbx'),use_selection=True,axis_forward='-Z',axis_up='Y',apply_unit_scale=True,bake_anim=False,add_leaf_bones=False)
with open(os.path.join(OUT,'Architecture.json'),'w') as f:json.dump({'palette':palette,'assets':manifest},f,indent=2)
bpy.ops.mesh.primitive_plane_add(size=250,location=(20,12,-.3)); bpy.context.object.data.materials.append(mats['soil'])
bpy.ops.object.camera_add(location=(72,-65,65)); camera=bpy.context.object; camera.rotation_euler=(Vector((22,12,2))-camera.location).to_track_quat('-Z','Y').to_euler(); camera.data.type='ORTHO'; camera.data.ortho_scale=84
scene=bpy.context.scene; scene.camera=camera; scene.render.engine='CYCLES'; scene.cycles.samples=32
scene.world.color=(.32,.32,.32)
for pos,power,size in [((8,-12,32),10000,20),((45,35,30),8000,18)]:
    bpy.ops.object.light_add(type='AREA',location=pos); o=bpy.context.object; o.data.energy=power; o.data.shape='DISK'; o.data.size=size; o.rotation_euler=(Vector((22,10,0))-o.location).to_track_quat('-Z','Y').to_euler()
scene.view_settings.view_transform='Standard'; scene.view_settings.look='None'
scene.render.resolution_x=1500; scene.render.resolution_y=1050; scene.render.resolution_percentage=100; scene.render.filepath=os.path.join(OUT,'Architecture-review.png')
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'Architecture.blend')); bpy.ops.render.render(write_still=True)
print('ARCHITECTURE_COMPLETE',json.dumps(manifest))
