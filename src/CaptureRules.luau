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
-- Server round transitions are pure so the same rules can be exercised without live clients.
function R.New(teams,now,config)
    return {Team=teams,Started=now+3,Score={0,0},Flags={{},{}},Contribution={},Protected={},Tags={},LastCapture=-math.huge,Config=config}
end
function R.Take(round,p,index,now)
    local team=round.Team[p] local flag=round.Flags[index]
    if now<round.Started or not team or team==index or flag.Carrier then return false end
    for _,other in round.Flags do if other.Carrier==p then return false end end
    flag.Carrier=p flag.DroppedAt=nil round.Contribution[p]=(round.Contribution[p] or 0)+1 return true
end
function R.Drop(round,p,now)
    for i,flag in round.Flags do if flag.Carrier==p then flag.Carrier=nil flag.DroppedAt=now return i end end
end
function R.ResetFlag(round,index)
    local flag=round.Flags[index] flag.Carrier=nil flag.DroppedAt=nil
end
function R.Capture(round,p,index,now)
    if now<round.Started or not R.CanCapture(round.Team[p],index,round.Flags[index],round.Flags[3-index],p)
        or now-round.LastCapture<round.Config.CaptureCooldown then return false end
    round.LastCapture=now round.Score[index]+=1 round.Contribution[p]=(round.Contribution[p] or 0)+2 R.ResetFlag(round,3-index) return true
end
function R.Tag(round,attacker,target,now)
    if now<round.Started or not round.Team[attacker] or not round.Team[target] or round.Team[attacker]==round.Team[target]
        or now<(round.Protected[target] or 0) or now<(round.Protected[attacker] or 0) or now<(round.Tags[attacker] or 0) then return false end
    round.Tags[attacker]=now+round.Config.TagCooldown round.Protected[target]=now+round.Config.RespawnProtection
    round.Contribution[attacker]=(round.Contribution[attacker] or 0)+1 return true
end
function R.Result(round,p,now)
    local team=round.Team[p]
    if not team or now-round.Started<round.Config.MatchMinimum or (round.Contribution[p] or 0)==0 then return 0,0 end
    local won=round.Score[team]>round.Score[3-team]
    return won and round.Config.WinTokens or round.Config.ParticipationTokens,won and round.Config.WinShards or round.Config.ParticipationShards
end
return R
