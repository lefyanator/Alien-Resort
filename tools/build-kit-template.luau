-- Reconstruct the uploaded Blender kit from its verified import transforms.
local fs=require('@lune/fs') local R=require('@lune/roblox') local serde=require('@lune/serde')
local data=serde.decode('json',fs.readFile('art/roblox-resort-kit.json'))
local folder=R.Instance.new('Folder') folder.Name='ResortKit'
for name,parts in data do
    local m=R.Instance.new('Model') m.Name=name m.WorldPivot=R.CFrame.new() m:SetAttribute('ArtSource','Blender') m.Parent=folder
    for _,info in parts do
        local p=R.Instance.new('MeshPart') p.Name=info.Name p.MeshContent=R.Content.fromUri(info.MeshId)
        p.InitialSize=R.Vector3.new(unpack(info.MeshSize))
        p.Size=R.Vector3.new(unpack(info.Size)) p.CFrame=R.CFrame.new(unpack(info.CFrame)) p.Color=R.Color3.new(unpack(info.Color))
        p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Material=R.Enum.Material.SmoothPlastic
        p:SetAttribute('BuildStage',3) p.Parent=m
    end
end
fs.writeFile('art/ResortKit.rbxm',R.serializeModel({folder}))
print('Saved '..#folder:GetChildren()..' authored mesh templates.')
