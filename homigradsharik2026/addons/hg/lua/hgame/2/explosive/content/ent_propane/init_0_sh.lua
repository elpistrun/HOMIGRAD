local ENT = oop.Reg("ent_propane","base_entity",true)
if not ENT then return INCLUDE_BREAK end

ENT.Category = "Homigrad"
ENT.PrintName = "Propane"
ENT.Spawnable = true

ENT.WorldModel = "models/props_junk/PropaneCanister001a.mdl"
ENT.DrawWeaponSelection = DrawWeaponSelection
ENT.OverridePaintIcon = OverridePaintIcon

ENT.FlyTime = 6
ENT.ConstructPowerRagdoll = 20000

if SERVER then return end

local Rand = math.Rand
local max = math.max

function ENT:Think()
    local start = self:GetNWFloat("Explode",0)
    if start == 0 then return end

    local delay = self:GetNWFloat("ExplodeDelay")
    local k = 1 - (start - CurTime() + delay) / delay

    if not IsValid(self.snd) then
        self.snd = sound.CreatePoint(self,"ambient/gas/steam_loop1.wav",125,"onechannel")
    end

    self.snd:Play()
    self.snd.pitch = 1 + 0.7 * k

    local pos = self:GetPos()
    if not IsValid(self.emitter) then self.emitter = ParticleEmitter(pos)  end
    self.emitter:SetPos(pos)

    local time = RealTime()
    if (self.emitDelay or 0) > time then return end
    self.emitDelay = time + 1 / 45

    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Right(),Rand(-5,5))
    ang:RotateAroundAxis(ang:Up(),Rand(-5,5))

    pos = pos + Vector(0,0,Rand(12,15)):Rotate(ang)

    local part = self.emitter:Add("sprites/heatwave",pos)

    if part then
        part:SetDieTime(Rand(0.1,0.2))
        part:SetVelocity(Vector(0,0,Rand(800,1024)):Rotate(ang))
        
        part:SetColor(255,255,255)
        part:SetStartSize(Rand(5,6))
        part:SetEndSize(Rand(55,75))
        
        part:SetStartAlpha(255)
        part:SetEndAlpha(0)
        part:SetCollide(true)
    end
    
    local part = self.emitter:Add("particles/flamelet" .. math.random(1,3),pos)

    if part then
        part:SetDieTime(Rand(0.2,0.4))
        part:SetVelocity(Vector(0,0,Rand(800,1024)):Rotate(ang))

        part:SetColor(125,125,125)
        part:SetStartSize(Rand(12,15))
        part:SetEndSize(Rand(55,75))

        part:SetRollDelta(Rand(-6,6))
        
        part:SetStartAlpha(Rand(5,15))
        part:SetEndAlpha(0)
        part:SetCollide(true)
    end

    local part = self.emitter:Add(ParticleMatSmoke[math.random(1,#ParticleMatSmoke)],pos)

    if part then
        part:SetDieTime(Rand(4,6))
        part:SetVelocity(Vector(0,0,Rand(800,1024) * 5):Rotate(ang))
        part:SetAirResistance(Rand(700,800))

        part:SetColor(125,125,125)
        part:SetStartSize(Rand(12,15))
        part:SetEndSize(Rand(95,125))

        part:SetRollDelta(Rand(-1,1))
        
        part:SetStartAlpha(0)
        part:SetEndAlpha(0)
        part:SetCollide(true)

        function part:Think(time)
            local k = 1 - max((self.create + 0.25 - time) / 0.25,0)


            part:SetStartAlpha(125 * k)
        end
    end
    
    self:NextThink(CurTime())

    return true
end

function ENT:OnRemove()
    if IsValid(self.emitter) then self.emitter:Finish() end
end