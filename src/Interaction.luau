-- Shared server checks. Client prompt visibility is never an authority.
local I={}
function I.Near(player,part,distance)
    local character=player.Character
    local hrp=character and character:FindFirstChild('HumanoidRootPart')
    local humanoid=character and character:FindFirstChildOfClass('Humanoid')
    return hrp~=nil and humanoid~=nil and humanoid.Health>0 and (hrp.Position-part.Position).Magnitude<=(distance or 16)
end
function I.Bind(prompt,authorize,callback)
    local holds=setmetatable({},{__mode='k'})
    prompt.PromptButtonHoldBegan:Connect(function(p)
        if prompt.Enabled and authorize(p) and I.Near(p,prompt.Parent) then
            holds[p]={At=os.clock(),Duration=prompt.HoldDuration,Character=p.Character}
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function(p)
        -- Roblox can send HoldEnded just before Triggered on a completed hold.
        if holds[p] then holds[p].Ended=os.clock() end
    end)
    prompt.Triggered:Connect(function(p)
        local hold=holds[p] holds[p]=nil
        if not prompt.Enabled or not authorize(p) or not I.Near(p,prompt.Parent) then return end
        local now=os.clock()
        if prompt.HoldDuration>0 and (not hold or hold.Character~=p.Character
            or (hold.Ended or now)-hold.At<hold.Duration-.08
            or (hold.Ended and now-hold.Ended>.25)) then return end
        callback(p)
    end)
end
return I
