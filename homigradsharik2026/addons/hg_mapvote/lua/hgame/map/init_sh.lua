adminPanel.commandRegistry("rtv_start",{},nil,nil,"rcon")
adminPanel.commandRegistry("rtv_end",{},nil,nil,"rcon")
adminPanel.commandRegistry("nortv",{"bool"},nil,nil,"rcon")

function RTVGetLeaders()
    local leader

    for vote,list in pairs(RTVVote) do
        if not RTVVoteNumber[vote] or RTVVoteNumber[vote] == 0 then continue end
        if not leader then leader = vote continue end

        if RTVVoteNumber[vote] > RTVVoteNumber[leader] then leader = vote end
    end

    local leaders = {leader}

    for vote,list in pairs(RTVVote) do
        if not RTVVoteNumber[vote] or RTVVoteNumber[vote] == 0 then continue end
        
        if vote == leaders[1] then continue end

        if RTVVoteNumber[vote] == RTVVoteNumber[leader] then leaders[#leaders + 1] = vote end
    end

    return leaders
end