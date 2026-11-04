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
        assert(instance and instance.Source==fs.readFile('src/'..name),'Out of sync: '..name)
        count+=1
    end
end
assert(count==15,'Expected all 15 active scripts')
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
