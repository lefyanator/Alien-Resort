-- Production guide/VIP checks and an explicit policy simulation, not a Studio playtest.
return function(O,C)
    local count=0
    local function check(value,message) count+=1 assert(value,message) end
    local function price(u,stage)
        local first=math.floor(u.Price*.2) local second=math.floor(u.Price*.3)
        return ({first,second,u.Price-first-second})[stage+1]
    end
    local function nextStage(index,stage)
        local u=C.Upgrades[index]
        return {Id=u.Id,Name=u.Name,Description=u.Description,Stage=stage,Price=price(u,stage)}
    end
    local function guide(patch)
        local s={Owned=true,Earned=10,Occupied=1,Cleaned=0,OwnsCleaner=false,Room2=false,Reception=false,Observatory=false,Bond=0,Balance=0,Next=nextStage(1,0)}
        for k,v in patch do s[k]=v end
        local g=O.Guide(s)
        check(type(g.Step)=='number' and type(g.Complete)=='boolean' and type(g.Title)=='string' and type(g.Detail)=='string' and type(g.Target)=='string' and type(g.Action)=='string' and type(g.Cost)=='number','complete guide contract')
        return g
    end
    local g=guide({Owned=false,Room2=true,Reception=true,OwnsCleaner=true})
    check(g.Step==1 and not g.Complete and g.Target=='ClaimTerminal','loaded stages never skip claiming')
    g=guide({Earned=0,Occupied=0}) check(g.Step==2 and g.Target=='LandingPad','new arrival objective')
    g=guide({Earned=0,Occupied=1}) check(g.Step==2 and g.Target=='StarterRoom','check-in objective before first payment')
    local cost=price(C.Upgrades[1],0)
    g=guide({Balance=cost-1}) check(g.Step==3 and g.Action=='' and g.Target=='StarterRoom','first stay explains checkout before affordable build')
    g=guide({Balance=cost}) check(g.Step==3 and g.Action=='Build' and g.Cost==cost,'exact construction boundary permits build while waiting')
    g=guide({Balance=cost,DirtyRoom='StarterRoom'}) check(g.Step==3 and g.Action=='' and g.Target=='Clean_StarterRoom' and g.Cost==0,'dirty room takes precedence over affordable build')
    g=guide({Cleaned=1,Balance=cost-1}) check(g.Step==4 and g.Action=='Build' and g.Cost==cost and g.Title:sub(1,8)=='Save for','manual cleaning advances to construction')
    g=guide({Cleaned=1,Balance=cost}) check(g.Step==4 and g.Title:sub(1,5)=='Build','affordable next stage has clear verb')
    g=guide({Earned=0,Room2=true,Next=nextStage(2,0)}) check(g.Step==5 and g.Action=='Build','legacy Room2 skips repeated first-income and cleaning lessons')
    g=guide({Room2=true,DirtyRoom='Room2',Next=nextStage(2,0)}) check(g.Step==5 and g.Target=='Clean_Room2' and g.Action~='Shop','cleaning override retains reception step without forcing cleaner')
    local cleanerPrice=0 for _,item in C.Shop do if item.Id=='Cleaner' then cleanerPrice=item.Price end end
    g=guide({Room2=true,Reception=true}) check(g.Step==6 and not g.Complete and g.Action=='Shop' and g.Cost==cleanerPrice,'cleaner follows reception')
    g=guide({Room2=true,Reception=true,OwnsCleaner=true}) check(g.Complete and g.Action=='Adventure','completed opening introduces companion activity')
    g=guide({Room2=true,Reception=true,OwnsCleaner=true,Bond=1,Next=nextStage(3,0)}) check(g.Complete and g.Action=='Build' and g.Target=='Kiosk','returning adventurer resumes construction')
    g=guide({Room2=true,Reception=true,OwnsCleaner=true,Bond=1,Observatory=true,Next=false}) check(g.Complete and g.Action=='Adventure' and g.Cost==0,'finished resort points to Palace without extra currency')
    check(not O.IsVIP(false,C.VIP.Every) and not O.IsVIP(true,0) and not O.IsVIP(true,-C.VIP.Every),'VIP cannot bypass unlock or sequence start')
    check(O.IsVIP(true,C.VIP.Every) and O.IsVIP(true,C.VIP.Every*2) and not O.IsVIP(true,C.VIP.Every+1),'VIP cadence is deterministic')
    check(not O.IsVIP(true,'3') and not O.IsVIP(true,1.5),'invalid sequences cannot trigger VIP')
    check(O.Payout(10,0,false)==10 and O.Payout(10,5,true)==15+C.VIP.Bonus,'VIP is additive to base and species payout')
    check(O.Payout(30,10,true)==40+C.VIP.Bonus,'upgraded VIP payout never multiplies all income')

    -- Greedy owner follows guide, buys only opening buildings/cleaner and cleans immediately.
    -- South rooms only. Real motion/network/cleaner routing is NOT simulated.
    local assumptions={Landing=3,Unload=1.2,Takeoff=3,Walk=8.5,Departure=5,CleanerTravel=8}
    local now,serial,padUntil=0,0,0 local events={} local rooms={} local stages={0,0}
    local s={Owned=true,Earned=0,Occupied=0,Cleaned=0,Balance=0,Bond=0,Room2=false,Reception=false,OwnsCleaner=false}
    local marks={Claim=0} local cleanerBusy=false
    local function schedule(at,fn) serial+=1 table.insert(events,{At=at,Fn=fn,Order=serial}) end
    local beginGuest
    beginGuest=function(room)
        local landing=math.max(now,padUntil) padUntil=landing+assumptions.Landing+assumptions.Unload+assumptions.Takeoff
        local entered=landing+assumptions.Landing+assumptions.Unload+assumptions.Walk
        schedule(entered,function() s.Occupied+=1 end)
        for payment=1,C.GuestStayPayments do schedule(entered+payment*C.IncomeInterval,function()
            s.Balance+=O.Payout(C.BasePayout,0,false) s.Earned+=C.BasePayout marks.FirstPayout=marks.FirstPayout or now
            if payment==C.GuestStayPayments then s.Occupied-=1 schedule(now+assumptions.Departure,function() room.Dirty=true end) end
        end) end
    end
    local function sweep()
        s.DirtyRoom=nil
        for i,room in rooms do if room.Dirty then
            s.DirtyRoom=s.DirtyRoom or ('Room'..i)
            if not room.Cleaning and (not s.OwnsCleaner or not cleanerBusy) then
                room.Cleaning=true local automated=s.OwnsCleaner cleanerBusy=automated or cleanerBusy
                schedule(now+(automated and (6+assumptions.CleanerTravel) or C.CleanSeconds),function()
                    room.Dirty=false room.Cleaning=false cleanerBusy=false
                    if not automated then s.Cleaned+=1 s.Balance+=C.CleanReward marks.FirstClean=marks.FirstClean or now end
                    schedule(now+(s.Reception and C.ReceptionArrivalDelay or C.ArrivalDelay),function() beginGuest(room) end)
                end)
            end
        end end
        for _=1,7 do
            local index=not s.Room2 and 1 or not s.Reception and 2 or nil
            s.Next=index and nextStage(index,stages[index]) or nil
            local current=O.Guide(s)
            if current.Action=='Build' and index and s.Balance>=current.Cost then
                s.Balance-=current.Cost stages[index]+=1
                if stages[index]==3 then
                    if index==1 then s.Room2=true marks.Room2=now local room={} table.insert(rooms,room) beginGuest(room)
                    else s.Reception=true marks.Reception=now end
                end
            elseif current.Action=='Shop' and s.Balance>=cleanerPrice then
                s.Balance-=cleanerPrice s.OwnsCleaner=true marks.Cleaner=now
            else break end
        end
    end
    local first={} table.insert(rooms,first) beginGuest(first)
    while #events>0 and now<600 do
        table.sort(events,function(a,b) return a.At==b.At and a.Order<b.Order or a.At<b.At end)
        local event=table.remove(events,1) now=event.At if now>600 then break end event.Fn() sweep()
        if O.Guide(s).Complete then break end
    end
    check(marks.FirstPayout and math.abs(marks.FirstPayout-(assumptions.Landing+assumptions.Unload+assumptions.Walk+C.IncomeInterval))<.001,'parallel takeoff is excluded from first-payment wait')
    check(marks.FirstClean and marks.Room2 and marks.Reception and marks.Cleaner,'simulation reaches every opening milestone')
    check(marks.Reception>=marks.Room2 and marks.Cleaner>=marks.Reception,'opening does not force cleaner before reception')
    check(marks.Cleaner<=600 and O.Guide(s).Complete,'default opening economy can complete inside ten simulated minutes')
    check(s.Balance>=0,'simulated purchases never spend below zero')
    return {Passed=count,Milestones=marks,Assumptions=assumptions,Scope='Simulated guide/payout policy; not live guests, travel, input, networking or retention'}
end
