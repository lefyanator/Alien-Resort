local P={}
local Config=require(script.Parent.Config)
local Players=game:GetService('Players')
local Http=game:GetService('HttpService')
local enabled=game.GameId~=0 and not game:GetService('RunService'):IsStudio()
local database=enabled and game:GetService('DataStoreService'):GetDataStore('OrbitOasis_Progress_v1')
local function bounded(value,maximum)
    if type(value)~='number' or value~=value or math.abs(value)==math.huge then return 0 end
    return math.clamp(math.floor(value),0,maximum)
end
function P.Normalize(data)
    data=type(data)=='table' and data or {}
    local result={Version=3,StarShards=bounded(data.StarShards,1000000),Bond={},Evolved={},Tokens=bounded(data.Tokens,100000000),Stages={},Owned={},Pets={Pebble=true},Earned=bounded(data.Earned,100000000),Species=data.Species==true,EquippedPet='Pebble'}
    local previous=true
    for _,u in Config.Upgrades do
        local n=previous and bounded(type(data.Stages)=='table' and data.Stages[u.Id],3) or 0
        result.Stages[u.Id]=n previous=n==3
    end
    for _,item in Config.Shop do if not item.Duration then result.Owned[item.Id]=type(data.Owned)=='table' and data.Owned[item.Id]==true end end
    for _,spec in Config.PetSpecies do
        result.Bond[spec.Id]=bounded(type(data.Bond)=='table' and data.Bond[spec.Id],1000)
        result.Evolved[spec.Id]=type(data.Evolved)=='table' and data.Evolved[spec.Id]==true
        if spec.Id~='Pebble' then result.Pets[spec.Id]=type(data.Pets)=='table' and data.Pets[spec.Id]==true end
        if data.EquippedPet==spec.Id and result.Pets[spec.Id] then result.EquippedPet=spec.Id end
    end
    return result
end
function P.Snapshot(p)
    local stats=p:FindFirstChild('leaderstats') local tokens=stats and stats:FindFirstChild('Tokens')
    local data={Tokens=tokens and tokens.Value or 0,Stages={},Owned={},Pets={},Bond={},Evolved={},StarShards=p:GetAttribute('StarShards'),EquippedPet=p:GetAttribute('EquippedPet'),Earned=p:GetAttribute('EarnedTotal'),Species=p:GetAttribute('SpeciesDiscovered')}
    for _,u in Config.Upgrades do data.Stages[u.Id]=p:GetAttribute('Stage_'..u.Id) end
    for _,item in Config.Shop do if not item.Duration then data.Owned[item.Id]=p:GetAttribute('Owns'..item.Id) end end
    for _,spec in Config.PetSpecies do data.Pets[spec.Id]=p:GetAttribute('Pet_'..spec.Id) data.Bond[spec.Id]=p:GetAttribute('Bond_'..spec.Id) data.Evolved[spec.Id]=p:GetAttribute('Evolved_'..spec.Id) end
    return P.Normalize(data)
end
-- Backend injection exercises the production load/save path without cloud writes.
function P.New(backend,options)
    local store={Normalize=P.Normalize,Snapshot=P.Snapshot,New=P.New}
    local sessions={} local started=false local closing=false
    options=options or {}
    local wait=options.Wait or task.wait
    local now=options.Now or os.time
    local guid=options.Guid or function() return Http:GenerateGUID(false) end
    local present=options.Present or function(p) return p.Parent==Players end
    local function compatible(record)
        return record==nil or (type(record)=='table' and type(record.Data)=='table'
            and (type(record.Data.Version)~='number' or record.Data.Version<=3))
    end
    function store.Load(p)
        p:SetAttribute('ProfileReady',false)
        if not backend then p:SetAttribute('SaveStatus','TEST SESSION - progress resets') return P.Normalize(nil) end
        local token=guid() local incompatible=false
        p:SetAttribute('SaveStatus','Loading progress...')
        for attempt=1,3 do
            local ok,record=pcall(function()
                return backend:UpdateAsync('Player_'..p.UserId,function(old)
                    if not compatible(old) then incompatible=true return nil end
                    old=type(old)=='table' and old or {}
                    local lock=type(old.Lock)=='table' and old.Lock
                    if lock and type(lock.Expires)=='number' and lock.Expires>now() and lock.Token~=token then return nil end
                    return {Data=P.Normalize(old.Data),Lock={Token=token,Expires=now()+180}}
                end)
            end)
            if ok and record and record.Lock and record.Lock.Token==token then
                local data=P.Normalize(record.Data)
                sessions[p]={Token=token,Busy=false,Loaded=data,Ready=false}
                if not present(p) or closing then store.Save(p,true) return nil end
                p:SetAttribute('SaveStatus','Progress loaded') return data
            end
            if not present(p) or closing then return nil end
            if incompatible then break end
            wait(attempt)
        end
        p:Kick('Your progress could not be safely loaded. Please rejoin shortly.') return nil
    end
    function store.Ready(p)
        if backend and not sessions[p] then return false end
        if sessions[p] then sessions[p].Ready=true end
        p:SetAttribute('ProfileReady',true) return true
    end
    function store.Save(p,release)
        local session=sessions[p] if not session then return not backend end
        while session.Busy and sessions[p]==session do wait(.1) end
        if sessions[p]~=session then return not session.Failed end
        session.Busy=true
        local data=session.Ready and P.Snapshot(p) or session.Loaded
        local success=false
        local writeId=guid()
        for attempt=1,3 do
            local ok,record=pcall(function()
                return backend:UpdateAsync('Player_'..p.UserId,function(old)
                    -- A committed release may lose its response after clearing the lock.
                    -- A stable write ID makes that retry idempotent, without reacquiring it.
                    if type(old)=='table' and old.WriteId==writeId then return old end
                    if not compatible(old) then return nil end
                    if type(old)~='table' or type(old.Lock)~='table' or old.Lock.Token~=session.Token then return nil end
                    return {Data=data,WriteId=writeId,Lock=not release and {Token=session.Token,Expires=now()+180} or nil}
                end)
            end)
            if ok and record and record.WriteId==writeId then success=true break end
            wait(attempt)
        end
        session.Busy=false
        if success then session.Loaded=data p:SetAttribute('SaveStatus','Progress saved')
        else
            p:SetAttribute('ProfileReady',false) p:SetAttribute('SaveStatus','Save failed - please rejoin')
            if present(p) then p:Kick('Saving failed. Please rejoin to protect your progress.') end
        end
        session.Failed=not success
        if release or not success then sessions[p]=nil end
        return success
    end
    function store.Start()
        if started then return end started=true
        task.spawn(function()
            while not closing do task.wait(45) if not closing then for p in sessions do task.spawn(store.Save,p,false) end end end
        end)
        game:BindToClose(function()
            closing=true local pending=0
            for p in sessions do pending+=1 task.spawn(function() store.Save(p,true) pending-=1 end) end
            local deadline=os.clock()+25 while pending>0 and os.clock()<deadline do task.wait(.1) end
        end)
    end
    return store
end
return P.New(database)
