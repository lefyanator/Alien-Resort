local Config=require(script.Parent.Config)
local Geometry=require(script.Parent.Geometry)
local Pets={}
function Pets.Find(id)
    for _,entry in Config.PetSpecies do if entry.Id==id then return entry end end
end
function Pets.Owned(player,id)
    return id=='Pebble' or player:GetAttribute('Pet_'..id)==true
end
function Pets.Create(parent,position,id)
    local spec=Pets.Find(id) or Config.PetSpecies[1]
    local model=Geometry.Guest(parent,position)
    model.Name=spec.Id..'Guest' model:SetAttribute('SpeciesId',spec.Id)
    for _,p in model:GetDescendants() do
        if p:IsA('BasePart') then
            p.CanCollide=false p.CanTouch=false p.CanQuery=false
            if p.Name=='Body' or p.Name=='Arm' then
                p.Color=spec.Color
                if spec.Id=='Jelly' then p.Material=Enum.Material.Glass p.Transparency=.25
                elseif spec.Id=='Lava' then p.Material=Enum.Material.Neon end
            end
            if spec.Id=='Slime' and p.Name=='Body' then p.Size=Vector3.new(3.7,2.7,3.2) end
        end
    end
    return model
end
function Pets.Refresh(plot)
    if plot.Companion then plot.Companion:Destroy() plot.Companion=nil end
    local p=plot.Owner if not p then return end
    local id=p:GetAttribute('EquippedPet') or 'Pebble'
    if not Pets.Find(id) or not Pets.Owned(p,id) then id='Pebble' p:SetAttribute('EquippedPet',id) end
    local model=Pets.Create(plot.Root.Guests,plot.Origin+Vector3.new(4,8,-42),id)
    model.Name='PetCompanion' model:SetAttribute('OwnerUserId',p.UserId) model:ScaleTo(.6)
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
        local target=hrp.CFrame*CFrame.new(3,-1.5,3)
        model:PivotTo(model:GetPivot():Lerp(target,.28))
    end
end
return Pets
