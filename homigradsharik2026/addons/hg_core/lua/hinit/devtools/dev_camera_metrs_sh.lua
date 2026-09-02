local SWEP = oop.Reg("weapon_dev_camera_metrs","base_weapon")
if not SWEP then return end

SWEP.PrintName = "DEV CAMERA METRS"
SWEP.Spawnable = true

SWEP.ViewModel = ""

function SWEP:PreDrawViewModel() return true end

local hitPos1
local hitPos2

local mat = Material("models/shadertest/shader4")

hook.Add("HUDPaint","Dev Camera Metrs",function()
    local wep = LocalPlayer():GetActiveWeapon()

    local w,h = ScrW(),ScrH()

    local text = ""

    if IsValid(wep) and wep:GetClass() == "weapon_dev_camera_metrs" then
        if LocalPlayer():KeyDown(IN_ATTACK) then
            local tr = LocalPlayer():EyeTrace()

            hitPos1 = tr.HitPos
            hitPos2 = hitPos2 or hitPos1
        elseif LocalPlayer():KeyDown(IN_ATTACK2) then
            local tr = LocalPlayer():EyeTrace()

            hitPos2 = tr.HitPos
            hitPos1 = hitPos1 or hitPos2
        elseif LocalPlayer():KeyDown(IN_RELOAD) then
            hitPos1 = nil
            hitPos2 = nil
        end
    end

    if hitPos1 and hitPos2 then
        text = text .. math.floor(hitPos1:Distance(hitPos2) * UNITS_TO_METERS * 100) / 100 .. " метров\n"
        text = text .. math.floor(hitPos1:Distance(hitPos2) * UNITS_TO_METERS * 100 / (BALISTIC_SCALE or 1)) / 100 .. " balistic метров"
    else
        return
    end

    text = markup.Parse("<font=HS.18>" .. text)

    local x,y = w / 2 - text:GetWidth() / 2,h * 0.016

    surface.SetDrawColor(0,0,0)
    surface.DrawRect(x,y,text:GetWidth(),text:GetHeight())
    text:Draw(x,y)

    cam.Start3D()
    render.SetMaterial(mat)
    render.DrawLine(hitPos1,hitPos2)
    render.DrawSphere(hitPos1,0.1,16,16)
    render.DrawSphere(hitPos2,0.1,16,16)
    cam.End3D()
end)