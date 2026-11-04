-- Run against an isolated source loader in Studio; no live players or DataStores.
return function(requireModule)
    local Geometry=requireModule('Geometry')
    local Plot=requireModule('PlotService')
    local Service=requireModule('ResortService')
    local Pets=requireModule('PetService')
    local Progress=requireModule('ProgressStore')
    local Config=requireModule('Config')
    local Interaction=requireModule('Interaction')
    local Visuals=requireModule('PetVisuals')
    local Rules=requireModule('CaptureRules')
    local scratch=Instance.new('Folder')
    local characters={}
    local plots={}
    local assertions=0
    local function check(value,message) assertions+=1 assert(value,message) end
    local function player(id)
        local p={UserId=id,DisplayName='Test'..id,Parent=game:GetService('Players'),Attributes={ProfileReady=true,EquippedPet='Pebble'}}
        local stats={Tokens={Value=10000}}
        function stats:FindFirstChild(name) return self[name] end
        p.leaderstats=stats
        function p:GetAttribute(k) return self.Attributes[k] end
        function p:SetAttribute(k,v) self.Attributes[k]=v end
        function p:FindFirstChild(k) return self[k] end
        local character=Instance.new('Model')
        local hrp=Instance.new('Part') hrp.Name='HumanoidRootPart' hrp.Anchored=true hrp.Parent=character
        local humanoid=Instance.new('Humanoid') humanoid.Parent=character
        character.PrimaryPart=hrp p.Character=character
        table.insert(characters,character)
        return p
    end
    local function near(p,part) p.Character:PivotTo(CFrame.new(part.Position+Vector3.new(0,2,0))) end
    local success,result=xpcall(function()
        for i=1,4 do
            local origin=Vector3.new(((i-1)%2)*220,0,math.floor((i-1)/2)*220)
            local root=Geometry.Build(scratch,'Plot'..i,origin)
            local plot=Plot.New(root,origin) table.insert(plots,plot)
            check((root.ClaimTerminal.Position-(origin+Vector3.new(0,7.5,-35))).Magnitude<.01,'terminal origin')
            check((root.Upgrades.Room3.Floor.Position-(origin+Vector3.new(-35,6.3,80))).Magnitude<.01,'north room origin')
            task.wait()
        end
        Service.Plots=plots
        local players={player(101),player(102),player(103),player(104),player(105)}
        for i=1,4 do check(Service.Assign(players[i])==plots[i],'unique assignment') end
        check(Service.Assign(players[5])==nil,'fifth player waits')
        for i=1,4 do
            near(players[i],plots[i].Root.ClaimTerminal)
            check(plots[i].Claim(players[i])==true,'owner can claim')
        end
        local a,b=players[1],players[2]
        check(Rules.CanCapture(1,1,{}, {Carrier=a},a),'capture with home flag')
        check(not Rules.CanCapture(1,2,{}, {Carrier=a},a),'wrong base rejected')
        check(not Rules.CanCapture(1,1,{Carrier=b}, {Carrier=a},a),'own carried flag blocks capture')
        check(not Rules.CanCapture(1,1,{DroppedAt=1}, {Carrier=a},a),'own dropped flag blocks capture')
        check(not Rules.CanCapture(1,1,{}, {Carrier=b},a),'wrong carrier rejected')
        local sizes=Rules.TeamSize({[a]=1,[b]=2}) check(sizes[1]==1 and sizes[2]==1,'team counting')
        local evolved=Progress.Normalize({StarShards=28,Bond={Pebble=34},Evolved={Pebble=true}})
        check(evolved.StarShards==28 and evolved.Bond.Pebble==34 and evolved.Evolved.Pebble,'adventure migration')
        local empty=Progress.Normalize(nil)
        check(empty.StarShards==0 and empty.Bond.Pebble==0 and not empty.Evolved.Pebble,'legacy adventure defaults')
        for _,spec in Config.PetSpecies do
            local character=Visuals.Create(scratch,Vector3.zero,spec.Id)
            check(character.PrimaryPart~=nil and character:GetAttribute('SpeciesId')==spec.Id,'character identity')
            local feature=({Pebble='ExplorerPack',Jelly='Ribbon',Slime='SproutStem',Lava='TailFlame'})[spec.Id]
            check(character:FindFirstChild(feature)~=nil,'species has unique silhouette/accessory')
            check(#character:GetChildren()<=36,'character instance budget')
            character:ScaleTo(.6) Visuals.Animate(character,4.5,true)
            check(character.PrimaryPart.Position.Magnitude<.01,'animation preserves gameplay pivot')
            character:Destroy()
        end
        local function signal()
            local s={Listeners={}}
            function s:Connect(fn) table.insert(self.Listeners,fn) end
            function s:Fire(p) for _,fn in self.Listeners do fn(p) end end
            return s
        end
        local prompt={Enabled=true,Parent=plots[1].Root.ClaimTerminal,HoldDuration=.2,PromptButtonHoldBegan=signal(),PromptButtonHoldEnded=signal(),Triggered=signal()}
        local triggered=0
        near(a,prompt.Parent)
        Interaction.Bind(prompt,function(p) return p==a end,function() triggered+=1 end)
        prompt.Triggered:Fire(a) check(triggered==0,'trigger without hold rejected')
        prompt.PromptButtonHoldBegan:Fire(a) prompt.PromptButtonHoldEnded:Fire(a)
        prompt.Triggered:Fire(a) check(triggered==0,'short hold rejected')
        prompt.PromptButtonHoldBegan:Fire(a) task.wait(.22) prompt.PromptButtonHoldEnded:Fire(a)
        prompt.Triggered:Fire(a) check(triggered==1,'hold ended before trigger accepted')
        prompt.Triggered:Fire(a) check(triggered==1,'replayed trigger rejected')
        near(b,plots[1].Root.BuildPads.Room2)
        local before=b.leaderstats.Tokens.Value
        check(plots[1].Buy(b,'Room2')==false,'foreign building purchase rejected')
        check(plots[1].Shop(b,'Garden')==false,'foreign shop purchase rejected')
        check(Pets.Buy(plots[1],b,'Jelly')==false,'foreign pet purchase rejected')
        check(b.leaderstats.Tokens.Value==before,'foreign balance unchanged')
        a.leaderstats.Tokens.Value=119
        check(Pets.Buy(plots[1],a,'Jelly')==false,'insufficient pet funds')
        check(not a:GetAttribute('Pet_Jelly'),'no free pet grant')
        a.leaderstats.Tokens.Value=10000
        check(Pets.Buy(plots[1],a,'Jelly')==true,'pet purchased')
        check(a.leaderstats.Tokens.Value==9880,'correct pet debit')
        check(Pets.Buy(plots[1],a,'Jelly')==false,'duplicate pet rejected')
        check(Pets.Equip(plots[1],a,'Lava')==false,'unowned pet equip rejected')
        check(Pets.Equip(plots[1],a,'Pebble')==true,'owned pet equip')
        check(Pets.Choose(a,2).Id=='Jelly','purchased species visits')
        check(Pets.Choose(b,2).Id=='Pebble','species isolated by player')
        near(a,plots[1].Root.BuildPads.Room2)
        for _=1,3 do check(plots[1].Buy(a,'Room2')==true,'stage purchase') end
        check(a:GetAttribute('Stage_Room2')==3,'stage complete')
        check(not b:GetAttribute('Stage_Room2'),'stages isolated')
        check(plots[2].Root.Upgrades.Room2:GetAttribute('Stage')==0,'other plot visuals unchanged')
        near(a,plots[1].Root.BuildPads.Observatory)
        check(plots[1].Buy(a,'Observatory')==false,'prerequisite enforced')
        for _,spec in Config.PetSpecies do if spec.Price>0 and not Pets.Owned(a,spec.Id) then check(Pets.Buy(plots[1],a,spec.Id)==true,'all pets purchasable') end end
        check(Pets.Equip(plots[1],a,'Lava')==true,'Lava equipped')
        local snapshot=Progress.Snapshot(a)
        check(snapshot.Pets.Lava and snapshot.Pets.Jelly and snapshot.EquippedPet=='Lava','pet persistence snapshot')
        check(snapshot.Stages.Room2==3,'old building progress retained')
        local legacy=Progress.Normalize({Tokens=83,Stages={Room2=3},Owned={Cleaner=true},Species=true})
        check(legacy.Tokens==83 and legacy.Stages.Room2==3 and legacy.Owned.Cleaner,'legacy migration')
        check(legacy.Pets.Pebble and legacy.EquippedPet=='Pebble','legacy free pet')
        local bad=Progress.Normalize({Tokens=math.huge,Earned=0/0,Stages={Room2=-4,Room3=3},Pets={Lava='yes'},EquippedPet='Lava'})
        check(bad.Tokens==0 and bad.Earned==0 and bad.Stages.Room3==0,'invalid profile values normalized')
        check(not bad.Pets.Lava and bad.EquippedPet=='Pebble','invalid pet ownership rejected')
        local bOwner=plots[2].Owner
        local generation=plots[1].Generation
        plots[1].Reset()
        check(plots[1].Generation==generation+1 and plots[1].Owner==nil,'reset invalidates guest jobs')
        check(plots[2].Owner==bOwner and b:GetAttribute('OwnsResort'),'reset isolated')
        Service.Assignments[a]=nil plots[1].Reserved=nil
        check(Service.Assign(players[5])==plots[1],'vacant plot reusable')
        return {Passed=assertions,Plots=#plots,PetSpecies=#Config.PetSpecies}
    end,debug.traceback)
    for _,plot in plots do plot.Reset() end
    scratch:Destroy() for _,c in characters do c:Destroy() end
    if not success then error(result) end
    return result
end
