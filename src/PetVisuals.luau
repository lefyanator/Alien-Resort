-- Shared Blender templates with procedural fallback, used by pets and portraits.
local V={}
local C={Ink=Color3.fromRGB(25,35,62),Cream=Color3.fromRGB(255,246,222),Teal=Color3.fromRGB(66,221,193),Coral=Color3.fromRGB(255,142,126),Lilac=Color3.fromRGB(180,143,247),Gold=Color3.fromRGB(255,211,93)}
function V.Create(parent,position,id)
    local templates=game:GetService('ReplicatedStorage'):FindFirstChild('PetTemplates')
    local template=templates and templates:FindFirstChild(id)
    if template and template:IsA('Model') and template.PrimaryPart and template:GetAttribute('ArtVersion')==1 then
        local imported=template:Clone()
        imported.Name=id..'Guest' imported:PivotTo(CFrame.new(position)) imported.Parent=parent
        return imported
    end
    local model=Instance.new('Model') model.Name=id..'Guest'
    local function part(name,size,offset,color,shape,animated)
        local p=Instance.new((name=='FlameEar' or name=='Wing') and 'WedgePart' or 'Part') p.Name=name p.Size=size
        p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
        p.Material=Enum.Material.SmoothPlastic p.Color=color if p:IsA('Part') then p.Shape=shape or Enum.PartType.Ball end
        p.CFrame=CFrame.new(position)*offset p.Parent=model
        p:SetAttribute('RestOffset',offset) p:SetAttribute('RestSize',size)
        if animated then p:SetAttribute('Motion',animated) end
        return p
    end
    local function ball(name,size,x,y,z,color,motion) return part(name,size,CFrame.new(x,y,z),color,nil,motion) end
    local root=part('CharacterRoot',Vector3.one,CFrame.new(),C.Ink,Enum.PartType.Block) root.Transparency=1
    model.PrimaryPart=root
    local function eyes(y,z,spread,large)
        for _,side in {-1,1} do
            ball('Eye',Vector3.new(large,.72,.22),side*spread,y,z,C.Ink,'Blink')
            ball('EyeShine',Vector3.new(.15,.2,.08),side*spread-.09,y+.14,z-.12,C.Cream,'Blink')
            ball('Cheek',Vector3.new(.38,.2,.09),side*(spread+.35),y-.5,z+.08,C.Coral)
        end
    end
    if id=='Jelly' then
        local body=ball('Body',Vector3.new(3.6,3.1,3.1),0,.25,0,C.Lilac,'Jelly') body.Transparency=.2 body.Material=Enum.Material.Glass
        ball('HeartCore',Vector3.new(1.55,1.55,1.55),0,.05,.2,Color3.fromRGB(245,181,242),'Float')
        for i=1,5 do
            local x=(i-3)*.61
            ball('BellFrill',Vector3.new(.95,.65,.9),x,-.95,-.35,C.Lilac,'Float')
        end
        for i=1,4 do
            local x=(i-2.5)*.76
            ball('Ribbon',Vector3.new(.48,1.75,.5),x,-1.7,.15,C.Lilac,i%2==0 and 'SwayL' or 'SwayR')
            ball('RibbonTip',Vector3.new(.62,.62,.62),x,-2.45,.15,Color3.fromRGB(228,184,255),'Float')
        end
        eyes(.42,-1.48,.64,.6)
        ball('WonderMouth',Vector3.new(.3,.38,.13),0,-.23,-1.51,C.Ink)
        part('MoonCrown',Vector3.new(.55,.9,.35),CFrame.new(.65,1.93,0)*CFrame.Angles(0,0,-.45),C.Gold,nil,'SwayL')
        ball('CrownStar',Vector3.new(.48,.48,.48),1,2.32,0,C.Gold,'Float')
    elseif id=='Slime' then
        ball('Body',Vector3.new(4.1,2.7,3.3),0,-.45,0,Color3.fromRGB(153,223,87),'Jelly')
        ball('Belly',Vector3.new(2.1,1.15,.4),0,-1.05,-1.46,Color3.fromRGB(217,246,157))
        for _,side in {-1,1} do
            ball('MudBoot',Vector3.new(1.05,.65,1.3),side*.95,-1.85,-.15,Color3.fromRGB(112,83,84),'Foot')
            part('Leaf',Vector3.new(.72,1.65,.35),CFrame.new(side*.43,1.48,0)*CFrame.Angles(0,0,side*-.65),Color3.fromRGB(64,154,99),nil,side<0 and 'SwayL' or 'SwayR')
        end
        ball('SproutStem',Vector3.new(.2,.65,.2),0,1.05,0,Color3.fromRGB(64,154,99))
        eyes(-.05,-1.58,.82,.66)
        ball('Grin',Vector3.new(.68,.3,.16),0,-.65,-1.7,C.Ink)
        part('Scarf',Vector3.new(2.9,.35,.24),CFrame.new(0,-1.12,-1.58),C.Coral,Enum.PartType.Block)
        part('ScarfTail',Vector3.new(.45,.8,.22),CFrame.new(1.18,-1.52,-1.52)*CFrame.Angles(0,0,.35),C.Coral,Enum.PartType.Block,'SwayL')
        ball('LeafTail',Vector3.new(1.4,.6,1),0,-.65,1.8,Color3.fromRGB(64,154,99),'SwayR')
    elseif id=='Lava' then
        ball('Body',Vector3.new(3.1,3.1,2.8),0,-.05,0,Color3.fromRGB(66,57,83),'Breath')
        ball('Head',Vector3.new(3.3,2.45,2.7),0,.65,-.28,Color3.fromRGB(66,57,83))
        local belly=ball('EmberBelly',Vector3.new(1.85,1.9,.45),0,-.35,-1.3,Color3.fromRGB(255,153,76),'Breath') belly.Material=Enum.Material.SmoothPlastic
        for _,side in {-1,1} do
            part('FlameEar',Vector3.new(.7,1.55,.9),CFrame.new(side*1.18,2,-.1)*CFrame.Angles(0,0,side*-.28),Color3.fromRGB(255,151,79),Enum.PartType.Block,side<0 and 'SwayL' or 'SwayR')
            ball('Paw',Vector3.new(.95,.7,1.2),side*.83,-1.65,-.25,Color3.fromRGB(93,73,102),'Foot')
            part('Wing',Vector3.new(.45,1.7,1.5),CFrame.new(side*1.65,.2,.5)*CFrame.Angles(0,0,side*-.48),C.Coral,Enum.PartType.Block,side<0 and 'SwayL' or 'SwayR')
        end
        eyes(.8,-1.6,.7,.6)
        ball('Grin',Vector3.new(.65,.24,.15),0,.14,-1.68,C.Ink)
        part('TinyTooth',Vector3.new(.2,.22,.12),CFrame.new(.13,.11,-1.78),C.Cream,Enum.PartType.Block)
        for i=1,3 do ball('Tail',Vector3.new(.7,.7,.9),.25+i*.3,-.6+i*.18,1.1+i*.45,Color3.fromRGB(93,73,102),'SwayR') end
        local flame=ball('TailFlame',Vector3.new(.8,1.1,.75),1.25,.25,2.65,Color3.fromRGB(255,182,75),'Float') flame.Material=Enum.Material.Neon
        for _,side in {-1,1} do ball('Freckle',Vector3.new(.22,.18,.1),side*1.15,.45,-1.39,C.Gold) end
    else
        ball('Body',Vector3.new(2.85,3.25,2.6),0,0,0,C.Teal,'Breath')
        ball('Belly',Vector3.new(1.8,1.85,.34),0,-.4,-1.22,C.Cream)
        for _,side in {-1,1} do
            ball('Mitten',Vector3.new(.65,1.2,.8),side*1.45,-.5,-.05,C.Teal,'Foot')
            ball('Boot',Vector3.new(.9,.65,1.25),side*.72,-1.7,-.05,C.Lilac,'Foot')
            part('Antenna',Vector3.new(.14,.85,.14),CFrame.new(side*.73,1.85,0)*CFrame.Angles(0,0,side*-.2),C.Ink,Enum.PartType.Block,side<0 and 'SwayL' or 'SwayR')
            ball('AntennaTip',Vector3.new(.44,.44,.44),side*.85,2.28,0,C.Gold,'Float')
        end
        eyes(.5,-1.28,.6,.48)
        ball('Smile',Vector3.new(.55,.19,.16),0,-.15,-1.35,C.Ink)
        part('ExplorerPack',Vector3.new(1.6,1.8,.75),CFrame.new(0,-.2,1.3),C.Coral,Enum.PartType.Block)
        ball('StarBadge',Vector3.new(.42,.42,.15),.63,-.72,-1.31,C.Gold)
    end
    model:SetAttribute('SpeciesId',id) model.Parent=parent
    return model
end
function V.Animate(model,t,moving)
    if not model.Parent or not model.PrimaryPart then return end
    local pivot=model:GetPivot() local scale=model:GetScale()
    local blink=t%4.6>4.42
    for _,p in model:GetChildren() do
        if p:IsA('BasePart') and p:GetAttribute('Motion') then
            local rest=p:GetAttribute('RestOffset') local size=p:GetAttribute('RestSize')
            local offset=CFrame.new(rest.Position*scale)*rest.Rotation
            local motion=p:GetAttribute('Motion') local phase=t*2.7
            if motion=='SwayL' or motion=='SwayR' then offset*=CFrame.Angles(0,0,math.sin(phase)*(motion=='SwayL' and .12 or -.12))
            elseif motion=='Float' then offset+=Vector3.new(0,math.sin(phase)*.1*scale,0)
            elseif motion=='Foot' and moving then offset*=CFrame.Angles(math.sin(t*8+rest.Position.X)*.23,0,0) end
            p.CFrame=pivot*offset
            if motion=='Blink' then p.Size=size*Vector3.new(scale,scale*(blink and .12 or 1),scale)
            elseif motion=='Jelly' then p.Size=size*Vector3.new(scale*(1+math.sin(phase)*.025),scale*(1-math.sin(phase)*.035),scale)
            elseif motion=='Breath' then p.Size=size*Vector3.new(scale,scale*(1+math.sin(phase)*.015),scale) end
        end
    end
end
return V
