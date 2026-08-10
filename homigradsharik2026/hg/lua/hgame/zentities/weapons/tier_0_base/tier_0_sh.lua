local SWEP,CLASS = oop.Reg("hg_wep",{"hg_wep_base","tpik_animate","wep_lib_camera","wep_lib_attachment"},true)--пашол нахуй
if not SWEP then return INCLUDE_BREAK end

CLASS.NonRegisterGMOD = true

SWEP.AttachmentMenuWeaponAngRotate = Angle(0,90,0)

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)

SWEP.PrintName 				= "TPIK WEAPON"
SWEP.Author 				= "0oa"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.HoldType = "ar2"

SWEP.SupportCustomAttack = true

SWEP.itemType = "weapon"

SWEP.PhysicsBox = {-Vector(12,1,2.5),Vector(16,1,1)}

SWEP.CorrectiveDropInfo = {
    bone = "weapon",

    ang = Angle(0,-90,0),
    vec = Vector(0,-19,0)
}

SWEP:TableLink("wmData",{
    center = {Vector(-19,4.3,3),Angle(0,0,0)}
})

SWEP:TableLink("wmFastData",{
    center = {Vector(-19,4.3,3),Angle(0,0,0)}
})

SWEP.Primary.ShellSoundOut = "weapons/eft/ak/ak74_round_out.ogg"
SWEP.Primary.SoundEmpty = "weapons/eft/ak/ak74_trigger_empty.wav"

SWEP.Primary.DefaultClip = 0
SWEP.BulletDamageMul = 1

SWEP.InvSnd = {
    list = {
        "arc9_eft_shared/weap_bolt_out.ogg"
    }
}
SWEP.InvMoveFromSnd = {
    list = {
        "arc9_eft_shared/weap_ar_pickup.ogg"
    }
}

SWEP.InvMoveToSnd = {
    list = {
        "arc9_eft_shared/weap_bolt_out.ogg"
    }
}

if SERVER then
    function SWEP:EmitLocalSound(sndName,level,volume,pitch,pos)
        local src = IsValid(self:GetOwner()) and self:GetOwner() or self
        sound.EmitNET(src:EntIndex(),sndName,level,volume,pitch,pos or self:GetPos())
        net.SendOmit(src)
    end
else
    function SWEP:EmitLocalSound(sndName,level,volume,pitch,pos)
        local src = IsValid(self:GetOwner()) and self:GetOwner() or self
        sound.Emit(src:EntIndex(),sndName,level,volume,pitch,pos or self:GetPos())
    end
end

RIFLE_DEPLOY_TIME = 0.8
RIFLE_DEPLOY_SKIP = 0.7
RIFLE_HOLSTER_TIME = 0.5

RIFLE_UNLOAD_TIME = 1.5
RIFLE_UNLOAD_SKIP = 0.6
RIFLE_LOAD_TIME = 1.5
RIFLE_LOAD_SKIP = 0.9

PISTOLRIFLE_DEPLOY_TIME = 0.7
PISTOLRIFLE_DEPLOY_SKIP = 0.5
PISTOLRIFLE_HOLSTER_TIME = 0.5

PISTOLRIFLE_LOAD_TIME = 1.17
PISTOLRIFLE_UNLOAD_TIME = 1.17

RIFLE_CHAMBER = 1

PISTOL_DEPLOY_TIME = 0.6
PISTOL_HOLSTER_TIME = 0.5