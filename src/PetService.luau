local Config=require(script.Parent.Config)
local Visuals=require(script.Parent.PetVisuals)
local Pets={}
function Pets.Find(id)
    for _,entry in Config.PetSpecies do if entry.Id==id then return entry end end
end
function Pets.Owned(player,id)
    return id=='Pebble' or player:GetAttribute('Pet_'..id)==true
end
function Pets.Create(parent,position,id)
    local spec=Pets.Find(id) or Config.PetSpecies[1]
    local model=Visuals.Create(parent,position,spec.Id)
    game:GetService("CollectionService"):AddTag(model,"ResortAlien")
    return model
end
function Pets.Refresh(plot)
    if plot.Companion then plot.Companion:Destroy() plot.Companion=nil end
    local p=plot.Owner if not p then return end
    local id=p:GetAttribute('EquippedPet') or 'Pebble'
    if not Pets.Find(id) or not Pets.Owned(p,id) then id='Pebble' p:SetAttribute('EquippedPet',id) end
    local model=Pets.Create(plot.Root.Guests,plot.Origin+Vector3.new(4,8,-42),id)
    model.Name='PetCompanion' model:SetAttribute('OwnerUserId',p.UserId) model:ScaleTo(.6)
    local spec=Pets.Find(id)
    model:SetAttribute('CharacterName',spec.CharacterName)
    local tag=Instance.new('BillboardGui') tag.Name='CharacterName' tag.Adornee=model.PrimaryPart tag.Size=UDim2.fromOffset(130,24) tag.StudsOffsetWorldSpace=Vector3.new(0,2.4,0) tag.MaxDistance=35 tag.Parent=model
    local text=Instance.new('TextLabel') text.BackgroundTransparency=1 text.Size=UDim2.fromScale(1,1) text.Text=spec.CharacterName..' / '..spec.Name text.Font=Enum.Font.GothamBold text.TextSize=11 text.TextColor3=Color3.new(1,1,1) text.TextStrokeTransparency=.35 text.Parent=tag
    if p:GetAttribute('Evolved_'..id) then
        local halo=Instance.new('Part') halo.Name='EvolutionHalo' halo.Shape=Enum.PartType.Cylinder halo.Size=Vector3.new(.12,1.6,1.6) halo.CFrame=model:GetPivot()*CFrame.new(0,2,0)*CFrame.Angles(0,0,math.pi/2) halo.Color=Color3.fromRGB(255,210,94) halo.Material=Enum.Material.Neon halo.Anchored=true halo.CanCollide=false halo.CanTouch=false halo.CanQuery=false halo.Parent=model
    end
    plot.Companion=model
end
function Pets.Buy(plot,p,id)
    if plot.Owner~=p or not p:GetAttribute('ProfileReady') then return false,'owner' end
    local spec=Pets.Find(id) if not spec then return false,'item' end
    if Pets.Owned(p,id) then return false,'owned' end
    local tokens=p.leaderstats.Tokens
    if tokens.Value<spec.Price then return false,'funds' end
    -- No yields between check, payment, and ownership grant.
    tokens.Value-=spec.Price p:SetAttribute('Pet_'..id,true)
    p:SetAttribute('EquippedPet',id) Pets.Refresh(plot)
    return true
end
function Pets.Equip(plot,p,id)
    if plot.Owner~=p or not p:GetAttribute('ProfileReady') then return false,'owner' end
    if not Pets.Find(id) or not Pets.Owned(p,id) then return false,'locked' end
    if p:GetAttribute('PetJob')==id then p:SetAttribute('PetJob',nil) end
    p:SetAttribute('EquippedPet',id) Pets.Refresh(plot) return true
end
function Pets.Choose(player,sequence)
    local owned={}
    for _,spec in Config.PetSpecies do if Pets.Owned(player,spec.Id) then table.insert(owned,spec) end end
    return owned[(sequence-1)%#owned+1]
end
function Pets.Step(plot)
    local p=plot.Owner local model=plot.Companion
    local hrp=p and p.Character and p.Character:FindFirstChild('HumanoidRootPart')
    if model and model.Parent and hrp then
        -- Server follows owner; companions never collide or grant arbitrary rewards.
        local id=model:GetAttribute('SpeciesId') local now=os.clock()
        local bob=id=='Jelly' and (.4+math.sin(now*2)*.3) or id=='Slime' and math.abs(math.sin(now*3))*.18 or 0
        local target=hrp.CFrame*CFrame.new(3,-1.5+bob,3)
        -- Coarse server position keeps streaming relevant; clients draw the smooth follow.
        if (model:GetPivot().Position-target.Position).Magnitude>8 then model:PivotTo(target) end
    end
end
return Pets
