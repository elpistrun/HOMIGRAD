local SWEP = oop.Reg("weapon_dev_camera","base_weapon")
if not SWEP then return end

SWEP.PrintName = "DEV CAMERA"
SWEP.Spawnable = true

SWEP.ViewModel = ""

function SWEP:PreDrawViewModel()
    return true
end

local fov = 90
local hit
local hitEntity

function SWEP:CalcView(ply,pos,ang,_fov)
    DEVCAMERAFOV = 90

    return pos,ang,fov
end

function SWEP:AdjustMouseSensitivity()
    return fov / 90
end

function SWEP:Holster()
    DEVCAMERAFOV = nil

    return true
end

hook.Add("InputMouseApply","CANERADEV",function(cmd,x,y)
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() != "weapon_dev_camera" then return end

    if LocalPlayer():KeyDown(IN_ATTACK2) then
        cmd:SetMouseX(0)
        cmd:SetMouseY(0)

        fov = math.Clamp(fov + y / 10,5,90)

        return true
    end
end)

SWEP.FirstView = true

hook.Add("HUDPaint","Dev Camera",function()
    local w,h = ScrW(),ScrH()

    local wep = IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_dev_camera"
    if not hit and not wep then return end

    local text = ""

    text = "FOV: " .. math.floor(fov * 10) / 10

    if wep then
        if LocalPlayer():KeyDown(IN_ATTACK) then
            local tr = LocalPlayer():EyeTrace()

            hit = tr.HitPos
            hitEntity = tr.Entity
        elseif LocalPlayer():KeyDown(IN_RELOAD) then
            hit = nil
            htiEntity = nil
        end
    end

    if hit then
        text = text .. "\nPOINT1: " .. math.floor(hit:Distance(EyePos()))

        if IsValid(hitEntity) and hitEntity:IsPlayer() then
            text = text .. " " .. (
                hitEntity.renderLOD0 and "renderLOD0" or
                hitEntity.renderLOD1 and "renderLOD1" or
                hitEntity.renderLOD2 and "renderLOD2" or
                hitEntity.renderLOD2_5 and "renderLOD2_5" or
                hitEntity.renderLOD3 and "renderLOD3" or
                hitEntity.renderLOD4 and "renderLOD4" or
                "none"
            )
        end
    end

    text = markup.Parse("<font=HS.18>" .. text)

    local x,y = w / 2 - text:GetWidth() / 2,h * 0.016

    surface.SetDrawColor(0,0,0)
    surface.DrawRect(x,y,text:GetWidth(),text:GetHeight())
    text:Draw(x,y)
end)