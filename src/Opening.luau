local Config=require(script.Parent.Config)
local O={}

function O.IsVIP(observatory,sequence)
    return observatory==true and type(sequence)=='number' and sequence>0 and sequence%Config.VIP.Every==0
end

function O.Payout(base,speciesBonus,vip)
    return base+(speciesBonus or 0)+(vip==true and Config.VIP.Bonus or 0)
end

function O.Guide(s)
    local room2,reception,cleaner=s.Room2==true,s.Reception==true,s.OwnsCleaner==true
    local g={Step=1,Complete=false,Title='Claim your FREE resort',Detail='Hold the terminal prompt to welcome your first guest.',Target='ClaimTerminal',Action='',Cost=0}
    if not s.Owned then return g end
    g.Complete=room2 and reception and cleaner
    local function build(fallback)
        local n=s.Next
        g.Action='Build' g.Target=n and n.Id or fallback g.Cost=n and n.Price or 0
        g.Title=(n and (s.Balance or 0)<n.Price and 'Save for ' or 'Build ')..(n and n.Name or 'your next building')
        g.Detail=n and (Config.StageNames[(n.Stage or 0)+1]..' / '..n.Price..' tokens. '..n.Description) or 'Open BUILD to see your next construction stage.'
    end
    if (s.Earned or 0)==0 and not room2 then
        g.Step=2 g.Title=(s.Occupied or 0)>0 and 'Your guest has checked in!' or 'Your first guest is arriving'
        g.Detail=(s.Occupied or 0)>0 and 'Watch the room countdown. Your first payment unlocks your next step.' or 'Follow the landing marker. Your guest will walk to the free room.'
        g.Target=(s.Occupied or 0)>0 and 'StarterRoom' or 'LandingPad'
    elseif (s.Cleaned or 0)==0 and not room2 and not cleaner then
        g.Step=3 g.Title='Your first guest stay' g.Target='StarterRoom'
        g.Detail='Guests pay '..Config.GuestStayPayments..' times, then check out. Clean the room to welcome the next guest.'
        if s.Next and (s.Balance or 0)>=s.Next.Price then build('Room2') g.Detail..=' You can build while guests stay.' end
    elseif not room2 then
        g.Step=4 build('Room2')
    elseif not reception then
        g.Step=5 build('Reception')
    elseif not cleaner then
        g.Step=6 g.Title='Hire your cleaning crew' g.Target='StarterRoom' g.Action='Shop'
        for _,item in Config.Shop do if item.Id=='Cleaner' then g.Cost=item.Price break end end
        g.Detail='Buy the cleaner in SHOP. It prepares every dirty room while you build or explore.'
    else
        g.Step=6
        if (s.Bond or 0)==0 then
            g.Title='Take your pet on its first adventure' g.Detail='Your resort can look after itself. Travel to the Commons and start pet training.' g.Target='CommonsShuttle' g.Action='Adventure'
        elseif s.Next then
            build(s.Next.Id)
        elseif s.Observatory then
            g.Title='Your Orbital Palace is ready' g.Detail='Board the floating hotel from the Commons. Observatory guests also include VIP visitors.' g.Target='CommonsShuttle' g.Action='Adventure'
        else
            g.Title='Your resort is ready for adventure' g.Detail='Explore the Commons, bond with your pets and work towards the Observatory.' g.Target='CommonsShuttle' g.Action='Adventure'
        end
    end
    if s.DirtyRoom and not cleaner then
        g.Title='Room needs cleaning!' g.Detail='Hold the clean prompt to prepare the room for the next guest (+'..Config.CleanReward..' tokens).'
        g.Target='Clean_'..s.DirtyRoom g.Action='' g.Cost=0
    end
    return g
end

return O
