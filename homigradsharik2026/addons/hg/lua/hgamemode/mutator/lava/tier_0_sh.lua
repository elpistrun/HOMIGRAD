local MUTATOR = Mutator_Reg("lava","base",true)
if not MUTATOR then return INCLUDE_BREAK end

MUTATOR.Title = "mutator_lava"
MUTATOR.Desc = "mutator_lava_desc"
MUTATOR.Icon = Material("icon16/ipod_cast.png")

function MUTATOR:SetupVars()
    self:SetupVar("Height")
    self:SetupVar("Speed")
end

function MUTATOR:Off()
    if self.snd and self.snd:IsPlaying() then self.snd:Stop() end
    if self.snd2 and self.snd2:IsPlaying() then self.snd2:Stop() end
end

MUTATOR.EventPlug["Think"] = "Think"
function MUTATOR:Think()
    local var = self:GetHeight()
    if not var then return end//lol

    local snd = self.snd
    if not snd then
        snd = CreateSound(LocalPlayer(),"ambient/waterrun.wav")
        self.snd = snd
    end

    local snd2 = self.snd2
    if not snd2 then
        snd2 = CreateSound(LocalPlayer(),"ambient/ambience/wind_light02_loop.wav")
        self.snd2 = snd2
    end

    snd:Play()
    snd2:Play()

    local v = 1 - math.Clamp((EyePos()[3] - var) / 4000,0,1)

    v = math.max(v,0.1)
    
    snd:ChangeVolume(v)
    snd2:ChangeVolume(v)

    snd:ChangePitch(Lerp(v,5,90))
    snd2:ChangePitch(Lerp(v,5,90))

    util.ScreenShake(EyePos(),v * 5,v * 24,0.1,32,false)

    if v == 1 then
        snd:SetDSP(14)
        snd:ChangeVolume(0.25)

        snd2:SetDSP(14)
        snd2:ChangeVolume(0.25)
    elseif v > 0.75 then
        snd:SetDSP(3)
        snd2:SetDSP(0)
    elseif v >= 0.8 then
        snd2:SetDSP(4)
    else
        snd:SetDSP(25)
        snd2:SetDSP(0)
    end
end

local white = Color(255,255,255)
local lava = Material("models/MCModelPack/animated/lava")

local size = 16000
local w,h = 10,10

MUTATOR.HookPlug["PostDrawOpaqueRenderables"] = "PostDrawOpaqueRenderables"
function MUTATOR:PostDrawOpaqueRenderables()
    local height = self:GetHeight()
    if not height then return end

    local pos = EyePos()

    local sizeX,sizeY = size / w * 2,size / h * 2

    local time = RealTime()

    for x = -w,w do
        for y = -h,h do
            render.SetMaterial(lava)
            render.DrawQuadEasy(
                Vector(sizeX * x,sizeY * y,height),
                Vector(0,0,1),
                sizeX,sizeY,white,0)

            render.DrawQuadEasy(
                Vector(sizeX * x,sizeY * y,height),
                Vector(0,0,-1),
                sizeX,sizeY,white,0)
        end
    end
end

MUTATOR.HookPlug["HUDPaint"] = "HUDPaint"
function MUTATOR:HUDPaint()
    local height = self:GetHeight()

    local v = 1 - math.Clamp((EyePos()[3] - height) / 4000,0,1)

    surface.SetDrawColor(255,145,0,25 * v)

    local h = ScrH() * (1 - (math.abs(math.cos(RealTime()) / 5)))
    
    draw.GradientDown(0,h,ScrW(),ScrH() - h + 1)

    surface.SetDrawColor(255,145,0,45 * (math.max(v - 0.8,0) / 0.2))
    surface.DrawRect(0,0,ScrW(),ScrH())

    if v == 1 then
        surface.SetDrawColor(255,145,0,225)
        surface.DrawRect(0,0,ScrW(),ScrH())
    end
end

MUTATOR.EventPlug["DSP"] = "DSP"
function MUTATOR:DSP()
    if EyePos()[3] < self:GetHeight() then return 31 end
end

local math_Clamp = math.Clamp
local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

local max = math.max

MUTATOR.EventPlug["RenderScreenspaceEffects"] = "RenderScreenspaceEffects"

function MUTATOR:RenderScreenspaceEffects()
    local height = self:GetHeight()
    if not height then return end

    local v = 1 - math.Clamp((EyePos()[3] - height) / 2000,0,1)

    if v == 0 then return end

	tab["$pp_colour_addr"] = v * 0.5 / 1.5
    tab["$pp_colour_addg"] = v * 0.25 / 1.5

    DrawColorModify(tab)

    DrawBloom(
        0,
        v * 0.25,
        32,
        32,
        1,
        1,
        0.5,
        0.25,
        0
    )
end

function MUTATOR:GetDescTextOnCursor()
    return {
        "speed: " .. (self:GetSpeed() or 0),
        "height: " .. math.floor(self:GetHeight() or 0),
    }
end

function MUTATOR:CreateUI(page)
    self:CreatePanelEnabled(page)

    local slider = self:CreatePanelSlider(page,"Height",nil,"Height")
    slider:SetMin(-16000)
    slider:SetMax(16000)

    local slider = self:CreatePanelSlider(page,"Speed",nil,"Speed")
    slider:SetMin(-100)
    slider:SetMax(100)
end