"""Original resort kit. Blender --background --python art/build_resort_kit.py.
Exports actual authored topology, grouped by asset/material; no sphere substitution.
"""
import bpy, math, os, json
from mathutils import Vector
OUT=os.path.dirname(os.path.abspath(__file__))
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
palette={'ink':'22293F','plum':'613E94','orange':'F09A42','mint':'65E3BA','cream':'F9E4B6','pink':'E986C2','steel':'71849D','soil':'39334C'}
mats={}
for key,h in palette.items():
    m=bpy.data.materials.new(key); m.diffuse_color=tuple(int(h[i:i+2],16)/255 for i in (0,2,4))+(1,)
    m.use_nodes=True; bs=m.node_tree.nodes['Principled BSDF']; bs.inputs['Base Color'].default_value=m.diffuse_color; bs.inputs['Roughness'].default_value=.38
    mats[key]=m
groups={}; current=''; origin=Vector((0,0,0))
def finish(o,name,color):
    o.name=name; o.location+=origin; o.data.materials.append(mats[color]); groups[current].append(o)
    return o
def box(name,pos,size,color,bevel=.12):
    bpy.ops.mesh.primitive_cube_add(size=1,location=pos); o=bpy.context.object; o.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        mod=o.modifiers.new('Soft manufactured edges','BEVEL'); mod.width=bevel; mod.segments=3
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return finish(o,name,color)
def sphere(name,pos,size,color):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,location=pos); o=bpy.context.object; o.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    for p in o.data.polygons:p.use_smooth=True
    return finish(o,name,color)
def ring(name,pos,radius,thick,color,rotation=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=32,minor_segments=8,location=pos,major_radius=radius,minor_radius=thick,rotation=rotation)
    return finish(bpy.context.object,name,color)
def tube(name,points,radius,color):
    c=bpy.data.curves.new(name,'CURVE'); c.dimensions='3D'; c.resolution_u=8; c.bevel_depth=radius; c.bevel_resolution=2
    s=c.splines.new('BEZIER'); s.bezier_points.add(len(points)-1)
    for p,co in zip(s.bezier_points,points):p.co=co; p.handle_left_type='AUTO'; p.handle_right_type='AUTO'
    o=bpy.data.objects.new(name,c); bpy.context.collection.objects.link(o); bpy.context.view_layer.objects.active=o; o.select_set(True)
    bpy.ops.object.convert(target='MESH'); return finish(bpy.context.object,name,color)
def lathe(name,profile,color):
    verts=[]; faces=[]; n=40
    for r,z in profile:
        for j in range(n):
            a=j*2*math.pi/n; verts.append((r*math.cos(a),r*math.sin(a),z))
    for k in range(len(profile)-1):
        for j in range(n):a=k*n+j; b=k*n+(j+1)%n; faces.append((a,b,b+n,a+n))
    me=bpy.data.meshes.new(name); me.from_pydata(verts,[],faces); me.update()
    o=bpy.data.objects.new(name,me); bpy.context.collection.objects.link(o)
    for p in me.polygons:p.use_smooth=True
    return finish(o,name,color)
def start(name,x,y):
    global current,origin
    current=name; origin=Vector((x,y,0)); groups[name]=[]

start('SporeTree',0,0)
lathe('Root mound',[(0,0),(1.8,0),(2,.25),(1.3,.65),(0,.8)],'soil')
tube('Organic stem',[(0,0,.3),(.15,0,2),(-.4,0,4.2),(0,0,6.5)],.42,'cream')
lathe('Sculpted bell cap',[(0,6.8),(.6,6.75),(1.5,6.45),(2.5,5.9),(3.3,5.35),(3.5,5.15),(3.1,4.95),(2,5.15),(.4,5.65),(0,5.7)],'orange')
ring('Cream lip',(0,0,5.15),3.35,.12,'cream')
for j in range(12):
    a=j*math.tau/12
    tube('Radial gill',[(r*math.cos(a),r*math.sin(a),z) for r,z in [(.4,5.5),(1.5,5.25),(2.7,5.02),(3.25,5.1)]],.055,'plum')
for j in range(7):
    a=j*math.tau/7; r=1.8 if j%2 else 2.7
    sphere('Cap freckles',(r*math.cos(a),r*math.sin(a),6.25 if r<2 else 5.72),(.26,.26,.09),'cream')
for j in range(4):
    a=j*math.tau/4+.5
    tube('Root tendril',[(0,0,.6),(math.cos(a),math.sin(a),.3),(2*math.cos(a),2*math.sin(a),.08)],.16,'plum')
    x,y=2.6*math.cos(a),2.6*math.sin(a)
    tube('Spore filament',[(x,y,5.1),(x,y,4.6),(x*.95,y*.95,4.2)],.04,'cream')
    sphere('Seed lantern',(x*.95,y*.95,4),(.17,.17,.3),'mint')

start('ReceptionDesk',12,0)
box('Body',(0,0,1.4),(10,2.6,2.7),'plum',.45)
box('Floating worktop',(0,0,2.9),(10.6,3,.28),'cream')
box('Toe recess',(0,0,.2),(8.6,2,.4),'ink')
for x in [-3.9,-2.6,-1.3,0,1.3,2.6,3.9]:box('Fluted front',(x,-1.33,1.55),(.12,.12,1.9),'orange',.04)
box('Terminal stem',(-2,0,3.3),(.25,.25,.7),'steel')
box('Terminal bezel',(-2,0,4),(2.5,.25,1.5),'ink')
box('Terminal display',(-2,-.14,4),(2.15,.04,1.15),'mint',.06)
for i in range(3):box('Display line',(-2,-.17,4.3-i*.25),(1.3,.02,.08),'ink',.02)
ring('Desk bell foot',(2,-.5,3.1),.35,.09,'steel'); sphere('Desk bell',(2,-.5,3.2),(.34,.34,.18),'orange')
box('Key tray',(3.5,.3,3.1),(1.3,1,.14),'ink')
for x in [3.2,3.5,3.8]:box('Room card',(x,.3,3.22),(.2,.6,.08),'mint',.025)

start('CafeCounter',27,0)
box('Bar base',(0,0,1.4),(13,2.8,2.8),'ink',.3)
box('Cream bar',(0,0,3),(13.5,3.2,.35),'cream')
for x in range(-6,7):box('Orange fluting',(x,-1.42,1.5),(.7,.15,2.25),'orange',.08)
box('Espresso machine',(3,.3,4),(2.6,1.5,1.7),'plum',.2)
box('Drip tray',(3,-.6,3.25),(2.5,.8,.15),'steel')
for x in [2.4,3.6]:
    ring('Control dial',(x,-.49,4.3),.17,.05,'cream',(math.pi/2,0,0))
    tube('Coffee spout',[(x,-.5,4),(x,-.7,3.8)],.07,'steel')
for i in range(3):
    x=-4+i*1.4; ring('Donut pastry',(x,-.3,3.36),.4,.17,'orange'); ring('Pink icing',(x,-.3,3.48),.4,.12,'pink')
for x in [-1,0]:
    sphere('Shake cup',(x,.5,3.6),(.3,.3,.5),'mint'); ring('Cup lid',(x,.5,4),.3,.045,'cream')
    tube('Bent straw',[(x,.5,4),(x,.5,4.65),(x+.2,.5,4.75)],.045,'pink')

start('SuiteBed',0,13)
box('Recessed base',(0,0,.4),(6.1,7.5,.8),'ink',.35)
box('Bed frame',(0,0,.9),(6.8,8.1,.7),'plum',.3)
box('Mattress',(0,0,1.5),(6.3,7.7,.75),'cream',.3)
box('Quilt',(0,-1,1.95),(6.35,5.5,.25),'mint',.18)
for y in [-3,-2,-1,0,1]:box('Quilt seams',(0,y,2.09),(5.8,.035,.018),'steel',.008)
box('Headboard',(0,3.8,2.3),(7,.5,3.7),'plum',.4)
box('Padded inset',(0,3.49,2.5),(6.2,.15,2.6),'pink',.25)
for x in [-1.6,1.6]:box('Pillow',(x,2.5,2),(2.6,1.7,.6),'cream',.27)

start('CleanerBot',12,13)
lathe('Hover chassis',[(0,.3),(1.15,.3),(1.4,.6),(1.3,1.2),(.9,1.4),(0,1.4)],'plum')
ring('Bumper',(0,0,.65),1.3,.13,'orange')
box('Canister',(0,.2,1.7),(1.5,1.1,1.3),'mint',.3)
box('Face',(0,-.65,1.8),(1.5,.25,.7),'ink',.2)
for x in [-.38,.38]:sphere('Eyes',(x,-.81,1.85),(.12,.05,.15),'cream')
tube('Vacuum hose',[(.8,.2,1.9),(1.5,.2,1.7),(1.7,-.5,.5)],.12,'steel')
box('Nozzle',(1.7,-.65,.35),(.9,.5,.3),'orange')
for x in [-.75,.75]:
    ring('Brush hub',(x,-.9,.25),.35,.1,'steel')
    for j in range(6):
        a=j*math.tau/6; tube('Brush bristle',[(x,-.9,.22),(x+.55*math.cos(a),-.9+.55*math.sin(a),.12)],.035,'cream')

start('RobotHelmet',19,13)
box('Helmet',(0,0,1),(2.1,1.7,1.8),'cream',.45)
box('Visor',(0,-.78,1),(1.8,.3,1.1),'ink',.3)
for x in [-.45,.45]:box('Friendly eyes',(x,-.955,1.15),(.25,.07,.3),'mint',.1)
tube('Smile',[(-.3,-.96,.8),(0,-.98,.72),(.3,-.96,.8)],.045,'mint')
for x in [-1.1,1.1]:sphere('Ear pod',(x,0,1),(.23,.5,.5),'plum'); ring('Ear trim',(x,0,1),.35,.07,'orange',(0,math.pi/2,0))
tube('Antenna',[(0,.1,1.9),(0,.1,2.4),(.2,.1,2.55)],.07,'steel'); sphere('Signal lamp',(.2,.1,2.55),(.17,.17,.17),'orange')

start('RescueEngine',27,13)
lathe('Thruster',[(0,.2),(1.2,.2),(1.6,.6),(1.5,1.2),(1,2.2),(.6,2.5),(0,2.5)],'steel')
ring('Exhaust ring',(0,0,.5),1.4,.18,'orange')
for j in range(6):
    a=j*math.tau/6; box('Heat fin',(1.2*math.cos(a),1.2*math.sin(a),1.2),(.3,.3,1.4),'plum',.08)
ring('Reactor',(0,0,2.25),.7,.14,'mint')

# Apply transforms and consolidate disconnected detail by material, preserving exact geometry.
manifest={}
for name,objects in groups.items():
    merged=[]
    by_color={color:[o for o in objects if o.data.materials[0].name==color] for color in palette}
    for color in palette:
        chosen=by_color[color]
        if not chosen:continue
        bpy.ops.object.select_all(action='DESELECT')
        for o in chosen:o.select_set(True)
        bpy.context.view_layer.objects.active=chosen[0]; bpy.ops.object.join(); o=bpy.context.object
        o.name=name+'__'+color
        bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
        merged.append(o)
    groups[name]=merged
    manifest[name]={'objects':[o.name for o in merged],'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in merged)}
bpy.ops.object.select_all(action='DESELECT')
for objects in groups.values():
    for o in objects:o.select_set(True)
bpy.ops.export_scene.fbx(filepath=os.path.join(OUT,'ResortKit.fbx'),use_selection=True,axis_forward='-Z',axis_up='Y',apply_unit_scale=True,bake_anim=False,add_leaf_bones=False)
with open(os.path.join(OUT,'resort-kit.json'),'w') as f:json.dump({'palette':palette,'assets':manifest},f,indent=2)
# A neutral, readable art review render, not a game screenshot.
bpy.ops.mesh.primitive_plane_add(size=200,location=(12,7,-.1)); floor=bpy.context.object; floor.data.materials.append(mats['soil'])
bpy.ops.object.camera_add(location=(44,-43,42)); camera=bpy.context.object; camera.rotation_euler=(Vector((13,6,2))-camera.location).to_track_quat('-Z','Y').to_euler(); camera.data.type='ORTHO'; camera.data.ortho_scale=44
scene=bpy.context.scene; scene.camera=camera; scene.render.engine='CYCLES'; scene.cycles.samples=24
scene.world.color=(.3,.3,.3)
for pos,power,size in [((8,-10,25),6500,15),((25,15,22),5000,12)]:
    bpy.ops.object.light_add(type='AREA',location=pos); o=bpy.context.object; o.data.energy=power; o.data.shape='DISK'; o.data.size=size; o.rotation_euler=(Vector((12,5,0))-o.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=1400; scene.render.resolution_y=1000; scene.render.resolution_percentage=100
scene.render.filepath=os.path.join(OUT,'ResortKit-review.png')
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'Alien-Resort-Kit.blend'),compress=True); bpy.ops.render.render(write_still=True)
print('RESORT_KIT_COMPLETE',json.dumps(manifest))
