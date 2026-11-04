local Tween=game:GetService('TweenService')
local T={Colors={Ink=Color3.fromRGB(31,40,65),Muted=Color3.fromRGB(112,124,147),Cream=Color3.fromRGB(252,247,235),White=Color3.fromRGB(255,255,255),Teal=Color3.fromRGB(59,208,181),Lilac=Color3.fromRGB(177,147,239),Gold=Color3.fromRGB(255,210,94),Coral=Color3.fromRGB(248,143,125),Line=Color3.fromRGB(220,226,237),Soft=Color3.fromRGB(240,243,250)}}
function T.Round(o,r) local c=Instance.new('UICorner') c.CornerRadius=UDim.new(0,r or 14) c.Parent=o end
function T.Stroke(o,color,width)
    local s=Instance.new('UIStroke') s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Color=color or T.Colors.Line s.Thickness=width or 1 s.Parent=o return s
end
function T.Panel(parent,name,color,z)
    local f=Instance.new('Frame') f.Name=name f.BackgroundColor3=color or T.Colors.White f.BorderSizePixel=0 f.ZIndex=z or 1 f.Parent=parent T.Round(f) return f
end
function T.Text(parent,name,value,size,color,z)
    local t=Instance.new('TextLabel') t.Name=name t.Text=value t.Font=Enum.Font.GothamBold t.TextSize=size or 14 t.TextColor3=color or T.Colors.Ink t.TextXAlignment=Enum.TextXAlignment.Left t.BackgroundTransparency=1 t.TextWrapped=true t.ZIndex=z or parent.ZIndex+1 t.Parent=parent return t
end
function T.Button(parent,name,value,color,z)
    local b=Instance.new('TextButton') b.Name=name b.Text=value b.Font=Enum.Font.GothamBold b.TextSize=13 b.TextColor3=T.Colors.Ink b.BackgroundColor3=color or T.Colors.Gold b.BorderSizePixel=0 b.AutoButtonColor=false b.Selectable=true b.ZIndex=z or parent.ZIndex+1 b.Parent=parent T.Round(b,11)
    local minimum=Instance.new('UISizeConstraint') minimum.MinSize=Vector2.new(44,44) minimum.Parent=b
    local scale=Instance.new('UIScale') scale.Parent=b
    local function hover() Tween:Create(scale,TweenInfo.new(.12),{Scale=1.025}):Play() end
    local function leave() Tween:Create(scale,TweenInfo.new(.12),{Scale=1}):Play() end
    if name=='Scrim' then return b end
    b.MouseEnter:Connect(hover) b.MouseLeave:Connect(leave) b.SelectionGained:Connect(hover) b.SelectionLost:Connect(leave)
    b.MouseButton1Down:Connect(function() Tween:Create(scale,TweenInfo.new(.07),{Scale=.97}):Play() end)
    b.MouseButton1Up:Connect(leave)
    return b
end
function T.Coin(parent,size,z)
    local coin=T.Panel(parent,'Token',T.Colors.Gold,z) coin.Size=UDim2.fromOffset(size,size) T.Round(coin,size)
    T.Stroke(coin,Color3.fromRGB(207,150,43),2)
    local inset=T.Panel(coin,'Inset',Color3.fromRGB(255,227,139),z+1) inset.Position=UDim2.fromScale(.17,.17) inset.Size=UDim2.fromScale(.66,.66) T.Round(inset,size)
    local diamond=Instance.new('Frame') diamond.Name='MintMark' diamond.BorderSizePixel=0 diamond.BackgroundColor3=Color3.fromRGB(192,130,38) diamond.ZIndex=z+2 diamond.Parent=inset diamond.AnchorPoint=Vector2.new(.5,.5) diamond.Position=UDim2.fromScale(.5,.5) diamond.Size=UDim2.fromScale(.4,.4) diamond.Rotation=45
    local shine=T.Panel(coin,'Shine',Color3.fromRGB(255,244,199),z+3) shine.Position=UDim2.fromScale(.22,.15) shine.Size=UDim2.fromScale(.18,.09) shine.Rotation=-30

    return coin
end
function T.Format(n)
    local text=tostring(math.floor(n))
    local result=text:reverse():gsub('(%d%d%d)','%1,'):reverse():gsub('^,','')
    return result
end
return T
