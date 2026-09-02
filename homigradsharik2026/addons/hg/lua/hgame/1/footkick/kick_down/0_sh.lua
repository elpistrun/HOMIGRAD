local ANM = animationEntity.Reg("anm_kick_down","anm_kick",true)
if not ANM then return INCLUDE_BREAK end

ANM.sequence = "range_melee"
ANM.delay = 0.6

function ANM:StartPost()
    local ply = self.parent

    ply:SetCooldown("kick",0.4 + ply:GetMetabolismStaminaDelay() * 3)

    if SERVER then
        ply:SetStamina(ply:GetStamina() - 2)
    end

    if CLIENT then
        sound.Emit(ply:EntIndex(),"weapons/melee/matelbat/bat_draw.wav",75,1,90,ply:GetPos() + ply:OBBCenter())
    end
end

function ANM:MoveThink(mv)
    mv:SetMaxSpeed(mv:GetMaxSpeed() * self.moveMul)
end

local mins = -Vector(0,6,6)
local maxs = Vector(0,6,6)

function ANM:ParseTrace(tr)
    local ply = self.parent
    local eyePos,eyeAng = ply:Eye()
    eyeAngYaw = Angle(0,eyeAng[2],0)

    local pos = ply:GetPos() + Vector(16,0,0):Rotate(eyeAngYaw)
    
    tr.start = pos + ply:OBBCenter()
    tr.endpos = pos + Vector(0,0,-64)

    tr.mins = mins
    tr.maxs = maxs
    
    return tr
end