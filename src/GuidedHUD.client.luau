local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local waiting=Instance.new('ScreenGui') waiting.Name='ResortLoading' waiting.Parent=player:WaitForChild('PlayerGui')
local status=Instance.new('TextLabel') status.Size=UDim2.new(.8,0,0,70) status.Position=UDim2.fromScale(.1,.4) status.Text='Loading your plot...' status.TextScaled=true status.Parent=waiting
local function waitMessage() status.Text=player:GetAttribute('GuideTitle') or 'Loading your plot...' end
local waitingConnection=player:GetAttributeChangedSignal('GuideTitle'):Connect(waitMessage)
while not player:GetAttribute('PlotName') do player:GetAttributeChangedSignal('PlotName'):Wait() end
local world=workspace:WaitForChild('ResortPlots'):WaitForChild(player:GetAttribute('PlotName'))
waitingConnection:Disconnect() waiting:Destroy()
world:WaitForChild("StarterRoom"):WaitForChild("Floor")
world:WaitForChild("Upgrades"):WaitForChild("Room2"):WaitForChild("Floor")
world.Upgrades:WaitForChild("Room3"):WaitForChild("Floor")
world:WaitForChild("BuildPads")
world:WaitForChild("LandingPad"):WaitForChild("LandingSurface")
world:WaitForChild("ClaimTerminal")
local gui=Instance.new("ScreenGui") gui.Name="AlienResortHUD" gui.ResetOnSpawn=false gui.Parent=player:WaitForChild("PlayerGui")
local cream=Color3.fromRGB(255,255,255) local teal=Color3.fromRGB(255,224,82) local dark=Color3.fromRGB(116,76,212)
local function corner(o) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,18) c.Parent=o
    local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(63,42,115) stroke.Thickness=3 stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Parent=o end
local function text(parent,name,value,pos,size,fontSize,color)
    local t=Instance.new("TextLabel") t.Name=name t.BackgroundTransparency=1 t.Position=pos t.Size=size t.Text=value t.TextColor3=color or cream t.Font=Enum.Font.FredokaOne t.TextSize=fontSize t.TextXAlignment=Enum.TextXAlignment.Left t.TextWrapped=true t.Parent=parent return t
end
local function frame(parent,name,pos,size)
    local f=Instance.new("Frame") f.Name=name f.Position=pos f.Size=size f.BackgroundColor3=dark f.BackgroundTransparency=0 f.Parent=parent corner(f) return f
end
local cashCard=frame(gui,"Balance",UDim2.fromOffset(12,12),UDim2.fromOffset(224,92))
text(cashCard,"Brand","ORBIT & OASIS",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,15),11,teal)
local cash=text(cashCard,"Tokens","0 tokens",UDim2.fromOffset(12,27),UDim2.new(1,-24,0,28),25)
local rate=text(cashCard,"Income","Rooms earn money automatically",UDim2.fromOffset(12,61),UDim2.new(1,-24,0,22),11)
local book=Instance.new("TextButton") book.Name="BookButton" book.AnchorPoint=Vector2.new(1,0) book.Position=UDim2.new(1,-12,0,12) book.Size=UDim2.fromOffset(118,38) book.Text="ALIENS 0/1" book.Font=Enum.Font.FredokaOne book.TextSize=12 book.TextColor3=dark book.BackgroundColor3=teal book.Parent=gui corner(book)
local guide=frame(gui,"Guide",UDim2.new(.5,0,1,-16),UDim2.new(.9,0,0,132)) guide.AnchorPoint=Vector2.new(.5,1)
local constraint=Instance.new("UISizeConstraint") constraint.MaxSize=Vector2.new(600,132) constraint.Parent=guide
local step=text(guide,"Step","YOUR NEXT STEP",UDim2.fromOffset(14,10),UDim2.new(1,-28,0,15),11,teal)
local title=text(guide,"Title","Claim your FREE resort",UDim2.fromOffset(14,28),UDim2.new(1,-28,0,29),19)
local detail=text(guide,"Detail","",UDim2.fromOffset(14,60),UDim2.new(1,-28,0,39),13)
local track=frame(guide,"ProgressTrack",UDim2.new(0,14,1,-18),UDim2.new(1,-28,0,6)) track.BackgroundColor3=Color3.fromRGB(65,78,100)
local fill=frame(track,"Fill",UDim2.fromScale(0,0),UDim2.fromScale(0,1)) fill.BackgroundColor3=teal
local panel=frame(gui,"Book",UDim2.fromScale(.5,.45),UDim2.new(.85,0,0,220)) panel.AnchorPoint=Vector2.new(.5,.5) panel.Visible=false
local pc=Instance.new("UISizeConstraint") pc.MaxSize=Vector2.new(440,220) pc.Parent=panel
text(panel,"Heading","ALIEN FIELD GUIDE",UDim2.fromOffset(18,16),UDim2.new(1,-65,0,28),19,teal)
local species=text(panel,"Species","",UDim2.fromOffset(18,60),UDim2.new(1,-36,0,125),16)
local close=Instance.new("TextButton") close.Text="×" close.TextSize=25 close.TextColor3=cream close.BackgroundTransparency=1 close.Size=UDim2.fromOffset(40,40) close.Position=UDim2.new(1,-44,0,7) close.Parent=panel
book.Activated:Connect(function() panel.Visible=not panel.Visible end) close.Activated:Connect(function() panel.Visible=false end)
local toast=frame(gui,"Notification",UDim2.new(.5,0,0,112),UDim2.new(.86,0,0,42)) toast.AnchorPoint=Vector2.new(.5,0) toast.Visible=false
local ts=Instance.new("UISizeConstraint") ts.MaxSize=Vector2.new(520,42) ts.Parent=toast
local toastText=text(toast,"Message","",UDim2.fromOffset(12,3),UDim2.new(1,-24,1,-6),13) toastText.TextXAlignment=Enum.TextXAlignment.Center
local toastToken=0
local function notify(message)
    toastToken+=1 local token=toastToken toastText.Text=message toast.Visible=true
    task.delay(4,function() if token==toastToken then toast.Visible=false end end)
end
local marker=Instance.new("BillboardGui") marker.Name="TaskMarker" marker.Size=UDim2.fromOffset(190,86) marker.StudsOffsetWorldSpace=Vector3.new(0,7,0) marker.AlwaysOnTop=true marker.MaxDistance=200 marker.Parent=gui
local markerText=text(marker,"Arrow","▼\nSTART HERE",UDim2.fromScale(0,0),UDim2.fromScale(1,1),20,teal) markerText.TextXAlignment=Enum.TextXAlignment.Center markerText.TextStrokeTransparency=.35
local highlight=Instance.new("Highlight") highlight.Name="TaskHighlight" highlight.FillColor=teal highlight.FillTransparency=.7 highlight.OutlineColor=cream highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop highlight.Parent=world
local destination=Instance.new("Attachment") destination.Name="LocalGuideDestination" destination.Position=Vector3.new(0,1.5,0)
local beam=Instance.new("Beam") beam.Name="TaskRoute" beam.Color=ColorSequence.new(teal) beam.FaceCamera=true beam.Width0=.22 beam.Width1=.22 beam.Transparency=NumberSequence.new(.15) beam.LightEmission=.8 beam.Attachment1=destination beam.Parent=world
local function bindCharacter(character)
    local hrp=character:WaitForChild("HumanoidRootPart",10)
    if hrp then local origin=Instance.new("Attachment") origin.Position=Vector3.new(0,-2,0) origin.Parent=hrp beam.Attachment0=origin end
end
player.CharacterAdded:Connect(bindCharacter) if player.Character then task.spawn(bindCharacter,player.Character) end
local function selectTarget(id)
    if id and string.sub(id,1,6)=="Clean_" then local name=string.sub(id,7) local room=name=="StarterRoom" and world.StarterRoom or world.Upgrades:FindFirstChild(name) if room then return room.Floor,room,"CLEAN ME!" end end
    if id=="ClaimTerminal" then return world.ClaimTerminal,world.ClaimTerminal,"CLAIM FREE RESORT"
    elseif id=="LandingPad" then return world.LandingPad.LandingSurface,world.LandingPad,"GUEST ARRIVING"
    elseif id=="StarterRoom" then return world.StarterRoom.Floor,world.StarterRoom,"GUEST INCOME"
    elseif id and world.BuildPads:FindFirstChild(id) then return world.BuildPads[id],world.BuildPads[id],"BUILD HERE" end
end
local tokens=player:WaitForChild("leaderstats"):WaitForChild("Tokens")
local function update()
    cash.Text=string.format("%d tokens",tokens.Value)
    rate.Text=player:GetAttribute("OwnsResort") and string.format("%d occupied • +%d every 10s",player:GetAttribute("OccupiedRooms") or 0,player:GetAttribute("IncomePerTick") or 0) or "Rooms earn money automatically"
    title.Text=player:GetAttribute("GuideTitle") or "Claim your FREE resort"
    detail.Text=player:GetAttribute("GuideDetail") or "Walk to the arrow. Hold E or tap the terminal prompt."
    local cost=player:GetAttribute("NextCost") or 0
    step.Text=cost>0 and string.format("NEXT UPGRADE  •  %d / %d TOKENS",tokens.Value,cost) or "YOUR NEXT STEP"
    track.Visible=cost>0 fill.Size=UDim2.fromScale(cost>0 and math.clamp(tokens.Value/cost,0,1) or 0,1)
    local part,object,caption=selectTarget(player:GetAttribute("GuideTarget") or "ClaimTerminal")
    marker.Enabled=part~=nil highlight.Enabled=object~=nil beam.Enabled=part~=nil
    marker.Adornee=part highlight.Adornee=object destination.Parent=part markerText.Text="▼\n"..(caption or "")
    local found=player:GetAttribute("SpeciesDiscovered") book.Text="ALIEN PETS"
    species.Text=found and "PEBBLE ALIEN • DISCOVERED\n\nYour starter guest is free. Buy more alien pets to unlock new visitors and earn extra tokens." or "FIRST CONTACT\n\nClaim your free resort and welcome a visitor to discover your first alien."
end
tokens.Changed:Connect(update)
for _,key in {"GuideTitle","GuideDetail","GuideTarget","NextCost","OwnsResort","IncomePerTick","OccupiedRooms","SpeciesDiscovered"} do player:GetAttributeChangedSignal(key):Connect(update) end
player:GetAttributeChangedSignal("NoticeVersion"):Connect(function() notify(player:GetAttribute("ResortNotice") or "") end)
local roomLabels={}
for _,room in {world.StarterRoom,world.Upgrades.Room2,world.Upgrades.Room3} do
    local bb=Instance.new("BillboardGui") bb.Name="RoomIncome" bb.Adornee=room.Floor bb.Size=UDim2.fromOffset(210,54) bb.StudsOffsetWorldSpace=Vector3.new(0,14,0) bb.MaxDistance=90 bb.Parent=gui
    local bg=frame(bb,"Card",UDim2.fromScale(0,0),UDim2.fromScale(1,1))
    local status=text(bg,"Status","",UDim2.fromOffset(8,4),UDim2.new(1,-16,1,-8),13) status.TextXAlignment=Enum.TextXAlignment.Center
    table.insert(roomLabels,{room=room,gui=bb,label=status})
    room:GetAttributeChangedSignal("PaymentVersion"):Connect(function()
        local popup=Instance.new("BillboardGui") popup.Adornee=room.Floor popup.Size=UDim2.fromOffset(150,45) popup.StudsOffsetWorldSpace=Vector3.new(0,10,0) popup.AlwaysOnTop=true popup.Parent=gui
        local t=text(popup,"Earned","+"..tostring(room:GetAttribute("LastPayout") or 10).." tokens",UDim2.fromScale(0,0),UDim2.fromScale(1,1),23,teal) t.TextXAlignment=Enum.TextXAlignment.Center t.TextStrokeTransparency=.3
        TweenService:Create(popup,TweenInfo.new(1.6),{StudsOffsetWorldSpace=Vector3.new(0,14,0)}):Play()
        TweenService:Create(t,TweenInfo.new(1.6),{TextTransparency=1,TextStrokeTransparency=1}):Play()
        task.delay(1.7,function() popup:Destroy() end)
    end)
end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
    elapsed+=dt if elapsed<.1 then return end elapsed=0
    marker.StudsOffsetWorldSpace=Vector3.new(0,7+math.sin(os.clock()*3)*.35,0)
    for _,entry in roomLabels do
        entry.gui.Enabled=entry.room.Floor.Transparency<1 and (entry.room:GetAttribute("Stage")==nil or entry.room:GetAttribute("Stage")==3)
        local state=entry.room:GetAttribute("GuestStatus") or "Waiting for your first guest"
        if state=="Occupied" then
            local seconds=math.max(0,math.ceil((entry.room:GetAttribute("NextPaymentAt") or 0)-workspace:GetServerTimeNow()))
            entry.label.Text="GUEST CHECKED IN\nPayment in "..seconds.."s"
        else entry.label.Text=state end
    end
end)
player:GetAttributeChangedSignal("PayoutVersion"):Connect(function()
    cash.TextColor3=teal TweenService:Create(cash,TweenInfo.new(.8),{TextColor3=cream}):Play()
end)
update()
-- Shared display configuration; all purchases remain server validated.
local config=require(game:GetService("ReplicatedStorage"):WaitForChild("ResortDisplayConfig"))
local roadmap=frame(gui,"Roadmap",UDim2.fromScale(.5,.46),UDim2.new(.92,0,.64,0))
roadmap.AnchorPoint=Vector2.new(.5,.5) roadmap.Visible=false roadmap.ZIndex=5
local limit=Instance.new("UISizeConstraint") limit.MaxSize=Vector2.new(580,500) limit.Parent=roadmap
local heading=text(roadmap,"Heading","RESORT ROADMAP",UDim2.fromOffset(14,10),UDim2.new(1,-60,0,28),19,teal) heading.ZIndex=6
local milestone=text(roadmap,"Milestone","",UDim2.fromOffset(14,40),UDim2.new(1,-28,0,36),13) milestone.ZIndex=6
local dismiss=Instance.new("TextButton") dismiss.Text="×" dismiss.TextSize=25 dismiss.TextColor3=cream dismiss.BackgroundTransparency=1 dismiss.Position=UDim2.new(1,-44,0,8) dismiss.Size=UDim2.fromOffset(36,36) dismiss.ZIndex=6 dismiss.Parent=roadmap
local list=Instance.new("ScrollingFrame") list.Name="Steps" list.Position=UDim2.fromOffset(12,82) list.Size=UDim2.new(1,-24,1,-96) list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=4 list.CanvasSize=UDim2.fromOffset(0,#config.Upgrades*87) list.ZIndex=6 list.Parent=roadmap
local rows={}
for i,u in config.Upgrades do
    local card=frame(list,u.Id,UDim2.fromOffset(0,(i-1)*87),UDim2.new(1,-8,0,80)) card.BackgroundColor3=Color3.fromRGB(77,160,219) card.ZIndex=6
    local name=text(card,"Name",i..". "..u.Name,UDim2.fromOffset(10,5),UDim2.new(1,-20,0,22),14) name.ZIndex=7
    local benefit=text(card,"Benefit",u.Description,UDim2.fromOffset(10,28),UDim2.new(1,-20,0,22),12) benefit.ZIndex=7
    local status=text(card,"Status","",UDim2.fromOffset(10,53),UDim2.new(1,-20,0,20),12,teal) status.ZIndex=7
    rows[i]=status
end
local roadmapButton=Instance.new("TextButton") roadmapButton.Name="RoadmapButton" roadmapButton.AnchorPoint=Vector2.new(1,0) roadmapButton.Position=UDim2.new(1,-12,0,56) roadmapButton.Size=UDim2.fromOffset(118,38) roadmapButton.BackgroundColor3=dark roadmapButton.TextColor3=cream roadmapButton.Font=Enum.Font.FredokaOne roadmapButton.TextSize=12 roadmapButton.Parent=gui corner(roadmapButton)
roadmapButton.Activated:Connect(function() roadmap.Visible=not roadmap.Visible panel.Visible=false guide.Visible=not roadmap.Visible end)
dismiss.Activated:Connect(function() roadmap.Visible=false guide.Visible=true end)
book.Activated:Connect(function() roadmap.Visible=false guide.Visible=true end)
local function refreshRoadmap()
    local built=player:GetAttribute("BuiltCount") or 0
    roadmapButton.Text="BUILD "..built.."/"..#rows
    local rank=built>=6 and "GALACTIC DESTINATION" or built>=4 and "GROWING RESORT" or built>=2 and "SPACE GETAWAY" or "STARTER OUTPOST"
    milestone.Text=rank.."  •  "..built.."/"..#rows.." upgrades built"
    for i,u in config.Upgrades do
        local stage=player:GetAttribute("Stage_"..u.Id) or 0
        local prices={math.floor(u.Price*.2),math.floor(u.Price*.3),u.Price-math.floor(u.Price*.2)-math.floor(u.Price*.3)}
        local price=prices[math.min(stage+1,3)]
        if i<=built then rows[i].Text="BUILT" rows[i].TextColor3=teal
        elseif not player:GetAttribute("OwnsResort") then rows[i].Text=price.." tokens • Claim your free resort first" rows[i].TextColor3=cream
        elseif i==built+1 then rows[i].Text=tokens.Value>=price and (price.." tokens • READY — follow the build marker") or (price.." tokens • "..math.max(0,price-tokens.Value).." more needed") rows[i].TextColor3=teal
        else rows[i].Text=price.." tokens • Requires "..config.Upgrades[i-1].Name rows[i].TextColor3=cream end
        if stage<3 then rows[i].Text=config.StageNames[stage+1].." - "..rows[i].Text end
    end
end
for _,u in config.Upgrades do player:GetAttributeChangedSignal("Stage_"..u.Id):Connect(refreshRoadmap) end
player:GetAttributeChangedSignal("BuiltCount"):Connect(refreshRoadmap)
player:GetAttributeChangedSignal("OwnsResort"):Connect(refreshRoadmap)
tokens.Changed:Connect(refreshRoadmap)
refreshRoadmap()

local shopButton=roadmapButton:Clone() shopButton.Name="ShopButton" shopButton.Position=UDim2.new(1,-12,0,100) shopButton.Text="SHOP" shopButton.BackgroundColor3=Color3.fromRGB(243,117,160) shopButton.Parent=gui
local shop=frame(gui,"Shop",UDim2.fromScale(.5,.46),UDim2.new(.92,0,.64,0)) shop.AnchorPoint=Vector2.new(.5,.5) shop.Visible=false shop.ZIndex=10
local sl=limit:Clone() sl.Parent=shop
local sh=text(shop,"Heading","ROBOT SUPPLY SHOP",UDim2.fromOffset(14,12),UDim2.new(1,-60,0,30),21) sh.ZIndex=11
local sc=dismiss:Clone() sc.Parent=shop sc.ZIndex=12
local items=Instance.new("ScrollingFrame") items.Name="Items" items.Position=UDim2.fromOffset(12,55) items.Size=UDim2.new(1,-24,1,-65) items.BackgroundTransparency=1 items.BorderSizePixel=0 items.ScrollBarThickness=5 items.CanvasSize=UDim2.fromOffset(0,#config.Shop*104) items.ZIndex=11 items.Parent=shop
local shopRows={}
for i,item in config.Shop do
    local card=frame(items,item.Id,UDim2.fromOffset(0,(i-1)*104),UDim2.new(1,-8,0,96)) card.BackgroundColor3=i%2==0 and Color3.fromRGB(57,173,180) or Color3.fromRGB(209,99,169) card.ZIndex=11
    local name=text(card,"Name",item.Name,UDim2.fromOffset(10,4),UDim2.new(1,-20,0,24),18) name.ZIndex=12
    local desc=text(card,"Benefit",item.Description,UDim2.fromOffset(10,29),UDim2.new(1,-20,0,28),12) desc.ZIndex=12
    local buy=Instance.new("TextButton") buy.Name="Buy" buy.Position=UDim2.new(0,10,1,-32) buy.Size=UDim2.new(1,-20,0,27) buy.BackgroundColor3=teal buy.TextColor3=Color3.fromRGB(64,40,105) buy.Font=Enum.Font.FredokaOne buy.TextSize=14 buy.ZIndex=12 buy.Parent=card corner(buy)
    buy.Activated:Connect(function() game.ReplicatedStorage.ResortShop:FireServer("Shop",item.Id) end)
    shopRows[item.Id]=buy
end
shopButton.Activated:Connect(function() shop.Visible=not shop.Visible roadmap.Visible=false panel.Visible=false guide.Visible=not shop.Visible end)
sc.Activated:Connect(function() shop.Visible=false guide.Visible=true end)
roadmapButton.Activated:Connect(function() shop.Visible=false end)
book.Activated:Connect(function() shop.Visible=false end)
local boostLabel=text(gui,"BoostTimers","",UDim2.fromOffset(14,110),UDim2.fromOffset(225,65),13,teal)
local ticker=0
RunService.Heartbeat:Connect(function(dt)
    ticker+=dt if ticker<.25 then return end ticker=0
    local active={}
    for _,item in config.Shop do
        local seconds=math.max(0,math.ceil((player:GetAttribute(item.Id.."Until") or 0)-workspace:GetServerTimeNow()))
        local owned=player:GetAttribute("Owns"..item.Id)
        shopRows[item.Id].Text=owned and "OWNED" or seconds>0 and ("ACTIVE: "..seconds.."s") or (item.Price.." TOKENS - BUY")
        if seconds>0 then table.insert(active,item.Name..": "..seconds.."s") end
    end
    boostLabel.Text=table.concat(active,"\n")
end)
for _,o in gui:GetDescendants() do
    if o:IsA("TextButton") then
        local scale=Instance.new("UIScale") scale.Parent=o
        o.MouseEnter:Connect(function() TweenService:Create(scale,TweenInfo.new(.12),{Scale=1.04}):Play() end)
        o.MouseLeave:Connect(function() TweenService:Create(scale,TweenInfo.new(.12),{Scale=1}):Play() end)
    end
end

require(game.ReplicatedStorage:WaitForChild("SimulatorTheme")).Apply(gui,config)

-- Local-only next-stage ghost: no collision and never a purchase authority.
local preview
local function updatePreview()
    if preview then preview:Destroy() preview=nil end
    local id=player:GetAttribute("GuideTarget")
    local building=id and world.Upgrades:FindFirstChild(id)
    if not building then return end
    local stage=(player:GetAttribute("Stage_"..id) or 0)+1
    if stage>3 then return end
    preview=Instance.new("Model") preview.Name="ConstructionPreview" preview.Parent=workspace
    for _,p in building:GetDescendants() do
        if p:IsA("BasePart") and p:GetAttribute("BuildStage")==stage then
            local ghost=Instance.new("Part") ghost.Name="Preview" ghost.Size=p.Size ghost.CFrame=p.CFrame ghost.Anchored=true ghost.CanCollide=false ghost.CanTouch=false ghost.CanQuery=false ghost.Transparency=.78 ghost.Color=Color3.fromRGB(70,226,255) ghost.Material=Enum.Material.ForceField ghost.Parent=preview
        end
    end
end
player:GetAttributeChangedSignal("GuideTarget"):Connect(updatePreview)
for _,u in config.Upgrades do player:GetAttributeChangedSignal("Stage_"..u.Id):Connect(function() task.defer(updatePreview) end) end
updatePreview()

local saveStatus=text(gui,"SaveStatus","",UDim2.new(1,-250,1,-21),UDim2.fromOffset(240,16),10,Color3.fromRGB(255,255,255))
saveStatus.TextXAlignment=Enum.TextXAlignment.Right saveStatus.TextStrokeTransparency=.3
local function saving() saveStatus.Text=player:GetAttribute("SaveStatus") or "Loading..." end
player:GetAttributeChangedSignal("SaveStatus"):Connect(saving) saving()

-- Token pet shop: ownership is permanent, equipment is one companion at a time.
local pets=frame(gui,'Pets',UDim2.fromScale(.5,.48),UDim2.new(.92,0,.68,0)) pets.AnchorPoint=Vector2.new(.5,.5) pets.Visible=false pets.ZIndex=20
local maxPets=Instance.new('UISizeConstraint') maxPets.MaxSize=Vector2.new(540,520) maxPets.Parent=pets
local ph=text(pets,'Heading','ALIEN PETS',UDim2.fromOffset(14,10),UDim2.new(1,-60,0,30),21) ph.ZIndex=21
local px=Instance.new('TextButton') px.Text='X' px.Size=UDim2.fromOffset(44,40) px.Position=UDim2.new(1,-48,0,5) px.ZIndex=22 px.Parent=pets
local petList=Instance.new('ScrollingFrame') petList.BackgroundTransparency=1 petList.BorderSizePixel=0 petList.Position=UDim2.fromOffset(12,52) petList.Size=UDim2.new(1,-24,1,-64) petList.CanvasSize=UDim2.fromOffset(0,#config.PetSpecies*116) petList.ScrollBarThickness=5 petList.ZIndex=21 petList.Parent=pets
local petButtons={}
for i,spec in config.PetSpecies do
    local card=frame(petList,spec.Id,UDim2.fromOffset(0,(i-1)*116),UDim2.new(1,-8,0,108)) card.ZIndex=21 card.BackgroundColor3=spec.Color
    local n=text(card,'Name',spec.Name,UDim2.fromOffset(10,4),UDim2.new(1,-20,0,25),18,dark) n.ZIndex=22
    local d=text(card,'Description',spec.Description,UDim2.fromOffset(10,30),UDim2.new(1,-20,0,32),12,dark) d.ZIndex=22
    local buy=Instance.new('TextButton') buy.Position=UDim2.new(0,10,1,-38) buy.Size=UDim2.new(1,-20,0,32) buy.ZIndex=22 buy.Font=Enum.Font.FredokaOne buy.TextSize=14 buy.Parent=card corner(buy)
    buy.Activated:Connect(function()
        if not player:GetAttribute('OwnsResort') then notify('Claim your own plot first!') return end
        local owned=spec.Id=='Pebble' or player:GetAttribute('Pet_'..spec.Id)
        game.ReplicatedStorage.ResortShop:FireServer(owned and 'EquipPet' or 'BuyPet',spec.Id)
    end)
    petButtons[spec.Id]=buy
end
local function refreshPets()
    local ownedCount=0
    for _,spec in config.PetSpecies do
        local owned=spec.Id=='Pebble' or player:GetAttribute('Pet_'..spec.Id)==true
        if owned then ownedCount+=1 end
        petButtons[spec.Id].Text=player:GetAttribute('EquippedPet')==spec.Id and 'EQUIPPED' or owned and 'EQUIP' or (spec.Price..' TOKENS - BUY')
    end
    ph.Text='ALIEN PETS  '..ownedCount..'/'..#config.PetSpecies
end
book.Activated:Connect(function() panel.Visible=false pets.Visible=not pets.Visible shop.Visible=false roadmap.Visible=false guide.Visible=not pets.Visible end)
px.Activated:Connect(function() pets.Visible=false guide.Visible=true end)
shopButton.Activated:Connect(function() pets.Visible=false end)
roadmapButton.Activated:Connect(function() pets.Visible=false end)
player:GetAttributeChangedSignal('EquippedPet'):Connect(refreshPets)
for _,spec in config.PetSpecies do player:GetAttributeChangedSignal('Pet_'..spec.Id):Connect(refreshPets) end
refreshPets()
