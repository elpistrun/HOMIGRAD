local SWEP = oop.Reg("wep_mr43_sawed","wep_mr43",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= "MR43 Sawed"
SWEP.IconOverride = "entities/arc9_eft_mr43_sawedoff.png"

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,-18,1)
        }
    }
}

SWEP.CameraPos = Vector(-27,0,0.9)
SWEP.MuzzlePos = Vector(-7.8,0,0)

function SWEP:InitWorldModelBodygroup(wm)
    wm:SetBodygroup(1,1)
    wm:SetBodygroup(3,4)
end

function SWEP:DoAnimationRecoil(wmAngle,wmVector)
    local recoil = self.recoil
    local scopeLerp = self.scopeLerp
    local abs = self.recoilRandAbs

    wmAngle[1] = wmAngle[1] - math.max(recoil - 0.2,0) / 0.8 * 20 + math.ease.InBounce(recoil) * 15 + math.sin(CurTime() * 3) * recoil * 2
    wmAngle[1] = wmAngle[1] - math.max(recoil - 0.5,0) / 0.5 * 45
    wmAngle[1] = wmAngle[1] - recoil * 15

    wmAngle[2] = wmAngle[2] + recoil * abs + math.max(recoil - 0.5,0) / 0.5 * 15 * abs - math.ease.InBounce(recoil) * 5 * abs + math.cos(CurTime() * 3) * recoil * 2
    wmVector[3] = wmVector[3] + 4 * recoil
end