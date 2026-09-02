local breathStart
local breathMode
local breathDelay

local random = math.random

fumosModels = {
    ["models/miside/chibi.mdl"] = true
}

event.Add("PreCalcView","FumosModels",function(ply,view)
    if not fumosModels[ply:GetModel()] then return end

    CameraLandSet = Vector()
end)

local function playSndBreath(ply,mode,delay)
    if not ply.renderLOD1 then return end
    
    local pitch = math.max(80 + 50 * (1 - delay),90)
    local volumeMul = 1 - delay

    if volumeMul <= 0 then return end

    local ent = ply:GetDummy()

    if ent ~= ply then
        pos = ent:GetPos()
    else
        pos,ang = ply:Eye()
        pos:Add(Vector(5,0,0):Rotate(ang))
    end
    
    local fumsoVersion = fumosModels[ply:GetModel()]

    if mode == "out" then
        if ply.lastBreathSndOut then ply:StopSound(ply.lastBreathSndOut) end

        if fumsoVersion then
            ply.lastBreathSndOut = "homigrad/pick.wav"
            sound.Emit(ent:EntIndex(),ply.lastBreathSndOut,75,0.2 * volumeMul,pitch + random(-5,5) - 24)
        else
            ply.lastBreathSndOut = "homigrad/player/male/breath/out" .. random(1,9) .. ".wav"
            sound.Emit(ent:EntIndex(),ply.lastBreathSndOut,75,0.2 * volumeMul,pitch + random(-5,5) - 12)
        end
    else
        if ply.lastBreathSndIn then ply:StopSound(ply.lastBreathSndIn) end

        if fumsoVersion then
            ply.lastBreathSndOut = "homigrad/pick.wav"
            sound.Emit(ent:EntIndex(),ply.lastBreathSndOut,75,0.2 * volumeMul,pitch + random(-5,5) + 24)
        else
            ply.lastBreathSndIn = "homigrad/player/male/breath/in" .. random(1,9) .. ".wav"
            sound.Emit(ent:EntIndex(),ply.lastBreathSndIn,75,0.1 * volumeMul,pitch + random(-5,5) + 12)
        end
    end
end

net.Receive("breath",function()
    if not InitNET then return end--ok

    local ent = net.ReadEntity()
    if not IsValid(ent) then return end--LOL
    
    local delay = tonumber(net.ReadString())
    local mode = net.ReadBool() and "in" or "out"
    
    if ent == LocalPlayer() then
        breathStart = RealTime()
        breathDelay = delay
        breathMode = mode
    end

    ent.breathTime = CurTime()
    ent.breathMode = mode
    ent.breathDelay = delay

    playSndBreath(ent,breathMode,delay)
end)

net.Receive("cough",function()
    if not InitNET then return end//ok
    
    local ent = net.ReadEntity()

    sound.Emit(ent:EntIndex(),"homigrad/player/male/cough/" .. math.random(1,4) .. ".wav",75,0.5,random(90,105))

    if ent == LocalPlayer() then
        coughStart = RealTime()
    end
end)

local y,setY = 0,0

event.Add("PreCalcView","Breath",function(ply,view)
    if not ply:Alive() or not breathStart or ply:GetMoveType() == MOVETYPE_NOCLIP then return end

    setY = math.max(breathStart + breathDelay - RealTime(),0) / breathDelay

    if breathMode == "out" then
        setY = -setY / 4.5
    else
        
    end

    local volumeMul = 1 - breathDelay
    setY = setY * volumeMul

    y = LerpFT(breathMode == "out" and 0.25 or 0.1,y,setY)

    view.ang:Add(Angle(4 * y,0,math.cos(RealTime()) * y))
    view.fov = view.fov + y
end,15)

local y,setY = 0,0

event.Add("PreCalcView","Cough",function(ply,view)
    if not ply:Alive() or not coughStart or ply:GetMoveType() == MOVETYPE_NOCLIP then return end

    setY = math.max(coughStart + 1 - RealTime(),0) / 1

    y = LerpFT(0.1,y,setY)

    view.ang:Add(Angle(10 * y,0,math.sin(RealTime()) * y * 13))
    view.fov = view.fov + y
end,15)

local glow = Material("homigrad/vgui/vignette.png","smooth")

hook.Add("PreDrawHUD","Breath",function()
    local ply = LocalPlayer()

    cam.Start2D()
    surface.SetDrawColor(0,0,0,200 * (1 - (ply.breathDelay or 1)))
    surface.SetMaterial(glow)
    surface.DrawTexturedRect(0,0,ScrW(),ScrH())
    cam.End2D()
end)