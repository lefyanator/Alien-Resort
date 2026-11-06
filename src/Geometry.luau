local G = {}
local C = {cream=Color3.fromRGB(207,198,218), teal=Color3.fromRGB(69,230,193), dark=Color3.fromRGB(23,27,61), purple=Color3.fromRGB(112,63,190), coral=Color3.fromRGB(255,125,39), rock=Color3.fromRGB(58,46,82)}
G.Colors = C
local function part(parent,name,size,pos,color,material,shape)
    local templates=shape==Enum.PartType.Ball and game.ReplicatedStorage:FindFirstChild('PetTemplates')
    local surface=templates and templates:FindFirstChild('Pebble') and templates.Pebble:FindFirstChild('Body')
    local p=surface and surface:Clone() or Instance.new("Part") p:ClearAllChildren() p.Name=name p.Size=size p.CFrame=CFrame.new(pos) p.Color=color p.CastShadow=true
    p.Material=material or Enum.Material.SmoothPlastic p.Anchored=true p.CanTouch=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
    if shape and p:IsA('Part') then p.Shape=shape end p.Parent=parent return p
end
G.Part=part
local function keepBelow(p,ceiling)
    local cf,size=p.CFrame,p.Size
    local halfHeight=(math.abs(cf.RightVector.Y)*size.X+math.abs(cf.UpVector.Y)*size.Y+math.abs(cf.LookVector.Y)*size.Z)/2
    p.CFrame-=Vector3.new(0,math.max(0,p.Position.Y+halfHeight-ceiling),0)
end
G.KeepBelow=keepBelow
-- Uploaded Blender meshes retain authored topology and floor-based pivots.
function G.Asset(parent,kind,cf)
    local library=game.ServerStorage:FindFirstChild('ResortKit')
    local template=library and library:FindFirstChild(kind)
    if not template then return nil end
    local copy=template:Clone() copy:PivotTo(cf) copy.Parent=parent return copy
end
-- Small reusable silhouettes; decorative parts never block players or raycasts.
function G.Prop(parent,kind,pos,accent)
    local authored=G.Asset(parent,kind,CFrame.new(pos))
    if authored then return authored end
    if kind=='SporeTree' or kind=='Tendril' or kind=='SkyRay' then
        local m=Instance.new('Model') m.Name=kind m.Parent=parent
        local function limb(name,size,offset,color,angle)
            local v=part(m,name,size,pos+offset,color,nil,Enum.PartType.Ball) v.CanCollide=false v.CanQuery=false
            v.CFrame*=CFrame.Angles(0,0,angle or 0) return v
        end
        if kind=='SkyRay' then
            limb('Body',Vector3.new(4,1.2,2.6),Vector3.zero,C.purple)
            for _,s in {-1,1} do
                limb('Fin',Vector3.new(4,.4,3),Vector3.new(s*2,0,.4),C.coral,s*.22)
                limb('Eye',Vector3.new(.4,.4,.3),Vector3.new(s*.7,.4,-1.1),C.teal)
            end
            limb('Tail',Vector3.new(.25,.3,4),Vector3.new(0,0,2.4),C.coral,.15)
        else
            limb('Root',Vector3.new(7,1.3,5),Vector3.new(0,.5,0),C.rock)
            limb('CurvedStem',Vector3.new(1.3,8,1.6),Vector3.new(0,4,0),C.purple,.22)
        if kind=='SporeTree' then
            limb('MushroomCrown',Vector3.new(10,3,8),Vector3.new(-.8,8,0),accent or C.coral,-.12)
            for i=1,3 do limb('SporeBulb',Vector3.new(.8,1.7,.8),Vector3.new(i*2-5,6.4,-1),C.teal) end
        else
            limb('UpperTendril',Vector3.new(1.4,5,1.8),Vector3.new(-1.8,8,0),C.coral,-.6)
            limb('AlienBud',Vector3.new(3,3.8,3),Vector3.new(-3,10,0),C.teal)
        end
        end
        m.WorldPivot=CFrame.new(pos) m:SetAttribute('Hover',kind=='SkyRay' and .6 or kind=='Tendril' and .18 or .08)
        game.CollectionService:AddTag(m,'CosmicScenery') return m
    end
    local library=game.ServerStorage:FindFirstChild('WorldProps')
    local key=kind=='Palm' and ({'PalmA','PalmB','PalmC'})[(math.floor(math.abs(pos.X+pos.Z))%3)+1] or kind=='Flowers' and 'Bush' or kind
    local template=library and library:FindFirstChild(key)
    if template then
        local copy=template:Clone() copy.Name=kind copy:PivotTo(CFrame.new(pos)*CFrame.Angles(0,math.rad(math.floor(pos.X*13+pos.Z*7)%360),0))
        for _,v in copy:GetDescendants() do if v:IsA('BasePart') then v:SetAttribute('BuildStage',3) end end
        copy.Parent=parent return copy
    end
    local m=Instance.new('Model') m.Name=kind m.Parent=parent accent=accent or C.teal
    local function p(name,size,offset,color,shape)
        local v=part(m,name,size,pos+offset,color,nil,shape) v.CanCollide=false v.CanQuery=false v:SetAttribute('BuildStage',3) return v
    end
    local function ball(name,size,offset,color) return p(name,size,offset,color,Enum.PartType.Ball) end
    local function disc(name,r,h,offset,color)
        local v=p(name,Vector3.new(h,r*2,r*2),offset,color,Enum.PartType.Cylinder) v.Orientation=Vector3.new(0,0,90) return v
    end
    if kind=='Palm' or kind=='Flowers' then
        disc('Planter',2.1,1,Vector3.new(0,.5,0),C.cream) disc('Soil',1.8,.1,Vector3.new(0,1.05,0),C.dark)
        if kind=='Palm' then
            disc('Trunk',.35,5,Vector3.new(0,3.5,0),C.coral)
            for i=1,5 do local a=i*math.pi*2/5 local leaf=ball('Leaf',Vector3.new(1.8,.65,5),Vector3.new(math.sin(a)*1.8,6,math.cos(a)*1.8),C.teal) leaf.Orientation=Vector3.new(12,i*72,0) end
        else
            for i=1,3 do
                local x=(i-2)*1.1 p('Stem',Vector3.new(.15,2,.15),Vector3.new(x,2,0),C.teal)
                for j=1,5 do local a=j*math.pi*2/5 ball('Petal',Vector3.new(.8,.8,.35),Vector3.new(x+math.cos(a)*.48,3+math.sin(a)*.48,0),accent) end
                ball('Pollen',Vector3.new(.55,.55,.45),Vector3.new(x,3,-.15),C.cream)
            end
        end
    elseif kind=='Luggage' then
        ball('Case',Vector3.new(1.6,2.2,1),Vector3.new(0,1.3,0),accent)
        for _,x in {-.55,.55} do ball('Wheel',Vector3.new(.4,.4,.4),Vector3.new(x,.25,0),C.dark) end
        p('Handle',Vector3.new(.7,.2,.2),Vector3.new(0,2.6,0),C.dark)
        p('Belt',Vector3.new(.18,1.9,1.03),Vector3.new(0,1.3,0),C.cream)
    elseif kind=='Lamp' then
        disc('Base',.85,.3,Vector3.new(0,.15,0),C.dark) disc('Stem',.15,3,Vector3.new(0,1.7,0),C.dark)
        ball('Shade',Vector3.new(2,1.4,2),Vector3.new(0,3.4,0),accent)
        ball('Bulb',Vector3.new(.8,.6,.8),Vector3.new(0,3,0),C.cream)
    elseif kind=='Console' then
        disc('Pedestal',1.4,1,Vector3.new(0,.5,0),C.dark)
        local screen=p('Screen',Vector3.new(3,2,.35),Vector3.new(0,2,0),accent) screen.Orientation=Vector3.new(-15,0,0)
        for i=1,3 do ball('Button',Vector3.new(.3,.3,.2),Vector3.new((i-2)*.7,1.4,-.35),C.cream) end
    elseif kind=='Chair' then
        disc('Base',.9,.2,Vector3.new(0,.1,0),C.dark)
        disc('Leg',.18,1.8,Vector3.new(0,1,0),C.dark)
        disc('Seat',1.3,.45,Vector3.new(0,2,0),accent)
        p('Backrest',Vector3.new(2.5,2,.4),Vector3.new(0,3,1),accent)
    end
    m.WorldPivot=CFrame.new(pos)
    return m
end
local function cylinder(parent,name,radius,height,pos,color,material)
    local p=part(parent,name,Vector3.new(height,radius*2,radius*2),pos,color,material,Enum.PartType.Cylinder)
    p.Orientation=Vector3.new(0,0,90) return p
end
local function textOn(parent,name,pos,size,text,color)
    local p=part(parent,name,size,pos,C.dark) p.CanCollide=false
    local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.CanvasSize=Vector2.new(900,240) gui.Parent=p
    local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Text=text t.TextColor3=color or C.cream t.Font=Enum.Font.GothamBold t.TextScaled=true t.Parent=gui
    local padding=Instance.new("UIPadding") padding.PaddingLeft=UDim.new(0,20) padding.PaddingRight=UDim.new(0,20) padding.PaddingTop=UDim.new(0,15) padding.PaddingBottom=UDim.new(0,15) padding.Parent=t
    return p
end
local function folder(parent,name)
    local f=Instance.new("Model") f.Name=name f.Parent=parent return f
end
function G.DressCommons(root,origin)
    local art=folder(root,'CommonsArt')
    local function p(name,size,pos,color,shape)
        local v=part(art,name,size,origin+pos,color,nil,shape) v.CanCollide=false v.CanQuery=false return v
    end
    local function disc(name,r,h,pos,color)
        local v=p(name,Vector3.new(h,r*2,r*2),pos,color,Enum.PartType.Cylinder) v.Orientation=Vector3.new(0,0,90) return v
    end
    -- Chamfered terraces replace the oversized slab without changing interaction locations.
    root.CommonsDeck:Destroy() root.CommonsIsland:Destroy()
    for _,v in root:GetChildren() do if v.Name=='EdgeRail' or v.Name=='NebulaPlanter' or v.Name=='NebulaCrystal' then v:Destroy() end end
    local function floor(name,size,pos,color)
        local v=p(name,size,pos,color) v.CanCollide=true v.CanQuery=true return v
    end
    local function terrace(name,width,depth,y,z,color)
        local cut=12
        floor(name,Vector3.new(width-cut*2,1,depth),Vector3.new(0,y,z),color)
        floor(name..'Wings',Vector3.new(width,1,depth-cut*2),Vector3.new(0,y,z),color)
        for _,sx in {-1,1} do for _,sz in {-1,1} do
            local corner=Instance.new('CornerWedgePart') corner.Name=name..'Bevel' corner.Size=Vector3.new(cut,1,cut)
            corner.CFrame=CFrame.new(origin+Vector3.new(sx*(width-cut)/2,y,z+sz*(depth-cut)/2))*CFrame.Angles(0,math.rad(sx==1 and (sz==1 and 0 or 90) or (sz==1 and 270 or 180)),0)
            corner.Color=color corner.Material=Enum.Material.SmoothPlastic corner.Anchored=true corner.CanTouch=false corner.Parent=art
        end end
    end
    terrace('LowerBelt',232,184,1.8,0,C.rock)
    terrace('DeckRim',228,180,4.1,0,C.dark)
    terrace('CommonsDeck',222,174,5.4,0,Color3.fromRGB(76,58,106))
    -- The underside reads as buoyant asteroid clusters rather than stacked cylinders.
    for _,rock in {{-68,-10,-28,83,34,74},{54,-14,-18,105,43,88},{-34,-22,48,88,51,72},{56,-13,62,64,34,57}} do
        local v=p('AsteroidRoot',Vector3.new(rock[4],rock[5],rock[6]),Vector3.new(rock[1],rock[2],rock[3]),C.rock,Enum.PartType.Ball)
        v.Orientation=Vector3.new(8,rock[1]*3,14)
        keepBelow(v,origin.Y+.8)
    end
    for _,side in {-1,1} do
        p('ArenaSideBelt',Vector3.new(4,8,83),Vector3.new(side*96,3,-43),C.purple)
        p('ArenaRail',Vector3.new(1,2,76),Vector3.new(side*91,8,-43),C.dark)
        local pyl=p('StadiumPylon',Vector3.new(7,22,7),Vector3.new(side*95,15,-80),C.dark)
        pyl.Orientation=Vector3.new(0,0,side*8)
        p('PylonBadge',Vector3.new(4,7,1),Vector3.new(side*95,18,-84),side<0 and C.teal or C.coral)
    end
    -- Public seating is outside the match boundary; both end routes remain open.
    for _,x in {-48,48} do
        for row=1,2 do floor('SpectatorTier',Vector3.new(30,1+row*1.3,5),Vector3.new(x,6+row*.65,-81-row*3),C.dark) end
    end
    for _,z in {-88,87} do p('TerraceRail',Vector3.new(192,1.5,.7),Vector3.new(0,7,z),C.dark) end
    for _,x in {-109,109} do p('PromenadeRail',Vector3.new(.7,1.5,161),Vector3.new(x,7,0),C.dark) end
    p('CentralPromenade',Vector3.new(10,.12,162),Vector3.new(0,6,0),Color3.fromRGB(133,115,159))
    p('ActivityWalk',Vector3.new(205,.12,7),Vector3.new(0,6,33),Color3.fromRGB(133,115,159))
    for _,spec in {{-75,C.coral},{-25,C.purple},{25,C.teal},{75,C.coral}} do
        disc('ActivityGarden',13,.18,Vector3.new(spec[1],5.95,20),C.dark)
        if spec[1]==-25 then
            p('BouncePavilion',Vector3.new(25,4,23),Vector3.new(spec[1],17,21),spec[2],Enum.PartType.Ball)
            for _,dx in {-10,10} do p('CanopyPillar',Vector3.new(.8,10,.8),Vector3.new(spec[1]+dx,11,28),C.cream) end
        end
        G.Prop(art,'Bush',origin+Vector3.new(spec[1]+10,6,29),spec[2])
    end
    for i=1,3 do disc('BounceCoil',3+i*.5,.35,Vector3.new(-25,7+i*.65,20),C.purple) end
    p('ScannerDish',Vector3.new(6,2,6),Vector3.new(-75,11,24),C.coral,Enum.PartType.Ball)
    p('ScannerMast',Vector3.new(.6,4,.6),Vector3.new(-75,9,24),C.cream)
    for i=1,5 do
        local cp=root:FindFirstChild('Training '..i)
        if cp then
            local localPos=cp.Position-origin
            local gate=G.Asset(art,'TrainingGate',CFrame.new(cp.Position+Vector3.new(0,.5,0)))
            if not gate then
            for _,dx in {-4.5,4.5} do p('TrainingArch',Vector3.new(.7,6,.7),localPos+Vector3.new(dx,3,0),C.coral) end
            p('ArchTop',Vector3.new(10,.7,.7),localPos+Vector3.new(0,6,0),C.teal)
            end
            p('CourseStripe',Vector3.new(8,.15,2),localPos+Vector3.new(0,.6,0),C.cream)
            textOn(art,'GateNumber',cp.Position+Vector3.new(0,7,0),Vector3.new(4,2,.2),tostring(i)..' / 5',C.coral)
        end
    end
    for _,v in root:GetChildren() do
        if v.Name=='ArenaCover' then
            v.Shape=Enum.PartType.Cylinder v.Size=Vector3.new(6,8,8) v.Orientation=Vector3.new(0,0,90) v.Color=C.purple
            disc('CoverCap',4.2,.3,v.Position-origin+Vector3.new(0,3,0),C.teal)
        elseif v.Name:find('Rescue system',1,true) then
            G.Prop(art,'Console',v.Position+Vector3.new(0,1,0),C.coral)
            G.Asset(art,'RescueEngine',CFrame.new(v.Position+Vector3.new(0,1,3)))
        elseif v.Name:find('Buried stardust',1,true) then
            local chest=G.Asset(art,'TreasureChest',CFrame.new(v.Position+Vector3.new(0,-.5,0)))
            v.Transparency=chest and 1 or 0 v.Shape=Enum.PartType.Ball v.Color=C.purple
            if not chest then p('TreasureGem',Vector3.new(1.5,2.8,1.5),v.Position-origin+Vector3.new(0,1.5,0),C.teal,Enum.PartType.Ball) end
        end
    end
    textOn(art,'TrainingBrief',origin+Vector3.new(-69,11,36),Vector3.new(23,4,.3),'PET TRAINING\nFOLLOW GATES 1 > 5',C.teal)
    textOn(art,'RescueBrief',origin+Vector3.new(65,13,32),Vector3.new(23,4,.3),'SHUTTLE RESCUE\nREPAIR ALL 3 SYSTEMS',C.coral)
    for _,v in root:GetChildren() do if v.Name:find('Buried stardust',1,true) then
        local at=v.Position-origin
        p('ExcavationRim',Vector3.new(6,.2,6),at+Vector3.new(0,-.6,0),C.dark)
        textOn(art,'TreasureBrief',v.Position+Vector3.new(0,5,1.5),Vector3.new(8,2,.2),'PIP\'S DIG SITE',C.coral)
        for _,dx in {-2.6,2.6} do p('DigSiteBeacon',Vector3.new(.3,3,.3),at+Vector3.new(dx,1,2),C.coral) end
    end end
    for _,z in {-78,-8} do p('ArenaBoundary',Vector3.new(178,.2,.5),Vector3.new(0,6.5,z),C.teal) end
    for _,x in {-77,77} do disc('GoalCrest',8,.15,Vector3.new(x,7.6,-43),x<0 and C.teal or C.coral) end
    -- Team goals use different colour and a ring silhouette visible across the field.
    for _,x in {-77,77} do
        local color=x<0 and C.teal or C.coral
        for _,z in {-49,-37} do p('GoalFin',Vector3.new(1,10,2),Vector3.new(x,12,z),color) end
        p('GoalCrown',Vector3.new(2,1,14),Vector3.new(x,17,-43),color)
    end
    p('HalfwayLine',Vector3.new(.5,.2,72),Vector3.new(0,6.5,-43),C.cream)
    for _,x in {-14,14} do p('StadiumEntrance',Vector3.new(2,18,3),Vector3.new(x,15,1),C.dark) end
    local scoreboard=textOn(art,'ArenaScoreboard',origin+Vector3.new(0,24,1),Vector3.new(32,7,1),'STARCORE CAPTURE\nTAKE • RETURN • SCORE',C.cream)
    scoreboard.SurfaceGui.Face=Enum.NormalId.Back scoreboard.SurfaceGui.TextLabel.Name='Text'
    scoreboard.CanQuery=false
    for _,x in {49,81} do p('RepairBayPost',Vector3.new(1,14,1),Vector3.new(x,12,66),C.coral) end
    p('RepairBayArch',Vector3.new(34,1,3),Vector3.new(65,19,66),C.coral)
    p('RepairBayRoof',Vector3.new(36,3,26),Vector3.new(65,20,55),C.coral,Enum.PartType.Ball)
    for _,x in {18,30} do p('LabPylon',Vector3.new(1,10,1),Vector3.new(x,11,82),C.purple) end
    local lab=p('LabDome',Vector3.new(22,7,18),Vector3.new(24,16,81),C.purple,Enum.PartType.Ball)
    disc('EvolutionRing',5,.4,Vector3.new(24,7,78),C.teal)
    p('EvolutionCore',Vector3.new(2.5,3.5,2.5),Vector3.new(24,10,81),C.coral,Enum.PartType.Ball)
    for _,pos in {Vector3.new(21,6,20),Vector3.new(29,6,20)} do G.Prop(art,'Flowers',origin+pos,C.coral) end
    for _,pos in {Vector3.new(-100,6,73),Vector3.new(100,6,73)} do G.Prop(art,'SporeTree',origin+pos) end
    for _,pos in {Vector3.new(-107,5.9,42),Vector3.new(102,5.9,42),Vector3.new(-42,5.9,86),Vector3.new(48,5.9,87)} do G.Prop(art,'Bush',origin+pos) end
    local beacon=root:FindFirstChild('Ancient Beacon')
    if beacon then beacon.Shape=Enum.PartType.Cylinder beacon.Size=Vector3.new(8,3,3) beacon.Orientation=Vector3.new(0,0,90) end
    p('BeaconLens',Vector3.new(5,4,5),Vector3.new(75,15,20),C.coral,Enum.PartType.Ball)
    G.Prop(art,'SkyRay',origin+Vector3.new(-28,20,50))
    G.Prop(art,'Tendril',origin+Vector3.new(104,7,48))
    G.Prop(art,'SporeTree',origin+Vector3.new(-102,7,36))
end
function G.SkyHotel(parent,origin)
    local m=folder(parent,'SkyHotel') m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
    local center=origin+Vector3.new(0,62,50)
    local function p(name,size,offset,color,shape)
        local v=part(m,name,size,center+offset,color,nil,shape) v.CanCollide=false v.CanQuery=false return v
    end
    local function disc(name,radius,height,y,color)
        local v=p(name,Vector3.new(height,radius*2,radius*2),Vector3.new(0,y,0),color,Enum.PartType.Cylinder) v.Orientation=Vector3.new(0,0,90) return v
    end
    p('MothershipHull',Vector3.new(104,16,80),Vector3.new(0,-6,0),C.dark,Enum.PartType.Ball)
    p('OrangeFlightRim',Vector3.new(108,3,84),Vector3.new(0,-5,0),C.coral,Enum.PartType.Ball)
    local floor=disc('SkyDeck',35,1,6,C.purple) floor.CanCollide=true floor.CanQuery=true
    for i=1,12 do
        local a=i*math.pi/6 local x,z=math.cos(a)*34,math.sin(a)*34
        local rail=p('SkyRail',Vector3.new(18,3,.8),Vector3.new(x,8,z),C.coral,Enum.PartType.Ball) rail.CFrame=CFrame.new(rail.Position)*CFrame.Angles(0,math.pi/2-a,0) rail.CanCollide=true
        local window=p('ObservationWindow',Vector3.new(10,5,.4),Vector3.new(math.cos(a)*31,14,math.sin(a)*27),C.teal) window.CFrame=CFrame.new(window.Position)*CFrame.Angles(0,math.pi/2-a,0) window.Material=Enum.Material.Glass window.Transparency=.4
    end
    for i,offset in {Vector3.new(-24,20,1),Vector3.new(0,26,0),Vector3.new(24,20,1)} do
        p('SuspendedSuite',Vector3.new(18,20+(i%2)*10,20),offset,C.purple,Enum.PartType.Ball)
        p('SuiteGlass',Vector3.new(18.5,5,20.5),offset+Vector3.new(0,2,0),C.teal,Enum.PartType.Ball)
        p('SuiteCrown',Vector3.new(22,5,24),offset+Vector3.new(0,11,0),C.coral,Enum.PartType.Ball)
    end
    p('LiftSpine',Vector3.new(.6,57,.6),Vector3.new(0,-24,8),C.coral).Material=Enum.Material.Neon
    textOn(m,'HotelName',center+Vector3.new(0,12,-31),Vector3.new(25,5,.5),'THE ORBITAL PALACE\nUNLOCK: COMPLETE OBSERVATORY',C.coral)
    local ground=part(m,'BoardingLift',Vector3.new(7,.5,7),origin+Vector3.new(0,6.2,58),C.coral) ground.CanCollide=false
    local exit=part(m,'ReturnLift',Vector3.new(7,.5,7),center+Vector3.new(0,7,23),C.coral) exit.CanCollide=false
    for _,x in {-17,17} do G.Prop(m,'Chair',center+Vector3.new(x,6.5,22)) end
    m:SetAttribute('UnlockStage',3) return m
end
function G.UFO(parent,pos)
    local m=folder(parent,"GuestShuttle")
    -- A cylinder's local X axis is its axle. Never use the rotated hull as
    -- the animation pivot: an explicit world-upright root owns orientation.
    local pivot=part(m,"FlightRoot",Vector3.one,pos,C.dark)
    pivot.Transparency=1 pivot.CanCollide=false pivot.CanQuery=false
    m.PrimaryPart=pivot
    part(m,"LowerShell",Vector3.new(13,2.3,13),pos-Vector3.new(0,.25,0),C.dark,nil,Enum.PartType.Ball)
    cylinder(m,"Hull",7,1.8,pos,C.cream)
    cylinder(m,"Rim",7.4,.4,pos-Vector3.new(0,.5,0),C.teal,Enum.Material.Neon)
    local dome=part(m,"Dome",Vector3.new(7,4,7),pos+Vector3.new(0,1.4,0),C.purple,Enum.Material.Glass,Enum.PartType.Ball) dome.Transparency=.2
    cylinder(m,"CabinSeal",3.7,.3,pos+Vector3.new(0,1.1,0),C.dark)
    for i=1,12 do
        local a=i*math.pi*2/12
        local light=part(m,"RunningLight",Vector3.new(.7,.5,.7),pos+Vector3.new(math.cos(a)*6.3,.75,math.sin(a)*6.3),i%3==0 and C.coral or C.teal,Enum.Material.Neon,Enum.PartType.Ball)
    end
    for i=1,3 do
        local a=i*math.pi*2/3 local offset=Vector3.new(math.cos(a)*4.5,0,math.sin(a)*4.5)
        part(m,"LandingStrut",Vector3.new(.55,2,.55),pos+offset-Vector3.new(0,1.7,0),C.dark,Enum.Material.Metal)
        part(m,"LandingFoot",Vector3.new(2,.5,2),pos+offset-Vector3.new(0,2.7,0),C.coral,nil,Enum.PartType.Ball)
    end
    for _,v in m:GetDescendants() do if v:IsA("BasePart") then v.CanCollide=false end end
    m:PivotTo(CFrame.new(pos))
    m:SetAttribute("AssetVersion","upright-0.2")
    return m
end
function G.SetVisible(model,visible)
    for _,p in model:GetDescendants() do
        if p:IsA("BasePart") then
            if p:GetAttribute("OriginalTransparency")==nil then p:SetAttribute("OriginalTransparency",p.Transparency) p:SetAttribute("OriginalCollision",p.CanCollide) end
            p.Transparency=visible and p:GetAttribute("OriginalTransparency") or 1
            p.CanCollide=visible and p:GetAttribute("OriginalCollision") or false
            p.CanTouch=visible
        elseif p:IsA("SurfaceGui") or p:IsA("BillboardGui") then p.Enabled=visible end
    end
end
function G.Decorate(root)
    local d=folder(root,"ResortDetails")
    for _,spec in {{-49,18},{49,-12}} do
        G.Prop(d,'SporeTree',Vector3.new(spec[1],5.35,spec[2]))
        G.Prop(d,'Bush',Vector3.new(spec[1]-3,5.35,spec[2]+5))
    end
    for _,spec in {{-46,39},{44,34},{-51,-26}} do G.Prop(d,'Bush',Vector3.new(spec[1],5.35,spec[2])) end
    -- Raised habitat islands break the empty ground while preserving every guest lane.
    for i,spec in {{-47,-8,8,4},{43,32,10,6},{-23,43,7,3}} do
        local pos=Vector3.new(spec[1],5.2+spec[4]/2,spec[2])
        local rock=part(d,'HabitatMound',Vector3.new(spec[3]*2,spec[4],spec[3]*1.4),pos,C.rock,Enum.Material.Slate,Enum.PartType.Ball) rock.CanCollide=false rock.CanQuery=false
        G.Prop(d,i%2==0 and 'Tendril' or 'SporeTree',Vector3.new(spec[1],5.2+spec[4],spec[2]),i%2==0 and C.purple or C.coral)
    end
    G.Prop(d,'SkyRay',Vector3.new(23,17,36))
    part(d,'SporeLookout',Vector3.new(16,1,13),Vector3.new(-38,8,34),C.dark,Enum.Material.Metal)
    part(d,'LookoutRock',Vector3.new(18,5,15),Vector3.new(-38,5.5,34),C.rock,Enum.Material.Slate,Enum.PartType.Ball).CanCollide=false
    for i=1,3 do part(d,'LookoutStep',Vector3.new(2.5,.8,6),Vector3.new(-24-i*2,5.3+i*.8,34),C.purple,Enum.Material.Metal) end
    G.Prop(d,'Tendril',Vector3.new(-41,8.5,36))
    for _,z in {28,40} do part(d,'LookoutRail',Vector3.new(15,2,.4),Vector3.new(-38,9.4,z),C.coral) end
end
function G.Build(parent,name,origin)
    -- Construct each independent model at local zero, then translate once.
    local root=folder(nil,name)
    root:SetAttribute("BuildVersion","0.1.0")
    local island=folder(root,"Island")
    cylinder(island,"UpperIsland",65,5,Vector3.new(0,2.5,0),C.purple)
    cylinder(island,"CreamRim",65.8,.7,Vector3.new(0,4,0),C.cream)
    cylinder(island,"Ground",63,.7,Vector3.new(0,5,0),Color3.fromRGB(74,56,98))
    for _,r in {{-20,-7,-7,78,30,77},{21,-9,10,75,32,68},{-5,-20,9,55,33,57}} do
        local rock=part(island,'AsteroidRoot',Vector3.new(r[4],r[5],r[6]),Vector3.new(r[1],r[2],r[3]),C.rock,Enum.Material.Slate,Enum.PartType.Ball)
        rock.Orientation=Vector3.new(12,r[1]*4,15) rock.CanCollide=false rock.CanQuery=false
        keepBelow(rock,.8)
    end
    for _,s in {-1,1} do
        local crystal=part(island,'LiftCrystal',Vector3.new(5,15,5),Vector3.new(s*40,-9,3),s<0 and C.teal or C.purple,Enum.Material.Glass)
        crystal.Orientation=Vector3.new(0,0,s*18) crystal.CanCollide=false crystal.CanQuery=false
    end
    part(island,"MainWalk",Vector3.new(12,.3,105),Vector3.new(0,5.5,0),C.cream)
    for _,z in {-10,20} do part(island,"CrossWalk",Vector3.new(90,.3,8),Vector3.new(0,5.5,z),C.cream) end
    for _,x in {-7,7} do part(island,"PathInlay",Vector3.new(.3,.15,100),Vector3.new(x,5.7,0),C.dark) end
    local pad=folder(root,"LandingPad")
    cylinder(pad,"Ring",14,.5,Vector3.new(0,5.9,36),C.teal,Enum.Material.Neon)
    cylinder(pad,"LandingSurface",12.8,.5,Vector3.new(0,6.2,36),C.dark)
    textOn(pad,"ArrivalSign",Vector3.new(0,7.5,50),Vector3.new(18,2,.3),"ARRIVALS / 01",C.teal)
    local upgrades=folder(root,"Upgrades")
    folder(upgrades,"Reception") folder(upgrades,"Kiosk")
    local buttons=folder(root,"BuildPads")
    for i,entry in {{"Room2",Vector3.new(24,6,-10)},{"Reception",Vector3.new(-24,6,-39)},{"Kiosk",Vector3.new(24,6,-39)}} do
        local b=cylinder(buttons,entry[1],3.3,.5,entry[2],C.teal,Enum.Material.Neon)
        local prompt=Instance.new("ProximityPrompt") prompt.Name="BuildPrompt" prompt.ActionText="Build" prompt.ObjectText=entry[1] prompt.HoldDuration=.25 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false prompt.Enabled=false prompt.Parent=b
        local bb=Instance.new("BillboardGui") bb.Name="Label" bb.Size=UDim2.fromOffset(210,64) bb.StudsOffset=Vector3.new(0,4,0) bb.MaxDistance=65 bb.AlwaysOnTop=false bb.Parent=b
        local t=Instance.new("TextLabel") t.Name="Text" t.Size=UDim2.fromScale(1,1) t.BackgroundColor3=C.dark t.BackgroundTransparency=.12 t.TextColor3=C.cream t.Font=Enum.Font.GothamBold t.TextSize=15 t.TextWrapped=true t.Text=entry[1] t.Parent=bb
        local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,12) corner.Parent=t
    end
    local claim=part(root,"ClaimTerminal",Vector3.new(5,4,3),Vector3.new(0,7.5,-35),C.dark)
    part(root,"ClaimTop",Vector3.new(5.4,.4,3.4),Vector3.new(0,9.7,-35),C.teal,Enum.Material.Neon)
    local cp=Instance.new("ProximityPrompt") cp.ActionText="Claim free resort" cp.ObjectText="YOUR SPACE GETAWAY" cp.MaxActivationDistance=12 cp.HoldDuration=.2 cp.RequiresLineOfSight=false cp.Parent=claim
    textOn(root,"ResortSign",Vector3.new(-17,9,-51),Vector3.new(14,2,.4),"ORBIT & OASIS",C.cream)
    part(root,"SignPost",Vector3.new(.4,3,.4),Vector3.new(-17,7,-51),C.dark)
    for i=1,6 do
        local a=i*math.pi*2/6 local x,z=math.cos(a)*59,math.sin(a)*59
        part(root,"BeaconPost",Vector3.new(.5,3,.5),Vector3.new(x,7,z),C.dark)
        part(root,"Beacon",Vector3.new(1.1,.4,1.1),Vector3.new(x,8.7,z),C.teal,Enum.Material.Neon)
    end
    folder(root,"Guests")
    for _,m in upgrades:GetChildren() do G.SetVisible(m,false) end
    local spawn=Instance.new("SpawnLocation") spawn.Name="ResortSpawn" spawn.Size=Vector3.new(6,.3,6) spawn.Position=Vector3.new(0,5.8,-56) spawn.Transparency=1 spawn.Anchored=true spawn.Neutral=true spawn.Duration=0 spawn.Parent=root
    G.Decorate(root)
    require(script.Parent.Expansion).Build(root,G)
    for _,m in upgrades:GetChildren() do G.SetVisible(m,false) end
    for _,p in root:GetDescendants() do
        if p:IsA("BasePart") then p.CFrame+=origin end
    end
    for _,m in root:GetDescendants() do
        if m:IsA('Model') and game.CollectionService:HasTag(m,'CosmicScenery') then m.WorldPivot+=origin end
    end
    root:SetAttribute("Origin",origin)
    root:SetAttribute("BuildVersion","0.7.0")
    root.Parent=parent
    return root
end
return G
