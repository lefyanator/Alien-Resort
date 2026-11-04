local X={}
local Config=require(script.Parent.Config)
local G=require(script.Parent.Geometry)
local TweenService=game:GetService('TweenService')
local Interaction=require(script.Parent.Interaction)
local foundation={Foundation=true,Floor=true,EntryStep=true}
local structure={BackWall=true,WindowSill=true,WindowHeader=true,Glass=true,WindowFrame=true,FrontWall=true,DoorHeader=true,DoorFrame=true,RoofCornice=true,Roof=true,RoofCap=true,EntranceCanopy=true,BuildingName=true,Dome=true,Skylight=true}
function X.StagePrice(u,stage)
    local first=math.floor(u.Price*.2) local second=math.floor(u.Price*.3)
    return ({first,second,u.Price-first-second})[stage+1]
end
function X.SetStage(model,stage)
    model:SetAttribute('Stage',stage)
    for _,p in model:GetDescendants() do
        if p:IsA('BasePart') then
            if p:GetAttribute('OriginalTransparency')==nil then p:SetAttribute('OriginalTransparency',p.Transparency) p:SetAttribute('OriginalCollision',p.CanCollide) end
            local level=p:GetAttribute('BuildStage') or (foundation[p.Name] and 1 or structure[p.Name] and 2 or 3)
            p:SetAttribute('BuildStage',level)
            local visible=stage>=level
            p.Transparency=visible and p:GetAttribute('OriginalTransparency') or 1
            p.CanCollide=visible and p:GetAttribute('OriginalCollision') or false
        elseif p:IsA('ProximityPrompt') and p:GetAttribute('RequiresBuild') then p.Enabled=stage>=p:GetAttribute('RequiresBuild')
        elseif p:IsA('SurfaceGui') then p.Enabled=stage>=2 end
    end
end
function X.Boost(p,id) return (p:GetAttribute(id..'Until') or 0)>workspace:GetServerTimeNow() end
local function part(parent,name,size,cf,color)
    local p=Instance.new('Part') p.Name=name p.Size=size p.CFrame=cf p.Color=color p.Material=Enum.Material.SmoothPlastic p.Anchored=true p.CanCollide=false p.Parent=parent return p
end
function X.Robot(character)
    local old=character:FindFirstChild('RobotSuit') if old then old:Destroy() end
    local head=character:WaitForChild('Head',10) if not head then return end
    for _,o in character:GetDescendants() do
        if o:IsA('Accessory') or o:IsA('Shirt') or o:IsA('Pants') or o:IsA('ShirtGraphic') or o:IsA('SurfaceAppearance') or o:IsA('BodyColors') then o:Destroy()
        elseif o:IsA('BasePart') and o.Name~='HumanoidRootPart' then o.Color=Color3.fromRGB(210,226,240) o.Material=Enum.Material.Metal if o:IsA('MeshPart') then o.TextureID='' end
        elseif o:IsA('SpecialMesh') then o.TextureId=''
        elseif o:IsA('Decal') then o.Transparency=1 end
    end
    local suit=Instance.new('Model') suit.Name='RobotSuit' suit.Parent=character
    -- Hide avatar meshes; simple shells follow the existing animated joints.
    for _,limb in character:GetChildren() do
        if limb:IsA('BasePart') and limb.Name~='HumanoidRootPart' then
            limb.Transparency=1
            if limb~=head then
                local color=string.find(limb.Name,'Torso') and G.Colors.teal or G.Colors.cream
                local shell=part(suit,'Robot'..limb.Name,limb.Size*1.03,limb.CFrame,color)
                shell.Shape=Enum.PartType.Ball
                shell.Anchored=false shell.Massless=true
                local joint=Instance.new('WeldConstraint') joint.Part0=limb joint.Part1=shell joint.Parent=shell
            end
        end
    end
    local function weld(name,size,offset,color)
        local p=part(suit,name,size,head.CFrame*offset,color) p.Anchored=false p.Massless=true
        local w=Instance.new('WeldConstraint') w.Part0=head w.Part1=p w.Parent=p return p
    end
    weld('Helmet',Vector3.new(2.15,1.85,1.8),CFrame.new(),G.Colors.cream).Shape=Enum.PartType.Ball
    weld('FaceScreen',Vector3.new(1.85,1.15,.35),CFrame.new(0,0,-.77),G.Colors.dark).Shape=Enum.PartType.Ball
    for _,x in {-.45,.45} do local e=weld('Eye',Vector3.new(.3,.32,.1),CFrame.new(x,.12,-.92),G.Colors.teal) e.Material=Enum.Material.Neon end
    weld('Smile',Vector3.new(.6,.1,.1),CFrame.new(0,-.23,-.92),G.Colors.teal)
    weld('Antenna',Vector3.new(.15,.65,.15),CFrame.new(0,1.05,0),G.Colors.dark)
    local tip=weld('AntennaTip',Vector3.new(.4,.4,.4),CFrame.new(0,1.45,0),G.Colors.coral) tip.Shape=Enum.PartType.Ball
end
function X.New(S,root,refresh)
    local X=setmetatable({},{__index=X})
    local origin=S.Origin
    local function localPart(parent,name,size,cf,color) return part(parent,name,size,cf+origin,color) end
    local extras=Instance.new('Folder') extras.Name='SessionExtras' extras.Parent=root
    local rooms={root.StarterRoom,root.Upgrades.Room2,root.Upgrades.Room3}
    local function dirty(room,value)
        room:SetAttribute('Dirty',value) room:SetAttribute('GuestStatus',value and 'Needs cleaning!' or 'Ready for guests')
        room.Floor.CleanPrompt.Enabled=value
        local mess=room:FindFirstChild('GuestMess')
        if mess then mess:Destroy() end
        if value then
            mess=Instance.new('Model') mess.Name='GuestMess' mess.Parent=room
            for i=1,3 do
                local p=part(mess,'Spill',Vector3.new(1.8,.08,1.4),CFrame.new(room.Floor.Position+Vector3.new(-4+i, .38,-2)),Color3.fromRGB(134,93,65)) p.Shape=Enum.PartType.Ball
                part(mess,'UsedCup',Vector3.new(.5,.7,.5),CFrame.new(room.Floor.Position+Vector3.new(-4+i,.7,0)),G.Colors.coral)
            end
        end
    end
    X.MarkDirty=function(room) dirty(room,true) refresh() end
    local function finish(room,p,manual)
        if not room:GetAttribute('Dirty') then return false end
        dirty(room,false)
        local sparkle=Instance.new('Sparkles') sparkle.SparkleColor=G.Colors.teal sparkle.Parent=room.Floor
        game:GetService('Debris'):AddItem(sparkle,2)
        if manual then p.leaderstats.Tokens.Value+=Config.CleanReward p:SetAttribute('RoomsCleaned',(p:GetAttribute('RoomsCleaned') or 0)+1) end
        refresh() return true
    end
    for _,room in rooms do
        local prompt=Instance.new('ProximityPrompt') prompt.Name='CleanPrompt' prompt.ActionText='Clean room (+3 tokens)' prompt.ObjectText='Guest room' prompt.HoldDuration=Config.CleanSeconds prompt.MaxActivationDistance=12 prompt.RequiresLineOfSight=false prompt.Enabled=false prompt.Parent=room.Floor
        Interaction.Bind(prompt,function(p) return p==S.Owner and p:GetAttribute('ProfileReady') end,function(p)
            local hrp=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
            -- Interaction.Bind validates the completed hold before this callback.
            if p==S.Owner and hrp and (hrp.Position-room.Floor.Position).Magnitude<=16 then finish(room,p,true) end
        end)
    end
    function X.Buy(p,id,restoring)
        if p~=S.Owner or not p:GetAttribute('ProfileReady') or type(id)~='string' then return false,'owner' end
        local item for _,v in Config.Shop do if v.Id==id then item=v break end end
        if not item then return false,'item' end
        if item.Duration then if X.Boost(p,id) then return false,'active' end
        elseif not restoring and p:GetAttribute('Owns'..id) then return false,'owned' end
        if not restoring and p.leaderstats.Tokens.Value<item.Price then return false,'funds' end
        if not restoring then p.leaderstats.Tokens.Value-=item.Price end
        if item.Duration then p:SetAttribute(id..'Until',workspace:GetServerTimeNow()+item.Duration)
        else
            p:SetAttribute('Owns'..id,true)
            if id=='Garden' then
                for _,x in {-43,43} do G.Prop(extras,'Flowers',origin+Vector3.new(x,5.35,-17),G.Colors.coral) end
            elseif id=='Tables' then
                for _,z in {-26,-38} do
                    G.Prop(extras,'CafeTable',origin+Vector3.new(44,5.35,z))
                    for _,dz in {-3,3} do local pos=origin+Vector3.new(44,5.35,z+dz) local chair=G.Prop(extras,'Chair',pos,G.Colors.coral) chair:PivotTo(CFrame.new(pos)*CFrame.Angles(0,dz>0 and 0 or math.pi,0)) end
                end
            end
        end
        if item.Bonus then p:SetAttribute('IncomePerTick',(p:GetAttribute('IncomePerTick') or 0)+item.Bonus*(p:GetAttribute('OccupiedRooms') or 0)) end
        p:SetAttribute('ResortNotice',item.Name..' ready!') p:SetAttribute('NoticeVersion',(p:GetAttribute('NoticeVersion') or 0)+1)
        refresh() return true
    end
    local cleaner,working=false,false
    task.spawn(function()
        while root.Parent do
            task.wait(.5)
            local p=S.Owner
            if p then
                local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid') if h then h.WalkSpeed=p:GetAttribute('ArenaTeam') and 16 or (X.Boost(p,'Turbo') and 24 or 16) end
                for _,room in rooms do room.Floor.CleanPrompt.HoldDuration=X.Boost(p,'Foam') and 1 or Config.CleanSeconds end
                if p:GetAttribute('OwnsCleaner') and not cleaner then
                    cleaner=Instance.new('Model') cleaner.Name='CleanerBot' cleaner.Parent=extras
                    local body=part(cleaner,'Body',Vector3.new(2.6,1.2,2.6),CFrame.new(origin+Vector3.new(-10,6.4,-28)),G.Colors.purple) body.Shape=Enum.PartType.Ball cleaner.PrimaryPart=body
                    part(cleaner,'Face',Vector3.new(1.6,.5,.15),body.CFrame*CFrame.new(0,.3,-1.2),G.Colors.teal)
                    part(cleaner,'Brush',Vector3.new(3,.2,3),body.CFrame*CFrame.new(0,-.5,0),G.Colors.dark)
                end
                if cleaner and not working then
                    for _,room in rooms do if room:GetAttribute('Dirty') then
                        working=true local generation=S.Generation local owner=p
                        local bot=cleaner
                        task.spawn(function()
                            local destination=room.Floor.Position+Vector3.new(-3,1,0)
                            local function move(pos)
                                if S.Owner~=owner or S.Generation~=generation or not bot.Parent then return false end
                                local value=Instance.new('CFrameValue') value.Value=bot:GetPivot()
                                local start=value.Value.Position
                                local peak=Vector3.new((start.X+pos.X)/2,math.max(start.Y,pos.Y)+2.2,(start.Z+pos.Z)/2)
                                local connection=value.Changed:Connect(function(cf) if bot.Parent then bot:PivotTo(cf) end end)
                                local duration=math.max(.28,(start-pos).Magnitude/16)
                                local up=TweenService:Create(value,TweenInfo.new(duration*.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=CFrame.new(peak)})
                                up:Play() up.Completed:Wait()
                                if not bot.Parent then connection:Disconnect() value:Destroy() return false end
                                local down=TweenService:Create(value,TweenInfo.new(duration*.55,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Value=CFrame.new(pos)})
                                down:Play() down.Completed:Wait()
                                connection:Disconnect() value:Destroy()
                                return S.Owner==owner and S.Generation==generation and bot.Parent~=nil
                            end
                            local start=bot:GetPivot().Position
                            local north=destination.Z-origin.Z>50
                            local lane=start.Z-origin.Z>50 and 62 or -10
                            local route={Vector3.new(start.X,6.8+origin.Y,lane+origin.Z),origin+Vector3.new(17,6.8,lane),origin+Vector3.new(17,6.8,north and 62 or -10),Vector3.new(destination.X,6.8+origin.Y,(north and 62 or -10)+origin.Z),destination}
                            for _,pos in route do if not move(pos) then if S.Generation==generation then working=false end return end end
                            task.wait(6)
                            if S.Owner==owner and S.Generation==generation then finish(room,owner,false) end
                            if S.Generation==generation then working=false end
                        end)
                        break
                    end end
                end
            elseif cleaner then cleaner:Destroy() cleaner=nil end
        end
    end)
    X.Reset=function()
        for _,room in rooms do dirty(room,false) room:SetAttribute('NextPaymentAt',0) end
        extras:ClearAllChildren() cleaner=nil working=false
    end
    return X
end
return X
