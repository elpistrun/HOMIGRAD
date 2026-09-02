local Level = oop.Reg("level_jailbreak","level_base",true)
if not Level then return INCLUDE_BREAK end

adminPanel.successRegistry("jailbreak_moderate",nil,"jailbreak")

adminPanel.commandRegistry("jailbreak_add",{{type = "steamid64",required = true},{type = "string",required = true}},nil,nil,"jailbreak"):SetDontShowGUI(true)
adminPanel.commandRegistry("jailbreak_ranks",{},nil,nil,"jailbreak"):SetDontShowGUI(true)

adminPanel.commandRegistry("jailbreak_ban",{{type = "steamid64",required = true},{type = "string",required = true}},"async",nil,"jailbreak")
adminPanel.commandRegistry("jailbreak_unban",{{type = "steamid64",required = true},{type = "string",required = true}},"async",nil,"jailbreak")

Level:SetEndType("team")

Level.ShouldReplaceCSSWeapons = false

Level.blue = {"jailbreak_blue",Color(55,55,255),
    weapons = {
        "weapon_event_speaker",
        "med_kit","med_kit","med_kit",
        "weapon_physgun","gmod_tool"
    },
    main_weapon = {
        "weapon_ak47",
    },
    secondary_weapon = {},
    models = Level.StandardPlayerModels
}

Level.red = {"jailbreak_red",Color(255,55,55),
    models = Level.StandardPlayerModels
}

Level.teamEncoder = {
    [1] = "blue",
    [2] = "red"
}

function Level:GetMaxBlue()
    return math.max(math.ceil(#player.GetAll() / 8),1)
end

function Level:CanUseSpawnMenu(ply)
    if ply:Team() == 1 and ply:Alive() then
        local rank,rankID = jailbreakManager:GetRank(ply)

        return rankID == true or tonumber(rankID or 0) >= 3
    end
end

function Level:CantUseFootkick() return false end

function Level:TeamTab_Team(id,team)
    if id ~= 1 then return end

    local rank = jailbreakManager:GetRank(LocalPlayer())
    local col = rank[2]

    for i,armor in pairs(rank.armors or empty) do
        local armor,col = self.GetArmor(armor,col)

        team.armors[#team.armors + 1] = {Armor_GetValidName(armor),col}
    end
end

function Level:DrawScreenspace() return false end