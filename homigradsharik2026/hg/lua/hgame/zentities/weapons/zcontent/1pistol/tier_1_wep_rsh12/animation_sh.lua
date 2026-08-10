local SWEP = oop.Get("wep_rsh12")
if not SWEP then return end

SWEP:Event_Add("SetupDataTables","Roll",function(self)
    self:NetworkVar("Int","ChamberCount")
    self.animIteration = 1
end)

SWEP.AnimationList = {
    ["deploy"] = {
        index = 7,
        delay = PISTOL_DEPLOY_TIME,
        skip = PISTOL_CAN_SKIP,
        startCycle = 0.27,
    },
    ["holster"] = {
        index = 17,
        delay = PISTOL_HOLSTER_TIME
    },

    ["fire"] = {
        index = 32,
        delay = 0.2,

        inversion = true,
        add = -2
    },

    ["fire_empty"] = {
        index = 37,
        delay = 0.2,

        inversion = true,
        add = -2,
    },

    ["rev_inspect"] = {
        index = 53,
        limit = 4,
        delay = 3,
    },

    ["rev_uninsert"] = {
        index = 67,
        delay = 1,

        soundUnInsert = {{"weapons/eft/rsh12/rsh_12_ammo_out.ogg",75,0.4}},

        sound = {[0] = {{"weapons/eft/rsh12/rsh_12_reload_start.ogg",75,0.4}}},
        
        limit = 0,

        grabLeftHand = {[0] = false}
    },

    ["drum_open"] = {
        index = 62,
        delay = 1,
        startCycle = 0.3,
        sound = {[0] = {{"weapons/eft/rsh12/rsh_12_reload_start.ogg",75,0.4}}},
        limit = 0,
        inversion = true,

        grabLeftHand = {[0] = false}
    },

    ["drum_end"] = {
        index = 62,
        delay = 0.8,
        skip = 0.5,
        
        startCycle = 0.3,
        sound = {[0] = {{"weapons/eft/rsh12/rsh_12_reload_end.ogg",75,0.4}}},
        limit = 0,

        grabLeftHand = {[0] = false},

        canRepalce = true
    },

    ["rev_unload"] = {
        index = 102,
        delay = 1.6,
        sound = {
            [0] = {{"weapons/eft/rsh12/rsh_12_reload_end.ogg",75,0.4}},
            [0.45] = {{"weapons/eft/rsh12/rsh_12_purge_shells.ogg",75,0.4}}
        },
        rejectShell = 0.45,

        grabLeftHand = {[0] = false}
    },

    ["rev_insert"] = {
        index = 97,
        delay = 0.6,

        sound = {
            [0.8] = {{"weapons/eft/rsh12/rsh_12_ammo_in.ogg",75,0.4}}
        },

        limit = 0,

        grabLeftHand = {[0] = false}
    }
}

SWEP.AnimationInspectList = {
    "inspect"
}

SWEP.oldIteration = 0
SWEP.AnimIterationInversion = true

SWEP:Event_Add("SequenceStart","Iteration",function(self)
    self.oldIteration = self.animIteration
end)

function SWEP:PreGetSequenceIndex(sequenceObject,wm)
    local maxIteration = self.Primary.ClipSize
    local sequenceObject = self.sequenceObject

    if sequenceObject then
        local cycle = sequenceObject:GetCycle()

        if sequenceObject.GetSequenceTransform then return sequenceObject:GetSequenceTransform(),cycle end

        if sequenceObject.limit == 0 then return sequenceObject.index,cycle end

        local max = (sequenceObject.limit or self:GetAnimIterationMax())
        local value = self.oldIteration % max + (sequenceObject.add or 0)
        if value < 0 then value = max + value end
        if value > max then value = max - value end

        return sequenceObject.index + value,cycle
    end

    return self.animIteration,1
end

SWEP:Event_Add("Init","Iteration",function(self)
    self.animIteration = 1

    self:SetChamberCount(self:Clip1())
end)

function SWEP:GetAnimIterationMax() return self.Primary.ClipSize end

function SWEP:AttackAnimation()
    self:PlayAnimation("fire")

    if self.AnimIterationInversion then
        self.animIteration = self.animIteration - 1
        if self.animIteration <= 0 then self.animIteration = self:GetAnimIterationMax() end
    end
end

function SWEP:AttackEmptyAnimation()
    self:PlayAnimation("fire_empty")

    if self.AnimIterationInversion then
        self.animIteration = self.animIteration - 1
        if self.animIteration <= 0 then self.animIteration = self:GetAnimIterationMax() end
    end
end

if CLIENT then
    function SWEP:ShootEffect(pos,ang)
        local color = Color(255,225,125)

        local dir = Vector(1,0,0):Rotate(ang)

        self:ShootLight(pos,dir,color)
        self:ShootEffect_Manual(pos,dir,color,{
            gasAround = 1,
            gasForwardScale = 2,
            gasAroundBack = 12
        })
    end
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