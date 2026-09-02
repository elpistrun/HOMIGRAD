local SWEP = oop.Get("weapon_hands")
if not SWEP then return end

SWEP.AnimationList = {
    ["idle"] = {
        index = 1,
        delay = 0.5,
        endless = true,
    },
    ["deploy"] = {
        index = 3,
        delay = 0.45,

        endCycle = 0.7,
    },
    ["holster"] = {
        index = 3,
        delay = 0.33,

        endCycle = 0.7,

        inversion = true,
    }
}

local DefaultLeftElbowDown = 140
local DefaultRightElbowDown = 150

-- ATTACK RIGHT

local ATTACK_RIGHT = {
    index = 2,
    delay = 0.9,

    endCycle = 0.5,
    load = 0.28,
    skip = 0.4,

    hitbox = {-Vector(0,10,1),Vector(0,-1,1)},
    distanceMul = 0.8,

    Start = function(self)
        self.parent:EmitLocalSound("weapons/melee/matelbat/bat_heavy" .. math.random(1,3) .. ".wav",60)
    end
}

SWEP.AnimationList["attack_right"] = ATTACK_RIGHT

local graphVector = {
    {0,Vector()},
    {0.4,Vector(-2,-10,-4)},
    {1,Vector()},
}

local graphAngle = {
    {0,Angle()},
    {0.17,Angle(0,-10,-2)},
    {0.35,Angle(-20,40,-20)},
    {1,Angle()},
}

local graphDown = {
    {0,140},
    {0.3,-30},
    {1,140}
}

ATTACK_RIGHT.OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
    wmVector:Add(math.EvalGraphVector(self:GetCycle(),graphVector))
    wmAngle:Add(math.EvalGraphAngle(self:GetCycle(),graphAngle))

    tpikMatrix.rightDown = math.EvalGraph(self:GetCycle(),graphDown)
end

local graphAngle = {
    {0,Angle()},
    {0.2,Angle(0,10,10)},
    {1,Angle()},
}

ATTACK_RIGHT.OnBones = function(self,ent)
    ent:AddBoneAng("spine",math.EvalGraphAngle(self:GetCycle(),graphAngle))
end

local graphAngle = {
    {0,Angle()},
    {0.25,Angle(0,0,-10)},
    {1,Angle()},
}

ATTACK_RIGHT.OnChangeCamera = function(self,ply,view)
    view.ang:Add(math.EvalGraphAngle(self:GetCycle(),graphAngle))
end

ATTACK_RIGHT.OnHoldType = function(self,cycle) return cycle <= 0.8 and "pistol" end

-- ATTACK LEFT

local ATTACK_LEFT = {
    index = 1,
    delay = 0.7,

    endCycle = 0.8,
    load = 0.3,
    skip = 0.5,

    hitbox = {-Vector(0,3,1),Vector(0,4,1)},
    distanceMul = 0.75,

    Start = function(self)
        self.parent:EmitLocalSound("weapons/melee/matelbat/bat_light" .. math.random(1,3) .. ".wav",60)
    end
}

SWEP.AnimationList["attack_left"] = ATTACK_LEFT

local graphVector = {
    {0,Vector()},
    {0.4,Vector(1,-6,0)},
    {1,Vector()},
}

local graphAngle = {
    {0,Angle()},
    {0.4,Angle(-8,15,60)},
    {1,Angle()},
}

local graphDown = {
    {0,140},
    {0.5,33},
    {1,140}
}

ATTACK_LEFT.OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
    wmVector:Add(math.EvalGraphVector(self:GetCycle(),graphVector))
    wmAngle:Add(math.EvalGraphAngle(self:GetCycle(),graphAngle))

    tpikMatrix.leftDown = math.EvalGraph(self:GetCycle(),graphDown)
end

local graphAngle = {
    {0,Angle()},
    {0.2,Angle(0,0,0)},
    {0.4,Angle(0,0,-30)},
    {1,Angle()},
}

ATTACK_LEFT.OnBones = function(self,ent)
    ent:AddBoneAng("spine",math.EvalGraphAngle(self:GetCycle(),graphAngle))
end

local graphAngle = {
    {0,Angle()},
    {0.25,Angle(0,0,10)},
    {1,Angle()}
}

ATTACK_LEFT.OnChangeCamera = function(self,cycle,ply,view)
    view.ang:Add(math.EvalGraphAngle(cycle,graphAngle))
end

local cos,sin = math.cos,math.sin

function SWEP:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    Ang[1] = Lerp(self:GetStandAnimK(),0,Ang[1])

    tpikMatrix.leftDown = DefaultLeftElbowDown
    tpikMatrix.rightDown = DefaultRightElbowDown

    local sequenceObject = self.sequenceObject

    local time = RealTime()
    local breathK = tpikMatrix.link:GetBreathAnimK()

    wmVector:Add(Vector(0,0,cos(time) / 10 + breathK / 6))
    wmAngle:Add(Angle(sin(time) / 6 + breathK * 8,math.sin(time) * breathK * 3,0))

    self.blockLerp = LerpFT(0.8,self.blockLerp or 0,self.blockState and 1 or 0)
    
    if self.blockLerp > 0.01 then
        wmAngle[1] = Lerp(self.blockLerp,wmAngle[1],5)
        wmAngle[2] = Lerp(self.blockLerp,wmAngle[2],-15)
        wmAngle[3] = Lerp(self.blockLerp,wmAngle[3],25)

        wmVector[1] = Lerp(self.blockLerp,wmVector[1],-8)
        wmVector[2] = Lerp(self.blockLerp,wmVector[2],0)
        wmVector[3] = Lerp(self.blockLerp,wmVector[3],7)
    end
    
    local k = math.max(self:GetFightBlockStart() - CurTime() + 0.3,0) / 0.3--hit

    if k > 0 then
        wmAngle[1] = wmAngle[1] - 25 * k
    end
end

function SWEP:GetSequenceIdleIndex() return 1,1 end

function SWEP:DoBones(ply,link,tpikMatrix)
    self:DoBonesAnimation(ply,link,tpikMatrix)
    
    local holdType = self.HoldTypeCombat

    local sequenceObject = self.sequenceObject

    if sequenceObject then
        local cycle = sequenceObject:GetCycle()

        if sequenceObject.OnHoldType then
            holdType = sequenceObject.OnHoldType(self,cycle,ply) or holdType
        end
    end
    
    if self:GetStandAnimK() == 1 and self.stateHandling != "holster" and self:GetFightState() then
        self:SetWeaponHoldType(holdType)
    else
        self:SetWeaponHoldType(IsValid(link:GetCarryObject()) and "magic" or self.HoldType)
    end
end

local hitLeft,hitRight = 0,0

function SWEP:PreCalcView(ply,view)
    view.mulSideLerp = Lerp(self:GetStandAnimK(),view.mulSideLerp or 1,2)

    hitLeft = LerpFT(0.6,hitLeft,math.max((self.hitStartLeft or 0) - RealTime() + 0.5,0) / 0.5)
    
    local ang = view.ang

    if hitLeft > 0 then
        ang[1] = ang[1] + 7 * hitLeft

        ang[2] = ang[2] + 5 * hitLeft
        ang[3] = ang[3] + 5 * hitLeft
    end

    hitRight = LerpFT(0.6,hitRight,math.max((self.hitStartRight or 0) - RealTime() + 0.5,0) / 0.5)
    
    if hitRight > 0 then
        ang[1] = ang[1] + 7 * hitRight

        ang[2] = ang[2] - 5 * hitRight
        ang[3] = ang[3] - 5 * hitRight
    end
end

function SWEP:GetModelForTPIKLeftHand()
    return (self:GetFightState() or self.stateHandling == "holster") and self.wm
end

function SWEP:GetModelForTPIKRightHand()
    return (self:GetFightState() or self.stateHandling == "holster") and self.wm
end