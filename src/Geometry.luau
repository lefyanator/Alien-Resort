local G = {}
local C = {cream=Color3.fromRGB(245,237,216), teal=Color3.fromRGB(56,214,193), dark=Color3.fromRGB(25,42,66), purple=Color3.fromRGB(157,137,226), coral=Color3.fromRGB(255,151,124), rock=Color3.fromRGB(65,66,99)}
G.Colors = C
local function part(parent,name,size,pos,color,material,shape)
    local templates=shape==Enum.PartType.Ball and game.ReplicatedStorage:FindFirstChild('PetTemplates')
    local surface=templates and templates:FindFirstChild('Pebble') and templates.Pebble:FindFirstChild('Body')
    local p=surface and surface:Clone() or Instance.new("Part") p:ClearAllChildren() p.Name=name p.Size=size p.CFrame=CFrame.new(pos) p.Color=color p.CastShadow=true
    p.Material=material or Enum.Material.SmoothPlastic p.Anchored=true p.CanTouch=false p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
    if shape and p:IsA('Part') then p.Shape=shape end p.Parent=parent return p
end
G.Part=part
-- Small reusable silhouettes; decorative parts never block players or raycasts.
function G.Prop(parent,kind,pos,accent)
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
local function plant(parent,x,z)
    G.Prop(parent,'Palm',Vector3.new(x,5.7,z))
end
function G.DressCommons(root,origin)
    local art=folder(root,'CommonsArt')
    local function p(name,size,pos,color,shape)
        local v=part(art,name,size,origin+pos,color,nil,shape) v.CanCollide=false v.CanQuery=false return v
    end
    local function disc(name,r,h,pos,color)
        local v=p(name,Vector3.new(h,r*2,r*2),pos,color,Enum.PartType.Cylinder) v.Orientation=Vector3.new(0,0,90) return v
    end
    root.CommonsDeck.Color=Color3.fromRGB(84,112,136)
    p('CentralPromenade',Vector3.new(10,.12,162),Vector3.new(0,6,0),C.cream)
    p('ActivityWalk',Vector3.new(205,.12,7),Vector3.new(0,6,33),C.cream)
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
            for _,dx in {-4.5,4.5} do p('TrainingArch',Vector3.new(.7,6,.7),localPos+Vector3.new(dx,3,0),C.coral) end
            p('ArchTop',Vector3.new(10,.7,.7),localPos+Vector3.new(0,6,0),C.teal)
            p('CourseStripe',Vector3.new(8,.15,2),localPos+Vector3.new(0,.6,0),C.cream)
        end
    end
    for _,v in root:GetChildren() do
        if v.Name=='ArenaCover' then
            v.Shape=Enum.PartType.Cylinder v.Size=Vector3.new(6,8,8) v.Orientation=Vector3.new(0,0,90) v.Color=C.purple
            disc('CoverCap',4.2,.3,v.Position-origin+Vector3.new(0,3,0),C.teal)
        elseif v.Name:find('Rescue system',1,true) then
            G.Prop(art,'Console',v.Position+Vector3.new(0,1,0),C.coral)
        elseif v.Name:find('Buried stardust',1,true) then
            v.Transparency=0 v.Shape=Enum.PartType.Ball v.Color=C.purple
            p('TreasureGem',Vector3.new(1.5,2.8,1.5),v.Position-origin+Vector3.new(0,1.5,0),C.teal,Enum.PartType.Ball)
        end
    end
    for _,z in {-78,-8} do p('ArenaBoundary',Vector3.new(178,.2,.5),Vector3.new(0,6.5,z),C.teal) end
    for _,x in {-77,77} do disc('GoalCrest',8,.15,Vector3.new(x,7.6,-43),x<0 and C.teal or C.coral) end
    p('HalfwayLine',Vector3.new(.5,.2,72),Vector3.new(0,6.5,-43),C.cream)
    for _,x in {49,81} do p('RepairBayPost',Vector3.new(1,14,1),Vector3.new(x,12,66),C.coral) end
    p('RepairBayArch',Vector3.new(34,1,3),Vector3.new(65,19,66),C.coral)
    p('RepairBayRoof',Vector3.new(36,3,26),Vector3.new(65,20,55),C.coral,Enum.PartType.Ball)
    for _,x in {18,30} do p('LabPylon',Vector3.new(1,10,1),Vector3.new(x,11,82),C.purple) end
    local lab=p('LabDome',Vector3.new(22,7,18),Vector3.new(24,16,81),C.purple,Enum.PartType.Ball)
    disc('EvolutionRing',5,.4,Vector3.new(24,7,78),C.teal)
    p('EvolutionCore',Vector3.new(2.5,3.5,2.5),Vector3.new(24,10,81),C.coral,Enum.PartType.Ball)
    for _,pos in {Vector3.new(21,6,20),Vector3.new(29,6,20)} do G.Prop(art,'Flowers',origin+pos,C.coral) end
    for _,pos in {Vector3.new(-100,6,73),Vector3.new(100,6,73)} do G.Prop(art,'Palm',origin+pos) end
    local beacon=root:FindFirstChild('Ancient Beacon')
    if beacon then beacon.Shape=Enum.PartType.Cylinder beacon.Size=Vector3.new(8,3,3) beacon.Orientation=Vector3.new(0,0,90) end
    p('BeaconLens',Vector3.new(5,4,5),Vector3.new(75,15,20),C.coral,Enum.PartType.Ball)
end
function G.Room(parent,name,x,z,accent)
    local m=folder(parent,name)
    part(m,"Deck",Vector3.new(21,1,18),Vector3.new(x,5.5,z),C.dark)
    part(m,"Floor",Vector3.new(18,0.6,15),Vector3.new(x,6.3,z),C.cream)
    part(m,"Back",Vector3.new(18,9,0.7),Vector3.new(x,10.5,z+7.5),C.cream)
    part(m,"SideL",Vector3.new(0.7,9,15),Vector3.new(x-9,10.5,z),C.cream)
    part(m,"SideR",Vector3.new(0.7,9,15),Vector3.new(x+9,10.5,z),C.cream)
    part(m,"Roof",Vector3.new(21,1.2,18),Vector3.new(x,15.6,z),accent)
    part(m,"RoofInset",Vector3.new(17,0.6,14),Vector3.new(x,16.4,z),C.cream)
    for _,offset in {-6,6} do part(m,"FrontPanel",Vector3.new(6,9,0.7),Vector3.new(x+offset,10.5,z-7.5),C.cream) end
    part(m,"DoorGlow",Vector3.new(6,0.3,0.4),Vector3.new(x,14.7,z-7.9),accent,Enum.Material.Neon)
    local window=part(m,"Window",Vector3.new(5,3.5,0.2),Vector3.new(x-5.5,11,z-7.95),C.teal,Enum.Material.Glass) window.Transparency=.25
    part(m,"BedBase",Vector3.new(6,1.2,8),Vector3.new(x+4,7.2,z+2),C.dark)
    part(m,"Duvet",Vector3.new(6.2,0.7,6),Vector3.new(x+4,8.1,z+1),accent)
    part(m,"Pillow",Vector3.new(4.5,0.6,1.8),Vector3.new(x+4,8.2,z+4),C.cream)
    textOn(m,"RoomSign",Vector3.new(x,17.7,z-7.5),Vector3.new(13,2,0.4),name=="StarterRoom" and "01 / ORBIT POD" or "02 / MOON POD",C.cream)
    return m
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
function G.Guest(parent,pos)
    local m=folder(parent,"PebbleGuest")
    local body=part(m,"Body",Vector3.new(2.8,3.6,2.4),pos,C.teal,nil,Enum.PartType.Ball)
    part(m,"Belly",Vector3.new(1.8,2,.4),pos+Vector3.new(0,-.3,-1.05),C.cream,nil,Enum.PartType.Ball)
    for _,x in {-.65,.65} do
        part(m,"Eye",Vector3.new(.43,.6,.25),pos+Vector3.new(x,.65,-1.13),C.dark,nil,Enum.PartType.Ball)
        part(m,"Foot",Vector3.new(.85,.6,1.25),pos+Vector3.new(x,-1.8,0),C.purple,nil,Enum.PartType.Ball)
        part(m,"Antenna",Vector3.new(.15,1.3,.15),pos+Vector3.new(x,2,0),C.dark)
        part(m,"AntennaTip",Vector3.new(.5,.5,.5),pos+Vector3.new(x,2.7,0),C.coral,Enum.Material.Neon,Enum.PartType.Ball)
    end
    part(m,"Suitcase",Vector3.new(.8,1.2,1.1),pos+Vector3.new(1.7,-1,0),C.coral)
    for _,x in {-1.4,1.4} do
        part(m,"Arm",Vector3.new(.7,1.7,.8),pos+Vector3.new(x,-.5,0),C.teal,nil,Enum.PartType.Ball)
    end
    part(m,"Backpack",Vector3.new(1.8,2,.7),pos+Vector3.new(0,-.2,1.1),C.purple,nil,Enum.PartType.Ball)
    part(m,"Buckle",Vector3.new(.7,.4,.2),pos+Vector3.new(0,-.5,-1.3),C.coral)
    part(m,"Smile",Vector3.new(.5,.12,.15),pos+Vector3.new(0,.1,-1.3),C.dark)
    m.PrimaryPart=body
    for _,v in m:GetChildren() do if v:IsA("BasePart") then v.CanCollide=false v.CanTouch=false end end
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
        G.Prop(d,'Palm',Vector3.new(spec[1],5.35,spec[2]))
        G.Prop(d,'Bush',Vector3.new(spec[1]-3,5.35,spec[2]+5))
    end
    for _,spec in {{-46,39},{44,34},{-51,-26}} do G.Prop(d,'Bush',Vector3.new(spec[1],5.35,spec[2])) end
end
function G.Build(parent,name,origin)
    -- Construct each independent model at local zero, then translate once.
    local root=folder(nil,name)
    root:SetAttribute("BuildVersion","0.1.0")
    local island=folder(root,"Island")
    cylinder(island,"UpperIsland",65,5,Vector3.new(0,2.5,0),C.purple)
    cylinder(island,"CreamRim",65.8,.7,Vector3.new(0,4,0),C.cream)
    cylinder(island,"Ground",63,.7,Vector3.new(0,5,0),Color3.fromRGB(199,191,168))
    for i=1,3 do cylinder(island,"FloatingRock",58-i*10,6,Vector3.new(0,-i*5,0),C.rock) end
    part(island,"MainWalk",Vector3.new(12,.3,105),Vector3.new(0,5.5,0),C.cream)
    for _,z in {-10,20} do part(island,"CrossWalk",Vector3.new(90,.3,8),Vector3.new(0,5.5,z),C.cream) end
    for _,x in {-7,7} do part(island,"PathLight",Vector3.new(.3,.15,100),Vector3.new(x,5.7,0),C.teal,Enum.Material.Neon) end
    local pad=folder(root,"LandingPad")
    cylinder(pad,"Ring",14,.5,Vector3.new(0,5.9,36),C.teal,Enum.Material.Neon)
    cylinder(pad,"LandingSurface",12.8,.5,Vector3.new(0,6.2,36),C.dark)
    textOn(pad,"ArrivalSign",Vector3.new(0,7.5,50),Vector3.new(18,2,.3),"ARRIVALS / 01",C.teal)
    G.Room(root,"StarterRoom",-29,7,C.teal)
    local upgrades=folder(root,"Upgrades")
    G.Room(upgrades,"Room2",29,7,C.purple)
    local reception=folder(upgrades,"Reception")
    part(reception,"Counter",Vector3.new(15,4,5),Vector3.new(-28,7.5,-28),C.cream)
    part(reception,"CounterTop",Vector3.new(16,.5,6),Vector3.new(-28,9.8,-28),C.teal)
    part(reception,"Terminal",Vector3.new(4,2.4,.5),Vector3.new(-28,11,-28),C.dark)
    for _,x in {-35,-21} do part(reception,"CanopyPost",Vector3.new(.5,10,.5),Vector3.new(x,10.5,-26),C.dark) end
    part(reception,"Canopy",Vector3.new(18,1,9),Vector3.new(-28,15.5,-28),C.coral)
    textOn(reception,"Sign",Vector3.new(-28,16.8,-32),Vector3.new(18,2,.3),"STAR RECEPTION",C.cream)
    local kiosk=folder(upgrades,"Kiosk")
    part(kiosk,"Counter",Vector3.new(14,4,7),Vector3.new(29,7.5,-27),C.cream)
    part(kiosk,"CounterTop",Vector3.new(15,.6,8),Vector3.new(29,10,-27),C.coral)
    for _,x in {23,35} do part(kiosk,"Post",Vector3.new(.5,8,.5),Vector3.new(x,10,-27),C.dark) end
    part(kiosk,"Canopy",Vector3.new(17,1,10),Vector3.new(29,14.5,-27),C.purple)
    textOn(kiosk,"Sign",Vector3.new(29,16,-32),Vector3.new(17,2,.3),"COSMIC SNACKS",C.cream)
    for i=1,4 do cylinder(kiosk,"Drink",.6,1.5,Vector3.new(24+i*2,11,-28),i%2==0 and C.teal or C.purple) end
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
    local backdrop=folder(root,"SpaceScenery")
    for _,spec in {{Vector3.new(-190,85,170),60,C.purple},{Vector3.new(220,120,230),90,C.teal},{Vector3.new(-100,130,320),35,C.coral}} do
        local p=part(backdrop,"DistantMoon",Vector3.new(spec[2],spec[2],spec[2]),spec[1],spec[3],nil,Enum.PartType.Ball) p.CanCollide=false
    end
    folder(root,"Guests")
    for _,m in upgrades:GetChildren() do G.SetVisible(m,false) end
    local spawn=Instance.new("SpawnLocation") spawn.Name="ResortSpawn" spawn.Size=Vector3.new(6,.3,6) spawn.Position=Vector3.new(0,5.8,-56) spawn.Transparency=1 spawn.Anchored=true spawn.Neutral=true spawn.Duration=0 spawn.Parent=root
    G.Decorate(root)
    require(script.Parent.Expansion).Build(root,G)
    for _,m in upgrades:GetChildren() do G.SetVisible(m,false) end
    local scenery=root:FindFirstChild("SpaceScenery")
    if scenery then scenery:Destroy() end
    for _,p in root:GetDescendants() do
        if p:IsA("BasePart") then p.CFrame+=origin end
    end
    root:SetAttribute("Origin",origin)
    root:SetAttribute("BuildVersion","0.7.0")
    root.Parent=parent
    return root
end
return G
