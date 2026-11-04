local Players=game:GetService('Players')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local Config=require(script.Parent.Config)
local Geometry=require(script.Parent.Geometry)
local Plot=require(script.Parent.PlotService)
local Progress=require(script.Parent.ProgressStore)
local Pets=require(script.Parent.PetService)
local Extras=require(script.Parent.ResortExtras)
local Service={Plots={},Assignments={},Started=false}
local cooldown={}
local function notice(p,message)
    p:SetAttribute('ResortNotice',message)
    p:SetAttribute('NoticeVersion',(p:GetAttribute('NoticeVersion') or 0)+1)
end
function Service.Assign(p)
    if Service.Assignments[p] then return Service.Assignments[p] end
    if p.Parent~=Players or not p:GetAttribute('ProfileReady') then return end
    for _,plot in Service.Plots do
        if not plot.Reserved then
            plot.Reserved=p Service.Assignments[p]=plot
            plot.Root:SetAttribute('ReservedUserId',p.UserId)
            p:SetAttribute('PlotName',plot.Root.Name)
            p:SetAttribute('GuideTitle','Claim your FREE resort')
            p:SetAttribute('GuideDetail','Your own island is ready. Hold the terminal prompt to begin.')
            p:SetAttribute('GuideTarget','ClaimTerminal')
            plot.Root.ClaimTerminal.ProximityPrompt.ObjectText=p.DisplayName..' / FREE PLOT'
            if p.Character then p.Character:PivotTo(CFrame.new(plot.Origin+Vector3.new(0,10,-44))) end
            return plot
        end
    end
    p:SetAttribute('GuideTitle','Waiting for a free plot')
    p:SetAttribute('GuideDetail','All four islands are in use. You will get one when a player leaves.')
    p:SetAttribute('GuideTarget','')
end
function Service.Release(p)
    local plot=Service.Assignments[p] if not plot then return end
    plot.Reset() plot.Reserved=nil plot.Root:SetAttribute('ReservedUserId',nil)
    Service.Assignments[p]=nil p:SetAttribute('PlotName',nil)
    for _,waiting in Players:GetPlayers() do if waiting~=p then Service.Assign(waiting) end end
end
function Service.Start()
    if Service.Started then return end Service.Started=true
    local old=workspace:FindFirstChild('AlienResort')
    if old then old.Parent=game:GetService('ServerStorage') old.Name='LegacyResort_Backup' end
    local container=Instance.new('Folder') container.Name='ResortPlots' container.Parent=workspace
    for i=1,Config.PlotCount do
        local origin=Vector3.new(((i-1)%2)*Config.PlotSpacing,0,math.floor((i-1)/2)*Config.PlotSpacing)
        local root=Geometry.Build(container,'Plot'..i,origin) root:SetAttribute('PlotIndex',i)
        table.insert(Service.Plots,Plot.New(root,origin)) task.wait()
    end
    local remote=ReplicatedStorage:FindFirstChild('ResortShop') or Instance.new('RemoteEvent')
    remote.Name='ResortShop' remote.Parent=ReplicatedStorage
    remote.OnServerEvent:Connect(function(p,action,id)
        if type(action)~='string' or #action>32 then return end
        if os.clock()-(cooldown[p] or -math.huge)<.35 then return end cooldown[p]=os.clock()
        local plot=Service.Assignments[p]
        if not plot or plot.Owner~=p or not p:GetAttribute('ProfileReady') then notice(p,'Claim your own plot first!') return end
        if type(id)~='string' or #id>32 then return end
        local ok,why
        if action=='Shop' then ok,why=plot.Shop(p,id)
        elseif action=='BuyPet' then ok,why=Pets.Buy(plot,p,id)
        elseif action=='EquipPet' then ok,why=Pets.Equip(plot,p,id)
        else return end
        if ok then
            plot.Refresh()
            local spec=Pets.Find(id)
            notice(p,action=='Shop' and 'Supplies ready!' or (spec.CharacterName..': '..spec.Greeting))
        else notice(p,({funds='Not enough tokens!',owned='Already owned. Equip it from Pets.',active='This boost is still active!',locked='Buy this pet before equipping it.'})[why] or 'Unable to buy this item.') end
    end)
    require(script.Parent.AdventureService).Start(Service)
    Progress.Start()
    local function setup(p)
        if p:GetAttribute('SetupStarted') then return end p:SetAttribute('SetupStarted',true)
        p:SetAttribute('ProfileReady',false) p:SetAttribute('OwnsResort',false)
        local stats=Instance.new('Folder') stats.Name='leaderstats' stats.Parent=p
        local tokens=Instance.new('IntValue') tokens.Name='Tokens' tokens.Parent=stats
        p:SetAttribute('BuiltCount',0) p:SetAttribute('EarnedTotal',0)
        p:SetAttribute('IncomePerTick',0) p:SetAttribute('OccupiedRooms',0) p:SetAttribute('GuestsServed',0)
        p:SetAttribute('GuideTitle','Preparing your resort...') p:SetAttribute('GuideDetail','Loading progress safely.')
        tokens.Changed:Connect(function() local plot=Service.Assignments[p] if plot and plot.Owner==p then plot.Refresh() end end)
        local function spawn(character)
            local hrp=character:WaitForChild('HumanoidRootPart',10) local plot=Service.Assignments[p]
            if hrp and p.Character==character and plot then character:PivotTo(CFrame.new(plot.Origin+Vector3.new(0,10,-44))) end
        end
        p.CharacterAdded:Connect(spawn) p.CharacterAppearanceLoaded:Connect(Extras.Robot)
        if p.Character then task.spawn(spawn,p.Character) task.spawn(Extras.Robot,p.Character) end
        local data=Progress.Load(p) if not data or p.Parent~=Players then return end
        tokens.Value=data.Tokens
        p:SetAttribute('EarnedTotal',data.Earned) p:SetAttribute('SpeciesDiscovered',data.Species)
        for id,stage in data.Stages do p:SetAttribute('Stage_'..id,stage) end
        for id,owned in data.Owned do p:SetAttribute('Owns'..id,owned) end
        for id,owned in data.Pets do p:SetAttribute('Pet_'..id,owned) end
        p:SetAttribute('EquippedPet',data.EquippedPet)
        p:SetAttribute('StarShards',data.StarShards)
        for _,spec in Config.PetSpecies do p:SetAttribute('Bond_'..spec.Id,data.Bond[spec.Id]) p:SetAttribute('Evolved_'..spec.Id,data.Evolved[spec.Id]) end
        Progress.Ready(p) Service.Assign(p)
    end
    Players.PlayerAdded:Connect(function(p) task.spawn(setup,p) end)
    Players.PlayerRemoving:Connect(function(p)
        p:SetAttribute('ProfileReady',false)
        Service.Release(p) cooldown[p]=nil Progress.Save(p,true)
    end)
    for _,p in Players:GetPlayers() do task.spawn(setup,p) end
    task.spawn(function()
        while container.Parent do task.wait(.1) for _,plot in Service.Plots do Pets.Step(plot) end end
    end)
    print('Alien Resort 0.9.1: Cosmic Commons, pet abilities, training, rescue and Starcore Capture ready.')
end
return Service
