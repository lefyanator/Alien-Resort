-- Studio edit-time installer. Pass art/roblox-pets.json decoded with HttpService.
-- The base is art/PetSurface.obj, uploaded through Studio Importer.
return function(data,baseMesh)
    assert(data.Version==1 and baseMesh:IsA('MeshPart'),'Expected Blender export and imported mesh')
    local folder=Instance.new('Folder') folder.Name='PetTemplates'
    for species,entry in data.Pets do
        local model=Instance.new('Model') model.Name=species
        local root=Instance.new('Part') root.Name='CharacterRoot' root.Size=Vector3.one root.Transparency=1 root.Anchored=true root.CanCollide=false root.CanTouch=false root.CanQuery=false root.Parent=model
        model.PrimaryPart=root
        for _,info in entry.Parts do
            local p=baseMesh:Clone() p.Name=info.Name
            p:ClearAllChildren() p.Size=Vector3.new(unpack(info.Size))
            local position=Vector3.new(unpack(info.Position))
            local cf=CFrame.new(position.X,position.Y,position.Z,unpack(info.Rotation))
            p.CFrame=cf p.PivotOffset=CFrame.new() p.Color=Color3.fromRGB(unpack(info.Color)) p.TextureID=''
            p.Material=Enum.Material.SmoothPlastic p.Transparency=0 p.Reflectance=0
            p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
            p:SetAttribute('RestOffset',cf) p:SetAttribute('RestSize',p.Size)
            if info.Motion then p:SetAttribute('Motion',info.Motion) end
            p.Parent=model
        end
        model:SetAttribute('SpeciesId',species) model:SetAttribute('ArtSource','Blender') model:SetAttribute('ArtVersion',1)
        model.Parent=folder
    end
    local old=game.ReplicatedStorage:FindFirstChild('PetTemplates')
    if old then old:Destroy() end
    folder.Parent=game.ReplicatedStorage
    return folder
end
