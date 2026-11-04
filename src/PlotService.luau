local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Geometry=require(script.Parent.Geometry)
local Config=require(script.Parent.Config)
local ExtrasModule=require(script.Parent.ResortExtras)
local Interaction=require(script.Parent.Interaction)
local Pets=require(script.Parent.PetService)
local Plot={}
function Plot.New(root,origin)
local S={Owner=nil,Unlocked={},Generation=0,Occupied=0,Started=false,LandingBusy=false,Root=root,Origin=origin,Sequence=0}
local Extras
local function tell(player,message)
    player:SetAttribute("ResortNotice",message)
    player:SetAttribute("NoticeVersion",(player:GetAttribute("NoticeVersion") or 0)+1)
end
local function money(player) return player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Tokens") end
local function balance(player) local tokens=money(player) return tokens and tokens.Value or 0 end
local function objective()
    if not S.Owner then return end
    local p=S.Owner
    local earned=p:GetAttribute("EarnedTotal") or 0
    local nextUpgrade
    for _,u in Config.Upgrades do if not S.Unlocked[u.Id] then nextUpgrade=u break end end
    local stage=nextUpgrade and (p:GetAttribute("Stage_"..nextUpgrade.Id) or 0) or 0
    local price=nextUpgrade and Extras.StagePrice(nextUpgrade,stage) or 0
    local title,description,target,cost
    if earned==0 and S.Occupied==0 then
        title="Your first guest is arriving"
        description="Follow the marker to the landing pad. Your guest will walk to the free room."
        target="LandingPad"
    elseif earned==0 then
        title="Your guest has checked in!"
        description="Occupied rooms earn tokens automatically. Watch the payment countdown above the room."
        target="StarterRoom"
    elseif S.Unlocked.Reception and p:GetAttribute('OwnsCleaner') and ((p:GetAttribute('Bond_Pebble') or 0)+(p:GetAttribute('Bond_Jelly') or 0)+(p:GetAttribute('Bond_Slime') or 0)+(p:GetAttribute('Bond_Lava') or 0))==0 then
        title='Take your pet on its first adventure'
        description='Open ADVENTURE, travel to the Commons, and finish training to earn Star Shards.'
        target='CommonsShuttle' cost=0
    elseif (p:GetAttribute('RoomsCleaned') or 0)>0 and not p:GetAttribute('OwnsCleaner') then
        title='Hire your cleaning crew' description='Open SHOP: the cleaner keeps all rooms earning while you explore.' target='StarterRoom' cost=80
    elseif nextUpgrade and balance(p)<price then
        title="Save for "..nextUpgrade.Name
        description=nextUpgrade.Description..". Guests are earning the tokens for you."
        target="StarterRoom" cost=price
    elseif nextUpgrade then
        title="Build "..nextUpgrade.Name..": "..Config.StageNames[stage+1]
        description="Follow the glowing marker. Hold E or tap the build prompt. "..nextUpgrade.Description
        target=nextUpgrade.Id cost=price
    else
        title="Your first resort is complete!"
        description="Three guest suites, a cafe, lounge and observatory! Enjoy your completed resort."
        target="" cost=0
    end
    for _,room in {root.StarterRoom,root.Upgrades.Room2,root.Upgrades.Room3} do
        if room:GetAttribute("Dirty") and not p:GetAttribute("OwnsCleaner") then
            title="Room needs cleaning!" description="Follow the marker. Hold the clean prompt to prepare for the next guest (+3 tokens)." target="Clean_"..room.Name cost=0 break
        end
    end
    p:SetAttribute("GuideTitle",title) p:SetAttribute("GuideDetail",description)
    p:SetAttribute("GuideTarget",target) p:SetAttribute("NextCost",cost or 0)
    p:SetAttribute("ResortObjective",title)
end
local function refresh()
    for i,u in Config.Upgrades do
        local b=root.BuildPads[u.Id]
        local unlocked=S.Unlocked[u.Id]
        local stage=S.Owner and (S.Owner:GetAttribute("Stage_"..u.Id) or 0) or 0
        local price=Extras.StagePrice(u,math.min(stage,2))
        local available=S.Owner~=nil and not unlocked and (i==1 or S.Unlocked[Config.Upgrades[i-1].Id])
        b.Transparency=available and .15 or 1
        b.BuildPrompt.Enabled=available==true
        b.BuildPrompt.ObjectText=u.Name.." / "..Config.StageNames[math.min(stage+1,3)].." / "..price.." tokens"
        b.Label.Enabled=false
        local affordable=available and balance(S.Owner)>=price
        local status
        if not S.Owner then status="Claim your resort first"
        elseif not available then status="Requires "..Config.Upgrades[math.max(1,i-1)].Name
        elseif affordable then status="READY TO BUILD • "..price.." tokens"
        else status="Save "..price.." tokens" end
        b.Label.Text.Text=u.Name.." - "..Config.StageNames[math.min(stage+1,3)].."\n"..status.."\n"..u.Description
        b.Label.Size=UDim2.fromOffset(240,94)
        b.Color=affordable and Geometry.Colors.teal or Geometry.Colors.rock
    end
    objective()
end
local function nearby(player,part) return Interaction.Near(player,part) end
local function travel(model,position,duration)
    position+=origin
    if not model.Parent then return end
    local value=Instance.new("CFrameValue") value.Value=model:GetPivot()
    local connection=value.Changed:Connect(function(v) if model.Parent then model:PivotTo(v) end end)
    local rotation=model:GetPivot().Rotation
    local delta=position-model:GetPivot().Position
    if model:GetAttribute("SpeciesId") and Vector3.new(delta.X,0,delta.Z).Magnitude>.1 then
        rotation=CFrame.lookAt(Vector3.zero,Vector3.new(delta.X,0,delta.Z)).Rotation
    end
    local tween=TweenService:Create(value,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Value=CFrame.new(position)*rotation})
    tween:Play() tween.Completed:Wait() connection:Disconnect() value:Destroy()
end
local function alive(generation) return S.Owner~=nil and S.Owner.Parent==Players and S.Owner:GetAttribute("ProfileReady") and S.Generation==generation end
local function payoutAmount()
    local amount=Config.BasePayout+(S.Unlocked.Kiosk and Config.KioskBonus or 0)
    for _,u in Config.Upgrades do if S.Unlocked[u.Id] then amount+=u.Bonus or 0 end end
    if S.Owner then for _,u in Config.Shop do if u.Bonus and S.Owner:GetAttribute("Owns"..u.Id) then amount+=u.Bonus end end end
    if S.Owner then amount+=S.Owner:GetAttribute('JobGuestBonus') or 0 end
    return amount
end
local function updateRate()
    if S.Owner then
        S.Owner:SetAttribute("OccupiedRooms",S.Occupied)
        S.Owner:SetAttribute("IncomePerTick",(function() local total=0 for _,r in {root.StarterRoom,root.Upgrades.Room2,root.Upgrades.Room3} do if r:GetAttribute("Occupied") then local spec=Pets.Find(r:GetAttribute("GuestSpecies")) total+=payoutAmount()+(spec and spec.Bonus or 0) end end return total end)())
        objective()
    end
end
local function runRoom(roomId,x)
    local generation=S.Generation
    task.spawn(function()
        local activeShip,activeGuest,landingTicket
        local success,err=xpcall(function()
            while alive(generation) do
                -- Share one pad: ships land upright, unload, then clear it.
                while S.LandingBusy and alive(generation) do task.wait(.25) end
                if not alive(generation) then break end
                landingTicket={} S.LandingBusy=landingTicket
                local room=roomId==1 and root.StarterRoom or root.Upgrades[roomId==2 and "Room2" or "Room3"]
                local z=room.Floor.Position.Z-origin.Z
                local approach=z>50 and 62 or -10
                room:SetAttribute("GuestStatus","Guest arriving")
                local landing=Vector3.new(0,9.4,36)
                local ship=Geometry.UFO(root.Guests,origin+landing+Vector3.new(0,32,0)) activeShip=ship
                ship:SetAttribute("FlightPhase","Landing")
                travel(ship,landing,3)
                if not alive(generation) then ship:Destroy() break end
                ship:SetAttribute("FlightPhase","Landed")
                task.wait(1.2)
                if not alive(generation) then ship:Destroy() break end
                S.Sequence+=1
                local species=Pets.Choose(S.Owner,S.Sequence)
                local guest=Pets.Create(root.Guests,origin+Vector3.new(0,8.6,26),species.Id) activeGuest=guest
                room:SetAttribute("GuestSpecies",species.Name)
                S.Owner:SetAttribute("SpeciesDiscovered",true)
                if not S.Owner:GetAttribute("HasSeenGuest") then S.Owner:SetAttribute("HasSeenGuest",true) tell(S.Owner,"First contact! Pebble alien discovered.") end
                room:SetAttribute("GuestStatus","Walking to room")
                ship:SetAttribute("FlightPhase","Taking off")
                travel(ship,landing+Vector3.new(0,45,0),3)
                ship:Destroy()
                if not alive(generation) then guest:Destroy() break end
                if S.LandingBusy==landingTicket then S.LandingBusy=false end
                if z>50 then
                    -- Walk around the landing pad, not across arriving ships.
                    travel(guest,Vector3.new(17,7.8,26),1.5)
                    travel(guest,Vector3.new(17,7.8,54),2)
                    travel(guest,Vector3.new(0,7.8,54),1.5)
                end
                travel(guest,Vector3.new(0,7.8,approach),3.5)
                travel(guest,Vector3.new(x,7.8,approach),2)
                -- Approach the room through its open front door.
                travel(guest,Vector3.new(x,8,z-11),2)
                travel(guest,Vector3.new(x,8.7,z),1)
                if not alive(generation) then guest:Destroy() break end
                room:SetAttribute("GuestStatus","Occupied")
                room:SetAttribute("Occupied",true)
                S.Occupied+=1 updateRate()
                for _=1,Config.GuestStayPayments do
                    room:SetAttribute("NextPaymentAt",workspace:GetServerTimeNow()+Config.IncomeInterval)
                    task.wait(Config.IncomeInterval)
                    if not alive(generation) then break end
                    local tokens=money(S.Owner)
                    if not tokens then break end
                    local payout=payoutAmount()+species.Bonus
                    tokens.Value+=payout
                    S.Owner:SetAttribute("EarnedTotal",(S.Owner:GetAttribute("EarnedTotal") or 0)+payout)
                    room:SetAttribute("LastPayout",payout)
                    room:SetAttribute("PaymentVersion",(room:GetAttribute("PaymentVersion") or 0)+1)
                    S.Owner:SetAttribute("LastPayout",payout)
                    S.Owner:SetAttribute("PayoutVersion",(S.Owner:GetAttribute("PayoutVersion") or 0)+1)
                    refresh()
                end
                if not alive(generation) then guest:Destroy() break end
                room:SetAttribute("Occupied",false)
                S.Occupied=math.max(0,S.Occupied-1) updateRate()
                room:SetAttribute("GuestStatus","Next guest on the way")
                room:SetAttribute("NextPaymentAt",0)
                S.Owner:SetAttribute("GuestsServed",(S.Owner:GetAttribute("GuestsServed") or 0)+1)
                travel(guest,Vector3.new(x,8,z-11),1)
                travel(guest,Vector3.new(0,8,approach),2)
                if z>50 then
                    travel(guest,Vector3.new(0,8,54),1)
                    travel(guest,Vector3.new(17,8,54),1.5)
                    travel(guest,Vector3.new(17,8,26),2)
                end
                travel(guest,Vector3.new(0,8,26),2)
                guest:Destroy()
                if not alive(generation) then break end
                Extras.MarkDirty(room)
                while room:GetAttribute("Dirty") and alive(generation) do task.wait(.5) end
                if not alive(generation) then break end
                task.wait(Extras.Boost(S.Owner,"Beacon") and 1 or (S.Unlocked.Reception and Config.ReceptionArrivalDelay or Config.ArrivalDelay))
            end
        end,debug.traceback)
        if activeShip then activeShip:Destroy() end
        if activeGuest then activeGuest:Destroy() end
        if not success then
            warn("AlienResort guest loop: "..tostring(err))
            -- Retry only this plot generation; never restart work for a new owner.
            if alive(generation) then
                if S.LandingBusy==landingTicket then S.LandingBusy=false end
                local room=roomId==1 and root.StarterRoom or root.Upgrades[roomId==2 and "Room2" or "Room3"]
                if room:GetAttribute("Occupied") then room:SetAttribute("Occupied",false) S.Occupied=math.max(0,S.Occupied-1) end
                updateRate()
                task.delay(3,function() if alive(generation) then runRoom(roomId,x) end end)
            end
        end
    end)
end
function S.Claim(player)
    if not player:GetAttribute("ProfileReady") then return false,"loading" end
    if root:GetAttribute("ReservedUserId")~=player.UserId or player:GetAttribute("OwnsResort") then return false,"reservation" end
    if S.Owner then tell(player,S.Owner==player and "This resort is already yours." or "This plot belongs to another player.") return false,"occupied" end
    if not nearby(player,root.ClaimTerminal) then return false,"distance" end
    if not money(player) then return false,"not_ready" end
    S.Owner=player S.Generation+=1 S.Unlocked={} S.Occupied=0
    player:SetAttribute("OwnsResort",true)
    player:SetAttribute("PlotName",root.Name)
    root.ClaimTerminal.ProximityPrompt.ObjectText=player.DisplayName.." / RESORT"
    root:SetAttribute("OwnerUserId",player.UserId)
    root.ClaimTerminal.ProximityPrompt.Enabled=false
    tell(player,"Welcome, resort owner! Your first guest is on the way.")
    local built=0
    for _,u in Config.Upgrades do
        local stage=player:GetAttribute("Stage_"..u.Id) or 0
        Extras.SetStage(root.Upgrades[u.Id],stage)
        if stage==3 then S.Unlocked[u.Id]=true built+=1 end
    end
    player:SetAttribute("BuiltCount",built)
    for _,item in Config.Shop do if not item.Duration and player:GetAttribute("Owns"..item.Id) then Extras.Buy(player,item.Id,true) end end
    Pets.Refresh(S)
    refresh() runRoom(1,-29)
    if S.Unlocked.Room2 then runRoom(2,29) end
    if S.Unlocked.Room3 then runRoom(3,-35) end
    return true
end
function S.Buy(player,id)
    if player~=S.Owner or not player:GetAttribute("ProfileReady") then return false,"owner" end
    local entry,index
    for i,u in Config.Upgrades do if u.Id==id then entry=u index=i break end end
    if not entry then return false,"unknown_upgrade" end
    if S.Unlocked[id] then return false,"already_owned" end
    if index>1 and not S.Unlocked[Config.Upgrades[index-1].Id] then return false,"prerequisite" end
    if not nearby(player,root.BuildPads[id]) then return false,"distance" end
    local tokens=money(player)
    if not tokens then return false,"not_ready" end
    local stage=player:GetAttribute("Stage_"..id) or 0
    local price=Extras.StagePrice(entry,stage)
    if tokens.Value<price then tell(player,"You need "..(price-tokens.Value).." more tokens. Guests earn them for you!") return false,"funds" end
    -- No yield between validation, debit, and unlock.
    stage+=1
    player:SetAttribute("Stage_"..id,stage)
    if stage==3 then S.Unlocked[id]=true end
    tokens.Value-=price
    Extras.SetStage(root.Upgrades[id],stage)
    if stage<3 then refresh() tell(player,entry.Name..": "..Config.StageNames[stage].." complete!") return true end
    player:SetAttribute("BuiltCount",(player:GetAttribute("BuiltCount") or 0)+1)
    if id=="Room2" then runRoom(2,29) elseif id=="Room3" then runRoom(3,-35) end
    updateRate() refresh() tell(player,entry.Name.." built! "..entry.Description)
    return true
end
function S.Reset()
    S.Generation+=1
    if S.Owner then S.Owner:SetAttribute("OwnsResort",false) end
    S.Owner=nil S.Unlocked={} S.Occupied=0 S.LandingBusy=false
    root:SetAttribute("OwnerUserId",nil)
    root.Guests:ClearAllChildren()
    S.Companion=nil
    for _,room in {root.StarterRoom,root.Upgrades.Room2,root.Upgrades.Room3} do room:SetAttribute("Occupied",false) end
    Extras.Reset()
    for _,m in root.Upgrades:GetChildren() do Extras.SetStage(m,0) end
    root.ClaimTerminal.ProximityPrompt.Enabled=true
    root.ClaimTerminal.ProximityPrompt.ObjectText="FREE PLOT"
    refresh()
end
Extras=ExtrasModule.New(S,root,function() refresh() updateRate() end)
for _,m in root.Upgrades:GetChildren() do Extras.SetStage(m,0) end
Interaction.Bind(root.ClaimTerminal.ProximityPrompt,function(p) return p:GetAttribute('ProfileReady') and not p:GetAttribute('OwnsResort') end,S.Claim)
for _,u in Config.Upgrades do
    Interaction.Bind(root.BuildPads[u.Id].BuildPrompt,function(p) return p==S.Owner and p:GetAttribute('ProfileReady') end,function(p) S.Buy(p,u.Id) end)
end
S.Refresh=function() refresh() updateRate() end
S.Shop=Extras.Buy
S.MarkDirty=Extras.MarkDirty
refresh()
return S
end
return Plot
