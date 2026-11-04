-- Pure capture invariants shared by the round controller and regression checks.
local R={}
function R.CompletedRequest(requestAt,requestPet,completedAt,completedPet)
    return requestAt~=nil and completedAt~=nil and completedAt>=requestAt and completedPet==requestPet
end
function R.CanCapture(team,baseTeam,own,enemy,player)
    return team==baseTeam and not own.Carrier and not own.DroppedAt and enemy.Carrier==player
end
function R.TeamSize(teams)
    local counts={0,0}
    for _,team in teams do if team==1 or team==2 then counts[team]+=1 end end
    return counts
end
return R
