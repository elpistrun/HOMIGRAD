local PLAYER = FindMetaTable("Player")

local vecZero,angZero = Vector(),Angle()

local FrameNumber = FrameNumber
local TraceLine,TraceHull = util.TraceLine,util.TraceHull
local abs,max,min = math.abs,math.max,math.min

local tr = {}
tr.output = {}

local size = Vector(8,8,0)

function PLAYER:EyeTraceNoWall(startpos,endpos,filter,mask)
    tr.start = startpos
    tr.endpos = endpos

    tr.filter = filter or self
    tr.mask = mask

    tr.mins = -size
    tr.maxs = size

    local result = TraceHull(tr)

    endpos:Lerp(1 - result.Fraction,startpos)
end

local validClass = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true
}

function PLAYER:EyeMode()
    if not self:Alive() then return true end

    local wep = self:GetActiveWeapon()

    if IsValid(wep) then
        if wep.FirstView then return true end
        if validClass[wep:GetClass()] then return true end
    end

    return false
end

ModelSettings_EyeOffset = ModelSettings_EyeOffset or {}

local MatrixSet = Matrix()

function get_eye(self)
    if self:EyeMode() then return self:EyePos(),self:EyeAngles() end

    local ent = self:GetDummy()

    local ang = self:EyeAngles()
    local pos

    local startpos = self:EyePos()

    local setting = ModelSettings_EyeOffset[self:GetModel()]

    if ent ~= self then
        local head = ent:LookupBone("ValveBiped.Bip01_Head1")
        ent:CopyBoneMatrixHash(head,MatrixSet)

        local ang = MatrixSet:GetAngles()
        pos = MatrixSet:GetTranslation()

        pos:Add((setting and setting[2]:Clone() or Vector(4,0,0)):Rotate(ang))

        --if SERVER or self == LocalPlayer() then self:EyeTraceNoWall(startpos,pos,ent) end
    else
        eye = self:LookupAttachment("eyes")--xd
        eye = eye and self:GetAttachment(eye)

        if eye then
            local ang = eye.Ang

            pos = eye.Pos

            pos:Add((setting and setting[2]:Clone() or Vector(2,0,0)):Rotate(ang))

            if (SERVER or self == LocalPlayer()) and self:GetMoveType() ~= MOVETYPE_NOCLIP then self:EyeTraceNoWall(startpos,pos,ent) end
        else
            return self:EyePos(),self:EyeAngles()
        end
    end

    return pos,ang
end

function PLAYER:Eye(forceSet)
    local frameNumber = FrameNumber()

    if not forceSet and self.r_fEyeFrame == frameNumber then
        return self.eyePos:Clone(),self.eyeAng:Clone()
    end

    self.r_fEyeFrame = frameNumber

    local pos,ang = get_eye(self)

    self.eyePos = pos
    self.eyeAng = ang

    return pos:Clone(),ang:Clone()
end

local filterEnt1,filterEnt2
local filter = function(entHit) return entHit ~= filterEnt1 and entHit ~= filterEnt2 and entHit:GetClass() ~= "prop_dynamic" end

local tr = {
    filter = filter,
    mask = MASK_SOLID
}

function PLAYER:EyeTrace(dis)
    if self:EyeMode() then
        local trace = self:GetEyeTrace()

        return not dis and trace or (trace.HitPos:Distance(self:EyePos()) <= dis and trace)
    end

    local pos,ang = self:Eye()

    filterEnt1 = self
    filterEnt2 = ent

    tr.start = pos
    tr.endpos = pos + ang:Forward():Mul(32000)

    local result = TraceLine(tr)

    if dis and (result.HitPos:Distance(self.eyePos) or 0) > dis then return end

    return result
end

PlayerDisUse = 75

function PLAYER:IsLookOn(ent,dis)
    local tr = self:EyeTrace(dis or PlayerDisUse)
    
    return tr and tr.Entity == ent
end

if SERVER then
    event.Add("DoPlayerDeath","SaveEyePos",function(ply)
        local pos,ang = ply:Eye()
        ply.doDeathEyePos = pos
    end)

    event.Add("Player Death","Set DoDeath EyePos",function(ply)
        ply:SetPos(ply.doDeathEyePos or ply:GetPos())
    end)

    event.Add("PlayerSilentDeath","Set EyePos",function(ply)
        ply:SetPos(ply.doDeathEyePos or ply:GetPos())
    end)
end

function CalcSideK(yaw)
    local v = yaw

    if v > 0 then
        if v >= 90 then
            v = v - 90
        else
            v = 90 - v
        end

        v = 1 - v / 90
    else
        v = -v

        if v >= 90 then
            v = v - 90
        else
            v = 90 - v
        end

        v = 1 - v / 90

        v = -v
    end

    return v
end