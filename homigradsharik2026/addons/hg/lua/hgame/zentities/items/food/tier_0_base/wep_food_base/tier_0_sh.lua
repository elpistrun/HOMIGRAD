local SWEP,CLASS = oop.Reg("wep_food_base","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.IsFood = true

SWEP.Category = L("weapon_category_food")
SWEP.Spawnable = true
CLASS.NonRegisterGMOD = true

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.HoldType = "normal"

SWEP.HandBack = 0
SWEP.HandRight = 0

SWEP.anim = 0

SWEP.DelayEat = 1
SWEP.MaxValue = 4

SWEP.Slot = 5
SWEP.SlotPos = 10

SWEP.itemType = "other"

SWEP.InvMoveSnd = InvMoveSndPlastic

SWEP.dwsPos = Vector(0.5,-100,-3.5)
SWEP.dwsAng = Angle(0,0,0)

function SWEP:EmitSnd(snd)
    sound.Emit(self:EntIndex(),TypeID(snd) == TYPE_TABLE and snd[math.random(1,#snd)] or snd,75,1,math.random(95,105),self:GetPos())
end

function SWEP:EatValue(ent)
    if not SERVER then return end

    ent.hungry = math.min((ent.hungry or 10) + (self.HungryAdd or 0) / self.MaxValue,10)
    ent.blood = math.min((ent.blood or 5000) + 30 * (self.HungryAdd or 0) / self.MaxValue,5000)
    ent:SetStamina((ent.stamina or 100) + (self.StaminaAdd or 0) / self.MaxValue)

    if self.BreathRelief and ent.RelieveBreath then
        ent:RelieveBreath(self.BreathRelief / self.MaxValue)
    end
end

SndEat = SndEat or {}
for i = 1,9 do SndEat[i] = "snd_jack_eat" .. i .. ".ogg" end

SndEatWater = SndEatWater or {}
for i = 1,2 do SndEatWater[i] = "snd_jack_drink" .. i .. ".ogg" end

SWEP.SndEet = SndEat

if SERVER then
    util.AddNetworkString("eat")
else
    net.Receive("eat",function()
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end

        ent:EatValue()
    end)

    SWEP.ParticleColor = Color(255,255,255)
    SWEP.ParticleMat = Material("particle/particle_noisesphere")
    
    local random,Rand = math.random,math.Rand

    function SWEP:EatValue()
        local col = self.ParticleColor
        local r,g,b,a = col.r,col.g,col.b,col.a

        local data = self.wmFastData
        
        local pos,ang = self:Transform_GetFromRagdoll(self:GetOwner(),data.vec,data.ang)
        if not pos then return end//wtf
        
        local emitter = ParticleEmitter(pos)

        local dir = ang:Up()
        dir[3] = dir[3] + 2
        dir:Normalize()

        for i = 1,random(3,5) do
            local part = emitter:Add(self.ParticleMat,pos)
            if not part then continue end
    
            local dir = dir:Clone():Mul(100)
            dir:Rotate(Angle(Rand(-75,75),Rand(-125,125),0))
    
            part:SetDieTime(Rand(1,2))
    
            part:SetStartAlpha(random(125,155)) part:SetEndAlpha(255)
            part:SetStartSize(Rand(1,2)) part:SetEndSize(Rand(10,12))
    
            part:SetColor(r,g,b,a)
            part:SetRoll(Rand(-300,300))
            part:SetVelocity(dir) part:SetAirResistance(Rand(25,75))
            part:SetGravity(ParticleGravity)
            part:SetPos(pos)
        end
    
        emitter:Finish()
    end
end

SWEP:Event_Add("Think","Main",function(self)
    local owner = self:GetOwner()
    local time = CurTime()
    local hold

    if SERVER then
        self:SetNWBool("Eat",owner:KeyDown(IN_ATTACK))
        hold = self:GetNWBool("Eat")
    end

    if self:GetNWBool("Eat") then
        self.anim = LerpFT(0.5,self.anim,1)
    else
        self.anim = LerpFT(0.5,self.anim,0)
    end

    if SERVER then
        if hold ~= self.oldHold then
            self.delayEat = time + 1
        end

        if hold and self.delayEat < time then
            self.delayEat = time + self.DelayEat

            if self:EatValue(owner) ~= false then
                self.Value = (self.Value or self.MaxValue) - 1

                event.Call("Player Eat",self:GetOwner(),self)

                net.Start("eat")
                net.WriteEntity(self)
                net.SendPVS(self:GetPos())

                self:EmitSnd(self.SndEet)
                owner:ViewPunch(Angle(-2.5,0,math.Rand(-1,1)))

                if self.Value <= 0 then
                    local data = self.wmFastData
                    local pos,ang = self:Transform_GetFromRagdoll(self:GetOwner(),data.vec,data.ang)
                    DropProp(self.WorldModel,self.wmScale,pos,ang,Angle(0,owner:EyeAngles()[2],0):Forward():Mul(75):Add(Vector(0,0,75)),Vector(),collideSnd)

                    self:Remove()
                else
                    self:EmitSnd(self.SndEet)
                end
            end
        end

        self.oldHold = hold
    end

end)

function SWEP:DoBones(ply,link,tpikMatrix)
    local anim = self.anim

    if CLIENT and GetViewEntity() == ply and RenderIsMe() then
        ply:AddBoneAng("rupperarm",Angle(0,-25,20):Mul(anim))
        ply:AddBoneAng("rforearm",Angle(-24,-120 + self.HandBack,20):Mul(anim))
        ply:AddBoneAng("rhand",Angle(-20,self.HandRight,0):Mul(anim))
    else
        if ply.Crouching and ply:Crouching() then
            ply:AddBoneAng("rupperarm",Angle(0,-25,20):Mul(anim))
            ply:AddBoneAng("rforearm",Angle(-20,-15 + self.HandBack,0):Mul(anim))
            ply:AddBoneAng("rhand",Angle(-25,self.HandRight,0):Mul(anim))
        else
            ply:AddBoneAng("rupperarm",Angle(0,-25,20):Mul(anim))
            ply:AddBoneAng("rforearm",Angle(-30,-120 + self.HandBack,0):Mul(anim))
            ply:AddBoneAng("rhand",Angle(-0,self.HandRight,0):Mul(anim))
        end
    end

    self:SetupBones_WorldModel_ByHand(ply,link)
end

FoodCategories = {}

SWEP:Event_Add("Construct","Food Category",function(class)
    if class[1].ClassName == "wep_food_base" then return end//we
    
    FoodCategories[class[1].ClassName] = true
end)

function SWEP:InvSelectPanelDrawOver(w,h,icon,item)
    local text = ""

    if self.HungryAdd then text = text .. "Убирает голод\n" end
    if self.StaminaAdd then text = text .. "Восстанавливает стамину\n" end
    
	icon:DrawTip(text)
end
