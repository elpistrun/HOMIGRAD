local grtodown = Material( "vgui/gradient-u" )
local grtoup = Material( "vgui/gradient-d" )
local grtoright = Material( "vgui/gradient-l" )
local grtoleft = Material( "vgui/gradient-r" )

local ScrW,ScrH = ScrW,ScrH
local math_Clamp = math.Clamp
local k = 0
local k4 = 0
local time = 0

local old

local pulseStart = 0

event.Add("DSP","Otrub",function()
    local ply = LocalPlayer()

    if ply:Alive() and ply:GetNWBool("Otrub") then return 16 end
end)

local glow = Material("homigrad/vgui/vignette.png","smooth")
local gradient = Material("homigrad/vgui/gradient_up.png","smooth")

local painLerp = 0
local snd

hook.Add("PreDrawHUD","PainEffect",function()
    local ply = LocalPlayer()
    if not ply:Alive() then
        if snd and snd:IsPlaying() then
            snd:Stop()
        end

        painLerp = 0

        return
    end

    local active = ply:GetNW2Bool("Otrub")

    if active then
        cam.Start2D()

        surface.SetDrawColor(0,0,0,255)
        surface.DrawRect(0,0,ScrW(),ScrH())

        cam.End2D()
        
        local pulse = ply:GetNW2Float("pulse",0)

        if pulse ~= 0 and pulseStart + pulse * 60 < RealTime() then
            pulseStart = RealTime()

            surface.PlaySound("snd_jack_hmcd_heartpound.wav")
        end

        if snd and snd:IsPlaying() then
            snd:ChangeVolume(0,0.1)
            snd:ChangePitch(60,0.5)
        end

        return
    end

    local w,h = ScrW(),ScrH()

    painLerp = LerpFT(0.01,painLerp,math.Clamp(ply:GetNW2Float("pain") / 75,0,1))

    local k = painLerp

    if not snd then
        snd = CreateSound(LocalPlayer(),"homigrad/bass_noise.wav")
        snd:PlayEx(0,60)
    end

    if k <= 0.01 then
        snd:ChangeVolume(0,0.1)
        snd:ChangePitch(60,0.5)

        return
    end
    
    if not snd:IsPlaying() then
        snd:PlayEx(0,60)
    end

    snd:ChangeVolume(k * 0.3,0.1)
    snd:ChangePitch(120,0.1)

    cam.Start2D()

    for i = 1,4 do
        surface.SetDrawColor(0,0,0,200 * k)
        surface.SetMaterial(glow)
        surface.DrawTexturedRectRotated(w/2,h/2,w * 1.1,h * 1.1,math.Rand(-2,2))
    end

    surface.SetDrawColor(0,0,0,255 * k)
    surface.SetMaterial(gradient)

    local pulse = 1 - math.cos(CurTime() * 0.6) / 2 + k / 3

    local wSize,hSize = w * pulse,h * pulse

    for i = 1,2 do
        surface.DrawTexturedRectRotated(wSize/4,hSize/4,w * 2,hSize,45)
        surface.DrawTexturedRectRotated(w/4,h - hSize/4,w * 2,wSize,135)
        surface.DrawTexturedRectRotated(w - hSize/4,h - h/4,w * 2,hSize,225)
        surface.DrawTexturedRectRotated(w - wSize/4,hSize/4,w * 2,hSize,315)
    end

    k = math.min(k * 12,1)
    
    surface.SetDrawColor(0,0,0,255 * k)
    draw.GradientDown(0,h / 3,w,h - h / 3)

    cam.End2D()
end)

hook.Add("StartCommand","Fake",function(ply,cmd)
	if not ply:Alive() or not ply:GetNW2Bool("Otrub") then return end
	
	cmd:ClearButtons()
end)

hook.Add("RenderScreenspaceEffects","Painlosing",function()
    if not LocalPlayer():Alive() then return end
    
    local painlosing = LocalPlayer():GetNWFloat("painlosing",0)

    if painlosing > 0 then
       -- DrawMotionBlur(0.8,painlosing / 3,0.016)
    end
end)