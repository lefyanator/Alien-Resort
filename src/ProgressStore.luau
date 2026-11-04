local P={}
local Config=require(script.Parent.Config)
local Http=game:GetService('HttpService')
local enabled=game.GameId~=0 and not game:GetService('RunService'):IsStudio()
local database=enabled and game:GetService('DataStoreService'):GetDataStore('OrbitOasis_Progress_v1')
local sessions={}
local function bounded(value,max)
    return type(value)=='number' and value==value and math.clamp(math.floor(value),0,max) or 0
end
function P.Normalize(data)
    data=type(data)=='table' and data or {}
    local result={Tokens=bounded(data.Tokens,100000000),Stages={},Owned={},Earned=bounded(data.Earned,100000000),Species=data.Species==true}
    local previous=true
    for _,u in Config.Upgrades do
        local n=previous and bounded(type(data.Stages)=='table' and data.Stages[u.Id],3) or 0
        result.Stages[u.Id]=n previous=n==3
    end
    for _,item in Config.Shop do if not item.Duration then result.Owned[item.Id]=type(data.Owned)=='table' and data.Owned[item.Id]==true end end
    return result
end
function P.Snapshot(p)
    local tokens=p:FindFirstChild('leaderstats') and p.leaderstats:FindFirstChild('Tokens')
    local data={Tokens=tokens and tokens.Value or 0,Stages={},Owned={},Earned=p:GetAttribute('EarnedTotal'),Species=p:GetAttribute('SpeciesDiscovered')}
    for _,u in Config.Upgrades do data.Stages[u.Id]=p:GetAttribute('Stage_'..u.Id) end
    for _,item in Config.Shop do if not item.Duration then data.Owned[item.Id]=p:GetAttribute('Owns'..item.Id) end end
    return P.Normalize(data)
end
function P.Load(p)
    if not enabled then p:SetAttribute('SaveStatus','TEST SESSION - progress resets') p:SetAttribute('ProfileReady',true) return P.Normalize(nil) end
    local token=Http:GenerateGUID(false)
    p:SetAttribute('SaveStatus','Loading progress...')
    for attempt=1,3 do
        local ok,record=pcall(function()
            return database:UpdateAsync('Player_'..p.UserId,function(old)
                old=type(old)=='table' and old or {}
                if old.Lock and old.Lock.Expires>os.time() and old.Lock.Token~=token then return nil end
                return {Data=P.Normalize(old.Data),Lock={Token=token,Expires=os.time()+180}}
            end)
        end)
        if ok and record and record.Lock.Token==token then
            sessions[p]={Token=token,Busy=false}
            p:SetAttribute('SaveStatus','Progress loaded') p:SetAttribute('ProfileReady',true)
            return record.Data
        end
        task.wait(attempt)
    end
    p:Kick('Your progress could not be safely loaded. Please rejoin shortly.')
    return nil
end
function P.Save(p,release)
    local session=sessions[p] if not session then return not enabled end
    while session.Busy do task.wait(.1) end
    if sessions[p]~=session then return true end
    session.Busy=true
    local data=P.Snapshot(p) local success=false
    for attempt=1,3 do
        local ok,record=pcall(function()
            return database:UpdateAsync('Player_'..p.UserId,function(old)
                if not old or not old.Lock or old.Lock.Token~=session.Token then return nil end
                return {Data=data,Lock=not release and {Token=session.Token,Expires=os.time()+180} or nil}
            end)
        end)
        if ok and record then success=true break end
        task.wait(attempt)
    end
    session.Busy=false
    if success then p:SetAttribute('SaveStatus','Progress saved')
    else p:SetAttribute('SaveStatus','Save failed - reconnect to protect progress') p:Kick('Saving failed. Please rejoin shortly to protect your progress.') end
    if release or not success then sessions[p]=nil end
    return success
end
function P.Start()
    task.spawn(function() while task.wait(45) do for p in sessions do task.spawn(P.Save,p,false) end end end)
    game:BindToClose(function()
        local pending=0
        for p in sessions do pending+=1 task.spawn(function() P.Save(p,true) pending-=1 end) end
        local deadline=os.clock()+25 while pending>0 and os.clock()<deadline do task.wait(.1) end
    end)
end
return P
