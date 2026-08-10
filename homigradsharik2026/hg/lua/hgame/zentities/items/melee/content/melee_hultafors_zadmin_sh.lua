local SWEP = oop.Reg("wep_melee_hultafors_admin",{"wep_melee_hultafors","wep_lib_attachment","wep_lib_camera"})
if not SWEP then return end

SWEP.AttachmentBoneParent = "bone_mele"

SWEP.MainAttachment = {
    slots = {
        ["0"] = {
            slotPos = Vector(0,0,0),
        },
        ["1"] = {
            name = "silencer",
            slotPos = Vector(0,-5.5,17),
            slots = {
                [0] = {false}
            }
        },
        ["2"] = {
            name = "Scpe",
            slotPos = Vector(0,0,6),
            slots = {
                [0] = {false}
            }
        },
        ["3"] = {
            name = "Mytator",
            slotPos = Vector(0,0,-6),
            slots = {
                [0] = {false},
                ["hultafors_speed"] = {"hultafors_speed"},
                ["hultafors_speed2"] = {"hultafors_speed2"},
                ["hultafors_speed3"] = {"hultafors_speed3"},
                ["hultafors_speed_01"] = {"hultafors_speed_01"}
            }
        }
    }
}

timer.Simple(0,function()
    attachmentGame.ManualCreate(SWEP.MainAttachment.slots["1"].slots,"muzzle_12",Vector(0,-4,17),Angle(0,-90,0),{bone = "bone_mele"})
    attachmentGame.ManualCreate(SWEP.MainAttachment.slots["2"].slots,"scope_mount",Vector(0,0,19),Angle(0,0,0),{bone = "bone_mele"})
end)

SWEP:AttUpdate("Mutators",function(self,class)
    self.Primary.Delay = class.Primary.Delay
    self.AnimationList.attack_primary.delay = class.AnimationList.attack_primary.delay
end,function(self,att,key)
    if att.PrimaryDelay then
        self.Primary.Delay = att.PrimaryDelay
        self.AnimationList.attack_primary.delay = att.PrimaryDelay
    end
end)

WepAtt("hultafors_speed",{PrimaryDelay = 0.5})
WepAtt("hultafors_speed2",{PrimaryDelay = 0.1})
WepAtt("hultafors_speed3",{PrimaryDelay = 0})
WepAtt("hultafors_speed_01",{PrimaryDelay = 10})

SWEP.PrintName = "Hultafors Admin"

SWEP.Primary.Force = 3000
SWEP.Primary.ForceRagdoll = SWEP.Primary.Force * 8000

local graphAngle = {
    {0,Angle()},
    {0.4,Angle(0,-4.333,10)},
    {1,Angle()},
}

local graphCameraAngle = {
    {0.1,Angle()},
    {0.2,Angle(0,5,10)},
    {0.3,Angle(0,5,15)},
    {0.4,Angle(0,-10,-15)},
    {0.6,Angle(0,0,0)},
    {1,Angle()}
}

SWEP.AnimationList["attack_primary"] = {
    index = 6,
    delay = 4,
    
    skip = 0.9,

    load = 0.4,

    attackPosStart = Vector(0,0,0),
    attackPosEnd = Vector(PlayerDisUse * 1,0,0),

    hitboxMins = Vector(-2,-2,-12),
    hitboxMaxs = Vector(2,2,2),

    sound = {
        [0.08] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6,50}},
        [0.22] = {{{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,1,50}},
        [0.24] = {{{"weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing3.ogg"},75,1,50}},
    },

    OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
        wmAngle:Set(math.EvalGraphAngle(self:GetCycle("animation"),graphAngle))
    end,
    
    OnChangeCamera = function(self,pos,ang)
        ang:Add(math.EvalGraphAngle(self:GetCycle("animation"),graphCameraAngle))
    end,

    movementMul = 0.46
}

function SWEP:PreHit(dmgTab,result,surfaceName)
    dmgTab.fakeDown = true

    if dmgTab.target:IsPlayer() then
        if dmgTab.target:Health() - dmgTab.dmg <= 50 then
            dmgTab.headshootForce = true
        end

        dmgTab.effect_headExplode = true

        if dmgTab.hitgroup == HITGROUP_HEAD then
            gibParticles.bloodHitCreate(result.HitPos,result.HitNormal,result.Entity)
            surfaceWorld.CreateDecalBullet(result.HitPos,result.HitNormal,result.Entity,surfaceName)
            sound.Emit(nil,"homigrad/player/headshot/headshot_tp_" .. math.random(1,4) .. ".ogg",75,1,100,result.HitPos)
        end
    else
        dmgTab.headshootForce = true
        dmgTab.explodeHead = true
    end
    
end

function SWEP:PostHit(dmgTab)
    local ent = dmgTab.target:GetDummy()

    if ent.explodeHead or ent.breakHead then
        self:SetPVSVar("IsBlooded",true)
        inventoryGame.SyncItemByEntity(self)
    end

    local vel = Vector(self.Primary.ForceRagdoll,0,0):Rotate(dmgTab.force:GetNormalized():Angle())

 	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local physobj = ent:GetPhysicsObjectNum(i)

		physobj:AddVelocity(vel)
	end
end

SWEP.TextureMaterialName = "models/weapons/arc9/darsu_eft/melee/hultafors_subo"

local recipientFilter = SERVER and RecipientFilter(true)

SWEP.BulletDecalSizeW = 10
SWEP.BulletDecalSizeH = 10

function SWEP:HitPost(result,typeAttack,surfaceName)
    for i = 1,5 do
        if SERVER then
            surfaceWorld.CreateEffectBullet_Net(result.HitPos + Vector(0,math.Rand(-10,10),math.Rand(-10,10)):Rotate(result.HitNormal:Angle()),result.HitNormal,result.Entity,surfaceName,3)
            recipientFilter:AddPVS(result.HitPos)
            recipientFilter:RemovePlayer(self:GetOwner())
            net.Send(recipientFilter)
        else
            surfaceWorld.CreateEffectBullet(result.HitPos,result.HitNormal,nil,surfaceName,3)
        end
    end

    if SERVER then
        Explosive_WreckBuildings(nil,result.HitPos,1,1000,nil,true)
        Explosive_BlastDoors(nil,result.HitPos,1,100)

        Explosive_BlastThatDoor(result.Entity,result.Normal * 1000)
    end
end

SWEP.AttachmentMenuWeaponVec = Vector(0,0,0)
SWEP.AttachmentMenuWeaponAng = Angle(0,0,0)
SWEP.AttachmentMenuWeaponAngRotate = Angle(0,180,0)
SWEP.AttachmentMenuWeaponCenter = Vector(150,0,-9)

function SWEP:PreCalcView(ply,view)
    self:CalcViewAnimation(ply,view)
    self:CalcViewAttachmentMenu(ply,view)

    local cameraWM = self:GetCameraWM(ply)
    if not IsValid(cameraWM) then return end

    self:CalcViewScope(ply,view,view.vec,view.ang,view.fov)
end