-- lune run tools/rebuild-place.luau [optional native Studio snapshot .rbxm]
-- Rebuild locally; this never publishes a Roblox place or uploads assets.
local fs=require('@lune/fs')
local roblox=require('@lune/roblox')
local process=require('@lune/process')
local filename='Alien Resort Tycoon.rbxl'
local place=roblox.deserializePlace(fs.readFile(filename))
if process.args[1] then
    local snapshot=roblox.deserializeModel(fs.readFile(process.args[1]))[1]
    for _,service in snapshot:GetChildren() do
        local target=place:GetService(service.Name)
        if service.Name=='StarterPlayer' then
            for _,container in service:GetChildren() do
                local existing=target:FindFirstChild(container.Name)
                if existing and container.ClassName=='Folder' then
                    existing:ClearAllChildren()
                    for _,child in container:GetChildren() do child:Clone().Parent=existing end
                else
                    if existing then existing:Destroy() end
                    container:Clone().Parent=target
                end
            end
        else
            for _,child in target:GetChildren() do
                if child.ClassName~='Terrain' and child.ClassName~='Camera' then child:Destroy() end
            end
            for _,child in service:GetChildren() do child:Clone().Parent=target end
        end
    end
end
local replicated=place:GetService('ReplicatedStorage')
local old=replicated:FindFirstChild('PetTemplates') if old then old:Destroy() end
local templates=roblox.deserializeModel(fs.readFile('art/PetTemplates.rbxm'))[1]
templates.Parent=replicated
local propStorage=place:GetService('ServerStorage')
local oldProps=propStorage:FindFirstChild('WorldProps') if oldProps then oldProps:Destroy() end
roblox.deserializeModel(fs.readFile('art/WorldProps.rbxm'))[1].Parent=propStorage
local server=place:GetService('ServerScriptService'):FindFirstChild('AlienResort')
local starter=place:GetService('StarterPlayer'):FindFirstChild('StarterPlayerScripts')
for _,name in fs.readDir('src') do
    if name:sub(-5)=='.luau' then
        local client=name:find('.client.luau',1,true)~=nil
        local instanceName=client and 'AlienResortHUD' or name:gsub('%.server%.luau$',''):gsub('%.luau$','')
        local instance=(client and starter or server):FindFirstChild(instanceName)
        assert(instance,'Missing active script '..name)
        instance.Source=fs.readFile('src/'..name)
    end
end
fs.writeFile(filename,roblox.serializePlace(place))
print('Saved canonical place with current source and Blender templates.')
