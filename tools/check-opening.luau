-- Run from repository root: lune run tools/check-opening.luau
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local roblox=require('@lune/roblox')
local serde=require('@lune/serde')
local task=require('@lune/task')
local services={Players={},HttpService={},RunService={IsStudio=function() return true end}}
local game={GameId=0}
function game:GetService(name) return assert(services[name],'Unsupported headless service '..name) end
local cache={} local loadModule
loadModule=function(name)
    if cache[name] then return cache[name] end
    assert(name=='Config' or name=='Opening' or name=='CaptureRules' or name=='ProgressStore','Unsupported headless module '..name)
    local env={Color3=roblox.Color3,script={Parent={Config='Config'}},require=loadModule,game=game,task=task}
    local chunk=luau.load(fs.readFile('src/'..name..'.luau'),{debugName=name,environment=env})
    cache[name]=chunk() return cache[name]
end
local O=loadModule('Opening') local C=loadModule('Config')
local function spec(name) return luau.load(fs.readFile('tests/'..name..'.spec.luau'),{debugName=name..'.spec'})() end
local opening=spec('OpeningLoop')(O,C)
local capture=spec('CaptureRounds')(loadModule('CaptureRules'),C.Adventure)
local progress=spec('ProgressStore')(loadModule)
print(serde.encode('json',{Opening=opening,Capture={Passed=capture,Scope='Production pure transitions; network clients NOT TESTED'},Progress=progress,Passed=opening.Passed+capture+progress.Passed},true))
local count=0
for _,file in fs.readDir('src') do
    if file:sub(-5)=='.luau' then luau.compile(fs.readFile('src/'..file)) count+=1 end
end
print('PASS: '..count..' source files compile headlessly (not executed in the Roblox engine).')
