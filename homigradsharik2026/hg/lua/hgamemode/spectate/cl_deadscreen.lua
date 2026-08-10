local deathData = false

local lifeTime = RealTime()

event.Add("Player Spawn","Death Screen",function(ply)
    if ply ~= LocalPlayer() then return end

    lifeTime = RealTime()

    deathData = false
end)

local function startDeathScreen(data)
    deathData = data

    deathData.start = RealTime()
    deathData.type = data.type or "default"
    deathData.delay = data.delay or 4

    deathData.shake = 1
    deathData.shakeX = 0
    deathData.shakeY = 0
    deathData.randomX = math.Rand(-1,1)
    deathData.randomY = math.Rand(-1,1)

    deathData.lifeTime = RealTime() - lifeTime

    if LocalPlayer():IsOnGround() then
        deathData.look = EyePos()
    end

    deathData.startPos = EyePos()
    deathData.startAng = EyeAngles()

    sound.EmitScreen("homigrad/vgui/csgo_ui_crate_open.wav",0.44,100)

    if deathData.type == "headshoot" then
        deathData.shake = deathData.shake * 4
        
        for i = 1,3 do LocalPlayer():EmitSound("homigrad/headshoot.wav") end
    end
end

local function deathScreenActive()
    if not deathData then return false end

    local k = (deathData.start + deathData.delay - RealTime()) / deathData.delay

    return math.Clamp(k,0,1)
end

local vecZero = Vector(0.01,0.01,0.01)

local setAng = Angle()

event.Add("PreCalcView","Death Screen",function(ply,view)
    local time = RealTime()

    local k = deathScreenActive()
    if not k then return end

    local ent = ply:GetDummy()

    if not ply:Alive() then//lol??
        if deathData.ragdollEntIndex then
            ent = Entity(deathData.ragdollEntIndex)
        else
            ent = nil
        end
    end

    view.vec = deathData.startPos:Clone()
    view.ang = deathData.startAng:Clone()

    if IsValid(ent) then
        ent:SetupBones()

        local head = ent:LookupBone("ValveBiped.Bip01_Head1")

        if head then
            local matrix = ent:GetBoneMatrixNow(head)
            
            ent.headPop = true

            if matrix then
                view.vec = matrix:GetTranslation()
                view.ang = matrix:GetAngles()

                view.ang:RotateAroundAxis(view.ang:Up(),90)
                view.ang:RotateAroundAxis(view.ang:Right(),180)
                view.ang:RotateAroundAxis(view.ang:Forward(),90)
            end
        end
    end

    deathData.shakeX = math.Rand(-1,1) * deathData.shake
    deathData.shakeY = math.Rand(-1,1) * deathData.shake

    view.ang:Rotate(Angle(deathData.shakeY,deathData.shakeX,math.Rand(-0.5,0.5)):Mul(deathData.shake * 20))
    view.ang:Add(Angle(deathData.randomY,deathData.randomX,0):Mul(15))

    deathData.shake = LerpFT(0.075,deathData.shake,0)

    if deathData.look then
        //view.ang:Lerp((1 - k) * 0.5,(deathData.look - view.pos):Angle())
    end

    SpectateVec = view.vec
    
    setAng = view.ang

    return view
end,-22)

hook.Add("CreateMove","Death Screen",function(cmd)
    if not deathScreenActive() then return end

    if deathData.start - RealTime() + 1.5 <= 0 and cmd:GetButtons() > 0 then
        local ent = deathData.ragdollEntIndex and Entity(deathData.ragdollEntIndex)
        if IsValid(ent) then ent.headPop = nil end

        deathData = nil
    end
    
    cmd:ClearButtons()
    cmd:ClearMovement()

    cmd:SetViewAngles(Angle(setAng[1],setAng[2],0))//никогда не задавайте 3 значение блядь

    return false
end)

event.Add("Screen Size","Death Screen Fonts",function(mul)
	surface.CreateFont("Death75",{
		font = "Arial",
		size = math.ceil(75 * mul),
		weight = 1100,
        blursize = 50
	})
end)

hook.Add("HUDPaint","Death Screen",function()
    local k = deathScreenActive()
    if not k then return end

    local k2 = k

    k = 1 - k
    k = math.min(k * 1,1)

    surface.SetDrawColor(0,0,0,255 * k)

    local size = ScrH() * k

    local w,h = ScrW(),ScrH()
    
    draw.GradientUp(0,0,w,size)
    draw.GradientUp(0,0,w,size)
    draw.GradientDown(0,w - size,w,size + 1)

    surface.SetDrawColor(0,0,0,200 * k)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(0,0,0,255 * k)
    surface.SetBG("points50")
    draw.BG2(0,0,w,h)

    draw.SimpleText(L("death"),"Death75",w / 2 - deathData.shakeX * 6 * (w * 0.05),h / 2 - deathData.shakeY * 6 * (h * 0.05) + 15 * ScreenSize,Color(255,255,255,25),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText(L("death"),"HS.45",w / 2 - deathData.shakeX * 6 * (w * 0.05),h / 2 - deathData.shakeY * 6 * (h * 0.05),nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    surface.SetAlphaMultiplier(math.ease.InOutCubic(math.min(k,1)))

    local time = math.floor(deathData.lifeTime)

    if time < 60 then
        time = L("death_second",time)
    elseif time < 60 * 60 then
        time = L("death_minutes_seconds",math.floor(time / 60),time % 60)
    else
        time = L("death_hour_minutes_seconds",math.floor(time / 60 / 60),math.floor((time / 60) % 60),time % 60)
    end
    
    draw.SimpleText(L("death_lifetime",time),"HS.25",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) + h * 0.25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    if k == 1 then
        draw.SimpleText(L("death_canrespawn"),"HS.25",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) + h * (0.25 + 0.25 / 2),nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if deathData.mainReasonDeath then
        draw.SimpleText(deathData.mainReasonDeath,"HS.25",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) - h * 0.25,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if deathData.distance then
        draw.SimpleText(L("death_distance",math.floor(deathData.distance)),"HS.18",w / 2 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) - h * 0.25 + 30 * ScreenSize,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if deathData.reasons then
        local y = 0

        for reason in pairs(deathData.reasons) do
            draw.SimpleText(L("deadreason_" .. reason),"HS.18",w * 0.05 - deathData.shakeX * (w * 0.05),h / 2 - deathData.shakeY * (h * 0.05) - h * 0.25 + y,nil,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

            y = y + 25 * ScreenSize
        end
    end

    surface.SetAlphaMultiplier(1)

    surface.SetDrawColor(0,0,0,15 * k)
    surface.SetBG("points50")
    draw.BG2(0,0,w,h)
end)

concommand.Add("TEStdead",function()
    startDeathScreen({
        type = "headshoot",
        ang = Angle(math.Rand(-180,180),math.Rand(-180,180),0)
    })
end)

/*if LocalPlayer():SteamID() == "STEAM_0:1:164889146" then
    RunConsoleCommand("TEStdead")
end*/

event.Add("Player Death","Death Screen",function(ply,dmgTab)
    if ply ~= LocalPlayer() then return end

    local type = "default"

    if dmgTab.reasons["head"] or dmgTab.reasons["headExplode"] then
        type = "headshoot"
    end

    local boneName = ""
    if dmgTab.boneName then
        boneName = " " .. L("in") .. " " .. L("in_" .. dmgTab.boneName)
    end

    local wepName = ""
    if dmgTab.wepName then
        wepName = " " .. L("kill_by_wep") .. " " .. dmgTab.wepName
    end

    local mainReasonDeath = ""

    if dmgTab.killedBy == "player" then
        mainReasonDeath = L("by_kill") .. " " .. dmgTab.killedTarget:Name() .. boneName .. wepName
    elseif dmgTab.killedBy == "npc" then
        mainReasonDeath = L("by_kill_npc") .. " " .. dmgTab.killedTarget .. boneName .. wepName
    elseif dmgTab.killedBy == "object" then
        mainReasonDeath = L("by_kill_object") .. " " .. dmgTab.killedTarget .. boneName .. wepName
    end
    
    startDeathScreen({
        ragdollEntIndex = dmgTab.ragEntIndex,
        mainReasonDeath = mainReasonDeath,
        reasons = dmgTab.reasons,
        distance = dmgTab.distance
    })
end)
