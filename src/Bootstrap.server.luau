for _,name in {'SimulatorTheme','PetVisuals'} do
    local old=game.ReplicatedStorage:FindFirstChild(name) if old then old:Destroy() end
    local clone=script.Parent[name]:Clone() clone.Parent=game.ReplicatedStorage
end
local display=game:GetService("ReplicatedStorage"):FindFirstChild("ResortDisplayConfig")
if not display then
    display=script.Parent.Config:Clone()
    display.Name="ResortDisplayConfig"
    display.Parent=game:GetService("ReplicatedStorage")
end
local lighting=game:GetService("Lighting")
lighting.ClockTime=14
lighting.Brightness=3
lighting.Ambient=Color3.fromRGB(165,170,200)
lighting.OutdoorAmbient=Color3.fromRGB(170,175,210)
require(script.Parent.ResortService).Start()
