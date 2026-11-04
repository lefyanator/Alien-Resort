local Players=game:GetService('Players')
local Replicated=game:GetService('ReplicatedStorage')
local Tween=game:GetService('TweenService')
local Run=game:GetService('RunService')
local Input=game:GetService('UserInputService')
local Tags=game:GetService('CollectionService')
local GuiService=game:GetService('GuiService')
local p=Players.LocalPlayer
local T=require(Replicated:WaitForChild('SimulatorTheme'))
local Visuals=require(Replicated:WaitForChild('PetVisuals'))
local config=require(Replicated:WaitForChild('ResortDisplayConfig'))
local remote=Replicated:WaitForChild('ResortShop')
local C=T.Colors
local gui=Instance.new('ScreenGui') gui.Name='AlienResortHUD' gui.ResetOnSpawn=false gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.ClipToDeviceSafeArea=true gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=p:WaitForChild('PlayerGui')
local screen=Instance.new('Frame') screen.Name='SafeArea' screen.Size=UDim2.fromScale(1,1) screen.BackgroundTransparency=1 screen.Parent=gui
local function place(o,x,y,w,h) o.Position=UDim2.fromOffset(x,y) o.Size=UDim2.fromOffset(w,h) return o end
local function label(parent,name,value,size,color,x,y,w,h,z) return place(T.Text(parent,name,value,size,color,z),x,y,w,h) end
local wallet=place(T.Panel(screen,'Wallet',C.Ink,5),12,12,200,64)
T.Round(wallet,30) T.Stroke(wallet,C.Gold,2)
local walletScale=Instance.new('UIScale') walletScale.Parent=wallet
local coin=T.Coin(wallet,34,6) coin.Position=UDim2.fromOffset(12,10)
label(wallet,'Brand','TOKENS',9,C.Gold,58,6,120,12,6)
local tokenText=label(wallet,'Tokens','0',25,C.White,58,18,130,28,6) tokenText.Font=Enum.Font.FredokaOne
local rate=label(wallet,'Income','Your island is getting ready',10,Color3.fromRGB(215,228,243),12,46,176,14,6)
local fxButton=place(T.Button(screen,'Motion','FX ON',C.Cream,6),0,12,88,40)
local motion=true
fxButton.Activated:Connect(function() motion=not motion fxButton.Text=motion and 'FX ON' or 'FX QUIET' end)
local guide=place(T.Panel(screen,'Guide',C.Ink,4),280,12,380,64) T.Round(guide,24) T.Stroke(guide,C.Gold,2) guide.BackgroundTransparency=.12
local guideTitle=label(guide,'Title','Preparing your resort...',16,C.Gold,14,7,352,22) guideTitle.Font=Enum.Font.FredokaOne
local guideDetail=label(guide,'Detail','A whole island. A tiny crew. Your next adventure.',12,C.White,14,30,352,28)
local progress=T.Panel(guide,'Progress',C.Soft,5) progress.Position=UDim2.new(0,14,1,-10) progress.Size=UDim2.new(1,-28,0,4)
local progressFill=T.Panel(progress,'Fill',C.Teal,6) progressFill.Size=UDim2.fromScale(0,1)
local nav={}
for i,spec in {{'Pets','PETS',C.Lilac},{'Build','BUILD',C.Teal},{'Shop','SHOP',C.Gold}} do
    local b=T.Button(screen,spec[1],spec[2],spec[3],6) T.NavIcon(b,spec[1]) nav[spec[1]]=b
end
local save=label(screen,'SaveStatus','',10,C.Muted,12,0,280,16,3)
local toast=T.Panel(screen,'Notice',C.Ink,80) toast.AnchorPoint=Vector2.new(.5,0) toast.Visible=false
local toastText=label(toast,'Message','',13,C.White,14,7,380,38,81)
local toastVersion=0
local function notify(message,errorStyle)
    toastVersion+=1 local id=toastVersion
    toastText.Text=message toast.BackgroundColor3=errorStyle and Color3.fromRGB(143,64,76) or C.Ink toast.Visible=true
    task.delay(3.5,function() if id==toastVersion and toast.Parent then toast.Visible=false end end)
end
local scrim=T.Button(screen,'Scrim','',C.Ink,20) scrim.Size=UDim2.fromScale(1,1) scrim.BackgroundTransparency=.35 scrim.Visible=false scrim.Selectable=false
local modal=T.Panel(screen,'Collection',C.Cream,30) modal.AnchorPoint=Vector2.new(.5,.5) modal.Position=UDim2.fromScale(.5,.5) modal.Visible=false T.Stroke(modal,C.White,2)
local heading=label(modal,'Heading','MEET YOUR COSMIC CREW',23,C.Ink,20,16,700,30,31)
heading.Font=Enum.Font.FredokaOne heading.TextColor3=C.White heading.TextStrokeColor3=C.Ink heading.TextStrokeTransparency=0
local header=T.Panel(modal,'Header',C.Coral,30) header.Size=UDim2.new(1,0,0,54)
local subtitle=label(modal,'Subtitle','Buy once. Keep forever. Explore together.',12,C.Muted,20,48,700,24,31)
local close=place(T.Button(modal,'Close','X',C.White,35),0,14,44,44)
local tabs={}
for i,name in {'Pets','Build','Shop'} do tabs[name]=place(T.Button(modal,name..'Tab',string.upper(name),C.White,32),20+(i-1)*110,82,102,38) end
local list=Instance.new('ScrollingFrame') list.Name='Cards' list.Position=UDim2.fromOffset(16,136) list.Size=UDim2.new(1,-32,1,-152) list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=5 list.ScrollBarImageColor3=C.Muted list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.ZIndex=31 list.Parent=modal
local grid=Instance.new('UIGridLayout') grid.CellPadding=UDim2.fromOffset(12,12) grid.SortOrder=Enum.SortOrder.LayoutOrder grid.Parent=list
local bottomPadding=Instance.new('UIPadding') bottomPadding.PaddingBottom=UDim.new(0,8) bottomPadding.PaddingTop=UDim.new(0,4) bottomPadding.PaddingLeft=UDim.new(0,4) bottomPadding.Parent=list
local currentTab='Pets'
local cards={} local portraits={} local pending=nil
local world=nil local target=nil local highlight=nil local destination=nil local beam=nil local marker=nil
local tokenValue=0 local tokens=nil local display=Instance.new('NumberValue')
display.Changed:Connect(function(value) tokenText.Text=T.Format(value) end)
local numberTween=nil
local coins={} local activeAliens={} local roomLabels={}
local preview=nil
local refresh,layout,open,updateWayfinder
local drawer,selectedBuild,selectedAt,activityStatus
local boosts=label(screen,'ActiveBoosts','',12,C.White,12,0,280,40,6)
boosts.TextStrokeColor3=C.Ink boosts.TextStrokeTransparency=.1
local function clearCards()
    for _,card in cards do card.Frame:Destroy() end
    cards={} portraits={}
end
local function cardBase(id,order)
    local card=T.Panel(list,id,C.White,32) card.LayoutOrder=order T.Stroke(card)
    return card
end
local function send(action,id)
    if pending then return end
    if not p:GetAttribute('OwnsResort') or not p:GetAttribute('ProfileReady') then notify('Claim your own island first. Follow the marker!',true) return end
    pending={Action=action,Id=id,At=os.clock()}
    remote:FireServer(action,id) refresh()
    local request=pending
    task.delay(3,function() if pending==request and gui.Parent then pending=nil refresh() end end)
end
local function viewport(parent,spec)
    local view=Instance.new('ViewportFrame') view.Name='CharacterPortrait' view.BackgroundColor3=spec.Color:Lerp(C.White,.83) view.BorderSizePixel=0 view.Position=UDim2.new(0,10,0,10) view.Size=UDim2.new(1,-20,0,106) view.Ambient=Color3.fromRGB(220,220,240) view.LightColor=C.White view.LightDirection=Vector3.new(-1,-1,-1) view.ZIndex=33 view.Parent=parent T.Round(view,12)
    local space=Instance.new('WorldModel') space.Parent=view
    local model=Visuals.Create(space,Vector3.zero,spec.Id)
    local camera=Instance.new('Camera') camera.FieldOfView=34 camera.CFrame=CFrame.lookAt(Vector3.new(4,2,-8.5),Vector3.new(0,.05,0)) camera.Parent=view view.CurrentCamera=camera
    table.insert(portraits,{Model=model,Index=#portraits+1,View=view})
end
local function makePets()
    for i,spec in config.PetSpecies do
        local card=cardBase(spec.Id,i) viewport(card,spec)
        local overline=label(card,'Species',string.upper(spec.Name)..' / '..spec.Role,9,C.Muted,12,122,160,24,33) overline.Size=UDim2.new(1,-24,0,24)
        local name=label(card,'Name',spec.CharacterName,22,C.Ink,12,148,160,28,33) name.Size=UDim2.new(1,-24,0,28)
        local bio=label(card,'Personality',spec.Personality,11,C.Muted,12,178,160,32,33) bio.Size=UDim2.new(1,-24,0,32)
        local benefit=label(card,'Benefit',spec.Bonus>0 and ('+'..spec.Bonus..' per '..spec.Name..' guest payout') or 'Free starter companion',10,C.Ink,12,214,160,18,33) benefit.Size=UDim2.new(1,-24,0,24)
        local button=T.Button(card,'Action','',C.Gold,34) button.Position=UDim2.new(0,10,1,-54) button.Size=UDim2.new(1,-20,0,44)
        button.Activated:Connect(function()
            if p:GetAttribute('EquippedPet')==spec.Id then notify(spec.CharacterName..' is already adventuring with you.') return end
            local owned=spec.Id=='Pebble' or p:GetAttribute('Pet_'..spec.Id)
            if not owned and tokenValue<spec.Price then notify('Save '..T.Format(spec.Price-tokenValue)..' more tokens to meet '..spec.CharacterName..'.',true) return end
            send(owned and 'EquipPet' or 'BuyPet',spec.Id)
        end)
        table.insert(cards,{Frame=card,Button=button,Spec=spec})
    end
end
local function makeShop()
    for i,item in config.Shop do
        local card=cardBase(item.Id,i)
        local badge=label(card,'Icon',({Cleaner='⚙',Turbo='ϟ',Foam='✦',Beacon='◉',Garden='❀',Tables='☕'})[item.Id],28,C.Teal,12,8,34,36,33) badge.TextXAlignment=Enum.TextXAlignment.Center
        local name=label(card,'Name',item.Name,16,C.Ink,52,10,180,34,33) name.Size=UDim2.new(1,-64,0,34)
        local detail=label(card,'Description',item.Description,12,C.Muted,12,52,220,48,33) detail.Size=UDim2.new(1,-24,0,48)
        local typeText=item.Duration and ('BOOST / '..item.Duration..' SECONDS') or 'PERMANENT UPGRADE'
        local typeLabel=label(card,'Type',typeText,9,C.Muted,12,107,220,16,33) typeLabel.Size=UDim2.new(1,-24,0,16)
        local button=T.Button(card,'Action','',C.Gold,34) button.Position=UDim2.new(0,10,1,-54) button.Size=UDim2.new(1,-20,0,44)
        button.Activated:Connect(function() send('Shop',item.Id) end)
        table.insert(cards,{Frame=card,Button=button,Spec=item})
    end
end
local function stagePrice(u,stage)
    local first=math.floor(u.Price*.2) local second=math.floor(u.Price*.3)
    return ({first,second,u.Price-first-second})[math.min(stage+1,3)]
end
local function makeBuild()
    for i,u in config.Upgrades do
        local card=cardBase(u.Id,i)
        local badge=place(T.Panel(card,'Number',C.Soft,33),12,12,38,38)
        local n=label(badge,'Text',string.format('%02d',i),16,C.Teal,0,0,38,38,34) n.TextXAlignment=Enum.TextXAlignment.Center
        local name=label(card,'Name',u.Name,14,C.Ink,62,10,400,25,33) name.Size=UDim2.new(1,-74,0,25)
        local info=label(card,'Benefit',u.Description,11,C.Muted,62,36,400,32,33) info.Size=UDim2.new(1,-74,0,32)
        local status=label(card,'Stage','',11,C.Ink,12,76,400,20,33) status.Size=UDim2.new(1,-24,0,20)
        local segments={}
        for j=1,3 do local segment=T.Panel(card,'Stage'..j,C.Soft,33) segment.Position=UDim2.new((j-1)/3,12-(j-1)*8,0,104) segment.Size=UDim2.new(1/3,-16,0,5) segments[j]=segment end
        local button=T.Button(card,'Action','',C.Teal,34) button.Position=UDim2.new(0,10,1,-54) button.Size=UDim2.new(1,-20,0,44)
        button.Activated:Connect(function()
            local stage=p:GetAttribute('Stage_'..u.Id) or 0
            if not p:GetAttribute('OwnsResort') then notify('Claim your island first.',true) return end
            if stage==3 then notify('This building is complete.') return end
            if i>1 and (p:GetAttribute('Stage_'..config.Upgrades[i-1].Id) or 0)<3 then notify('Finish '..config.Upgrades[i-1].Name..' first.',true) return end
            selectedBuild=u.Id selectedAt=os.clock() open(nil) updateWayfinder() notify('Follow the marker to '..u.Name..'.')
        end)
        table.insert(cards,{Frame=card,Button=button,Spec=u,Status=status,Segments=segments,Index=i})
    end
end
layout=function()
    local w,h=screen.AbsoluteSize.X,screen.AbsoluteSize.Y if w<1 then return end
    local compact=w<920
    place(wallet,12,12,math.min(200,w-104),64)
    tokenText.Size=UDim2.new(1,-70,0,28) rate.Size=UDim2.new(1,-24,0,14)
    place(fxButton,w-80,12,68,36) fxButton.TextSize=11
    local names={'Pets','Build','Shop','Adventure'}
    if h<500 and w>=600 then
        place(guide,224,12,w-320,64)
        for i,name in names do if nav[name] then place(nav[name],12+((i-1)%2)*76,94+math.floor((i-1)/2)*76,64,64) end end
    elseif compact then
        place(guide,12,88,w-24,64)
        local bw=math.min(76,(w-48)/4)
        for i,name in names do if nav[name] then place(nav[name],12+(i-1)*(bw+8),164,bw,70) end end
    else
        local gw=math.min(380,w-440) place(guide,(w-gw)/2,12,gw,64)
        for i,name in names do if nav[name] then place(nav[name],12,104+(i-1)*86,70,70) end end
    end
    guideTitle.Size=UDim2.new(1,-28,0,22) guideDetail.Size=UDim2.new(1,-28,0,28)
    place(save,12,h-20,w-24,16)
    place(boosts,12,h-68,math.min(320,w-24),44)
    local mw=math.min(900,w-24) local mh=math.min(590,h-24)
    modal.Size=UDim2.fromOffset(mw,mh) close.Position=UDim2.new(1,-60,0,14)
    heading.Size=UDim2.new(1,-90,0,30) heading.TextSize=mw<500 and 18 or 23
    subtitle.Size=UDim2.new(1,-40,0,24)
    local tabWidth=(mw-56)/3
    for i,name in {'Pets','Build','Shop'} do place(tabs[name],20+(i-1)*(tabWidth+8),82,tabWidth,38) end
    local short=h<500
    subtitle.Visible=not short
    heading.Position=UDim2.fromOffset(20,short and 10 or 16)
    for i,name in {'Pets','Build','Shop'} do place(tabs[name],20+(i-1)*(tabWidth+8),short and 48 or 82,tabWidth,44) end
    list.Position=UDim2.fromOffset(16,short and 104 or 136)
    list.Size=UDim2.new(1,-32,1,short and -116 or -152)
    local available=mw-42
    local columns=currentTab=='Build' and (mw>700 and 2 or 1) or math.max(1,math.min(currentTab=='Pets' and 4 or 3,math.floor((available+12)/190)))
    if currentTab=='Pets' and available>=300 and columns==1 then columns=2 end
    local rowHeight=currentTab=='Pets' and (short and 184 or 298) or currentTab=='Build' and 180 or (short and 180 or 188)
    local count=currentTab=='Pets' and #config.PetSpecies or currentTab=='Build' and #config.Upgrades or #config.Shop
    local rows=math.ceil(count/columns)
    mh=math.min(mh,(short and 116 or 152)+rows*(rowHeight+12)-12)
    modal.Size=UDim2.fromOffset(mw,mh)
    grid.CellSize=UDim2.fromOffset(math.floor((available-(columns-1)*12)/columns),rowHeight)
    if currentTab=='Pets' then
        for _,entry in cards do
            local f=entry.Frame
            f.CharacterPortrait.Position=UDim2.fromOffset(10,short and 8 or 10)
            f.CharacterPortrait.Size=UDim2.new(1,-20,0,short and 62 or 106)
            local overline=f:FindFirstChild('Species') overline.Position=UDim2.fromOffset(12,short and 72 or 122) overline.Size=UDim2.new(1,-24,0,short and 12 or 24)
            local name=f:FindFirstChild('Name') name.Position=UDim2.fromOffset(12,short and 86 or 148) name.TextSize=short and 18 or 22 name.Size=UDim2.new(1,-24,0,short and 22 or 28)
            f.Personality.Visible=not short
            f.Benefit.Position=UDim2.fromOffset(12,short and 110 or 214) f.Benefit.Size=UDim2.new(1,-24,0,short and 16 or 24)
        end
    end
    toast.Size=UDim2.fromOffset(math.min(440,w-24),54) toast.Position=UDim2.new(.5,0,0,compact and math.min(252,h-72) or 118) toastText.Size=UDim2.new(1,-28,1,-14)
end
open=function(name)
    if drawer then drawer.Visible=false end
    if not name then modal.Visible=false scrim.Visible=false return end
    currentTab=name clearCards()
    if name=='Pets' then makePets() elseif name=='Shop' then makeShop() else makeBuild() end
    heading.Text=name=='Pets' and 'MEET YOUR COSMIC CREW' or name=='Shop' and 'RESORT SUPPLY STATION' or 'BUILD YOUR LITTLE UNIVERSE'
    subtitle.Text=name=='Pets' and 'One companion equipped. Every friendship stays yours.' or name=='Shop' and 'Useful upgrades. Clear prices. All bought with tokens.' or 'Three stages per building. Use your island build pads.'
    for tab,button in tabs do button.BackgroundColor3=tab==name and C.Ink or C.White button.TextColor3=tab==name and C.White or C.Ink end
    list.CanvasPosition=Vector2.zero modal.Visible=true scrim.Visible=true layout() refresh()
    if Input:GetLastInputType()==Enum.UserInputType.Gamepad1 then GuiService.SelectedObject=close end
end
for name,button in nav do button.Activated:Connect(function() open(name) end) end
for name,button in tabs do button.Activated:Connect(function() open(name) end) end
close.Activated:Connect(function() open(nil) end) scrim.Activated:Connect(function() open(nil) end)
Input.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.ButtonB then open(nil)
    elseif input.KeyCode==Enum.KeyCode.ButtonY or input.KeyCode==Enum.KeyCode.P then open('Pets')
    elseif input.KeyCode==Enum.KeyCode.B then open('Build')
    elseif input.KeyCode==Enum.KeyCode.M then open('Shop') end
end)
local function guideTarget(id)
    if not world then return end
    if id and id:sub(1,6)=='Clean_' then
        local name=id:sub(7) local room=name=='StarterRoom' and world.StarterRoom or world.Upgrades:FindFirstChild(name)
        if room then return room.Floor,room,'CLEAN ROOM' end
    elseif id=='CommonsShuttle' and world:FindFirstChild('CommonsShuttle') then return world.CommonsShuttle,world.CommonsShuttle,'ADVENTURE SHUTTLE'
    elseif id=='ClaimTerminal' then return world.ClaimTerminal,world.ClaimTerminal,'CLAIM YOUR ISLAND'
    elseif id=='LandingPad' then return world.LandingPad.LandingSurface,world.LandingPad,'GUEST ARRIVING'
    elseif id=='StarterRoom' then return world.StarterRoom.Floor,world.StarterRoom,'GUEST INCOME'
    elseif id and world.BuildPads:FindFirstChild(id) then return world.BuildPads[id],world.BuildPads[id],'BUILD NEXT STAGE' end
end
updateWayfinder=function()
    if not world or not marker then return end
    if selectedBuild and ((p:GetAttribute('Stage_'..selectedBuild) or 0)==3 or os.clock()-selectedAt>30) then selectedBuild=nil end
    local id=selectedBuild or p:GetAttribute('GuideTarget')
    local part,object,caption=guideTarget(id) target=part
    marker.Enabled=part~=nil marker.Adornee=part marker.Caption.Text='▼\n'..(caption or '')
    highlight.Enabled=object~=nil highlight.Adornee=object
    destination.Parent=part beam.Enabled=part~=nil
    if preview then preview:Destroy() preview=nil end
    local building=id and world.Upgrades:FindFirstChild(id)
    if not building or not p:GetAttribute('OwnsResort') then return end
    local stage=(p:GetAttribute('Stage_'..id) or 0)+1
    if stage>3 then return end
    preview=Instance.new('Model') preview.Name='LocalConstructionPreview' preview.Parent=workspace
    for _,part in building:GetDescendants() do
        if part:IsA('BasePart') and part:GetAttribute('BuildStage')==stage then
            local ghost=part:Clone() ghost:ClearAllChildren() ghost.Anchored=true ghost.CanCollide=false ghost.CanTouch=false ghost.CanQuery=false ghost.CastShadow=false ghost.Transparency=.86 ghost.Color=C.Teal ghost.Material=Enum.Material.ForceField ghost.Parent=preview
        end
    end
end
refresh=function()
    local owner=p:GetAttribute('OwnsResort')==true
    local occupied=p:GetAttribute('OccupiedRooms') or 0
    rate.Text=owner and (occupied..' room'..(occupied==1 and '' or 's')..' / +'..T.Format(p:GetAttribute('IncomePerTick') or 0)..' every '..config.IncomeInterval..'s') or 'Claim your own island to begin'
    guideTitle.Text=p:GetAttribute('GuideTitle') or 'Preparing your resort...'
    guideDetail.Text=p:GetAttribute('GuideDetail') or 'Loading your progress safely.'
    save.Text=p:GetAttribute('SaveStatus') or 'Loading progress...'
    local cost=p:GetAttribute('NextCost') or 0
    progress.Visible=cost>0 progressFill.Size=UDim2.fromScale(cost>0 and math.clamp(tokenValue/cost,0,1) or 0,1)
    for _,entry in cards do
        local spec=entry.Spec local button=entry.Button local text,color
        if currentTab=='Pets' then
            local owned=spec.Id=='Pebble' or p:GetAttribute('Pet_'..spec.Id)==true
            if p:GetAttribute('EquippedPet')==spec.Id then text='EQUIPPED  ✓' color=C.Teal
            elseif owned then text='EQUIP '..string.upper(spec.CharacterName) color=C.Soft
            else text=T.Format(spec.Price)..' TOKENS / ADOPT' color=tokenValue>=spec.Price and C.Gold or C.Soft end
        elseif currentTab=='Shop' then
            local seconds=math.max(0,math.ceil((p:GetAttribute(spec.Id..'Until') or 0)-workspace:GetServerTimeNow()))
            if not spec.Duration and p:GetAttribute('Owns'..spec.Id) then text='OWNED  ✓' color=C.Teal
            elseif seconds>0 then text='ACTIVE / '..seconds..'s' color=C.Lilac
            else text=T.Format(spec.Price)..' TOKENS / BUY' color=tokenValue>=spec.Price and C.Gold or C.Soft end
        else
            local stage=p:GetAttribute('Stage_'..spec.Id) or 0
            local previous=entry.Index==1 or (p:GetAttribute('Stage_'..config.Upgrades[entry.Index-1].Id) or 0)==3
            entry.Status.Text=stage==3 and 'COMPLETE / READY FOR GUESTS' or (config.StageNames[stage+1]..' / '..T.Format(stagePrice(spec,stage))..' tokens')
            for i,segment in entry.Segments do segment.BackgroundColor3=stage>=i and C.Teal or C.Soft end
            if stage==3 then text='BUILT  ✓' color=C.Soft
            elseif not previous then text='FINISH PREVIOUS BUILDING' color=C.Soft
            else text='SHOW MY BUILD PAD  →' color=C.Teal end
        end
        if pending and pending.Id==spec.Id then text='ONE MOMENT...' color=C.Soft end
        button.Text=not owner and 'CLAIM YOUR ISLAND FIRST' or text button.BackgroundColor3=color or C.Soft
    end
end
local function earnings(amount)
    local pop=T.Panel(screen,'Gain',C.Gold,92) pop.Size=UDim2.fromOffset(290,34) pop.AnchorPoint=Vector2.new(.5,0)
    local text=label(pop,'Text','CHA-CHING!  +'..T.Format(amount),17,C.Ink,0,0,290,34,93) text.TextXAlignment=Enum.TextXAlignment.Center
    local w=screen.AbsoluteSize.X local popupWidth=math.min(290,w-24) pop.Size=UDim2.fromOffset(popupWidth,34) text.Size=UDim2.fromScale(1,1)
    pop.Position=UDim2.fromOffset(w*.5,screen.AbsoluteSize.Y-(w<600 and 200 or 110))
    task.delay(.85,function()
        if pop.Parent then
            Tween:Create(text,TweenInfo.new(.3),{TextTransparency=1}):Play()
            Tween:Create(pop,TweenInfo.new(.3),{BackgroundTransparency=1,Position=pop.Position-UDim2.fromOffset(0,motion and 16 or 0)}):Play()
            task.delay(.32,function() pop:Destroy() end)
        end
    end)
    if not motion then return end
    walletScale.Scale=1.06 Tween:Create(walletScale,TweenInfo.new(.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
    local targetPoint=Vector2.new(wallet.Position.X.Offset+36,wallet.Position.Y.Offset+46)
    for i=1,math.min(8,math.max(4,math.floor(amount/3))) do
        local c=T.Coin(screen,22,90) c.AnchorPoint=Vector2.new(.5,.5)
        local start=Vector2.new(w*.5+(i-4)*20,screen.AbsoluteSize.Y*.57+(i%3)*12)
        c.Position=UDim2.fromOffset(start.X,start.Y)
        table.insert(coins,{Frame=c,Start=start,Finish=targetPoint,Control=Vector2.new((start.X+targetPoint.X)/2,math.max(30,targetPoint.Y-110)),At=os.clock()+i*.035})
    end
end
tokens=p:WaitForChild('leaderstats'):WaitForChild('Tokens') tokenValue=tokens.Value display.Value=tokenValue
tokens.Changed:Connect(function(value)
    local gain=value-tokenValue tokenValue=value
    if numberTween then numberTween:Cancel() end
    numberTween=Tween:Create(display,TweenInfo.new(motion and .35 or 0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=value}) numberTween:Play()
    if gain>0 and p:GetAttribute('ProfileReady') then earnings(gain) end
    refresh()
end)
p.AttributeChanged:Connect(function(key)
    if key=='GuideTarget' or key:sub(1,6)=='Stage_' then updateWayfinder() end
    if key=='NoticeVersion' then pending=nil notify(p:GetAttribute('ResortNotice') or '') end
    refresh()
end)
local function alienAdded(model) if model:IsA('Model') then activeAliens[model]={Last=model:GetPivot().Position,Follow=model:GetPivot()} end end
for _,model in Tags:GetTagged('ResortAlien') do alienAdded(model) end
Tags:GetInstanceAddedSignal('ResortAlien'):Connect(alienAdded)
Tags:GetInstanceRemovedSignal('ResortAlien'):Connect(function(model) activeAliens[model]=nil end)
task.spawn(function()
    while not p:GetAttribute('PlotName') do p:GetAttributeChangedSignal('PlotName'):Wait() end
    world=workspace:WaitForChild('ResortPlots'):WaitForChild(p:GetAttribute('PlotName'))
    world:WaitForChild('StarterRoom'):WaitForChild('Floor') world:WaitForChild('Upgrades'):WaitForChild('Room3'):WaitForChild('Floor')
    marker=Instance.new('BillboardGui') marker.Name='NextStepMarker' marker.Size=UDim2.fromOffset(120,48) marker.StudsOffsetWorldSpace=Vector3.new(0,7,0) marker.AlwaysOnTop=true marker.MaxDistance=100 marker.Parent=gui
    local caption=label(marker,'Caption','',13,C.Gold,0,0,120,48,5) caption.TextXAlignment=Enum.TextXAlignment.Center caption.TextStrokeTransparency=.35
    highlight=Instance.new('Highlight') highlight.FillColor=C.Teal highlight.FillTransparency=.82 highlight.OutlineColor=C.Cream highlight.Parent=world
    destination=Instance.new('Attachment') destination.Position=Vector3.new(0,1.5,0)
    beam=Instance.new('Beam') beam.Color=ColorSequence.new(C.Teal) beam.Width0=.14 beam.Width1=.14 beam.FaceCamera=true beam.Attachment1=destination beam.Parent=world
    local function character(c)
        local hrp=c:WaitForChild('HumanoidRootPart',10)
        if hrp then local a=Instance.new('Attachment') a.Position=Vector3.new(0,-2,0) a.Parent=hrp beam.Attachment0=a end
    end
    p.CharacterAdded:Connect(character) if p.Character then task.spawn(character,p.Character) end
    for _,room in {world.StarterRoom,world.Upgrades.Room2,world.Upgrades.Room3} do
        local bb=Instance.new('BillboardGui') bb.Size=UDim2.fromOffset(150,40) bb.Adornee=room.Floor bb.StudsOffsetWorldSpace=Vector3.new(0,14,0) bb.MaxDistance=22 bb.Parent=gui
        local panel=T.Panel(bb,'Room',C.Ink,2) panel.Size=UDim2.fromScale(1,1)
        local text=label(panel,'Status','',12,C.White,8,4,164,38,3) text.TextXAlignment=Enum.TextXAlignment.Center
        table.insert(roomLabels,{Room=room,Gui=bb,Text=text})
    end
    updateWayfinder()
end)
local quarter=0 local sceneClock=0
Run.RenderStepped:Connect(function(dt)
    local now=os.clock()
    for model,state in activeAliens do
        local owner=model:GetAttribute('OwnerUserId')
        local player=owner and Players:GetPlayerByUserId(owner)
        local hrp=player and player.Character and player.Character:FindFirstChild('HumanoidRootPart')
        if hrp and model.Parent then
            local goal=hrp.CFrame*CFrame.new(3,-1.5,3)
            state.Follow=Visuals.Follow(state.Follow,goal,dt)
            model:PivotTo(state.Follow)
        end
    end
    for i=#coins,1,-1 do
        local entry=coins[i] local t=math.clamp((now-entry.At)/.7,0,1)
        local point=(1-t)^2*entry.Start+2*(1-t)*t*entry.Control+t*t*entry.Finish
        entry.Frame.Position=UDim2.fromOffset(point.X,point.Y) entry.Frame.Rotation=t*160
        if t>=1 then entry.Frame:Destroy() table.remove(coins,i) end
    end
    if modal.Visible and currentTab=='Pets' then
        for _,portrait in portraits do
            if motion then portrait.Model:PivotTo(CFrame.new(0,math.sin(now*1.5+portrait.Index)*.08,0)*CFrame.Angles(0,math.sin(now*.6)*.18,0)) end
            Visuals.Animate(portrait.Model,motion and now or 0,false)
        end
    end
    if marker and motion then marker.StudsOffsetWorldSpace=Vector3.new(0,7+math.sin(now*2.5)*.25,0) end
    sceneClock+=dt
    if sceneClock>=1/30 then
        sceneClock=0 local camera=workspace.CurrentCamera
        for model,state in activeAliens do
            if model.Parent and camera and model:IsDescendantOf(workspace) and (model:GetPivot().Position-camera.CFrame.Position).Magnitude<190 then
                local position=model:GetPivot().Position local moving=(position-state.Last).Magnitude>.035 state.Last=position
                Visuals.Animate(model,motion and now or 0,moving and motion)
            end
        end
    end
    quarter+=dt if quarter<.25 then return end quarter=0
    if drawer and drawer.Visible and activityStatus then activityStatus() end
    local active={}
    for _,id in {'Turbo','Foam','Beacon'} do local left=math.ceil((p:GetAttribute(id..'Until') or 0)-workspace:GetServerTimeNow()) if left>0 then table.insert(active,string.upper(id)..' '..left..'s') end end
    boosts.Text=table.concat(active,'  /  ')
    if selectedBuild and os.clock()-selectedAt>30 then selectedBuild=nil updateWayfinder() end
    if modal.Visible and currentTab=='Shop' then refresh() end
    for _,entry in roomLabels do
        local room=entry.Room
        entry.Gui.Enabled=room.Floor.Transparency<1 and room:GetAttribute('Occupied')==true and (room:GetAttribute('Stage')==nil or room:GetAttribute('Stage')==3)
        local status=room:GetAttribute('GuestStatus') or 'Ready for guests'
        if status=='Occupied' then
            local seconds=math.max(0,math.ceil((room:GetAttribute('NextPaymentAt') or 0)-workspace:GetServerTimeNow()))
            entry.Text.Text=(room:GetAttribute('GuestSpecies') or 'Alien')..' checked in\nNext payout in '..seconds..'s'
        else entry.Text.Text=status end
    end
end)
screen:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
layout() refresh()
-- Mesh portraits may be opened before their shared surface has streamed in.
-- Preload instances (not raw mesh IDs, which are interpreted as image content).
task.spawn(function()
    local templates=Replicated:WaitForChild('PetTemplates',5)
    if not templates then return end
    local ok=pcall(function() game:GetService('ContentProvider'):PreloadAsync({templates}) end)
    if ok and modal.Visible and currentTab=='Pets' then open('Pets') end
end)

-- Adventure drawer: travel, useful pet actions, jobs, and progression.
local adventureRemote=Replicated:WaitForChild('ResortAdventure')
local play=T.Button(screen,'Adventure','ADVENTURE',C.Teal,8)
T.NavIcon(play,'Adventure') nav.Adventure=play
drawer=T.Panel(screen,'AdventureDrawer',C.Cream,45) drawer.AnchorPoint=Vector2.new(.5,.5) drawer.Position=UDim2.fromScale(.5,.5) drawer.Visible=false T.Stroke(drawer)
local title=label(drawer,'Title','BUILD. BOND. ADVENTURE.',17,C.Ink,14,12,400,25,46)
local summary=label(drawer,'Progress','',13,C.Ink,14,44,400,112,46)
local exit=T.Button(drawer,'Close','X',C.White,48) exit.Position=UDim2.new(1,-52,0,8) exit.Size=UDim2.fromOffset(44,44)
local actions=Instance.new('ScrollingFrame') actions.Position=UDim2.fromOffset(12,164) actions.Size=UDim2.new(1,-24,1,-176) actions.AutomaticCanvasSize=Enum.AutomaticSize.Y actions.CanvasSize=UDim2.new() actions.BackgroundTransparency=1 actions.BorderSizePixel=0 actions.ScrollBarThickness=5 actions.ZIndex=46 actions.Parent=drawer
local actionGrid=Instance.new('UIGridLayout') actionGrid.CellPadding=UDim2.fromOffset(8,8) actionGrid.Parent=actions
local definitions={{'Commons','TO THE COMMONS'},{'Home','RETURN HOME'},{'Ability','USE PET ABILITY'},{'Evolve','EVOLVE AT LAB'},{'Request','ACCEPT GUEST REQUEST'},{'Deliver','DELIVER REQUEST'},{'Job','PIP: WORK / REST','Pebble'},{'Job','JUNO: WORK / REST','Jelly'},{'Job','SPROUT: WORK / REST','Slime'},{'Job','EMBER: WORK / REST','Lava'}}
local actionButtons={} local lastAction=0
for i,entry in definitions do
    local button=T.Button(actions,'Action'..i,entry[2],i%2==0 and C.Soft or C.Teal,47) button.LayoutOrder=i button.TextSize=11 actionButtons[i]=button
    button.Activated:Connect(function()
        if not p:GetAttribute('OwnsResort') then notify('Claim your island first.',true) return end
        if os.clock()-lastAction<.4 then return end lastAction=os.clock()
        adventureRemote:FireServer(entry[1],entry[3]) if entry[1]=='Home' or entry[1]=='Commons' then open(nil) end
    end)
end
local function activityLayout()
    local w,h=screen.AbsoluteSize.X,screen.AbsoluteSize.Y
    layout()
    drawer.Size=UDim2.fromOffset(math.min(520,w-24),math.min(490,h-24)) title.Size=UDim2.new(1,-78,0,25) summary.Size=UDim2.new(1,-28,0,112)
    actionGrid.CellSize=UDim2.new(.5,-8,0,44)
end
activityStatus=function()
    local id=p:GetAttribute('EquippedPet') or 'Pebble'
    for i=7,10 do
        local entry=definitions[i] local pet=entry[3]
        local owned=pet=='Pebble' or p:GetAttribute('Pet_'..pet)
        actionButtons[i].Text=not owned and ('ADOPT '..string.upper(pet)..' FIRST') or p:GetAttribute('PetJob')==pet and (string.upper(pet)..': REST') or entry[2]
        actionButtons[i].Interactable=owned==true actionButtons[i].BackgroundColor3=owned and C.Teal or C.Soft
    end
    local cooldown=math.max(0,math.ceil((p:GetAttribute('AbilityUntil') or 0)-workspace:GetServerTimeNow()))
    summary.Text='SHARDS '..(p:GetAttribute('StarShards') or 0)..'/'..config.Adventure.EvolutionShards..'    BOND '..(p:GetAttribute('Bond_'..id) or 0)..'/'..config.Adventure.EvolutionBond..'\nJob: '..(p:GetAttribute('PetJob') or 'none')..' / Power: '..(cooldown>0 and (cooldown..'s') or 'READY')..'\n'..(p:GetAttribute('ActivityProgress') or 'Build your resort, then explore the Commons.')..(p:GetAttribute('ArenaTeam') and ('\nTEAM '..p:GetAttribute('ArenaTeam')..' / '..(p:GetAttribute('ArenaSeconds') or 0)..'s') or '')
end
play.Activated:Connect(function() local was=drawer.Visible open(nil) drawer.Visible=not was scrim.Visible=not was activityStatus() if not was then GuiService.SelectedObject=exit end end)
exit.Activated:Connect(function() open(nil) end)
for name,button in nav do if name~='Adventure' then button.Activated:Connect(function() drawer.Visible=false end) end end
p.AttributeChanged:Connect(activityStatus) screen:GetPropertyChangedSignal('AbsoluteSize'):Connect(activityLayout)
activityLayout() activityStatus()
