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
