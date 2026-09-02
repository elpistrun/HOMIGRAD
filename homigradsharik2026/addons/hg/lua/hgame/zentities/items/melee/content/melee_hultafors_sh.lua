local SWEP = oop.Reg("wep_melee_hultafors","wep_melee_base")
if not SWEP then return end

SWEP.PrintName = "Hultafors"
SWEP.itemType = "meleePrimary"

SWEP.BlockSecondaryWeapon = true
SWEP.EnableMetalVibration = true

SWEP.dwiPos = Vector(6,-100,-6)
SWEP.dwsAng = Angle(45,180,0)
SWEP.dwsPos = Vector(6,-120,-6)

SWEP.vbwUseWMDropData = true
SWEP.vbwIsHolster = false
SWEP.vbwPos = Vector(-9,-4,-1)
SWEP.vbwAng = Angle(90 + 12,0,0)

SWEP.wmDropData = {model = "models/weapons/arc9/darsu_eft/w_melee_hultafors.mdl",}

SWEP:TableLink("wmData",{
    model = "models/weapons/arc9/darsu_eft/c_melee_hultafors.mdl",
    vec = Vector(0,0,0),
    ang = Angle(0,0,0)
})

SWEP.Primary.Delay = 1.2
SWEP.Primary.DamageType = DMG_BLAST
SWEP.Primary.Damage = 28
SWEP.Primary.DamagePain = 10
SWEP.Primary.DamageImpulse = 1.1
SWEP.Primary.Force = 800
SWEP.Primary.ForceRagdoll = SWEP.Primary.Force * 10
SWEP.Primary.Volume = 1

SWEP.BulletDecalSizeW = 3
SWEP.BulletDecalSizeH = 3

SWEP.Primary.SoundHitFlesh = {
    pitch = 80,
    volume = 1,
    list = {"weapons/melee/hammer_hit_body1.ogg","weapons/melee/hammer_hit_body2.ogg"}
}

SWEP.Primary.SoundHit = {
    pitch = 80,
    volume = 1,
    list = {"weapons/melee/hammer_hit_wall1.ogg","weapons/melee/hammer_hit_wall2.ogg"}
}

SWEP.EnableBulletDecal = true
SWEP.EnableBulletEffect = true

SWEP.AnimationList = {
    ["deploy"] = {
        index = 2,
        delay = 1.3,
        startCycle = 0.2,

        skip = 0.5,

        sound = {
            [0.1] = {
                {{"weapons/melee/bat/sfx_cloth_jacket_leather_run_10.wav"},75,1,70},
                {{"weapons/melee/hammer_charge1.ogg"},75,1,100}
            }
        }
    },
    ["holster"] = {
        index = 1,
        delay = 0.7,
        endCycle = 0.5,

        sound = {
            [0] = {
                {{"weapons/melee/bat/sfx_cloth_jacket_leather_run_08.wav"},75,1,70},
                {{"weapons/melee/hammer_charge2.ogg"},75,1,100}
            }
        }
    },
    ["inspect"] = {
        index = 3,
        delay = 3,

        startCycle = 0.1,
        endCycle = 0.8,

        OnChangeEye = function(self,tpikMatrix,Pos,Ang,wmVector,wmAngle)
            wmVector[3] = wmVector[3] + 0
            wmVector[1] = wmVector[1] + 2
        end,
    }
}

local graphAngle = {
    {0,Angle()},
    {0.4,Angle(0,-4.333,10)},
    {1,Angle()},
}

local graphCameraAngle = {
    {0.1,Angle()},
    {0.2,Angle(-2.5,5,5)},
    {0.3,Angle(-5,5,10)},
    {0.4,Angle(5,-5,-10)},
    {0.6,Angle(0,0,0)},
    {1,Angle()}
}

SWEP.AnimationList["attack_primary"] = {
    index = 6,
    delay = 2,
    
    skip = 0.9,

    load = 0.4,

    attackPosStart = Vector(0,0,0),
    attackPosEnd = Vector(PlayerDisUse * 1,0,0),

    hitboxMins = -Vector(5,5,6),
    hitboxMaxs = Vector(5,5,4),

    sound = {
        [0.08] = {{"weapons/melee/matelbat/bat_draw.wav",75,0.6,90}},
        [0.22] = {{{"weapons/melee/bat/baseball_swing_1st_layer_01.wav","weapons/melee/bat/baseball_swing_1st_layer_02.wav","weapons/melee/bat/baseball_swing_1st_layer_03.wav","weapons/melee/bat/baseball_swing_1st_layer_04.wav"},75,1,80}},
        [0.24] = {{{"weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing1.ogg","weapons/melee/hammer_swing3.ogg"},75,1,100}},
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
    dmgTab.damageDoors = true

    if dmgTab.target:IsPlayer() then
        if dmgTab.target:Health() - dmgTab.dmg <= 90 then
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

function SWEP:PostHit(dmgTab,result,surfaceName)
    local ent = dmgTab.rag or dmgTab.ent or dmgTab.target

    if ent.explodeHead or ent.breakHead then
        self:SetPVSVar("IsBlooded",true)
        inventoryGame.SyncItemByEntity(self)
    end

    if dmgTab.hitedDoor then
        self:GetOwner():ViewPunch(Angle(25,0,0))
    end
end

function SWEP:HitPost(result,typeAttack,surfaceName)
    local info = surfaceWorld.Fast.sound.footkick[surfaceName]
    if not info then return end

    self:EmitLocalSound(info.list[math.random(1,#info.list)],75,1)
end