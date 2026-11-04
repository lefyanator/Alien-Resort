-- Server-owned Commons, activities, pet progression and Starcore Capture.
local Players=game:GetService('Players')
local Replicated=game:GetService('ReplicatedStorage')
local I=require(script.Parent.Interaction)
local Pets=require(script.Parent.PetService)
local Config=require(script.Parent.Config)
local Rules=require(script.Parent.CaptureRules)
local A={}
local C=Config.Adventure
function A.Start(resorts)
    local state={} local queue={} local match=nil local serial=0
    local root=Instance.new('Model') root.Name='CosmicCommons' root.Parent=workspace
    local origin=Vector3.new(180,0,190)
    local colors={Lilac=Color3.fromRGB(177,147,239),Teal=Color3.fromRGB(59,208,181),Gold=Color3.fromRGB(255,210,94),Ink=Color3.fromRGB(31,40,65),Cream=Color3.fromRGB(252,247,235),Blue=Color3.fromRGB(90,163,249),Red=Color3.fromRGB(248,143,125)}
    local function part(name,pos,size,color)
        local p=Instance.new('Part') p.Name=name p.Anchored=true p.Size=size p.Position=origin+pos p.Color=color p.Material=Enum.Material.SmoothPlastic p.Parent=root return p
    end
    local function sign(p,text)
        local bb=Instance.new('BillboardGui') bb.Size=UDim2.fromOffset(240,65) bb.StudsOffsetWorldSpace=Vector3.new(0,5,0) bb.MaxDistance=95 bb.Parent=p
        local t=Instance.new('TextLabel') t.Size=UDim2.fromScale(1,1) t.BackgroundColor3=colors.Ink t.BackgroundTransparency=.1 t.TextColor3=colors.Cream t.TextWrapped=true t.Font=Enum.Font.GothamBold t.TextSize=14 t.Text=text t.Parent=bb
        return t
    end
    local function say(p,text)
        p:SetAttribute('AdventureNotice',text) p:SetAttribute('ResortNotice',text) p:SetAttribute('NoticeVersion',(p:GetAttribute('NoticeVersion') or 0)+1)
    end
    local function plot(p) local s=resorts.Assignments[p] return s and s.Owner==p and p:GetAttribute('ProfileReady') and s end
    local function hrp(p) return p.Character and p.Character:FindFirstChild('HumanoidRootPart') end
    local function teleport(p,pos) if p.Character then p.Character:PivotTo(CFrame.new(pos)) end end
    local function data(p)
        if not state[p] then state[p]={Cooldown={},LastJob=0,Training=0} end return state[p]
    end
    local function bond(p,id,amount) p:SetAttribute('Bond_'..id,math.min(1000,(p:GetAttribute('Bond_'..id) or 0)+amount)) end
    local function reward(p,tokens,shards,id)
        if not plot(p) then return end
        p.leaderstats.Tokens.Value+=tokens p:SetAttribute('StarShards',(p:GetAttribute('StarShards') or 0)+shards)
        bond(p,id or p:GetAttribute('EquippedPet'),C.BondReward) plot(p).Refresh()
        say(p,'+'..tokens..' tokens / +'..shards..' Star Shards! Train, explore, then evolve your pet.')
    end
    local function ready(p,key,seconds)
        local d=data(p) if os.clock()<(d.Cooldown[key] or 0) then return false end d.Cooldown[key]=os.clock()+seconds return true
    end
    local function prompt(p,text,fn)
        local q=Instance.new('ProximityPrompt') q.ActionText=text q.ObjectText=p.Name q.HoldDuration=.5 q.MaxActivationDistance=12 q.RequiresLineOfSight=false q.Parent=p
        I.Bind(q,function(player) return plot(player)~=nil end,fn) return q
    end
    part('CommonsIsland',Vector3.new(0,2,0),Vector3.new(235,6,188),colors.Ink)
    part('CommonsDeck',Vector3.new(0,5.4,0),Vector3.new(232,1,185),colors.Cream)
    for _,x in {-116,116} do part('EdgeRail',Vector3.new(x,7,0),Vector3.new(1,2,184),colors.Teal) end
    for _,z in {-92,92} do part('EdgeRail',Vector3.new(0,7,z),Vector3.new(232,2,1),colors.Teal) end
    for _,x in {-106,106} do for _,z in {-80,-10,68} do
        local planter=part('NebulaPlanter',Vector3.new(x,6.7,z),Vector3.new(6,1.4,6),colors.Ink)
        local crystal=part('NebulaCrystal',Vector3.new(x,10,z),Vector3.new(2,5,2),colors.Teal) crystal.Material=Enum.Material.Neon crystal.Orientation=Vector3.new(12,0,25) crystal.CanCollide=false
    end end
    for _,x in {-12,12} do part('WelcomeArch',Vector3.new(x,12,75),Vector3.new(1,12,1),colors.Teal) end
    part('WelcomeArchTop',Vector3.new(0,18,75),Vector3.new(25,1,1),colors.Teal)
    for _,x in {-30,30} do
        part('SpectatorBench',Vector3.new(x,7,3),Vector3.new(12,1.2,3),colors.Cream)
        part('SpectatorBack',Vector3.new(x,8.5,4.4),Vector3.new(12,2,.5),colors.Teal)
    end
    local plaza=part('WELCOME / COSMIC COMMONS',Vector3.new(0,6,75),Vector3.new(32,1,18),colors.Teal)
    sign(plaza,'COSMIC COMMONS\nBuild a home. Adventure together. Evolve your crew.')
    local home=part('RETURN HOME',Vector3.new(-23,6,78),Vector3.new(8,1,8),colors.Gold)
    local function homePlayer(p) local s=plot(p) if s then teleport(p,s.Origin+Vector3.new(0,10,-44)) end end
    prompt(home,'Return to your resort',function(p) if match and match.Team[p] then say(p,'Leave the match before returning home.') else homePlayer(p) end end)
    for _,s in resorts.Plots do
        local dock=Instance.new('Part') dock.Name='CommonsShuttle' dock.Size=Vector3.new(7,1,7) dock.Position=s.Origin+Vector3.new(9,6,-43) dock.Anchored=true dock.Color=colors.Gold dock.Parent=s.Root
        sign(dock,'SHUTTLE TO COSMIC COMMONS\nActivities / Star Shards / pet evolution')
        prompt(dock,'Travel to the Commons',function(p) if plot(p)==s and not (match and match.Team[p]) then teleport(p,origin+Vector3.new(0,10,75)) end end)
    end
    -- Ordered traversal checkpoints. Rewards require elapsed time and all checkpoints.
    local checkpoints={}
    for i=1,5 do
        local cp=part('Training '..i,Vector3.new(-93+(i-1)*12,6+(i%2)*2,48),Vector3.new(8,1,8),i==5 and colors.Gold or colors.Teal)
        checkpoints[i]=cp sign(cp,i==1 and 'PET TRAINING\nStart here; follow checkpoints 1 → 5' or ('CHECKPOINT '..i))
        prompt(cp,i==1 and 'Start training' or 'Complete checkpoint',function(p)
            if match and match.Team[p] then return end
            local d=data(p)
            if i==1 then d.Training=1 d.TrainingAt=os.clock() d.TrainingPet=p:GetAttribute('EquippedPet') say(p,'Training started! Reach checkpoint 2 with your companion.')
            elseif d.Training==i-1 and d.TrainingPet==p:GetAttribute('EquippedPet') then
                d.Training=i
                if i==5 then
                    d.Training=0 d.CompletedTrainingAt=os.clock()
                    if os.clock()-d.TrainingAt>=C.TrainingMinimum and ready(p,'TrainingReward',C.ActivityCooldown) then reward(p,C.TrainingTokens,C.TrainingShards,d.TrainingPet)
                    else say(p,'Course complete! Rewards recharge; explore another activity.') end
                else say(p,'Checkpoint '..i..'! Next: '..(i+1)) end
            else say(p,'Start at checkpoint 1 and complete the course in order.') end
        end)
    end
    local treasure={}
    for i,pos in {Vector3.new(-95,6,-5),Vector3.new(93,6,5),Vector3.new(-30,6,78)} do
        local chest=part('Buried stardust '..i,pos,Vector3.new(4,2,4),colors.Gold) chest.Transparency=.6 treasure[i]=chest
        prompt(chest,'Ask Pip to excavate',function(p)
            if match and match.Team[p] then return end
            if p:GetAttribute('EquippedPet')~='Pebble' then say(p,'Equip Pip to detect and excavate this treasure.') return end
            if ready(p,'Treasure'..i,C.TreasureCooldown) then reward(p,p:GetAttribute('Evolved_Pebble') and C.TreasureTokens*2 or C.TreasureTokens,1,'Pebble') else say(p,'This deposit is regenerating. Try training or rescue.') end
        end)
    end
    -- Cooperative rescue. Three contributions; each person can contribute once per cycle.
    local ship=part('STRANDED SHUTTLE',Vector3.new(65,10,55),Vector3.new(22,8,16),colors.Blue)
    ship.Transparency=1 ship.CanCollide=false require(script.Parent.Geometry).UFO(root,origin+Vector3.new(65,9.5,55))
    local rescue={Contributors={},Count=0,Next=0} local rescueLabel=sign(ship,'GUEST RESCUE\nRepair 3 systems together. Solo players can repair all three.')
    for i,offset in {Vector3.new(-13,0,-9),Vector3.new(0,0,-12),Vector3.new(13,0,-9)} do
        local console=part('Rescue system '..i,Vector3.new(65,6,55)+offset,Vector3.new(5,2,5),colors.Coral or colors.Red)
        prompt(console,'Repair system',function(p)
            if match and match.Team[p] then return end
            if os.clock()<rescue.Next then say(p,'The rescued shuttle is departing. A new rescue arrives shortly.') return end
            if rescue[i] then say(p,'This system is repaired. Find another console.') return end
            rescue[i]=true rescue.Count+=1 rescue.Contributors[p]=true console.Color=colors.Teal
            rescueLabel.Text='GUEST RESCUE / '..rescue.Count..'/3 systems restored'
            if rescue.Count==3 then
                for player in rescue.Contributors do if plot(player) and ready(player,'RescueReward',C.ActivityCooldown) then reward(player,C.RescueTokens,C.RescueShards) end end
                rescue.Next=os.clock()+C.ActivityCooldown
                task.delay(C.ActivityCooldown,function()
                    if not root.Parent then return end
                    rescue={Contributors={},Count=0,Next=0} rescueLabel.Text='GUEST RESCUE\nRepair 3 systems. Bring friends or complete it solo.'
                    for _,v in root:GetChildren() do if v.Name:find('Rescue system') then v.Color=colors.Red end end
                end)
            end
        end)
    end
    local targets={}
    for _,spec in Config.PetSpecies do
        local x=({Pebble=-75,Jelly=-25,Slime=25,Lava=75})[spec.Id]
        local target=part(spec.Id..' ability station',Vector3.new(x,6,20),Vector3.new(9,1,9),spec.Color)
        targets[spec.Id]=target
        sign(target,({Pebble='PIP / TREASURE SCAN',Jelly='JUNO / BOUNCE PAD',Slime='SPROUT / RESTORE GARDEN',Lava='EMBER / LIGHT BEACON'})[spec.Id]..'\nEquip this pet and use its ability here')
    end
    local beacon=part('Ancient Beacon',Vector3.new(75,10,20),Vector3.new(3,8,3),colors.Ink)
    local garden=part('Wilted Garden',Vector3.new(25,6.8,20),Vector3.new(6,.6,6),colors.Ink)
    for _,s in resorts.Plots do
        local counter=Instance.new('Part') counter.Name='CafeServing' counter.Anchored=true counter.Size=Vector3.new(3,.5,3) counter.Position=s.Origin+Vector3.new(29,10.5,-33) counter.Color=colors.Gold counter.Parent=s.Root
        prompt(counter,'Serve a guest snack',function(p)
            if plot(p)~=s or (p:GetAttribute('Stage_Kiosk') or 0)<3 then say(p,'Complete your Cosmic Cafe first.') return end
            if not ready(p,'CafeServe',C.ActivityCooldown) then say(p,'Guests are still enjoying their snacks.') return end
            reward(p,8,1)
        end)
        local telescope=s.Root.Upgrades.Observatory:FindFirstChild('TelescopeStand')
        if telescope then prompt(telescope,'Read expedition clue',function(p)
            if plot(p)==s and (p:GetAttribute('Stage_Observatory') or 0)==3 then say(p,'Expedition clue: three stardust deposits surround the Commons. Bring Pip!') end
        end) end
    end
    local evo=part('EVOLUTION LAB',Vector3.new(24,6,78),Vector3.new(8,1,8),colors.Lilac or colors.Blue)
    sign(evo,'EVOLUTION LAB\n'..C.EvolutionShards..' Star Shards + '..C.EvolutionBond..' bonding / use Evolve')
    -- Arena occupies the southern half, with cover and home flags at opposite ends.
    part('StarcoreArena',Vector3.new(0,6,-43),Vector3.new(178,.5,72),colors.Ink)
    for _,x in {-42,0,42} do for _,z in {-60,-26} do part('ArenaCover',Vector3.new(x,9,z),Vector3.new(8,6,6),colors.Cream) end end
    local bases={part('BLUE HOME',Vector3.new(-77,7,-43),Vector3.new(12,1,16),colors.Blue),part('CORAL HOME',Vector3.new(77,7,-43),Vector3.new(12,1,16),colors.Red)}
    local flags={}
    for i,base in bases do
        local flag=part(i==1 and 'Blue Starcore' or 'Coral Starcore',base.Position-origin+Vector3.new(0,4,0),Vector3.new(2.4,2.4,2.4),i==1 and colors.Blue or colors.Red) flag.Shape=Enum.PartType.Ball flag.Material=Enum.Material.Neon flag.CanCollide=false flags[i]=flag
    end
    local queuePad=part('STARCORE CAPTURE / QUEUE',Vector3.new(0,6,1),Vector3.new(14,1,8),colors.Gold)
    local arenaLabel=sign(queuePad,'STARCORE CAPTURE\nJoin for 1v1 / 2v2. Train or rescue while waiting.')
    local function resetFlag(team)
        local f=match and match.Flags[team] if f then if f.Carrier then f.Carrier:SetAttribute('CarryingStarcore',false) end f.Carrier=nil f.DroppedAt=nil end
        flags[team].Position=bases[team].Position+Vector3.new(0,4,0)
    end
    local function drop(p)
        if not match then return end
        for i,f in match.Flags do if f.Carrier==p then
            f.Carrier=nil f.DroppedAt=os.clock() p:SetAttribute('CarryingStarcore',false)
            local h=hrp(p) flags[i].Position=h and h.Position+Vector3.new(0,1,0) or bases[i].Position+Vector3.new(0,4,0)
        end end
    end
    local function finish(reason)
        if not match then return end
        local old=match
        resetFlag(1) resetFlag(2) match=nil
        for p,team in old.Team do
            p:SetAttribute('ArenaTeam',nil) p:SetAttribute('CarryingStarcore',false) local h=hrp(p) if h and h:FindFirstChild('TagRunner') then h.TagRunner.Enabled=false end
            if p.Parent==Players then
                if (old.Contribution[p] or 0)>0 and os.clock()-old.Started>=C.MatchMinimum then
                    local won=old.Score[team]>old.Score[3-team]
                    reward(p,won and C.WinTokens or C.ParticipationTokens,won and C.WinShards or C.ParticipationShards)
                end
                homePlayer(p) say(p,reason..' / Blue '..old.Score[1]..' : '..old.Score[2]..' Coral')
            end
        end
        arenaLabel.Text='STARCORE CAPTURE\nJoin for 1v1 / 2v2. Solo? Try pet training.'
    end
    for i,flag in flags do prompt(flag,'Take / return Starcore',function(p)
        local team=match and match.Team[p] if not team then say(p,'Join a match first.') return end
        local f=match.Flags[i]
        if team==i then if f.DroppedAt then resetFlag(i) match.Contribution[p]=(match.Contribution[p] or 0)+1 end
        elseif not f.Carrier then
            for _,other in match.Flags do if other.Carrier==p then return end end
            f.Carrier=p f.DroppedAt=nil p:SetAttribute('CarryingStarcore',true) match.Contribution[p]=(match.Contribution[p] or 0)+1
            say(p,'You have the enemy Starcore! Return to your home base.')
        end
    end) end
    for i,base in bases do prompt(base,'Capture enemy Starcore',function(p)
        if not match or match.Team[p]~=i then return end
        local own,enemy=match.Flags[i],match.Flags[3-i]
        if own.Carrier or own.DroppedAt then say(p,'Your own Starcore must be home first.') return end
        if not Rules.CanCapture(match.Team[p],i,own,enemy,p) then return end
        if os.clock()-(match.LastCapture or 0)<C.CaptureCooldown then return end
        match.LastCapture=os.clock() match.Score[i]+=1 match.Contribution[p]=(match.Contribution[p] or 0)+2 resetFlag(3-i)
        for player in match.Team do say(player,'CAPTURE! Blue '..match.Score[1]..' : '..match.Score[2]..' Coral') end
    end) end
    prompt(queuePad,'Join / leave capture queue',function(p)
        if match and match.Team[p] then drop(p) match.Team[p]=nil p:SetAttribute('ArenaTeam',nil) homePlayer(p) return end
        queue[p]=not queue[p] or nil say(p,queue[p] and 'Queued! Training and rescue remain available while you wait.' or 'Left the queue.')
    end)
    local function setupCharacter(p,char)
        local h=char:WaitForChild('HumanoidRootPart',10) if not h then return end
        local q=Instance.new('ProximityPrompt') q.Name='TagRunner' q.Enabled=p:GetAttribute('ArenaTeam')~=nil q.ActionText='Tag enemy runner' q.HoldDuration=0 q.MaxActivationDistance=7 q.RequiresLineOfSight=true q.Parent=h
        I.Bind(q,function(attacker)
            if not (match and match.Team[p] and match.Team[attacker] and match.Team[p]~=match.Team[attacker] and I.Near(attacker,h,8)) then return false end
            local from=hrp(attacker) if not from then return false end
            local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={attacker.Character}
            local hit=workspace:Raycast(from.Position,h.Position-from.Position,params)
            return not hit or hit.Instance:IsDescendantOf(char)
        end,function(attacker)
            if not ready(attacker,'Tag',C.TagCooldown) or os.clock()<(data(p).ProtectedUntil or 0) then return end
            drop(p) data(p).ProtectedUntil=os.clock()+C.RespawnProtection
            teleport(p,bases[match.Team[p]].Position+Vector3.new(0,4,0))
            match.Contribution[attacker]=(match.Contribution[attacker] or 0)+1 say(p,'Tagged! Brief spawn protection is active.')
        end)
        local hum=char:FindFirstChildOfClass('Humanoid') if hum then hum.Died:Connect(function() drop(p) end) end
    end
    local function playerAdded(p)
        p.CharacterAdded:Connect(function(char) setupCharacter(p,char) end)
        if p.Character then task.spawn(setupCharacter,p,p.Character) end
    end
    Players.PlayerAdded:Connect(playerAdded) for _,p in Players:GetPlayers() do playerAdded(p) end
    Players.PlayerRemoving:Connect(function(p) drop(p) queue[p]=nil if state[p] and state[p].Worker then state[p].Worker:Destroy() end state[p]=nil if match then match.Team[p]=nil end end)
    local remote=Instance.new('RemoteEvent') remote.Name='ResortAdventure' remote.Parent=Replicated
    remote.OnServerEvent:Connect(function(p,action,id)
        if type(action)~='string' or #action>32 or not plot(p) or not ready(p,'Remote',.35) then return end
        local s=plot(p) local pet=p:GetAttribute('EquippedPet') local inMatch=match and match.Team[p]
        if action=='Home' then if inMatch then drop(p) match.Team[p]=nil p:SetAttribute('ArenaTeam',nil) end homePlayer(p)
        elseif action=='Commons' then if not inMatch then teleport(p,origin+Vector3.new(0,10,75)) end
        elseif action=='Job' then
            if inMatch or type(id)~='string' or not Pets.Find(id) or not Pets.Owned(p,id) then return end
            if id==pet then say(p,'Equip another companion first; the same pet cannot work and follow.') return end
            local requirement=({Pebble='Reception',Jelly='Lounge',Slime='Garden',Lava='Kiosk'})[id]
            local unlocked=requirement=='Garden' and p:GetAttribute('OwnsGarden') or (p:GetAttribute('Stage_'..requirement) or 0)==3
            if not unlocked then say(p,'Build '..requirement..' to unlock this pet job.') return end
            if p:GetAttribute('PetJob')==id then p:SetAttribute('PetJob',nil) else p:SetAttribute('PetJob',id) end say(p,'Pet job assignment updated.')
        elseif action=='Evolve' then
            if inMatch or not I.Near(p,evo) then say(p,'Visit the Evolution Lab in the Commons.') return end
            if p:GetAttribute('Evolved_'..pet) then say(p,'This pet is already evolved.') return end
            if (p:GetAttribute('StarShards') or 0)<C.EvolutionShards or (p:GetAttribute('Bond_'..pet) or 0)<C.EvolutionBond then say(p,'Need '..C.EvolutionShards..' Star Shards and '..C.EvolutionBond..' bonding with this pet.') return end
            p:SetAttribute('StarShards',p:GetAttribute('StarShards')-C.EvolutionShards) p:SetAttribute('Evolved_'..pet,true) Pets.Refresh(s) say(p,'EVOLVED! Your companion has a star halo and an upgraded adventure reward.')
        elseif action=='Ability' then
            if inMatch then say(p,'Pet powers are disabled during this fair-play capture prototype.') return end
            if not I.Near(p,targets[pet],20) then say(p,'Use your pet ability at its matching Commons station.') return end
            if not ready(p,'Ability',C.AbilityCooldown) then say(p,'Your pet ability is recharging.') return end
            local evolved=p:GetAttribute('Evolved_'..pet)
            if pet=='Pebble' then
                for _,chest in treasure do local spark=Instance.new('Highlight') spark.Adornee=chest spark.FillColor=colors.Gold spark.Parent=chest game:GetService('Debris'):AddItem(spark,5) end
                say(p,'Pip located three treasure deposits. Follow the golden highlights!')
            elseif pet=='Jelly' then
                local pad=part('JunoBouncePad',targets.Jelly.Position-origin+Vector3.new(0,.8,0),Vector3.new(7,.3,7),colors.Blue) pad.Material=Enum.Material.Neon game:GetService('Debris'):AddItem(pad,8)
                pad.Touched:Connect(function(hit)
                    local visitor=Players:GetPlayerFromCharacter(hit.Parent)
                    if visitor and plot(visitor) and not (match and match.Team[visitor]) and ready(visitor,'Bounce',1) then local h=hrp(visitor) if h then h.AssemblyLinearVelocity=Vector3.new(0,evolved and 65 or 55,0) end end
                end)
                local h=hrp(p) if h then h.AssemblyLinearVelocity=Vector3.new(0,evolved and 65 or 55,0) end
                say(p,'Juno launches you upward!')
            elseif pet=='Slime' then garden.Color=colors.Teal say(p,'Sprout restored the garden!')
            else beacon.Color=colors.Gold beacon.Material=Enum.Material.Neon say(p,'Ember activated the beacon!') end
            bond(p,pet,C.BondReward)
            if pet~='Pebble' and ready(p,'AbilityReward',C.ActivityCooldown) then reward(p,evolved and C.AbilityTokens*2 or C.AbilityTokens,1,pet) end
        elseif action=='Request' then
            if inMatch or not I.Near(p,s.Root.ClaimTerminal) then return end
            if (p:GetAttribute('Stage_Reception') or 0)<3 then say(p,'Complete reception to accept guest requests.') return end
            if not ready(p,'GuestRequest',C.ActivityCooldown) then say(p,'No new request yet. Try the Commons!') return end
            local d=data(p) d.RequestPet=pet d.RequestAt=os.clock() say(p,'Guest request: finish the training course with '..Pets.Find(pet).CharacterName..', then return here.')
        elseif action=='Deliver' then
            local d=data(p)
            if inMatch or not I.Near(p,s.Root.ClaimTerminal) or not d.RequestAt or not d.RequestDone then say(p,'Complete your training request, then return to your terminal.') return end
            d.RequestAt=nil d.RequestDone=nil reward(p,C.RequestTokens,1,d.RequestPet)
        end
    end)
    -- Expose no reward or capture remote: interaction state remains server-owned.
    task.spawn(function()
        while root.Parent do
            task.wait(.2)
            if not match then
                local waiting={} for p,inQueue in queue do if inQueue and plot(p) then table.insert(waiting,p) end end
                table.sort(waiting,function(a,b) return a.UserId<b.UserId end)
                if #waiting>=2 then
                    serial+=1 match={Id=serial,Started=os.clock(),Team={},Score={0,0},Flags={{},{}},Contribution={},LastCapture=0}
                    local count=#waiting>=4 and 4 or 2
                    for i=1,count do local p=waiting[i] local team=(i-1)%2+1 match.Team[p]=team queue[p]=nil p:SetAttribute('ArenaTeam',team) local h=hrp(p) if h and h:FindFirstChild('TagRunner') then h.TagRunner.Enabled=true end data(p).ProtectedUntil=os.clock()+C.RespawnProtection teleport(p,bases[team].Position+Vector3.new(0,4,0)) end
                end
            else
                local counts={0,0}
                for p,team in match.Team do
                    counts[team]+=1 local h=hrp(p)
                    if h and (h.Position.Y<0 or math.abs(h.Position.X-origin.X)>94 or h.Position.Z<origin.Z-83 or h.Position.Z>origin.Z-3) then drop(p) teleport(p,bases[team].Position+Vector3.new(0,4,0)) end
                    if h then p:SetAttribute('ArenaSeconds',math.max(0,math.ceil(C.MatchSeconds-(os.clock()-match.Started)))) end
                end
                for i,f in match.Flags do
                    if f.Carrier then local h=hrp(f.Carrier) if h then flags[i].Position=h.Position+Vector3.new(0,4,0) else drop(f.Carrier) end
                    elseif f.DroppedAt and os.clock()-f.DroppedAt>C.FlagReturnSeconds then resetFlag(i) end
                end
                arenaLabel.Text='STARCORE CAPTURE / '..math.max(0,math.ceil(C.MatchSeconds-(os.clock()-match.Started)))..'s\nBLUE '..match.Score[1]..' : '..match.Score[2]..' CORAL'
                if counts[1]==0 or counts[2]==0 then finish('Match ended: team disconnected') elseif os.clock()-match.Started>=C.MatchSeconds then finish('Round complete') end
            end
            for p,d in state do
                local s=plot(p)
                if s then
                    local assigned=p:GetAttribute('PetJob')
                    if assigned==p:GetAttribute('EquippedPet') then assigned=nil p:SetAttribute('PetJob',nil) end
                    if d.WorkerId~=assigned then
                        if d.Worker then d.Worker:Destroy() end d.Worker=nil d.WorkerId=assigned d.LastJob=os.clock()
                        if assigned then
                            local offset=({Pebble=Vector3.new(-28,9,-24),Jelly=Vector3.new(0,9,75),Slime=Vector3.new(43,9,-17),Lava=Vector3.new(29,9,-30)})[assigned]
                            d.Worker=Pets.Create(s.Root.SessionExtras,s.Origin+offset,assigned) d.Worker:ScaleTo(.55)
                        end
                    end
                    p:SetAttribute('JobGuestBonus',assigned=='Jelly' and 2 or assigned=='Lava' and 3 or 0)
                    if d.RequestAt and d.CompletedTrainingAt and d.CompletedTrainingAt>=d.RequestAt and d.TrainingPet==d.RequestPet then d.RequestDone=true end
                    local job=p:GetAttribute('PetJob')
                    if job and job~=p:GetAttribute('EquippedPet') and os.clock()-d.LastJob>=C.JobInterval then
                        d.LastJob=os.clock()
                        if job=='Slime' then for _,room in {s.Root.StarterRoom,s.Root.Upgrades.Room2,s.Root.Upgrades.Room3} do if room:GetAttribute('Dirty') then room:SetAttribute('Dirty',false) room:SetAttribute('GuestStatus','Ready for guests') room.Floor.CleanPrompt.Enabled=false local mess=room:FindFirstChild('GuestMess') if mess then mess:Destroy() end break end end end
                        p.leaderstats.Tokens.Value+=C.JobTokens bond(p,job,1) say(p,Pets.Find(job).CharacterName..' finished a resort job! +'..C.JobTokens..' tokens')
                    end
                end
            end
        end
    end)
end
return A
