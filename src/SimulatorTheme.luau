local Tween=game:GetService('TweenService')
local T={Motion=true,Colors={Ink=Color3.fromRGB(23,27,61),Muted=Color3.fromRGB(82,89,117),Cream=Color3.fromRGB(245,244,255),White=Color3.fromRGB(255,255,255),Teal=Color3.fromRGB(69,230,193),Lilac=Color3.fromRGB(139,92,246),Gold=Color3.fromRGB(255,209,102),Coral=Color3.fromRGB(255,111,174),Line=Color3.fromRGB(55,49,96),Soft=Color3.fromRGB(229,225,245)}}
function T.Round(o,r) local c=o:FindFirstChildOfClass('UICorner') or Instance.new('UICorner') c.CornerRadius=UDim.new(0,r or 14) c.Parent=o end
function T.Stroke(o,color,width)
    local s=Instance.new('UIStroke') s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Color=color or T.Colors.Line s.Thickness=width or 3 s.Parent=o return s
end
function T.Panel(parent,name,color,z)
    local f=Instance.new('Frame') f.Name=name f.BackgroundColor3=color or T.Colors.White f.BorderSizePixel=0 f.ZIndex=z or 1 f.Parent=parent T.Round(f) return f
end
function T.Text(parent,name,value,size,color,z)
    local t=Instance.new('TextLabel') t.Name=name t.Text=value t.Font=Enum.Font.GothamBold t.TextSize=size or 14 t.TextColor3=color or T.Colors.Ink t.TextXAlignment=Enum.TextXAlignment.Left t.BackgroundTransparency=1 t.TextWrapped=true t.ZIndex=z or parent.ZIndex+1 t.Parent=parent return t
end
function T.Button(parent,name,value,color,z)
    local b=Instance.new('TextButton') b.Name=name b.Text=value b.Font=Enum.Font.FredokaOne b.TextSize=15 b.TextColor3=T.Colors.Ink b.BackgroundColor3=color or T.Colors.Gold b.BorderSizePixel=0 b.AutoButtonColor=false b.Selectable=true b.ZIndex=z or parent.ZIndex+1 b.Parent=parent T.Round(b,15)
    local minimum=Instance.new('UISizeConstraint') minimum.MinSize=Vector2.new(44,44) minimum.Parent=b
    local scale=Instance.new('UIScale') scale.Parent=b
    local function animate(value,duration) if T.Motion then Tween:Create(scale,TweenInfo.new(duration),{Scale=value}):Play() else scale.Scale=1 end end
    local function hover() animate(1.025,.12) end
    local function leave() animate(1,.12) end
    if name=='Scrim' then return b end
    T.Stroke(b,T.Colors.Ink,3)
    local gradient=Instance.new('UIGradient') gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(204,210,239)) gradient.Rotation=90 gradient.Parent=b
    b.MouseEnter:Connect(hover) b.MouseLeave:Connect(leave) b.SelectionGained:Connect(hover) b.SelectionLost:Connect(leave)
    b.MouseButton1Down:Connect(function() animate(.97,.07) end)
    b.MouseButton1Up:Connect(leave)
    return b
end
function T.Window(panel,accent)
    T.Round(panel,22) T.Stroke(panel,T.Colors.Ink,3)
    panel.BackgroundColor3=Color3.fromRGB(27,48,85)
    T.Stroke(panel,Color3.fromRGB(90,199,255),2)
    local band=T.Panel(panel,'Accent',accent or T.Colors.Lilac,panel.ZIndex)
    band.Size=UDim2.new(1,0,0,64) T.Round(band,22)
    local gradient=Instance.new('UIGradient') gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(112,91,200)) gradient.Rotation=90 gradient.Parent=band
end
function T.NavIcon(b,kind)
    b.Text=kind=='Adventure' and 'TRAVEL' or string.upper(kind) b.TextColor3=T.Colors.White b.TextStrokeColor3=T.Colors.Ink b.TextStrokeTransparency=0 b.TextYAlignment=Enum.TextYAlignment.Bottom b.TextSize=12
    b:FindFirstChildOfClass('UICorner').CornerRadius=UDim.new(0,18)
    local well=T.Panel(b,'IconWell',T.Colors.Ink,b.ZIndex) well.Position=UDim2.fromScale(.15,.08) well.Size=UDim2.fromScale(.7,.62) well.BackgroundTransparency=.2 T.Round(well,12)
    local icon=Instance.new('Frame') icon.BackgroundTransparency=1 icon.Size=UDim2.fromOffset(32,32) icon.AnchorPoint=Vector2.new(.5,.5) icon.Position=UDim2.fromScale(.5,.38) icon.ZIndex=b.ZIndex+1 icon.Parent=b
    local function p(x,y,w,h,color,r) local f=T.Panel(icon,'Glyph',color or T.Colors.White,icon.ZIndex) f.Position=UDim2.fromOffset(x,y) f.Size=UDim2.fromOffset(w,h) T.Round(f,r or 4) return f end
    if kind=='Pets' then p(6,16,21,15,nil,9) for i=0,2 do p(i*11,2,9,11,nil,5) end
    elseif kind=='Build' then icon.Rotation=-35 p(12,9,7,23,T.Colors.Gold,2) p(3,2,27,12,nil,3)
    elseif kind=='Shop' then local handle=p(9,1,14,14,nil,7) handle.BackgroundTransparency=1 T.Stroke(handle,T.Colors.White,3) p(3,10,26,22,nil,5) p(13,16,6,10,T.Colors.Coral,2)
    else p(0,0,32,32,nil,16) local n=p(13,3,6,26,T.Colors.Coral,2) n.Rotation=35 end
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
function T.ModelIcon(parent,template)
    local view=Instance.new('ViewportFrame') view.Name='Illustration' view.BackgroundTransparency=1 view.Size=UDim2.fromScale(1,1) view.ZIndex=parent.ZIndex+1 view.Ambient=Color3.fromRGB(190,190,210) view.LightColor=Color3.new(1,1,1) view.LightDirection=Vector3.new(-1,-2,-3) view.Parent=parent
    local model=template:Clone() model:PivotTo(CFrame.new()) model.Parent=view
    local cf,size=model:GetBoundingBox() local camera=Instance.new('Camera') camera.FieldOfView=35
    local radius=math.max(size.X,size.Y,size.Z)*1.65 camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(radius*.55,radius*.35,-radius),cf.Position) camera.Parent=view view.CurrentCamera=camera
    return view
end
function T.SupplyIcon(parent,kind)
    local ink=T.Colors.Ink
    local function shape(name,x,y,w,h,color,r)
        local f=T.Panel(parent,name,color,parent.ZIndex+1) f.Position=UDim2.fromScale(x,y) f.Size=UDim2.fromScale(w,h) T.Round(f,r or 5) return f
    end
    if kind=='Turbo' then
        shape('Battery',.21,.18,.58,.66,T.Colors.Teal,10) shape('Positive',.38,.09,.24,.12,T.Colors.Gold,3)
        local charge=T.Text(parent,'Charge','ϟ',40,ink,parent.ZIndex+2) charge.Position=UDim2.fromScale(.2,.12) charge.Size=UDim2.fromScale(.6,.75) charge.TextXAlignment=Enum.TextXAlignment.Center
        shape('Gloss',.27,.25,.08,.45,T.Colors.White,3)
    elseif kind=='Foam' then
        shape('Bottle',.22,.35,.56,.54,T.Colors.Lilac,12) shape('Neck',.35,.23,.3,.2,T.Colors.Teal,4) shape('Pump',.3,.12,.5,.1,T.Colors.Cream,3)
        shape('Label',.3,.53,.4,.22,T.Colors.Cream,5)
        for i=1,3 do shape('FoamBubble',.12+i*.18,.32-i*.07,.12,.12,T.Colors.White,8) end
    elseif kind=='Beacon' then
        shape('Base',.15,.74,.7,.15,T.Colors.Lilac,7) shape('Mast',.45,.3,.1,.5,T.Colors.Gold,3)
        local lens=shape('Signal',.24,.12,.52,.42,T.Colors.Teal,20) T.Stroke(lens,ink,2)
        shape('Glint',.33,.2,.12,.1,T.Colors.White,3)
    end
end
return T
