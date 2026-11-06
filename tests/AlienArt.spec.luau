return function(requireModule)
    local G=requireModule('Geometry') local count=0
    local function check(v,message) count+=1 assert(v,message) end
    local scratch=Instance.new('Folder')
    local ok,result=pcall(function()
        local root=G.Build(scratch,'ArtTest',Vector3.new(360,0,360))
        check(root.Island.Ground.Color.R<.4,'Ground has deep contrast')
        check(root.Island.MainWalk.Material==Enum.Material.Metal,'Metal path material')
        check(root.ResortDetails.SporeLookout.CanCollide,'Raised lookout is playable')
        check(root.StarterRoom:FindFirstChild('PodHull')~=nil,'Starter pod silhouette')
        check(root.Upgrades.Room2:FindFirstChild('FloatingRoof')~=nil,'Split floating roof')
        for _,building in {root.StarterRoom,root.Upgrades.Room2,root.Upgrades.Room3,root.Upgrades.Kiosk,root.Upgrades.Reception,root.Upgrades.Lounge,root.Upgrades.Observatory} do
            local sign=building.BuildingName
            for _,v in building:GetDescendants() do
                if v:IsA('BasePart') and (v.Name:find('Roof') or v.Name=='MaglevBand' or v.Name:find('CafeAwning')) then
                    local cf,s=v.CFrame,v.Size
                    local half=(math.abs(cf.RightVector.Z)*s.X+math.abs(cf.UpVector.Z)*s.Y+math.abs(cf.LookVector.Z)*s.Z)/2
                    check(sign.Position.Z+sign.Size.Z/2<v.Position.Z-half,'Sign clears '..building.Name..' / '..v.Name)
                end
            end
        end
        local kit=assert(game.ServerStorage:FindFirstChild('ResortKit'),'Missing authored Blender templates')
        for _,asset in kit:GetChildren() do
            local _,bounds=asset:GetBoundingBox()
            check(math.max(bounds.X,bounds.Y,bounds.Z)<30,'Kit scale is studs, not centimetres')
            check(asset:GetAttribute('ArtSource')=='Blender','Mesh source attribution')
            for _,v in asset:GetDescendants() do
                check(not v:IsA('LuaSourceContainer'),'No scripts in imported art')
                if v:IsA('BasePart') then check(v:IsA('MeshPart') and v.MeshId~='' and v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'Static visual mesh physics') end
            end
        end
        local extras=requireModule('ResortExtras')
        for stage=0,3 do
            extras.SetStage(root.Upgrades.Kiosk,stage)
            for _,v in root.Upgrades.Kiosk.CafeCounter:GetChildren() do check((v.Transparency<1)==(stage==3),'Cafe art follows furnished stage') end
            check(root.Upgrades.Kiosk.ServiceCounter.Transparency==1,'Invisible service anchor never appears as floating counter')
            local proxy=root.Upgrades.Kiosk.FurnitureCollision
            check(proxy.Transparency==1 and proxy.CanCollide==(stage==3),'Furniture proxy blocks only a finished building')
        end
        for _,v in root:GetDescendants() do
            if v:IsA('Model') and game.CollectionService:HasTag(v,'CosmicScenery') then
                local cf=v:GetBoundingBox() check((cf.Position-v:GetPivot().Position).Magnitude<20,'Scenery pivot translates with plot')
            end
        end
        local palace=G.SkyHotel(scratch,Vector3.new(180,0,190))
        local _,size=palace:GetBoundingBox()
        check(size.X>=100,'Hero landmark has required scale')
        check(palace.SkyDeck.CanCollide and palace.SkyDeck.Position.Y>60,'Sky deck is solid and elevated')
        check(palace.ReturnLift.Position.Y>65 and palace.BoardingLift.Position.Y<10,'Both lift destinations exist')
        check(palace.ModelStreamingMode==Enum.ModelStreamingMode.Persistent,'Landmark remains visible at distance')
        check(#palace:GetDescendants()<80,'Landmark instance budget')
        for _,v in palace:GetDescendants() do
            if v.Name=='SkyRail' then
                local radial=(v.Position-palace.SkyDeck.Position)*Vector3.new(1,0,1)
                check(math.abs(v.CFrame.RightVector:Dot(radial.Unit))<.01,'Deck rails follow circumference')
            end
        end
        return count
    end)
    scratch:Destroy() assert(ok,result) return result
end
