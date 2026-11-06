-- Run from repository root: lune run tools/verify-sync.luau
local fs=require('@lune/fs')
local roblox=require('@lune/roblox')
local place=roblox.deserializePlace(fs.readFile('Alien Resort Tycoon.rbxl'))
local server=place:GetService('ServerScriptService'):FindFirstChild('AlienResort')
local starter=place:GetService('StarterPlayer'):FindFirstChild('StarterPlayerScripts')
local count=0
for _,name in fs.readDir('src') do
    if name:sub(-5)=='.luau' then
        local client=name:find('.client.luau',1,true)~=nil
        local instanceName=client and 'AlienResortHUD' or name:gsub('%.server%.luau$',''):gsub('%.luau$','')
        local instance=(client and starter or server):FindFirstChild(instanceName)
        assert(instance and instance.Source:gsub('\r\n','\n')==fs.readFile('src/'..name):gsub('\r\n','\n'),'Out of sync: '..name)
        count+=1
    end
end
assert(count==16,'Expected all 16 active scripts')
print('PASS: all '..count..' active place scripts match src/.')
local templates=place:GetService('ReplicatedStorage'):FindFirstChild('PetTemplates')
local exported=roblox.deserializeModel(fs.readFile('art/PetTemplates.rbxm'))[1]
for _,id in {'Pebble','Jelly','Slime','Lava'} do
    local model=templates and templates:FindFirstChild(id)
    assert(model and model.PrimaryPart and model.PrimaryPart.Name=='CharacterRoot','Missing Blender template '..id)
    assert(model:GetAttribute('ArtSource')=='Blender' and #model:GetChildren()==#exported[id]:GetChildren(),'Template mismatch '..id)
    for _,p in model:GetChildren() do
        if p:IsA('MeshPart') then
            assert(tostring(p.MeshContent):find('rbxassetid://134081985420522',1,true),'Unverified mesh dependency')
            assert(not p.CanCollide and not p.CanTouch and not p.CanQuery,'Collidable pet visual')
            assert(p:GetAttribute('RestOffset') and p:GetAttribute('RestSize'),'Missing animation rest data')
        end
    end
end
print('PASS: four Blender templates, shared mesh and animation metadata are embedded.')
local props=place:GetService('ServerStorage'):FindFirstChild('WorldProps')
assert(props and #props:GetChildren()==6,'Missing curated Creator Store props')
for _,model in props:GetChildren() do
    assert(model:GetAttribute('SourceAssetId'),'Missing prop attribution')
    for _,p in model:GetDescendants() do
        assert(not p:IsA('LuaSourceContainer'),'Executable code in prop bundle')
        if p:IsA('BasePart') then assert(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,'Invalid prop physics') end
    end
end
print('PASS: six attributed static Creator Store templates embedded.')
local kit=place:GetService('ServerStorage'):FindFirstChild('ResortKit')
local manifest=require('@lune/serde').decode('json',fs.readFile('art/roblox-resort-kit.json'))
assert(kit and #kit:GetChildren()==12,'Missing resort mesh kit')
for name,parts in manifest do
    local model=assert(kit:FindFirstChild(name),'Missing '..name)
    assert(#model:GetChildren()==#parts,'Wrong mesh count '..name)
    for _,info in parts do
        local p=assert(model:FindFirstChild(info.Name))
        local meshSize=roblox.Vector3.new(unpack(info.MeshSize))
        assert(tostring(p.MeshContent):find(info.MeshId,1,true) and (p.InitialSize-meshSize).Magnitude<math.max(.0001,meshSize.Magnitude*.000001),'Mesh import metadata mismatch '..p.Name)
        local expected=roblox.CFrame.new(unpack(info.CFrame))
        -- Binary place compression quantizes spatial values by a few millionths of a stud.
        assert((p.Size-roblox.Vector3.new(unpack(info.Size))).Magnitude<.0001 and (p.CFrame.Position-expected.Position).Magnitude<.0001 and (p.CFrame.RightVector-expected.RightVector).Magnitude<.0001 and (p.CFrame.UpVector-expected.UpVector).Magnitude<.0001,'Mesh transforms mismatch '..p.Name)
    end
end
assert(not place:GetService('ServerScriptService'):FindFirstChild('ArtAcceptance') and not place:GetService('ServerScriptService'):FindFirstChild('ArtReviewSetup'),'Test fixtures saved in canonical place')
print('PASS: 12 Blender resort templates match uploaded meshes, original sizes and transforms; no review fixtures.')
