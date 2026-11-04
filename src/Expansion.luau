-- Shared staged architecture with curated prop templates and authored service silhouettes.
local E={}
function E.Build(root,G)
    if root:GetAttribute("BuildVersion")=="0.3.0" then return end
    local C=G.Colors
    local function model(parent,name) local m=Instance.new("Model") m.Name=name m.Parent=parent return m end
    local function block(m,n,s,p,c) return G.Part(m,n,Vector3.new(unpack(s)),Vector3.new(unpack(p)),c or C.cream) end
    local function sign(m,n,x,y,z,w,h,words,color)
        local b=block(m,n,{w,h,.3},{x,y,z},C.dark)
        for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
            local g=Instance.new("SurfaceGui") g.Face=face g.CanvasSize=Vector2.new(800,200) g.Parent=b
            local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(.94,.84) t.Position=UDim2.fromScale(.03,.08) t.BackgroundTransparency=1 t.Text=words t.Font=Enum.Font.GothamBold t.TextScaled=true t.TextColor3=color or C.cream t.Parent=g
        end
    end
    local function shell(m,x,z,w,d,accent,title)
        block(m,"Foundation",{w+3,1,d+3},{x,5.5,z},C.dark)
        block(m,"Floor",{w,.6,d},{x,6.3,z})
        block(m,"BackWall",{w,10,.6},{x,11.3,z+d/2})
        for _,dx in {-w/2,w/2} do
            -- Actual window openings, with a low sill and header.
            block(m,"WindowSill",{.6,3,d},{x+dx,8,z})
            block(m,"WindowHeader",{.6,2,d},{x+dx,15.3,z})
            local glass=block(m,"Glass",{.25,5,d-2},{x+dx,11.8,z},C.teal) glass.Material=Enum.Material.Glass glass.Transparency=.65
            for _,dz in {-d/2,0,d/2} do block(m,"WindowFrame",{.8,10,.6},{x+dx,11.3,z+dz},accent) end
        end
        for _,dx in {-(w+6)/4,(w+6)/4} do block(m,"FrontWall",{(w-6)/2,10,.6},{x+dx,11.3,z-d/2}) end
        block(m,"DoorHeader",{6,2,.8},{x,15.3,z-d/2},accent)
        for _,dx in {-3.2,3.2} do block(m,"DoorFrame",{.4,8,.9},{x+dx,10.3,z-d/2},accent) end
        block(m,"EntryStep",{7,.3,3},{x,5.9,z-d/2-1.5},C.dark)
        block(m,"RoofCornice",{w+2,.7,d+2},{x,16.6,z},accent)
        block(m,"Roof",{w+1,1,d+1},{x,17.4,z})
        block(m,"RoofCap",{w-1,.4,d-1},{x,18.1,z},C.dark)
        block(m,"EntranceCanopy",{9,.4,4},{x,14.5,z-d/2-1},accent)
        sign(m,"BuildingName",x,19.8,z-d/2-.5,w,2.5,title,accent)
    end
    local function room(name,x,z,accent,title)
        local parent=name=="StarterRoom" and root or root.Upgrades
        local old=parent:FindFirstChild(name) if old then old:Destroy() end
        local m=model(parent,name) shell(m,x,z,20,18,accent,title)
        block(m,"BedFrame",{7,1,8},{x+4,7.1,z+3},C.dark)
        block(m,"Mattress",{6.6,.7,7.6},{x+4,7.9,z+3})
        block(m,"Blanket",{6.7,.3,5},{x+4,8.4,z+1.8},accent)
        block(m,"Headboard",{7,3,.5},{x+4,8.3,z+7},C.dark)
        for _,dx in {2.5,5.5} do block(m,"Pillow",{2.6,.6,1.8},{x+dx,8.5,z+5.5}) end
        block(m,"Rug",{7,.08,8},{x-4,6.65,z},accent)
        block(m,"Desk",{5,.5,2},{x-5,9,z+6},C.dark)
        for _,dx in {-7,-3} do block(m,"DeskLeg",{.3,2.5,1.5},{x+dx,7.8,z+6},C.dark) end
        local chair=G.Prop(m,'Chair',Vector3.new(x-5,6.6,z+3.5)) chair:PivotTo(CFrame.new(x-5,6.6,z+3.5))
        block(m,"Wardrobe",{3,7,3},{x-7,10,z-5},C.dark)
        sign(m,"RoomUse",x,12,z+8.5,8,2,"GUEST SUITE",accent)
        m:SetAttribute("GuestRoom",true)
        return m
    end
    room("StarterRoom",-29,7,C.teal,"01  ORBIT HOTEL")
    room("Room2",29,7,C.purple,"02  MOON HOTEL")
    for _,id in {"Reception","Kiosk"} do root.Upgrades[id]:Destroy() end
    local reception=model(root.Upgrades,"Reception") shell(reception,-28,-28,22,18,C.teal,"RECEPTION")
    block(reception,"CheckInDesk",{13,3,3},{-28,8,-25},C.dark)
    block(reception,"DeskTop",{14,.4,3.5},{-28,9.7,-25},C.cream)
    block(reception,"MonitorStand",{.4,1,.4},{-29,10.4,-25},C.dark)
    block(reception,"Monitor",{3,2,.3},{-29,11.3,-25},C.teal)
    sign(reception,"DeskLabel",-28,8.5,-26.6,9,1.5,"CHECK IN HERE",C.teal)
    sign(reception,"KeyWall",-28,13,-19.5,12,3,"WELCOME TO\nORBIT & OASIS",C.teal)
    for i=1,5 do block(reception,"RoomKey",{.4,.9,.3},{-34+i*2,10.5,-19.5},C.coral) end
    local snack=model(root.Upgrades,"Kiosk") shell(snack,29,-28,22,18,C.coral,"COSMIC CAFE")
    block(snack,"ServiceCounter",{17,3,3},{29,8,-32},C.coral)
    block(snack,"CounterTop",{18,.4,4},{29,9.7,-32},C.cream)
    sign(snack,"Menu",29,13,-19.5,17,4,"COSMIC CAFE\nMOON DONUTS  /  STAR SHAKES",C.coral)
    for i=1,4 do
        local food=block(snack,"MoonPastry",{1.6,.8,1.6},{22+i*2,10.3,-32},i%2==0 and C.purple or C.coral) food.Shape=Enum.PartType.Ball
        block(snack,"DrinkCup",{.7,1.4,.7},{22+i*2,10.6,-31},C.teal)
        block(snack,"Straw",{.12,.7,.12},{22+i*2,11.5,-31},C.cream)
    end
    block(snack,"Fridge",{4,6,3},{36,9.5,-23},C.dark)
    block(snack,"FridgeGlass",{3.3,4.6,.2},{36,9.7,-24.6},C.teal)
    -- Landmark silhouettes identify services even before their signs are readable.
    local cup=block(snack,"RooftopDrink",{5,7,5},{29,21.5,-28},C.coral) cup.Shape=Enum.PartType.Cylinder cup.Orientation=Vector3.new(0,0,90) cup.Size=Vector3.new(7,5,5)
    local lid=block(snack,"CupLid",{.5,5.7,5.7},{29,25.2,-28},C.cream) lid.Shape=Enum.PartType.Cylinder lid.Orientation=Vector3.new(0,0,90)
    local straw=block(snack,"GiantStraw",{.6,5,.6},{29.8,27.5,-28},C.teal) straw.Orientation=Vector3.new(0,0,-12)
    for i=0,8 do block(snack,"StripedAwning",{2.4,.35,4},{19.4+i*2.4,14.5,-39},i%2==0 and C.coral or C.cream) end
    block(reception,"WelcomeTower",{3,14,3},{-37,21,-22},C.teal)
    sign(reception,"TowerSign",-37,26,-23.7,5,5,"i",C.cream)
    local district=model(root,"NorthPromenade")
    block(district,"ExtensionLand",{74,4,44},{0,2.5,76},C.rock)
    block(district,"PromenadeDeck",{74,.7,44},{0,5,76},C.cream)
    for _,x in {-37,37} do
        local endcap=G.Part(district,'PromenadeEndcap',Vector3.new(.7,44,44),Vector3.new(x,5,76),C.cream,nil,Enum.PartType.Cylinder)
        endcap.Orientation=Vector3.new(0,0,90)
        local rock=G.Part(district,'PromenadeAsteroid',Vector3.new(43,23,43),Vector3.new(x,-7,76),C.rock,Enum.Material.Slate,Enum.PartType.Ball)
        rock.CanCollide=false rock.CanQuery=false rock.Orientation=Vector3.new(12,x*2,10)
        G.KeepBelow(rock,.8)
    end
    block(district,"Bridge",{12,1,18},{0,4.9,55},C.cream)
    block(district,"Walkway",{105,.2,8},{0,5.5,62},C.dark)
    for _,side in {-1,1} do
        for i=0,5 do
            local a=math.rad(-75+i*30) local x=side*(37+math.cos(a)*21) local z=76+math.sin(a)*21
            local rail=block(district,'CurvedGuardRail',{.6,1.5,10.7},{x,6.3,z},C.dark)
            rail.Orientation=Vector3.new(0,-side*math.deg(a),0)
        end
    end
    block(district,"BackRail",{74,1.5,.6},{0,6.3,97},C.dark)
    sign(district,"DistrictSign",0,10,58,18,3,"NORTH PROMENADE",C.teal)
    room("Room3",-35,80,C.coral,"03  AURORA SUITE")
    local lounge=model(root.Upgrades,"Lounge") shell(lounge,0,80,24,20,C.purple,"STARGAZER LOUNGE")
    for _,x in {-7,7} do
        block(lounge,"SofaSeat",{4,1.5,9},{x,7.5,80},C.purple)
        block(lounge,"SofaBack",{.8,3,9},{x+(x<0 and -2 or 2),9,80},C.dark)
    end
    local sky=block(lounge,"Skylight",{15,4,14},{0,18.5,80},C.purple) sky.Shape=Enum.PartType.Ball sky.Material=Enum.Material.Glass sky.Transparency=.35
    block(lounge,"CoffeeTable",{5,1,5},{0,7.5,80},C.cream)
    sign(lounge,"LoungeArt",0,12,89.5,13,4,"RELAX AMONG\nTHE STARS",C.purple)
    local observatory=model(root.Upgrades,"Observatory") shell(observatory,35,80,22,20,C.teal,"OBSERVATORY")
    local dome=block(observatory,"Dome",{19,9,18},{35,18,80},C.purple) dome.Shape=Enum.PartType.Ball
    block(observatory,"TelescopeStand",{1,4,1},{35,9,80},C.dark)
    local scope=block(observatory,"Telescope",{2.5,2.5,9},{35,12,80},C.teal) scope.Orientation=Vector3.new(-25,25,0)
    sign(observatory,"StarMap",35,12,89.5,14,5,"GALAXY TOURS\nOBSERVATION DECK",C.teal)
    for i,id in {"Room3","Lounge","Observatory"} do
        local pad=root.BuildPads.Room2:Clone() pad.Name=id pad.Position=Vector3.new((i-2)*35,6,64) pad.Parent=root.BuildPads
    end
    -- Keep the service footprints/routes, but give each roofline its own identity.
    local function roof(m,x,z,size,color)
        for _,n in {'Roof','RoofCap','RoofCornice'} do local old=m:FindFirstChild(n) if old then old:Destroy() end end
        local dome=G.Part(m,'CurvedRoof',Vector3.new(unpack(size)),Vector3.new(x,17.5,z),color,nil,Enum.PartType.Ball) dome:SetAttribute('BuildStage',2)
    end
    roof(root.StarterRoom,-29,7,{24,7,21},C.teal)
    roof(root.Upgrades.Room2,29,7,{24,10,21},C.purple)
    roof(root.Upgrades.Room3,-35,80,{24,6,22},C.coral)
    roof(lounge,0,80,{28,13,24},C.purple)
    roof(observatory,35,80,{25,14,24},C.dark)
    -- Aurora is an A-frame cabin, while the lounge is an open observatory pavilion.
    local aurora=root.Upgrades.Room3 aurora.CurvedRoof:Destroy()
    for _,side in {-1,1} do
        local wing=Instance.new('WedgePart') wing.Name='AuroraRoof' wing.Size=Vector3.new(22,7,12)
        wing.CFrame=CFrame.new(-35+side*6,19,80)*CFrame.Angles(0,math.rad(side*90),0)
        wing.Anchored=true wing.CanTouch=false wing.Color=C.coral wing.Material=Enum.Material.SmoothPlastic wing:SetAttribute('BuildStage',2) wing.Parent=aurora
    end
    aurora.BuildingName.Position+=Vector3.new(0,4,0)
    for _,v in lounge:GetChildren() do
        if v.Name=='FrontWall' or v.Name=='WindowSill' or v.Name=='Glass' or v.Name=='Skylight' then v:Destroy() end
    end
    local rim=G.Part(observatory,'ObservatoryRing',Vector3.new(.6,25,23),Vector3.new(35,17,80),C.teal,nil,Enum.PartType.Cylinder)
    rim.Orientation=Vector3.new(0,0,90) rim:SetAttribute('BuildStage',2)
    observatory.Dome:Destroy()
    local barrel=block(observatory,'SkyTelescope',{2.8,2.8,12},{35,23,79},C.teal) barrel.Shape=Enum.PartType.Cylinder barrel.Size=Vector3.new(12,3,3) barrel.Orientation=Vector3.new(0,0,35) barrel:SetAttribute('BuildStage',3)
    for _,v in snack:GetChildren() do if v.Name=='FrontWall' or v.Name=='RoofCap' then v:Destroy() end end
    local cafeRoof=snack:FindFirstChild('Roof') cafeRoof.Color=C.coral cafeRoof.Size=Vector3.new(26,2,23)
    cafeRoof.Color=Color3.fromRGB(172,92,63)
    for _,v in snack:GetChildren() do if v:IsA('BasePart') and (v.Name=='ServiceCounter' or v.Name=='WindowFrame' or v.Name=='DoorFrame') then v.Material=Enum.Material.Wood v.Color=Color3.fromRGB(108,76,57) end end
    for _,v in reception:GetChildren() do if v.Name=='FrontWall' then v:Destroy() end end
    local receptionDome=block(reception,'TowerDome',{7,5,7},{-37,29,-22},C.teal) receptionDome.Shape=Enum.PartType.Ball receptionDome:SetAttribute('BuildStage',2)
    for _,m in {root.StarterRoom,root.Upgrades.Room2,root.Upgrades.Room3} do
        local floor=m.Floor.Position
        G.Prop(m,'Lamp',Vector3.new(floor.X-4,6.6,floor.Z+6),C.coral)
        G.Prop(m,'Luggage',Vector3.new(floor.X-7,6.6,floor.Z-4),C.purple)
    end
    G.Prop(reception,'Bush',Vector3.new(-36,6.6,-22))
    G.Prop(snack,'Flowers',Vector3.new(37,6.6,-35),C.coral)
    G.Prop(district,'Palm',Vector3.new(49,5.35,94))
    root:SetAttribute("BuildVersion","0.3.0")
end
return E
