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
lighting.Brightness=2
for _,effect in lighting:GetChildren() do if effect:IsA('BloomEffect') then effect.Intensity=.15 effect.Size=16 effect.Threshold=1.2 end end
lighting.Ambient=Color3.fromRGB(104,91,132)
lighting.OutdoorAmbient=Color3.fromRGB(137,126,158)
require(script.Parent.ResortService).Start()
