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
assert(count==12,'Expected all 12 active scripts')
print('PASS: all '..count..' active place scripts match src/.')
