local SWEP = oop.Get("wep_bow")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 8,
        delay = 0.7,
        startCycle = 0.45,
        endCycle = 0.9,

        deploy = true,

        Start = function(self)
            self.parent:EmitLocalSound("weapons/bow/deploy.ogg",75,0.65,100)
        end
    },
    ["holster"] = {
        index = 0,
        delay = 0.56,

        inversion = true,

        endless = true,
        holster = true
    },

    ["prefire"] = {
        index = 5,
        delay = 0.9,

        canFireCycle = 0.7,

        endCycle = 0.8,

        canFight = true,
        endless = true,

        showArrow = true,

        Start = function(self)
            self.parent:GetSoundEntity():StopSound("weapons/bow/losefire.ogg")
            self.parent:EmitLocalSound("weapons/bow/prefire.ogg",75,0.65,90)
        end, 

        fire = true
    },

    ["losefire"] = {
        index = 5,
        delay = 0.4,

        canFight = true,
        inversion = true,

        Start = function(self)
            self.parent:GetSoundEntity():StopSound("weapons/bow/prefire.ogg")
        end,

        fire = true
    },

    ["fire"] = {
        index = 6,
        delay = 0.5,

        endCycle = 0.5,

        noFight = true,
        Start = function(self)
            self.parent:EmitLocalSound("weapons/bow/fire" .. math.random(1,3) .. ".ogg",75,1,100)
        end,

        hideArrow = {
            [0] = true,
        },

        fire = true
    },

    ["insert"] = {
        index = 6,
        delay = 0.5,

        startCycle = 0.4,

        noFight = true,
        endless = true,

        Start = function(self)
            self.parent:EmitLocalSound("weapons/bow/insert.wav",75,1,100)
        end,

        hideArrow = {
            [0] = false,
        },

        fire = true,
    }
}

function SWEP:OnDeploy()
    self:PlayAnimation("deploy")
end

function SWEP:OnHolster()
    self:PlayAnimation("holster")
end

function SWEP:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle)
    local k = 1 - self:GetStandAnimK()

    if self:IsSequencePlaying("deploy") then
        k = math.min(k / 3,1)
    end

    k = math.ease.InSine(k)

    wmAngle[1] = Lerp(k,wmAngle[1],60)
    wmVector[3] = Lerp(k,wmVector[3],-30)

    local cycle = self:IsSequencePlaying("prefire",true)

    if not cycle then
        cycle = self:IsSequencePlaying("losefire",true)

        if cycle then
            cycle = 1 - cycle
        end
    end

    if cycle then
        wmAngle[3] = Lerp(cycle,wmAngle[3],-60)
        wmAngle[2] = Lerp(cycle,wmAngle[2],0)

        wmVector[1] = Lerp(cycle,wmVector[1],17)
        wmVector[2] = Lerp(cycle,wmVector[2],-3)
        wmVector[3] = Lerp(cycle,wmVector[3],-7)
    end
end

local matrix_none = Matrix()

function SWEP:SetupModelPost(wm)
    if not IsValid(self) then return end
    
    local sequenceObject = self.sequenceObject

    if sequenceObject and (sequenceObject.hideArrow or sequenceObject.showArrow) then
        if sequenceObject:GetMark("hideArrow") then wm:PasteBoneMatrix(44,matrix_none) end
    elseif self:Clip1() <= 0 then
        wm:PasteBoneMatrix(44,matrix_none)
    end
end
