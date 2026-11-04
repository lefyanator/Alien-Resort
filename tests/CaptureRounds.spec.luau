-- Exercises the actual server transitions with an injected clock; no network-client claim.
return function(R,C)
    local count=0
    local function check(value,message) count+=1 assert(value,message) end
    local a,b,c,d={},{},{},{}
    local round=R.New({[a]=1,[b]=2,[c]=1,[d]=2},100,C)
    check(not R.Take(round,a,2,101),'cannot steal during countdown')
    check(not R.Take(round,a,1,104),'cannot steal own core')
    check(R.Take(round,a,2,104),'enemy core can be stolen')
    check(not R.Take(round,c,2,104),'core has one carrier')
    check(not R.Capture(round,a,2,105),'cannot score at enemy base')
    check(R.Take(round,b,1,105),'enemy takes own core')
    check(not R.Capture(round,a,1,105),'own core away blocks capture')
    check(R.Drop(round,b,106)==1,'death/leave drops correct core')
    check(not R.Capture(round,a,1,106),'dropped own core blocks capture')
    R.ResetFlag(round,1)
    check(R.Capture(round,a,1,107) and round.Score[1]==1,'home return enables score')
    check(not round.Flags[2].Carrier and not round.Flags[2].DroppedAt,'scored enemy core reset')
    check(not R.Capture(round,a,1,107),'cannot replay capture')
    check(R.Take(round,a,2,108),'next attack can take core')
    check(not R.Capture(round,a,1,108),'capture cooldown enforced')
    check(R.Capture(round,a,1,120),'capture cooldown expires')
    round.Protected[b]=130
    check(not R.Tag(round,a,b,121),'protected target cannot be tagged')
    round.Protected[b]=0 round.Protected[a]=130
    check(not R.Tag(round,a,b,121),'protected attacker cannot tag')
    round.Protected[a]=0
    check(not R.Tag(round,a,c,131),'cannot tag teammate')
    check(R.Tag(round,a,b,131),'enemy tag succeeds')
    check(not R.Tag(round,a,d,132),'tag cooldown prevents instant multi-tag')
    check(not R.Tag(round,a,b,134),'respawn protection enforced')
    check(R.Tag(round,a,b,136),'protection expires')
    check(R.Result(round,a,120)==0,'short rounds never pay')
    local tokens,shards=R.Result(round,a,160)
    check(tokens==C.WinTokens and shards==C.WinShards,'contributing winner paid')
    tokens,shards=R.Result(round,b,160)
    check(tokens==C.ParticipationTokens and shards==C.ParticipationShards,'contributing opponent paid')
    check(R.Result(round,c,160)==0,'idle teammate not paid')
    check(R.Result(round,{},160)==0,'outsider not paid')
    round.Score[2]=round.Score[1]
    check(R.Result(round,a,160)==C.ParticipationTokens,'ties use participation rewards')
    R.Take(round,d,1,161) check(R.Drop(round,d,162)==1,'disconnect drops core') round.Team[d]=nil
    check(not R.Take(round,d,1,163),'departed participant cannot retake')
    check(R.TeamSize(round.Team)[2]==1,'remaining team counts correct')
    return count
end
