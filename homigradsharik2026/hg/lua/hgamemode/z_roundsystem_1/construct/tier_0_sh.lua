local Level = oop.Reg("level_construct","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.ShouldSpawnLoot = false
Level.PropBreakLoot = false
Level.RoundTime = 600 -- 10 minutes
Level.LoadScreenTime = 3
Level.NoSelectRandom = true -- Don't randomly select via RTV

-- Construct: freebuild sandbox mode, no teams, no combat
Level.builder = {
    "builder", Color(255, 200, 50),
    weapons = {"weapon_hands", "weapon_physgun", "gmod_tool"},
    models = Level.StandardPlayerModels,
}

Level.teamEncoder = {
    [1] = "builder",
}

if SERVER then return end

function Level:DrawScreen(lply, k)
    local w, h = ScrW(), ScrH()

    draw.DrawText(L("level_construct"), "H.45", w / 2, h / 8, cgray, TEXT_ALIGN_CENTER)
    draw.DrawText(L("construct_loadscreen"), "H.25", w / 2, h / 2, cname, TEXT_ALIGN_CENTER)
    draw.DrawText(L("construct_loadscreen_desc"), "H.25", w / 2, h / 1.3, cgray, TEXT_ALIGN_CENTER)
end

function Level:HUDPaint()
    local lply = LocalPlayer()

    self:DrawLoadScreen()
    self:DrawRoundTime()
    self:DrawCenter()
end

function Level:Scoreboard_Status(ply)
    return
end

function Level:Scoreboard_DrawLast(ply)
    return false
end
