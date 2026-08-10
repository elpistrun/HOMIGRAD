local SWEP = oop.Get("weapon_flashlight")
if not SWEP then return end

SWEP.AnimationList = {
    ["deploy"] = {
        index = 4,
        delay = 0.3,

        endCycle = 0.4,

        deploy = true
    },

    ["holster"] = {
        index = 5,
        delay = 0.3,

        holster = true,
        endless = true,
        inversion = false
    }
}

local MatrixLocal = Matrix()
MatrixLocal:SetTranslation(Vector(-12,-6.5,7))
MatrixLocal:SetAngles(Angle(8,-13,0))
local ang_zero = Angle()

local MatrixSet = Matrix()
local MatrixLerp = Matrix()

local VecSet,AngSet = Vector(),Angle()

function SWEP:SetupBones_DoAnimation(tpikMatrix,Pos,Ang)
    self.followToActiveWeapon = nil

    local wm = self.wm
    if not IsValid(wm) then return end

    local wep = tpikMatrix.link:GetActiveWeapon()
    
    local passBlock

    if IsValid(wep) and (wep.SetupBones_DoAnimation) then
        if not IsValid(wep.wm) then return end

        passBlock = wep.SecondaryWeaponDontFollowHand

        local sequenceObject = wep.sequenceObject
        
        if sequenceObject and sequenceObject.secondaryWeaponFollow then
            pass = sequenceObject:GetMark("secondaryWeaponFollow",sequenceObject.secondaryWeaponFollow)
        end
    else
        passBlock = true
    end

    if passBlock then
        local muzzlePos,muzzleAng = self:GetShootMatrix(wm)

        self:DoCloseFraction(muzzlePos,muzzleAng,16,tpikMatrix.deltaTime)

        Pos:Sub(muzzleAng:Forward():Mul(16 * self.fraction))

        return
    end

    self.followToActiveWeapon = true
    
    IsFirstFrame(wep,"DoTPIKFrame")
    wep:DoTPIK(tpikMatrix.ent,tpikMatrix.link,tpikMatrix)

    tpikMatrix.wm = wm
    
    local matLeft = wep:DoTPIKLeftHandFingers(tpikMatrix.ent,wep.wm,true)
    if not matLeft then return end

    local sequenceObject = wep.sequenceObject

    MatrixSet:Set(matLeft)

    if not sequenceObject or not sequenceObject.fire then
        local pos,ang = wep:GetShootMatrix()
        ang[3] = 0

        MatrixSet:SetAngles(ang)
    end

    MatrixSet:Mul(MatrixLocal)

    MatrixSet:SetXYZ_PYR(VecSet,AngSet)

    local animK = wep.stateHandling == "holster" and 1 or wep:GetStandAnimK()
    animK = math.max(animK - 0.5,0) / 0.5
    animK = math.ease.InSine(animK)

    Pos:Lerp(animK,VecSet)
    Ang:Lerp(animK,AngSet)

    tpikMatrix.leftDown = Lerp(animK,tpikMatrix.leftDown,160)
end--пиздец, оно воркает и дрипает

local HSetupBones_DoAnimation_Immersive = SWEP.SetupBones_DoAnimation_Immersive

function SWEP:SetupBones_DoAnimation_Immersive(...)
    if self.followToActiveWeapon then return end
    
    HSetupBones_DoAnimation_Immersive(self,...)
end