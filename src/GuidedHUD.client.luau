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
local tooltip=T.Panel(screen,'Tooltip',C.Ink,100) tooltip.Visible=false tooltip.Size=UDim2.fromOffset(240,44) T.Stroke(tooltip,C.Lilac,1)
local tooltipText=label(tooltip,'Text','',12,C.White,10,4,220,36,101)
local function hint(button,text)
    local function show() if Input.TouchEnabled and not Input.MouseEnabled then return end tooltipText.Text=text local pos=button.AbsolutePosition-screen.AbsolutePosition tooltip.Position=UDim2.fromOffset(math.clamp(pos.X+button.AbsoluteSize.X+10,8,math.max(8,screen.AbsoluteSize.X-248)),math.clamp(pos.Y,8,math.max(8,screen.AbsoluteSize.Y-52))) tooltip.Visible=true end
    local function hide() tooltip.Visible=false end
    button.MouseEnter:Connect(show) button.MouseLeave:Connect(hide) button.SelectionGained:Connect(show) button.SelectionLost:Connect(hide)
end
local wallet=place(T.Panel(screen,'Wallet',C.Ink,5),12,12,200,64)
T.Round(wallet,30) T.Stroke(wallet,C.Gold,2)
local walletScale=Instance.new('UIScale') walletScale.Parent=wallet
local coin=T.Coin(wallet,34,6) coin.Position=UDim2.fromOffset(12,10)
label(wallet,'Brand','TOKENS',9,C.Gold,58,6,120,12,6)
local tokenText=label(wallet,'Tokens','0',25,C.White,58,18,130,28,6) tokenText.Font=Enum.Font.FredokaOne
local rate=label(wallet,'Income','Your island is getting ready',10,Color3.fromRGB(215,228,243),12,46,176,14,6)
local fxButton=place(T.Button(screen,'Motion','SETTINGS',C.Cream,6),0,12,88,44)
local motion,roomStatus,soundOn=p:GetAttribute('ReducedMotion')~=true,true,p:GetAttribute('SoundsEnabled')~=false
local settings,arena,arenaRefresh,settingsRefresh,resultSheet
local tutorial
local playFeedback=function() end
local guide=place(T.Panel(screen,'Guide',C.Ink,4),280,12,440,124) T.Round(guide,24) T.Stroke(guide,C.Gold,2) guide.BackgroundTransparency=.12
local guideStep=label(guide,'Step','YOUR FIRST TEN MINUTES',10,C.Teal,14,7,300,14)
local guideTitle=label(guide,'Title','Preparing your resort...',16,C.Gold,14,23,300,36) guideTitle.Font=Enum.Font.FredokaOne
local guideDetail=label(guide,'Detail','A whole island. A tiny crew. Your next adventure.',12,C.White,14,62,412,44)
local guideAction=place(T.Button(guide,'NextAction','BUILD →',C.Teal,7),0,16,76,44) guideAction.Position=UDim2.new(1,-90,0,16) guideAction.TextSize=11 guideAction.Visible=false
local progress=T.Panel(guide,'Progress',C.Soft,5) progress.BackgroundTransparency=1 progress.Position=UDim2.new(0,14,1,-10) progress.Size=UDim2.new(1,-28,0,4)
local guideSegments={}
for i=1,6 do
    local segment=T.Panel(progress,'Step'..i,C.Soft,6) segment.Position=UDim2.new((i-1)/6,2,0,0) segment.Size=UDim2.new(1/6,-4,1,0) guideSegments[i]=segment
end
local nav={}
for i,spec in {{'Pets','PETS',C.Lilac},{'Build','BUILD',C.Teal},{'Shop','SHOP',C.Gold}} do
    local b=T.Button(screen,spec[1],spec[2],spec[3],6) T.NavIcon(b,spec[1]) nav[spec[1]]=b
    hint(b,({Pets='Your companions • adopt, equip and evolve [P]',Build='Plan the next stage of your resort [B]',Shop='Helpers, decorations and timed boosts [M]'})[spec[1]])
end
local save=label(screen,'SaveStatus','',10,C.Muted,12,0,280,16,3)
local toast=T.Panel(screen,'Notice',C.Ink,80) toast.AnchorPoint=Vector2.new(.5,0) toast.Visible=false
local toastText=label(toast,'Message','',13,C.White,14,7,380,38,81)
local toastScale=Instance.new('UIScale') toastScale.Parent=toast
local toastVersion=0
local function notify(message,errorStyle,feedbackKind)
    toastVersion+=1 local id=toastVersion
    toastText.Text=message toast.BackgroundColor3=errorStyle and Color3.fromRGB(143,64,76) or C.Ink toast.Visible=true
    toastScale.Scale=motion and .96 or 1
    if motion then Tween:Create(toastScale,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play() end
    if not errorStyle then playFeedback(feedbackKind) end
    task.delay(3.5,function() if id==toastVersion and toast.Parent then toast.Visible=false end end)
end
local scrim=T.Button(screen,'Scrim','',C.Ink,20) scrim.Size=UDim2.fromScale(1,1) scrim.BackgroundTransparency=.35 scrim.Visible=false scrim.Selectable=false
local modal=T.Panel(screen,'Collection',C.Cream,30) modal.AnchorPoint=Vector2.new(.5,.5) modal.Position=UDim2.fromScale(.5,.5) modal.Visible=false T.Window(modal,C.Lilac)
local heading=label(modal,'Heading','MEET YOUR COSMIC CREW',23,C.Ink,20,16,700,30,31)
heading.Font=Enum.Font.FredokaOne heading.TextColor3=C.White heading.TextStrokeColor3=C.Ink heading.TextStrokeTransparency=0
heading.TextScaled=true
local headingTextSize=Instance.new('UITextSizeConstraint') headingTextSize.MinTextSize=10 headingTextSize.MaxTextSize=23 headingTextSize.Parent=heading
local header=modal.Accent
local subtitle=label(modal,'Subtitle','Buy once. Keep forever. Explore together.',12,C.White,20,68,700,24,31)
local close=place(T.Button(modal,'Close','X',C.Coral,35),0,14,44,44)
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
local coins={} local activeAliens={} local roomLabels={} local scenery={}
local function sceneryAdded(model) if model:IsA('Model') then scenery[model]=model:GetPivot() end end
for _,model in Tags:GetTagged('CosmicScenery') do sceneryAdded(model) end
Tags:GetInstanceAddedSignal('CosmicScenery'):Connect(sceneryAdded)
Tags:GetInstanceRemovedSignal('CosmicScenery'):Connect(function(model)scenery[model]=nil end)
local preview=nil
local refresh,layout,open,openAdventure,updateWayfinder
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
        local bio=label(card,'Personality',spec.Personality,12,C.Muted,12,178,160,32,33) bio.Size=UDim2.new(1,-24,0,32)
        local meter=T.Panel(card,'BondTrack',C.Soft,33) meter.Position=UDim2.new(0,12,0,236) meter.Size=UDim2.new(1,-24,0,4)
        local fill=T.Panel(meter,'Fill',C.Lilac,34) fill.Size=UDim2.fromScale(0,1)
        local benefit=label(card,'Benefit',spec.Bonus>0 and ('+'..spec.Bonus..' per '..spec.Name..' guest payout') or 'Free starter companion',10,C.Ink,12,214,160,18,33) benefit.Size=UDim2.new(1,-24,0,24)
        local button=T.Button(card,'Action','',C.Gold,34) button.Position=UDim2.new(0,10,1,-54) button.Size=UDim2.new(1,-20,0,44)
        button.Activated:Connect(function()
            if p:GetAttribute('EquippedPet')==spec.Id then notify(spec.CharacterName..' is already adventuring with you.') return end
            local owned=spec.Id=='Pebble' or p:GetAttribute('Pet_'..spec.Id)
            if not owned and tokenValue<spec.Price then notify('Save '..T.Format(spec.Price-tokenValue)..' more tokens to meet '..spec.CharacterName..'.',true) return end
            send(owned and 'EquipPet' or 'BuyPet',spec.Id)
        end)
        table.insert(cards,{Frame=card,Button=button,Spec=spec,Bio=bio,BondFill=fill})
    end
end
local function makeShop()
    for i,item in config.Shop do
        local card=cardBase(item.Id,i)
        local badge=label(card,'Icon',({Cleaner='⚙',Turbo='ϟ',Foam='✦',Beacon='◉',Garden='❀',Tables='☕'})[item.Id],28,C.Teal,12,8,34,36,33) badge.TextXAlignment=Enum.TextXAlignment.Center
        local library=Replicated:FindFirstChild('ResortPortraits')
        local template=library and library:FindFirstChild(({Cleaner='CleanerBot',Garden='SporeTree',Tables='CafeCounter'})[item.Id] or '')
        if template then badge.Text='' T.ModelIcon(badge,template)
        elseif item.Id=='Turbo' or item.Id=='Foam' or item.Id=='Beacon' then badge.Text='' T.SupplyIcon(badge,item.Id) end
        local name=label(card,'Name',item.Name,16,C.Ink,52,10,180,34,33) name.Size=UDim2.new(1,-64,0,34)
        local detail=label(card,'Description',item.Description,12,C.Muted,12,52,220,48,33) detail.Size=UDim2.new(1,-24,0,48)
        local typeText=item.Duration and ('BOOST / '..item.Duration..' SECONDS') or 'PERMANENT UPGRADE'
        local typeLabel=label(card,'Type',typeText,9,C.Muted,12,107,220,16,33) typeLabel.Size=UDim2.new(1,-24,0,16)
        label(card,'Price',T.Format(item.Price)..' TOKENS',12,Color3.fromRGB(139,91,22),0,0,138,20,33).TextXAlignment=Enum.TextXAlignment.Right
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
    place(wallet,12,12,math.min(200,w-116),64)
    tokenText.Size=UDim2.new(1,-70,0,28) rate.Size=UDim2.new(1,-24,0,14)
    place(fxButton,w-100,12,88,44) fxButton.TextSize=11
    local names={'Pets','Build','Shop','Adventure'}
    if h<500 and w>=600 then
        place(guide,224,12,w-336,124)
        for i,name in names do if nav[name] then place(nav[name],12+((i-1)%2)*76,94+math.floor((i-1)/2)*76,64,64) end end
    elseif compact then
        place(guide,12,88,w-24,124)
        local bw=math.min(76,(w-48)/4)
        for i,name in names do if nav[name] then place(nav[name],12+(i-1)*(bw+8),224,bw,70) end end
    else
        local gw=math.min(480,w-440) place(guide,(w-gw)/2,h-148,gw,124)
        for i,name in names do if nav[name] then place(nav[name],12,104+(i-1)*86,70,70) end end
    end
    guideStep.Size=UDim2.new(1,-28,0,14)
    guideTitle.Size=UDim2.new(1,guideAction.Visible and -112 or -28,0,36) guideDetail.Size=UDim2.new(1,-28,0,44)
    guideTitle.TextSize=guide.AbsoluteSize.X<350 and 14 or 16
    guideDetail.TextSize=guide.AbsoluteSize.X<350 and 11 or 12
    place(save,12,h-20,w-24,16)
    place(boosts,12,h-68,math.min(320,w-24),44)
    local mw=math.min(900,w-24) local mh=math.min(590,h-24)
    modal.Size=UDim2.fromOffset(mw,mh) close.Position=UDim2.new(1,-60,0,14)
    heading.Size=UDim2.new(1,-90,0,30)
    subtitle.Size=UDim2.new(1,-40,0,24)
    local tabWidth=(mw-56)/3
    for i,name in {'Pets','Build','Shop'} do place(tabs[name],20+(i-1)*(tabWidth+8),100,tabWidth,44) end
    local short=h<500
    subtitle.Visible=not short
    header.Size=UDim2.new(1,0,0,short and 50 or 60)
    heading.Position=UDim2.fromOffset(20,short and 10 or 16)
    for i,name in {'Pets','Build','Shop'} do place(tabs[name],20+(i-1)*(tabWidth+8),short and 58 or 100,tabWidth,44) end
    list.Position=UDim2.fromOffset(16,short and 112 or 154)
    list.Size=UDim2.new(1,-32,1,short and -124 or -170)
    local available=mw-42
    local columns=currentTab=='Shop' and 1 or currentTab=='Build' and (mw>700 and 2 or 1) or math.max(1,math.min(4,math.floor((available+12)/190)))
    local rowHeight=currentTab=='Pets' and (short and 184 or 298) or currentTab=='Build' and 180 or (mw<480 and 178 or 120)
    local count=currentTab=='Pets' and #config.PetSpecies or currentTab=='Build' and #config.Upgrades or #config.Shop
    local rows=math.ceil(count/columns)
    mh=math.min(mh,(short and 124 or 170)+rows*(rowHeight+12)-12)
    modal.Size=UDim2.fromOffset(mw,mh)
    grid.CellSize=UDim2.fromOffset(math.floor((available-(columns-1)*12)/columns),rowHeight)
    if currentTab=='Shop' then
        for _,entry in cards do
            local f=entry.Frame local narrow=mw<480
            place(f.Icon,10,10,70,70) f.Icon.TextSize=40
            local title=f:FindFirstChild('Name') place(title,90,10,available-110,30) title.Size=UDim2.new(1,narrow and -108 or -260,0,30)
            place(f.Description,90,42,available-110,40) f.Description.Size=UDim2.new(1,narrow and -104 or -260,0,42)
            place(f.Type,12,narrow and 91 or 91,available-24,14)
            f.Type.Size=UDim2.new(1,narrow and -128 or -24,0,14)
            f.Price.Position=UDim2.new(1,-150,0,narrow and 88 or 14) f.Price.Size=UDim2.fromOffset(138,20)
            f.Action.Position=UDim2.new(narrow and 0 or 1,narrow and 10 or -150,narrow and 1 or 0,narrow and -54 or 48)
            f.Action.Size=narrow and UDim2.new(1,-20,0,44) or UDim2.fromOffset(138,44)
            f.Action.BackgroundColor3=Color3.fromRGB(124,226,109)
        end
    end
    if currentTab=='Pets' then
        for _,entry in cards do
            local f=entry.Frame
            f.CharacterPortrait.Position=UDim2.fromOffset(10,short and 8 or 10)
            f.CharacterPortrait.Size=UDim2.new(1,-20,0,short and 62 or 106)
            local overline=f:FindFirstChild('Species') overline.Position=UDim2.fromOffset(12,short and 72 or 122) overline.Size=UDim2.new(1,-24,0,short and 12 or 24)
            local name=f:FindFirstChild('Name') name.Position=UDim2.fromOffset(12,short and 86 or 148) name.TextSize=short and 18 or 22 name.Size=UDim2.new(1,-24,0,short and 22 or 28)
            f.Personality.Visible=not short
            f.BondTrack.Visible=not short
            f.Benefit.Position=UDim2.fromOffset(12,short and 110 or 214) f.Benefit.Size=UDim2.new(1,-24,0,short and 16 or 24)
        end
    end
    toast.Size=UDim2.fromOffset(math.min(440,w-24),54) toast.Position=UDim2.new(.5,0,1,-(w>=920 and 212 or h<500 and 72 or 92)) toastText.Size=UDim2.new(1,-28,1,-14)
    if arena then
        arena.Position=UDim2.new(.5,0,0,compact and 88 or 12)
        arena.Size=UDim2.fromOffset(math.min(420,w-24),compact and 70 or 96)
        arena.Hint.Position=UDim2.fromOffset(14,compact and 48 or 57) arena.Hint.Size=UDim2.new(1,-28,0,compact and 18 or 32) arena.Hint.TextSize=compact and 10 or 12
        arena.Score.Position=UDim2.fromOffset(14,24) arena.Score.TextSize=compact and 18 or 21
    end
end
open=function(name)
    tooltip.Visible=false
    if drawer then drawer.Visible=false end
    if settings then settings.Visible=false end
    if tutorial then tutorial.Visible=false end
    if resultSheet then resultSheet.Visible=false end
    if not name then modal.Visible=false scrim.Visible=false GuiService.SelectedObject=nil return end
    currentTab=name clearCards()
    if name=='Pets' then makePets() elseif name=='Shop' then makeShop() else makeBuild() end
    heading.Text=name=='Pets' and 'MEET YOUR COSMIC CREW' or name=='Shop' and 'RESORT SUPPLY STATION' or 'BUILD YOUR LITTLE UNIVERSE'
    subtitle.Text=name=='Pets' and 'ADOPT • BOND • EVOLVE' or name=='Shop' and 'Permanent helpers and timed boosts. Tokens only.' or 'Foundation → structure → furnish. Build on your island.'
    header.BackgroundColor3=name=='Pets' and C.Lilac or name=='Shop' and C.Coral or C.Teal
    for tab,button in tabs do button.BackgroundColor3=tab==name and C.Ink or C.White button.TextColor3=tab==name and C.White or C.Ink end
    list.CanvasPosition=Vector2.zero modal.Visible=true scrim.Visible=true layout() refresh()
    if motion then modal.Position=UDim2.new(.5,0,.5,10) Tween:Create(modal,TweenInfo.new(.16,Enum.EasingStyle.Quad),{Position=UDim2.fromScale(.5,.5)}):Play() end
    if Input:GetLastInputType()==Enum.UserInputType.Gamepad1 then GuiService.SelectedObject=close end
end
for name,button in nav do button.Activated:Connect(function() open(name) end) end
guideAction.Activated:Connect(function()
    local action=p:GetAttribute('GuideAction')
    if action=='Adventure' then if openAdventure then openAdventure() end
    elseif action=='Build' or action=='Shop' then open(action) end
end)
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
    if not world or not world.Parent then return end
    local upgrades,pads=world:FindFirstChild('Upgrades'),world:FindFirstChild('BuildPads')
    if id and id:sub(1,6)=='Clean_' then
        local name=id:sub(7) local room=name=='StarterRoom' and world:FindFirstChild('StarterRoom') or upgrades and upgrades:FindFirstChild(name)
        if room then return room:FindFirstChild('Floor'),room,'CLEAN ROOM' end
    elseif id=='CommonsShuttle' and world:FindFirstChild('CommonsShuttle') then return world.CommonsShuttle,world.CommonsShuttle,'ADVENTURE SHUTTLE'
    elseif id=='ClaimTerminal' then local part=world:FindFirstChild('ClaimTerminal') return part,part,'CLAIM YOUR ISLAND'
    elseif id=='LandingPad' then local pad=world:FindFirstChild('LandingPad') return pad and pad:FindFirstChild('LandingSurface'),pad,'GUEST ARRIVING'
    elseif id=='StarterRoom' then local room=world:FindFirstChild('StarterRoom') return room and room:FindFirstChild('Floor'),room,'GUEST INCOME'
    elseif id and pads and pads:FindFirstChild(id) then return pads[id],pads[id],'BUILD NEXT STAGE' end
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
    local upgrades=world:FindFirstChild('Upgrades') local building=id and upgrades and upgrades:FindFirstChild(id)
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
    local steps=math.clamp(p:GetAttribute('GuideSteps') or 6,1,6)
    local step=math.clamp(p:GetAttribute('GuideStep') or 1,1,steps)
    local complete=p:GetAttribute('GuideComplete')==true
    guideStep.Text=complete and 'OPENING COMPLETE  •  EXPLORE & EXPAND' or ('STEP '..step..' / '..steps..(cost>0 and ('  •  '..T.Format(math.min(tokenValue,cost))..' / '..T.Format(cost)..' TOKENS') or '  •  FIRST TEN MINUTES'))
    for i,segment in guideSegments do segment.Visible=i<=steps segment.BackgroundColor3=(complete or i<step) and C.Teal or i==step and C.Gold or C.Soft end
    local action=p:GetAttribute('GuideAction')
    guideAction.Visible=owner and (action=='Build' or action=='Shop' or action=='Adventure')
    guideAction.Text=action=='Adventure' and 'TRAVEL →' or action=='Shop' and 'SHOP →' or 'BUILD →'
    guideTitle.Size=UDim2.new(1,guideAction.Visible and -112 or -28,0,36)
    for _,entry in cards do
        local spec=entry.Spec local button=entry.Button local text,color
        if currentTab=='Pets' then
            local owned=spec.Id=='Pebble' or p:GetAttribute('Pet_'..spec.Id)==true
            local bond=p:GetAttribute('Bond_'..spec.Id) or 0
            entry.BondFill.Size=UDim2.fromScale(math.clamp(bond/config.Adventure.EvolutionBond,0,1),1)
            entry.Bio.Text=owned and ('BOND '..bond..' / '..config.Adventure.EvolutionBond..'\n'..(p:GetAttribute('Evolved_'..spec.Id) and 'EVOLVED COMPANION' or 'Explore together to evolve')) or spec.Personality
            if p:GetAttribute('EquippedPet')==spec.Id then text='EQUIPPED  ✓' color=C.Teal
            elseif owned then text='EQUIP '..string.upper(spec.CharacterName) color=C.Soft
            else text=T.Format(spec.Price)..' TOKENS / ADOPT' color=tokenValue>=spec.Price and C.Gold or C.Soft end
        elseif currentTab=='Shop' then
            local seconds=math.max(0,math.ceil((p:GetAttribute(spec.Id..'Until') or 0)-workspace:GetServerTimeNow()))
            if not spec.Duration and p:GetAttribute('Owns'..spec.Id) then text='OWNED  ✓' color=C.Teal
            elseif seconds>0 then text='ACTIVE / '..seconds..'s' color=C.Lilac
            else text=T.Format(spec.Price)..' TOKENS / BUY' color=tokenValue>=spec.Price and Color3.fromRGB(124,226,109) or C.Soft end
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
        button.Text=not owner and (currentTab=='Shop' and 'CLAIM FIRST' or 'CLAIM YOUR ISLAND FIRST') or text button.BackgroundColor3=color or C.Soft
        button.Interactable=pending==nil
    end
end
local latestGain
local function earnings(amount,vip)
    playFeedback(vip and 'VIP' or 'Payment')
    if latestGain then latestGain:Destroy() end
    local pop=T.Panel(screen,'Gain',vip and C.Lilac or C.Gold,92) pop.Size=UDim2.fromOffset(320,40) pop.AnchorPoint=Vector2.new(.5,0) latestGain=pop
    local message=(vip and 'VIP PAYMENT!  +' or 'GUEST PAYMENT  +')..T.Format(amount)..' TOKENS'
    local text=label(pop,'Text',message,14,vip and C.White or C.Ink,0,0,320,40,93) text.TextXAlignment=Enum.TextXAlignment.Center
    local w=screen.AbsoluteSize.X local popupWidth=math.min(320,w-24) pop.Size=UDim2.fromOffset(popupWidth,40) text.Size=UDim2.fromScale(1,1)
    pop.Position=UDim2.fromOffset(w*.5,screen.AbsoluteSize.Y-(w>=920 and 200 or w<600 and 200 or 110))
    task.delay(1.4,function()
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
    tokenValue=value
    if numberTween then numberTween:Cancel() end
    numberTween=Tween:Create(display,TweenInfo.new(motion and .35 or 0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=value}) numberTween:Play()
    refresh()
end)
local payoutQueued=false
p:GetAttributeChangedSignal('PayoutVersion'):Connect(function()
    if payoutQueued then return end payoutQueued=true
    task.defer(function()
        payoutQueued=false
        -- A replication batch can contain several payments. Announce its latest
        -- payment; the token wallet independently shows the full balance.
        local amount=p:GetAttribute('LastPayout') or 0
        if not gui.Parent or amount<=0 or not p:GetAttribute('ProfileReady') then return end
        earnings(amount,p:GetAttribute('LastPayoutVIP')==true)
    end)
end)
local constructionEffects={} local buildStages={}
for _,upgrade in config.Upgrades do buildStages[upgrade.Id]=p:GetAttribute('Stage_'..upgrade.Id) or 0 end
local function clearConstruction(id)
    local effect=constructionEffects[id] if not effect then return end
    constructionEffects[id]=nil
    for _,tween in effect.Tweens do tween:Cancel() end
    for part,value in effect.Parts do if part.Parent then part.LocalTransparencyModifier=value end end
    effect.Highlight:Destroy()
end
local function clearAllConstruction()
    local ids={} for id in constructionEffects do table.insert(ids,id) end
    for _,id in ids do clearConstruction(id) end
end
local function revealConstruction(id,stage)
    clearConstruction(id)
    if not motion or not world or not p:GetAttribute('ProfileReady') then return end
    local upgrades=world:FindFirstChild('Upgrades') local building=upgrades and upgrades:FindFirstChild(id)
    if not building then return end
    local glow=Instance.new('Highlight') glow.Name='ConstructionReveal' glow.Adornee=building glow.FillColor=C.Teal glow.FillTransparency=.6 glow.OutlineColor=C.Gold glow.OutlineTransparency=.15 glow.DepthMode=Enum.HighlightDepthMode.Occluded glow.Parent=building
    local effect={Parts={},Tweens={},Highlight=glow} constructionEffects[id]=effect
    for _,part in building:GetDescendants() do
        if part:IsA('BasePart') and part:GetAttribute('BuildStage')==stage then
            local original=part.LocalTransparencyModifier effect.Parts[part]=original part.LocalTransparencyModifier=math.max(original,.8)
            local tween=Tween:Create(part,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{LocalTransparencyModifier=original}) table.insert(effect.Tweens,tween) tween:Play()
        end
    end
    local fade=Tween:Create(glow,TweenInfo.new(.45),{FillTransparency=1,OutlineTransparency=1}) table.insert(effect.Tweens,fade) fade:Play()
    task.delay(.46,function() if constructionEffects[id]==effect then clearConstruction(id) end end)
end
p.AttributeChanged:Connect(function(key)
    if key=='GuideTarget' or key:sub(1,6)=='Stage_' then updateWayfinder() end
    if key:sub(1,6)=='Stage_' then
        local id=key:sub(7) local stage=p:GetAttribute(key) or 0 local previous=buildStages[id] or 0 buildStages[id]=stage
        if stage>previous then task.defer(function() if gui.Parent then revealConstruction(id,stage) end end) end
    end
    if key=='NoticeVersion' then pending=nil notify(p:GetAttribute('ResortNotice') or '') end
    if key=='GuestEventVersion' then
        local message=p:GetAttribute('LastGuestEvent')
        if message and message~='' then notify(message,false,message:find('VIP',1,true) and 'VIP' or 'Payment') end
    end
    if key:sub(1,5)~='Arena' and key~='ActivityProgress' and key~='ProtectedUntil' then refresh() end
end)
local function alienAdded(model) if model:IsA('Model') then activeAliens[model]={Last=model:GetPivot().Position,Follow=model:GetPivot()} end end
for _,model in Tags:GetTagged('ResortAlien') do alienAdded(model) end
Tags:GetInstanceAddedSignal('ResortAlien'):Connect(alienAdded)
Tags:GetInstanceRemovedSignal('ResortAlien'):Connect(function(model) activeAliens[model]=nil end)
local initialView=false
local function attachBeam(character)
    local hrp=character:WaitForChild('HumanoidRootPart',10)
    if hrp and beam and beam.Parent then
        local a=hrp:FindFirstChild('ResortWayfinder') or Instance.new('Attachment') a.Name='ResortWayfinder' a.Position=Vector3.new(0,-2,0) a.Parent=hrp beam.Attachment0=a
        if not initialView and workspace.CurrentCamera then
            initialView=true
            local forward=(Vector3.new(180,hrp.Position.Y,240)-hrp.Position).Unit
            workspace.CurrentCamera.CFrame=CFrame.lookAt(hrp.Position-forward*16+Vector3.new(0,7,0),hrp.Position+forward*20+Vector3.new(0,5,0))
        end
    end
end
p.CharacterAdded:Connect(attachBeam)
local function bindWorld(newWorld)
    clearAllConstruction()
    if marker then marker:Destroy() end if highlight then highlight:Destroy() end if destination then destination:Destroy() end if beam then beam:Destroy() end if preview then preview:Destroy() preview=nil end
    for _,entry in roomLabels do entry.Gui:Destroy() end roomLabels={}
    world=newWorld marker=nil highlight=nil destination=nil beam=nil
    if not world then return end
    marker=Instance.new('BillboardGui') marker.Name='NextStepMarker' marker.Size=UDim2.fromOffset(120,48) marker.StudsOffsetWorldSpace=Vector3.new(0,7,0) marker.AlwaysOnTop=true marker.MaxDistance=100 marker.Parent=gui
    local caption=label(marker,'Caption','',13,C.Gold,0,0,120,48,5) caption.TextXAlignment=Enum.TextXAlignment.Center caption.TextStrokeTransparency=.35
    highlight=Instance.new('Highlight') highlight.FillColor=C.Teal highlight.FillTransparency=.82 highlight.OutlineColor=C.Cream highlight.Parent=world
    destination=Instance.new('Attachment') destination.Position=Vector3.new(0,1.5,0)
    beam=Instance.new('Beam') beam.Color=ColorSequence.new(C.Teal) beam.Width0=.14 beam.Width1=.14 beam.FaceCamera=true beam.Attachment1=destination beam.Parent=world
    if p.Character then task.spawn(attachBeam,p.Character) end
    local upgrades=world:FindFirstChild('Upgrades')
    for _,room in {world:FindFirstChild('StarterRoom'),upgrades and upgrades:FindFirstChild('Room2'),upgrades and upgrades:FindFirstChild('Room3')} do
        local floor=room and room:FindFirstChild('Floor')
        if not floor then continue end
        local bb=Instance.new('BillboardGui') bb.Size=UDim2.fromOffset(150,40) bb.Adornee=floor bb.StudsOffsetWorldSpace=Vector3.new(0,14,0) bb.MaxDistance=22 bb.Parent=gui
        local panel=T.Panel(bb,'Room',C.Ink,2) panel.Size=UDim2.fromScale(1,1)
        local text=label(panel,'Status','',12,C.White,8,4,134,32,3) text.TextXAlignment=Enum.TextXAlignment.Center
        table.insert(roomLabels,{Room=room,Gui=bb,Text=text})
    end
    updateWayfinder()
end
task.spawn(function()
    while gui.Parent do
        local plots=workspace:FindFirstChild('ResortPlots') local name=p:GetAttribute('PlotName')
        local candidate=plots and name and plots:FindFirstChild(name)
        if candidate~=world then bindWorld(candidate) elseif world and not target then updateWayfinder() end
        task.wait(1)
    end
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
        for model,rest in scenery do
            if model.Parent and camera and (rest.Position-camera.CFrame.Position).Magnitude<180 then
                model:PivotTo(rest+Vector3.new(0,motion and math.sin(now*1.2+rest.Position.X)*(model:GetAttribute('Hover') or .1) or 0,0))
            end
        end
        for model,state in activeAliens do
            if model.Parent and camera and model:IsDescendantOf(workspace) and (model:GetPivot().Position-camera.CFrame.Position).Magnitude<190 then
                local position=model:GetPivot().Position local moving=(position-state.Last).Magnitude>.035 state.Last=position
                Visuals.Animate(model,motion and now or 0,moving and motion)
            end
        end
    end
    quarter+=dt if quarter<.25 then return end quarter=0
    -- A runner must never see its own/teammate tag prompt: OneGlobally would hide cores.
    local team=p:GetAttribute('ArenaTeam')
    for _,other in Players:GetPlayers() do
        local h=other.Character and other.Character:FindFirstChild('HumanoidRootPart')
        local tag=h and h:FindFirstChild('TagRunner')
        if tag then tag.Enabled=other~=p and team~=nil and other:GetAttribute('ArenaTeam')~=nil and other:GetAttribute('ArenaTeam')~=team end
    end
    local commons=workspace:FindFirstChild('CosmicCommons')
    if commons then
        for i,names in {{'Blue Starcore','BLUE HOME'},{'Coral Starcore','CORAL HOME'}} do
            local flag=commons:FindFirstChild(names[1]) local base=commons:FindFirstChild(names[2])
            local take=flag and flag:FindFirstChildOfClass('ProximityPrompt') local score=base and base:FindFirstChildOfClass('ProximityPrompt')
            if take then take.Enabled=team~=nil and (team==i and flag:GetAttribute('Dropped')==true or team~=i and not flag:GetAttribute('CarrierUserId') and not p:GetAttribute('CarryingStarcore')) end
            if score then score.Enabled=team==i and p:GetAttribute('CarryingStarcore')==true end
        end
    end
    if arenaRefresh then arenaRefresh() end
    if drawer and drawer.Visible and activityStatus then activityStatus() end
    local active={}
    for _,id in {'Turbo','Foam','Beacon'} do local left=math.ceil((p:GetAttribute(id..'Until') or 0)-workspace:GetServerTimeNow()) if left>0 then table.insert(active,string.upper(id)..' '..left..'s') end end
    boosts.Text=table.concat(active,'  /  ')
    if selectedBuild and os.clock()-selectedAt>30 then selectedBuild=nil updateWayfinder() end
    if modal.Visible and currentTab=='Shop' then refresh() end
    for _,entry in roomLabels do
        local room=entry.Room
        local floor=room:FindFirstChild('Floor')
        entry.Gui.Enabled=roomStatus and floor~=nil and floor.Transparency<1 and room:GetAttribute('Occupied')==true and (room:GetAttribute('Stage')==nil or room:GetAttribute('Stage')==3)
        local status=room:GetAttribute('GuestStatus') or 'Ready for guests'
        if (room:GetAttribute('NextPaymentAt') or 0)>workspace:GetServerTimeNow()-.5 then
            local seconds=math.max(0,math.ceil((room:GetAttribute('NextPaymentAt') or 0)-workspace:GetServerTimeNow()))
            entry.Text.Text=(room:GetAttribute('GuestVIP') and '★ VIP ' or '')..(room:GetAttribute('GuestSpecies') or 'Alien')..' guest\nPayment in '..seconds..'s / '..(room:GetAttribute('PaymentsLeft') or 1)..' left'
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
    local targets={templates} local portraits=Replicated:FindFirstChild('ResortPortraits') if portraits then table.insert(targets,portraits) end
    local ok=pcall(function() game:GetService('ContentProvider'):PreloadAsync(targets) end)
    if ok and modal.Visible and currentTab=='Pets' then open('Pets') end
end)

-- Adventure drawer: travel, useful pet actions, jobs, and progression.
local adventureRemote=Replicated:WaitForChild('ResortAdventure')
local play=T.Button(screen,'Adventure','ADVENTURE',C.Teal,8)
T.NavIcon(play,'Adventure') nav.Adventure=play
hint(play,'Your passport • travel, pet powers and Starcore Capture') hint(fxButton,'Sound, animation and room-label settings')
drawer=T.Panel(screen,'AdventureDrawer',C.Cream,45) drawer.AnchorPoint=Vector2.new(.5,.5) drawer.Position=UDim2.fromScale(.5,.5) drawer.Visible=false T.Window(drawer,C.Lilac)
local title=label(drawer,'Title','YOUR COSMIC PASSPORT',19,C.White,14,12,400,32,46) title.Font=Enum.Font.FredokaOne title.TextStrokeColor3=C.Ink title.TextStrokeTransparency=.1
local summary=label(drawer,'Progress','',13,C.White,14,72,400,132,46)
local exit=T.Button(drawer,'Close','X',C.White,48) exit.Position=UDim2.new(1,-52,0,8) exit.Size=UDim2.fromOffset(44,44)
local actions=Instance.new('ScrollingFrame') actions.Name='Actions' actions.Position=UDim2.fromOffset(12,210) actions.Size=UDim2.new(1,-24,1,-222) actions.AutomaticCanvasSize=Enum.AutomaticSize.Y actions.CanvasSize=UDim2.new() actions.BackgroundTransparency=1 actions.BorderSizePixel=0 actions.ScrollBarThickness=5 actions.ZIndex=46 actions.Parent=drawer
local actionGrid=Instance.new('UIGridLayout') actionGrid.CellPadding=UDim2.fromOffset(8,8) actionGrid.Parent=actions
local definitions={{'Commons','TO THE COMMONS'},{'Home','RETURN HOME'},{'Ability','USE PET ABILITY'},{'Evolve','EVOLVE AT LAB'},{'Request','ACCEPT GUEST REQUEST'},{'Deliver','DELIVER REQUEST'},{'Job','PIP: WORK / REST','Pebble'},{'Job','JUNO: WORK / REST','Jelly'},{'Job','SPROUT: WORK / REST','Slime'},{'Job','EMBER: WORK / REST','Lava'},{'Queue','JOIN STARCORE CAPTURE'}}
local actionButtons={} local lastAction=0
for i,entry in definitions do
    local button=T.Button(actions,'Action'..i,entry[2],i%2==0 and C.Soft or C.Teal,47) button.LayoutOrder=i button.TextSize=11 actionButtons[i]=button
    button.Activated:Connect(function()
        if not p:GetAttribute('OwnsResort') then notify('Claim your island first.',true) return end
        if os.clock()-lastAction<.4 then return end lastAction=os.clock()
        local action=entry[1]
        if action=='Queue' then
            if p:GetAttribute('ArenaTeam') or p:GetAttribute('ArenaQueued') then action='Leave'
            else
                local root=workspace:FindFirstChild('CosmicCommons') local pad=root and root:FindFirstChild('STARCORE CAPTURE / QUEUE')
                local h=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
                if not h or not pad or (h.Position-pad.Position).Magnitude>14 then action='Commons' notify('Visit the Starcore gate to join the queue.') end
            end
        end
        adventureRemote:FireServer(action,entry[3]) if action=='Home' or action=='Commons' then open(nil) end
    end)
end
local function activityLayout()
    local w,h=screen.AbsoluteSize.X,screen.AbsoluteSize.Y
    layout()
    drawer.Size=UDim2.fromOffset(math.min(560,w-24),math.min(540,h-24)) title.Size=UDim2.new(1,-78,0,32) summary.Size=UDim2.new(1,-28,0,132)
    actionGrid.CellSize=UDim2.new(.5,-8,0,44)
end
activityStatus=function()
    local id=p:GetAttribute('EquippedPet') or 'Pebble'
    for i=7,10 do
        local entry=definitions[i] local pet=entry[3]
        local owned=pet=='Pebble' or p:GetAttribute('Pet_'..pet)
        local facility=({Pebble='Reception',Jelly='Lounge',Slime='Garden',Lava='Kiosk'})[pet]
        local unlocked=facility=='Garden' and p:GetAttribute('OwnsGarden') or (p:GetAttribute('Stage_'..facility) or 0)==3
        local usable=owned and (unlocked or p:GetAttribute('PetJob')==pet)
        actionButtons[i].Text=not owned and ('ADOPT '..string.upper(pet)..' FIRST') or not usable and ('BUILD '..string.upper(facility)..' FIRST') or p:GetAttribute('PetJob')==pet and (string.upper(pet)..': REST') or entry[2]
        actionButtons[i].Interactable=usable==true actionButtons[i].BackgroundColor3=usable and C.Teal or C.Soft
    end
    local cooldown=math.max(0,math.ceil((p:GetAttribute('AbilityUntil') or 0)-workspace:GetServerTimeNow()))
    local stages=0 local nextBuild=nil
    for _,u in config.Upgrades do local stage=p:GetAttribute('Stage_'..u.Id) or 0 stages+=stage if stage<3 and not nextBuild then nextBuild=u.Name..' • '..config.StageNames[stage+1] end end
    local stars=math.min(5,math.floor(stages/18*5))
    summary.Text='RESORT RATING '..stars..'/5  •  '..stages..'/18 BUILD STAGES\nNext: '..(nextBuild or 'Evolve your crew and master Starcore Capture')..'\nSHARDS '..(p:GetAttribute('StarShards') or 0)..'/'..config.Adventure.EvolutionShards..'    BOND '..(p:GetAttribute('Bond_'..id) or 0)..'/'..config.Adventure.EvolutionBond..'\nJob: '..(p:GetAttribute('PetJob') or 'none')..' / Power: '..(cooldown>0 and (cooldown..'s') or 'READY')..'\n'..(p:GetAttribute('ActivityProgress') or 'Build your resort, then explore the Commons.')
    actionButtons[11].Text=p:GetAttribute('ArenaTeam') and 'LEAVE MATCH' or p:GetAttribute('ArenaQueued') and 'LEAVE QUEUE' or 'JOIN STARCORE CAPTURE'
end
openAdventure=function()
    local was=drawer.Visible open(nil) drawer.Visible=not was scrim.Visible=not was activityStatus() if not was then GuiService.SelectedObject=exit end
end
play.Activated:Connect(openAdventure)
exit.Activated:Connect(function() open(nil) end)
for name,button in nav do if name~='Adventure' then button.Activated:Connect(function() drawer.Visible=false end) end end
p.AttributeChanged:Connect(function() if drawer.Visible then activityStatus() end end) screen:GetPropertyChangedSignal('AbsoluteSize'):Connect(activityLayout)
activityLayout() activityStatus()

-- One modal policy also covers accessibility controls; these affect only this client.
local SoundService=game:GetService('SoundService')
local feedback=SoundService:FindFirstChild('UIFeedback') or Instance.new('SoundGroup') feedback.Name='UIFeedback' feedback.Parent=SoundService
local chime=Instance.new('Sound') chime.Name='CosmicFeedback' chime.SoundId='rbxassetid://1293433423' chime.SoundGroup=feedback chime.Volume=.12 chime.PlaybackSpeed=1.4 chime.Parent=SoundService
local lastSound=-math.huge
playFeedback=function(kind)
    if soundOn and os.clock()-lastSound>.8 then lastSound=os.clock() chime.PlaybackSpeed=kind=='VIP' and 1.7 or kind=='Payment' and 1.2 or 1.4 chime:Play() end
end
gui.Destroying:Connect(function() clearAllConstruction() chime:Destroy() end)
settings=T.Panel(screen,'Settings',C.Cream,50) settings.AnchorPoint=Vector2.new(.5,.5) settings.Position=UDim2.fromScale(.5,.5) settings.Visible=false T.Window(settings,C.Lilac)
local settingsTitle=label(settings,'Title','MAKE IT YOURS',22,C.White,18,14,250,32,51) settingsTitle.Font=Enum.Font.FredokaOne
local settingsClose=place(T.Button(settings,'Close','X',C.White,53),0,12,44,44)
local settingsBody=Instance.new('ScrollingFrame') settingsBody.Name='Options' settingsBody.BackgroundTransparency=1 settingsBody.BorderSizePixel=0 settingsBody.AutomaticCanvasSize=Enum.AutomaticSize.Y settingsBody.CanvasSize=UDim2.new() settingsBody.ScrollBarThickness=4 settingsBody.Position=UDim2.fromOffset(16,78) settingsBody.Size=UDim2.new(1,-32,1,-94) settingsBody.ZIndex=51 settingsBody.Parent=settings
local settingButtons={}
for i,spec in {{'Motion','Animation','Reduced mode stops bobbing, coin trails and button scaling.'},{'Audio','Sound effects','Controls Alien Resort feedback audio; voice chat is unaffected.'},{'Labels','Room status labels','Hide room payout labels. Tutorial markers and prompts stay visible.'}} do
    local row=T.Panel(settingsBody,spec[1],C.White,51) row.Position=UDim2.fromOffset(0,(i-1)*96) row.Size=UDim2.new(1,-4,0,88) T.Stroke(row,C.Soft,1)
    label(row,'Name',spec[2],15,C.Ink,12,8,180,24,52)
    local detail=label(row,'Description',spec[3],12,C.Muted,12,36,250,42,52) detail.Size=UDim2.new(1,-24,0,42)
    local button=T.Button(row,'Toggle','',C.Teal,53) button.Position=UDim2.new(1,-94,0,4) button.Size=UDim2.fromOffset(82,44) button.TextSize=12 settingButtons[spec[1]]=button
end
settingsRefresh=function()
    settingButtons.Motion.Text=motion and 'FULL' or 'REDUCED' settingButtons.Motion.BackgroundColor3=motion and C.Teal or C.Soft
    settingButtons.Audio.Text=soundOn and 'ON' or 'MUTED' settingButtons.Audio.BackgroundColor3=soundOn and C.Teal or C.Soft
    settingButtons.Labels.Text=roomStatus and 'ON' or 'HIDDEN' settingButtons.Labels.BackgroundColor3=roomStatus and C.Teal or C.Soft
    T.Motion=motion feedback.Volume=soundOn and 1 or 0
    if not motion then
        clearAllConstruction() walletScale.Scale=1 toastScale.Scale=1
        for _,entry in coins do entry.Frame:Destroy() end table.clear(coins)
    end
end
settingButtons.Motion.Activated:Connect(function() motion=not motion settingsRefresh() end)
settingButtons.Audio.Activated:Connect(function() soundOn=not soundOn settingsRefresh() end)
settingButtons.Labels.Activated:Connect(function() roomStatus=not roomStatus settingsRefresh() end)
settingsClose.Activated:Connect(function() open(nil) end)
fxButton.Activated:Connect(function() local visible=settings.Visible open(nil) settings.Visible=not visible scrim.Visible=not visible settingsRefresh() if not visible then GuiService.SelectedObject=settingsClose end end)
local function settingsLayout() local w,h=screen.AbsoluteSize.X,screen.AbsoluteSize.Y settings.Size=UDim2.fromOffset(math.min(460,w-24),math.min(400,h-24)) settingsClose.Position=UDim2.new(1,-58,0,10) end
screen:GetPropertyChangedSignal('AbsoluteSize'):Connect(settingsLayout) settingsLayout() settingsRefresh()

-- Replayable field guide. Reading it never fires purchase/reward remotes or resets progress.
local lessons={
    {'WELCOME, CAPTAIN','Claim an empty island at its CLAIM pad. Your free starter suite opens immediately. Equip Pip in PETS, then follow the yellow next-step marker.','Build'},
    {'BUILD IN THREE STAGES','Open BUILD to see each stage price and select a building. Follow its marker, then hold the build-pad prompt to buy the stage. Repeat for foundation, structure and furniture. Services operate when fully furnished.','Build'},
    {'HOST YOUR FIRST GUEST','UFOs bring guests to available clean rooms. Guests pay every '..config.IncomeInterval..' seconds, then leave after '..config.GuestStayPayments..' payments. More completed rooms means more capacity.','Build'},
    {'CLEAN AND AUTOMATE','After checkout, hold the room clean prompt. Manual cleaning awards '..config.CleanReward..' tokens. Buy the Cleaner robot in SHOP to handle rooms automatically; allow time for travel and cleaning.','Shop'},
    {'CAFE AND RECEPTION','Reception shortens arrival gaps. Complete Cosmic Snacks to add income and unlock its serving prompt. Garden and terrace extras add payout bonuses. Unfinished services stay unavailable.','Build'},
    {'PETS, POWERS AND JOBS','PETS lets you adopt and equip companions. TRAVEL lists powers and work/rest controls. Use the matching Commons station for a pet power. Active jobs earn tokens over time; rest a pet when you want it back.','Pets'},
    {'PET TRAINING','At Cosmic Commons, follow the five numbered training gates in order with the same companion. Start at gate 1 and finish at 5. This is a course, not a race against other players. Rewards have a cooldown.','Adventure'},
    {'SHUTTLE RESCUE','Find the rescue shuttle and repair all three numbered systems. You can repair alone or with others. The shuttle departs when all systems work; contributors receive the rescue reward when eligible.','Adventure'},
    {'TREASURE AND EVOLUTION','Equip Pip and investigate the three stardust deposits. Deposits need time to regenerate. Build bond and collect star shards, then visit the evolution lab; the TRAVEL panel shows your progress.','Adventure'},
    {'STARCORE CAPTURE','Join the Commons queue for 1v1 or 2v2. Carry the opposing core to your base while your own core is home. Tag carriers, recover dropped cores, and follow the match scoreboard. Other players are needed.','Adventure'},
    {'REQUESTS AND BOOSTS','Accept a guest request in TRAVEL, follow its objective and deliver it. SHOP batteries, foam and beacons are temporary boosts; helpers and decorations are permanent. Read the price and duration before buying.','Shop'},
    {'THE ORBITAL PALACE','Complete the Observatory to unlock the Palace boarding lift and VIP arrivals. Use the return lift to leave the observation deck. SETTINGS controls sound and motion. Reopen TUTORIAL anytime.','Build'},
}
tutorial=T.Panel(screen,'Tutorial',C.Ink,55) tutorial.AnchorPoint=Vector2.new(.5,.5) tutorial.Position=UDim2.fromScale(.5,.5) tutorial.Visible=false T.Window(tutorial,C.Lilac)
local helpButton=T.Button(screen,'TutorialButton','?  TUTORIAL',C.Teal,9) helpButton.TextSize=12
local helpTitle=label(tutorial,'Title','RESORT FIELD GUIDE',20,C.White,18,14,250,32,56) helpTitle.Font=Enum.Font.FredokaOne helpTitle.TextScaled=true
local helpClose=place(T.Button(tutorial,'Close','X',C.Coral,58),0,10,44,44) helpClose.Position=UDim2.new(1,-56,0,10)
local helpBody=Instance.new('ScrollingFrame') helpBody.Name='Lesson' helpBody.BackgroundTransparency=1 helpBody.BorderSizePixel=0 helpBody.ScrollBarThickness=4 helpBody.AutomaticCanvasSize=Enum.AutomaticSize.Y helpBody.CanvasSize=UDim2.new() helpBody.Position=UDim2.fromOffset(18,76) helpBody.Size=UDim2.new(1,-36,1,-146) helpBody.ZIndex=56 helpBody.Parent=tutorial
local lessonTitle=label(helpBody,'Heading','',20,C.Gold,0,0,400,56,57) lessonTitle.Font=Enum.Font.FredokaOne lessonTitle.Size=UDim2.new(1,-8,0,56)
local lessonText=label(helpBody,'Instructions','',15,C.White,0,64,400,0,57) lessonText.Size=UDim2.new(1,-8,0,0) lessonText.AutomaticSize=Enum.AutomaticSize.Y lessonText.TextYAlignment=Enum.TextYAlignment.Top
local previous=T.Button(tutorial,'Previous','BACK',C.Soft,58) local following=T.Button(tutorial,'Next','NEXT',C.Teal,58)
local helpOpen=T.Button(tutorial,'OpenMenu','OPEN BUILD',C.Gold,58) helpOpen.TextSize=11
local lessonIndex=1
local function showLesson()
    local lesson=lessons[lessonIndex] lessonTitle.Text=lessonIndex..' / '..#lessons..'  '..lesson[1] lessonText.Text=lesson[2]
    previous.Visible=lessonIndex>1 following.Text=lessonIndex==#lessons and 'DONE' or 'NEXT'
    helpOpen.Text='OPEN '..(lesson[3]=='Adventure' and 'TRAVEL' or string.upper(lesson[3])) helpBody.CanvasPosition=Vector2.zero
end
local function helpLayout()
    local w,h=screen.AbsoluteSize.X,screen.AbsoluteSize.Y
    helpButton.Position=UDim2.new(1,-104,0,66) helpButton.Size=UDim2.fromOffset(92,44)
    -- Compact HUD already uses this band for the next-step card.
    if w<600 or (w<920 and h>=500) then helpButton.Position=UDim2.new(1,-104,0,304) end
    tutorial.Size=UDim2.fromOffset(math.min(540,w-24),math.min(430,h-24)) helpTitle.Size=UDim2.new(1,-86,0,32)
    local bw=(tutorial.AbsoluteSize.X-52)/3
    for i,b in {previous,helpOpen,following} do b.Position=UDim2.new(0,18+(i-1)*(bw+8),1,-58) b.Size=UDim2.fromOffset(bw,44) end
end
helpButton.Activated:Connect(function() open(nil) tutorial.Visible=true scrim.Visible=true showLesson() helpLayout() GuiService.SelectedObject=following end)
helpClose.Activated:Connect(function() open(nil) end)
previous.Activated:Connect(function() lessonIndex=math.max(1,lessonIndex-1) showLesson() end)
following.Activated:Connect(function() if lessonIndex==#lessons then open(nil) lessonIndex=1 else lessonIndex+=1 showLesson() end end)
helpOpen.Activated:Connect(function() local tab=lessons[lessonIndex][3] open(nil) if tab=='Adventure' then openAdventure() else open(tab) end end)
screen:GetPropertyChangedSignal('AbsoluteSize'):Connect(helpLayout) helpLayout()

-- Compact match HUD uses server-owned attributes. No client rewards or scoring.
arena=T.Panel(screen,'ArenaHUD',C.Ink,12) arena.AnchorPoint=Vector2.new(.5,0) arena.Visible=false T.Round(arena,22) T.Stroke(arena,C.Lilac,2)
local arenaMode=label(arena,'Mode','STARCORE CAPTURE',12,C.Gold,14,7,300,18,13)
local arenaScore=label(arena,'Score','',21,C.White,14,27,300,27,13) arenaScore.Font=Enum.Font.FredokaOne
local arenaHint=label(arena,'Hint','',12,C.White,14,57,360,28,13) arenaHint.Size=UDim2.new(1,-28,0,32)
local arenaLeave=place(T.Button(arena,'Leave','LEAVE',C.Coral,14),0,9,70,44) arenaLeave.AnchorPoint=Vector2.new(1,0) arenaLeave.Position=UDim2.new(1,-10,0,8) arenaLeave.TextSize=12
arenaLeave.Activated:Connect(function() adventureRemote:FireServer('Leave') end)
arenaRefresh=function()
    local team=p:GetAttribute('ArenaTeam') local queued=p:GetAttribute('ArenaQueued')
    arena.Visible=team~=nil or queued==true guide.Visible=not arena.Visible
    if not arena.Visible then return end
    local root=workspace:FindFirstChild('CosmicCommons')
    local blue=p:GetAttribute('ArenaBlueScore') or (root and root:GetAttribute('BlueScore')) or 0
    local coral=p:GetAttribute('ArenaCoralScore') or (root and root:GetAttribute('CoralScore')) or 0
    local countdown=p:GetAttribute('ArenaCountdown') or 0
    arenaMode.Text=team and ((team==1 and 'BLUE TEAM' or 'CORAL TEAM')..' • '..(p:GetAttribute('ArenaSeconds') or 0)..'s') or 'STARCORE • IN QUEUE'
    arenaScore.Text=queued and ((root and root:GetAttribute('QueueCount') or 1)..' QUEUED • '..(root and root:GetAttribute('QueueSeconds') or 0)..'s') or (blue..' BLUE  :  '..coral..' CORAL')
    arenaHint.Text=queued and 'Up to 2v2. Explore while waiting.' or p:GetAttribute('ArenaPhase')=='Countdown' and ('GET READY • '..countdown) or p:GetAttribute('CarryingStarcore') and 'CORE SECURED! Bring it to your home base.' or 'Steal their core. Return home. Tag nearby enemies.'
    arenaScore.Size=UDim2.new(1,-104,0,27) arenaMode.Size=UDim2.new(1,-100,0,18)
end
resultSheet=T.Panel(screen,'RoundResult',C.Cream,55) resultSheet.AnchorPoint=Vector2.new(.5,.5) resultSheet.Position=UDim2.fromScale(.5,.5) resultSheet.Visible=false T.Window(resultSheet,C.Lilac)
local resultTitle=label(resultSheet,'Title','ROUND RESULTS',22,C.White,18,14,270,32,56) resultTitle.Font=Enum.Font.FredokaOne
local resultText=label(resultSheet,'Rewards','',15,C.White,18,74,360,82,56) resultText.Size=UDim2.new(1,-36,0,82) resultText.TextXAlignment=Enum.TextXAlignment.Center
local resultClose=T.Button(resultSheet,'Continue','CONTINUE EXPLORING',C.Teal,57) resultClose.Position=UDim2.new(0,16,1,-58) resultClose.Size=UDim2.new(1,-32,0,44)
resultClose.Activated:Connect(function() open(nil) end)
local function resultLayout() resultSheet.Size=UDim2.fromOffset(math.min(420,screen.AbsoluteSize.X-24),224) resultTitle.Size=UDim2.new(1,-36,0,32) end
screen:GetPropertyChangedSignal('AbsoluteSize'):Connect(resultLayout) resultLayout()
p:GetAttributeChangedSignal('ArenaResultVersion'):Connect(function()
    local message=p:GetAttribute('ArenaResult')
    if message and message~='' then open(nil) resultText.Text=message resultSheet.Visible=true scrim.Visible=true playFeedback() GuiService.SelectedObject=resultClose end
end)
screen:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() layout() arenaRefresh() end)
layout() arenaRefresh()
