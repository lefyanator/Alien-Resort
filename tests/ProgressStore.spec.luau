-- Isolated production-path checks. No live players, DataStores or startup loop.
return function(requireModule)
    local P=requireModule('ProgressStore')
    local count=0 local sequence=0 local clock=1000
    local function check(value,message) count+=1 assert(value,message) end
    local legacy=P.Normalize({})
    check(legacy.RoomsCleaned==0 and legacy.GuestsServed==0,'legacy opening counters default safely')
    local counters=P.Normalize({RoomsCleaned=7,GuestsServed=12})
    check(counters.RoomsCleaned==7 and counters.GuestsServed==12,'opening counters survive normalization')
    local malformed=P.Normalize({RoomsCleaned=-2,GuestsServed=0/0})
    check(malformed.RoomsCleaned==0 and malformed.GuestsServed==0,'invalid opening counters are clamped')
    local function copy(value)
        if type(value)~='table' then return value end
        local result={} for k,v in value do result[k]=copy(v) end return result
    end
    local function backend(record)
        local db={Record=copy(record),Calls=0}
        function db:UpdateAsync(key,transform)
            self.Calls+=1 assert(key=='Player_42','DataStore key changed')
            if self.Before then self:Before() end
            if (self.FailBefore or 0)>0 then self.FailBefore-=1 error('simulated unavailable API') end
            local updated=transform(copy(self.Record))
            if self.Replay then updated=transform(copy(self.Record)) end
            if updated==nil then return nil end
            self.Record=copy(updated)
            if (self.FailAfter or 0)>0 then self.FailAfter-=1 error('committed, response lost') end
            return copy(self.Record)
        end
        return db
    end
    local function player()
        local p={UserId=42,Alive=true,Attributes={},leaderstats={Tokens={Value=0}}}
        function p:GetAttribute(key) return self.Attributes[key] end
        function p:SetAttribute(key,value) self.Attributes[key]=value end
        function p:FindFirstChild(key) return self[key] end
        function p.leaderstats:FindFirstChild(key) return self[key] end
        function p:Kick(reason) self.Kicked=reason end
        return p
    end
    local function store(db,wait)
        return P.New(db,{Now=function() return clock end,Wait=wait or function() end,
            Guid=function() sequence+=1 return 'test-'..sequence end,Present=function(p) return p.Alive end})
    end
    local function apply(p,data)
        p.leaderstats.Tokens.Value=data.Tokens
        p:SetAttribute('EquippedPet',data.EquippedPet)
        p:SetAttribute('RoomsCleaned',data.RoomsCleaned) p:SetAttribute('GuestsServed',data.GuestsServed)
        for id,value in data.Stages do p:SetAttribute('Stage_'..id,value) end
        for id,value in data.Pets do p:SetAttribute('Pet_'..id,value) end
        for id,value in data.Owned do p:SetAttribute('Owns'..id,value) end
    end

    local p=player() local s=store(nil)
    check(s.Load(p).Tokens==0,'Studio defaults')
    check(s.Ready(p) and s.Save(p,true),'Studio session remains supported')

    local db=backend({Data={Tokens=88,Stages={Room2=3},Owned={Cleaner=true},RoomsCleaned=7,GuestsServed=12}})
    p=player() s=store(db) local data=s.Load(p)
    check(data.Tokens==88 and data.Stages.Room2==3 and data.Owned.Cleaner,'legacy fields migrated')
    check(db.Record.Data.Version==3 and db.Record.Lock.Expires==1180,'schema and lease retained')
    apply(p,data) check(s.Ready(p),'loaded profile ready') p.leaderstats.Tokens.Value=200
    check(s.Save(p,false) and db.Record.Data.Tokens==200,'autosave captures current profile')
    check(db.Record.Data.RoomsCleaned==7 and db.Record.Data.GuestsServed==12,'autosave keeps completed opening counters')
    check(db.Record.Lock~=nil,'autosave renews lease')
    check(s.Save(p,true) and db.Record.Lock==nil,'release clears lease')
    local calls=db.Calls check(not s.Save(p,true) and db.Calls==calls,'released profile cannot write again')

    db=backend({Data={Tokens=91}}) p=player() s=store(db)
    function db:Before() self.Before=nil p.Alive=false end
    check(s.Load(p)==nil,'late load after leave is discarded')
    check(db.Record.Data.Tokens==91 and db.Record.Lock==nil,'late load releases preserved loaded snapshot')

    db=backend({Data={Tokens=125}}) p=player() local first=store(db) local second=store(db)
    data=first.Load(p) local token=db.Record.Lock.Token local other=player()
    check(second.Load(other)==nil and other.Kicked~=nil,'overlapping server cannot load leased profile')
    check(db.Record.Lock.Token==token and db.Record.Data.Tokens==125,'contending load never overwrites data')
    check(not second.Ready(other),'failed load cannot become ready')
    apply(p,data) first.Ready(p) check(first.Save(p,true),'original owner can still release')

    db=backend({Data={Tokens=63},Lock={Token='expired',Expires=999}}) p=player() s=store(db)
    check(s.Load(p).Tokens==63 and db.Record.Lock.Token~='expired','expired lease can be acquired')
    s.Save(p,true)
    for _,record in {{Data={Version=99,Tokens=800},Extra='future'},{Data='corrupt',Extra='preserve'}} do
        db=backend(record) p=player() s=store(db)
        check(s.Load(p)==nil and p.Kicked~=nil,'unsupported record refused')
        check(db.Record.Extra==record.Extra and db.Record.Lock==nil,'unsupported record left intact')
        check(not s.Ready(p) and not s.Save(p,true),'unsupported record cannot be saved')
    end

    db=backend(nil) db.FailBefore=3 p=player() s=store(db)
    check(s.Load(p)==nil and p.Kicked and db.Calls==3,'load outage retries then refuses play')
    check(db.Record==nil,'failed load never creates a blank save')

    db=backend({Data={Tokens=77}}) db.FailAfter=1 p=player() s=store(db)
    check(s.Load(p).Tokens==77 and db.Record.Lock~=nil,'lost load response reacquires same session token')
    check(s.Save(p,true),'recovered load releases')

    db=backend({Data={Tokens=50}}) p=player() s=store(db) data=s.Load(p) apply(p,data) s.Ready(p)
    p.leaderstats.Tokens.Value=321 db.FailAfter=1 db.Replay=true
    check(s.Save(p,true),'committed release with lost response is confirmed idempotently')
    check(db.Record.Data.Tokens==321 and db.Record.Lock==nil and not p.Kicked,'release retry preserves data and avoids false failure')

    db=backend({Data={Tokens=40}}) p=player() s=store(db) data=s.Load(p) apply(p,data) s.Ready(p)
    db.FailBefore=3 p.leaderstats.Tokens.Value=500
    check(not s.Save(p,false) and p.Kicked and not p:GetAttribute('ProfileReady'),'save outage stops further play')
    check(db.Record.Data.Tokens==40,'save outage preserves last good cloud data')

    db=backend({Data={Tokens=44}}) p=player() s=store(db) data=s.Load(p) apply(p,data) s.Ready(p)
    db.Record.Lock.Token='another-server' p.leaderstats.Tokens.Value=700
    check(not s.Save(p,true),'lost lease rejects save')
    check(db.Record.Lock.Token=='another-server' and db.Record.Data.Tokens==44,'lost lease cannot overwrite newer owner')

    -- Interleave an autosave with a release. The release snapshots after the busy write.
    db=backend({Data={Tokens=60}}) p=player()
    s=store(db,function() coroutine.yield('busy') end) data=s.Load(p) apply(p,data) s.Ready(p)
    p.leaderstats.Tokens.Value=100
    function db:Before() self.Before=nil coroutine.yield('write in flight') end
    local autosaved,released
    local auto=coroutine.create(function() autosaved=s.Save(p,false) end)
    check(coroutine.resume(auto),'autosave started')
    local release=coroutine.create(function() released=s.Save(p,true) end)
    check(coroutine.resume(release) and coroutine.status(release)=='suspended','release waits for in-flight save')
    p.leaderstats.Tokens.Value=150
    check(coroutine.resume(auto) and autosaved,'in-flight autosave completes')
    check(coroutine.resume(release) and released,'queued release completes')
    check(db.Record.Data.Tokens==150 and db.Record.Lock==nil,'queued release saves newest snapshot')
    return {Passed=count,Backend='fake UpdateAsync; production callbacks',Cloud='NOT TESTED'}
end
