local T={}
function T.Apply(gui,config)
    local black=Color3.fromRGB(28,28,38)
    local white=Color3.fromRGB(255,255,255)
    local red=Color3.fromRGB(255,62,76)
    local colors={Color3.fromRGB(58,219,230),Color3.fromRGB(175,112,255),Color3.fromRGB(255,183,66),Color3.fromRGB(98,230,94),Color3.fromRGB(255,122,176),Color3.fromRGB(70,173,255)}
    local function shape(parent,name,x,y,w,h,color,round)
        local f=Instance.new('Frame') f.Name=name f.Position=UDim2.fromScale(x,y) f.Size=UDim2.fromScale(w,h) f.BackgroundColor3=color f.BorderSizePixel=0 f.ZIndex=parent.ZIndex+1 f.Parent=parent
        local c=Instance.new('UICorner') c.CornerRadius=UDim.new(round or .12,0) c.Parent=f
        local s=Instance.new('UIStroke') s.Color=black s.Thickness=2 s.Parent=f return f
    end
    local function icon(parent,id)
        local holder=Instance.new('Frame') holder.Name='Illustration' holder.BackgroundTransparency=1 holder.Size=UDim2.fromScale(1,1) holder.ZIndex=parent.ZIndex+1 holder.Parent=parent
        if id=='Cleaner' or id=='Aliens' then
            shape(holder,'Antenna',.47,.07,.06,.18,black)
            shape(holder,'Tip',.4,.02,.2,.16,colors[3],.5)
            local head=shape(holder,'Robot',.16,.24,.68,.57,colors[1],.2)
            shape(head,'Screen',.12,.2,.76,.52,black)
            shape(head,'EyeL',.25,.3,.13,.16,white,.2) shape(head,'EyeR',.61,.3,.13,.16,white,.2)
        elseif id=='Foam' or id=='Beacon' or id=='Turbo' then
            shape(holder,'Bottle',.24,.33,.52,.55,id=='Foam' and colors[2] or id=='Turbo' and colors[3] or colors[1],.25)
            shape(holder,'Neck',.39,.2,.22,.22,white)
            shape(holder,'Cork',.34,.12,.32,.14,colors[3])
            local gleam=shape(holder,'Shine',.34,.45,.09,.22,white,.5) gleam.Rotation=15
        elseif id=='Garden' then
            shape(holder,'Pot',.3,.6,.4,.27,colors[3])
            shape(holder,'Stem',.47,.3,.06,.32,colors[4])
            for i=1,5 do local a=i*math.pi*2/5 shape(holder,'Petal',.38+math.cos(a)*.16,.25+math.sin(a)*.15,.23,.23,colors[5],.5) end
            shape(holder,'Centre',.41,.28,.18,.18,colors[3],.5)
        else
            shape(holder,'Base',.17,.47,.66,.36,colors[3])
            local roof=shape(holder,'Roof',.2,.19,.6,.35,colors[2]) roof.Rotation=-8
            shape(holder,'Door',.43,.57,.16,.26,white)
        end
    end
    for _,o in gui:GetDescendants() do
        if o:IsA('UIStroke') then o.Color=black o.Thickness=2.5 end
        if o:IsA('UICorner') then o.CornerRadius=UDim.new(0,10) end
        if o:IsA('TextLabel') or o:IsA('TextButton') then o.Font=Enum.Font.FredokaOne end
    end
    for _,name in {'Shop','Roadmap','Book'} do
        local p=gui[name] p.BackgroundColor3=white p.BackgroundTransparency=0
        local header=shape(p,'RedHeader',0,0,1,0,red) header.Size=UDim2.new(1,0,0,43) header.ZIndex=p.ZIndex
        p.Heading.TextColor3=white p.Heading.TextStrokeColor3=black p.Heading.TextStrokeTransparency=.6 p.Heading.Position=UDim2.fromOffset(12,5)
        for _,b in p:GetChildren() do if b:IsA('TextButton') then b.TextColor3=white b.Text='X' end end
    end
    gui.Roadmap.Milestone.TextColor3=black
    gui.Book.Species.TextColor3=black
    local shop=gui.Shop shop.Position=UDim2.fromScale(.5,.48) shop.Size=UDim2.new(.92,0,.68,0)
    local items=shop.Items items.Position=UDim2.fromOffset(10,54) items.Size=UDim2.new(1,-20,1,-64) items.CanvasSize=UDim2.fromOffset(0,534)
    for i,item in config.Shop do
        local card=items[item.Id] local col=(i-1)%2 local row=math.floor((i-1)/2)
        card.Position=UDim2.new(col*.5,3,0,row*178+3) card.Size=UDim2.new(.5,-10,0,168) card.BackgroundColor3=colors[i]
        local name=card:FindFirstChild('Name') name.Position=UDim2.fromOffset(5,4) name.Size=UDim2.new(1,-10,0,23) name.TextSize=15 name.TextColor3=white name.TextStrokeColor3=black name.TextStrokeTransparency=.2 name.TextXAlignment=Enum.TextXAlignment.Center
        card.Benefit.Position=UDim2.new(0,5,0,101) card.Benefit.Size=UDim2.new(1,-10,0,30) card.Benefit.TextSize=10 card.Benefit.TextColor3=black
        card.Buy.Position=UDim2.new(0,6,1,-30) card.Buy.Size=UDim2.new(1,-12,0,25) card.Buy.TextSize=12 card.Buy.TextColor3=black card.Buy.BackgroundColor3=Color3.fromRGB(255,231,64)
        local tile=Instance.new('Frame') tile.BackgroundTransparency=1 tile.Size=UDim2.fromOffset(76,70) tile.Position=UDim2.new(.5,-38,0,29) tile.ZIndex=12 tile.Parent=card icon(tile,item.Id)
    end
    for i,spec in {{'ShopButton','SHOP','Turbo'},{'RoadmapButton','BUILD','House'},{'BookButton','PETS','Aliens'}} do
        local b=gui[spec[1]] b.AnchorPoint=Vector2.zero b.Position=UDim2.new(0,12,.26,(i-1)*82) b.Size=UDim2.fromOffset(64,70) b.BackgroundColor3=colors[i] b.TextTransparency=1
        local tile=Instance.new('Frame') tile.BackgroundTransparency=1 tile.Size=UDim2.new(1,0,1,-17) tile.ZIndex=b.ZIndex+1 tile.Parent=b icon(tile,spec[3])
        local label=Instance.new('TextLabel') label.Text=spec[2] label.Font=Enum.Font.FredokaOne label.TextSize=13 label.TextColor3=white label.TextStrokeColor3=black label.TextStrokeTransparency=0 label.BackgroundTransparency=1 label.Position=UDim2.new(0,0,1,-18) label.Size=UDim2.new(1,0,0,18) label.ZIndex=b.ZIndex+5 label.Parent=b
    end
    local cash=gui.Balance cash.AnchorPoint=Vector2.new(.5,1) cash.Position=UDim2.new(.5,0,1,-8) cash.Size=UDim2.fromOffset(230,64) cash.BackgroundColor3=Color3.fromRGB(106,239,35)
    cash.Brand.Visible=false cash.Tokens.Position=UDim2.fromOffset(8,2) cash.Tokens.Size=UDim2.new(1,-16,0,33) cash.Tokens.TextXAlignment=Enum.TextXAlignment.Center cash.Tokens.TextStrokeColor3=black cash.Tokens.TextStrokeTransparency=0
    cash.Income.Position=UDim2.fromOffset(8,37) cash.Income.Size=UDim2.new(1,-16,0,18) cash.Income.TextColor3=black cash.Income.TextXAlignment=Enum.TextXAlignment.Center
    local guide=gui.Guide guide.AnchorPoint=Vector2.new(.5,0) guide.Position=UDim2.new(.5,0,0,8) guide.Size=UDim2.new(.72,0,0,82) guide.BackgroundColor3=white
    guide.Step.Visible=false guide.Title.Position=UDim2.fromOffset(10,4) guide.Title.Size=UDim2.new(1,-20,0,25) guide.Title.TextSize=16 guide.Title.TextColor3=black
    guide.Detail.Position=UDim2.fromOffset(10,28) guide.Detail.Size=UDim2.new(1,-20,0,35) guide.Detail.TextSize=12 guide.Detail.TextColor3=black
    guide.ProgressTrack.Position=UDim2.new(0,12,1,-10) guide.ProgressTrack.Size=UDim2.new(1,-24,0,5)
    gui.BoostTimers.Position=UDim2.new(1,-175,0,100) gui.BoostTimers.Size=UDim2.fromOffset(165,70)
    gui.Notification.Position=UDim2.new(.5,0,0,98)
end
return T
