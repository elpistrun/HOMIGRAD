local ENT = oop.Reg("ent_gas_base","base_entity",true)
if not ENT then return INCLUDE_BREAK end

ENT.PrintName = "Gas"
ENT.Author = "0oa"
ENT.Category = "Homigrad"

ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.EZgasParticle = true

function ENT:CanSee(ent,pos)
    local Tr = util.TraceLine({
        start = self:GetPos(),
        endpos = pos,
        filter = {self,ent},
        mask = MASK_SHOT
    })

    return not Tr.Hit
end

if SERVER then return end

HomigradGas = HomigradGas or {}
function ENT:Initialize()
    self.delayEmit = RealTime()
    
    HomigradGas[#HomigradGas + 1] = self
    self.ID = #HomigradGas
end

function ENT:OnRemove()
    table.remove(HomigradGas,self.ID)

    for id,ent in pairs(HomigradGas) do ent.ID = id end
end

// Draw World

local SetMaterial = render.SetMaterial
local DrawSprite = render.DrawSprite

local angZero = Angle(0,0,0)
local size = Vector(3,3,3)

local cos = math.cos
local sin = math.sin

local vecChange = Vector()
local SetDrawColor = surface.SetDrawColor

local random,Rand = math.random,math.Rand

local tr = {}
local TraceLine = util.TraceLine

GasParticleEmitters = GasParticleEmitters or {}

ENT.delayEmitMin = 0.4
ENT.delayEmitMax = 0.5

function ENT:DrawTranslucent()
    local time = RealTime()
    if self.delayEmit > time then return end
    self.delayEmit = time + Rand(self.delayEmitMin,self.delayEmitMax)

    local pos = self:GetPos()

    local emitter = self.emitter

    if not IsValid(emitter) then
        emitter = ParticleEmitter(pos)
        self.emitter = emitter

        self.emitterParticles = {}
    end
    
    emitter:SetPos(pos)

    self:EmitParticles(emitter,self:GetNWFloat("Size",0),pos)
end

function ENT:OnRemove()
    if IsValid(self.emitter) then
        for part in pairs(self.emitterParticles) do
            part:Remove()
        end

        self.emitter:Finish()
    end
end

function ENT:EmitParticles(emitter,size,pos)
    local gravity = ParticleGravity / 12

    for i = 1,random(1,2) do
        local part = emitter:Add(ParticleMatSmoke[random(1,#ParticleMatSmoke)],pos)
        if not part then continue end

        local dir = Vector(1,0,0):Rotate(Angle(Rand(-75,75),Rand(-180,180),0)):Mul((size * 4 + Rand(-125,125)))
        dir:Rotate(Angle(Rand(-75,75),Rand(-125,125),0))

        part:SetDieTime(Rand(3.5,4))
        local r = Rand(20,30)
        part:SetColor(r,r,r)

        part:SetStartAlpha(random(75,75)) part:SetEndAlpha(random(25,35))
        part:SetStartSize(Rand(size / 3,size / 2)) part:SetEndSize(size * 2 + Rand(-50,50))

        part:SetCollide(true)
        part:SetLighting(true)

        part:SetRoll(Rand(-6000,6000))
        part:SetVelocity(dir) part:SetAirResistance(Rand(300,400))
        part:SetBounce(0.5)
        part:SetGravity(gravity)
        part:SetPos(pos)

        self.emitterParticles[part] = true
    end

    for part in pairs(self.emitterParticles) do
        if not IsValid(part) then self.emitterParticles[part] = nil continue end

        local dir = (pos - part:GetPos())
        local dis = dir:Length()
        dir:Normalize()
        dir:Mul(Rand(75,200) * (dis <= size / 3 and -1 or 1 ))

        part:SetVelocity(part:GetVelocity() + dir)
    end
end

// Calculate

local NextThink = 0
local gasesCalculate,gases,gasesSet = {},{},{}

local id

local random,Rand = math.random,math.Rand
local abs,cos,sin = math.abs,math.cos,math.sin
local min,max = math.min,math.max
local Clamp = math.Clamp

hook.Add("Think","Gas",function()
    local Time = RealTime()

    if not id and NextThink < Time then
        NextThink = Time + 0.25

        id = 1
        for k in pairs(gasesCalculate) do gasesCalculate[k] = nil end
    end

    if id then
        local localPlayer = LocalPlayer()
        local localPlayerPos = localPlayer:EyePos()

        local start = SysTime()

        while true do
            if start - SysTime() > 1 / 10 then break end

            local ent = HomigradGas[id]

            if ent and not IsValid(ent) then//WTF
                table.remove(HomigradGas,id)
                for id,ent in pairs(HomigradGas) do ent.ID = id end

                continue
            end

            if not ent then//End
                id = nil
                gasesSet = gasesCalculate

                break
            end

            //

            local size = ent:GetNWFloat("Size")
            local dis = 1 - min(ent:GetPos():Distance(localPlayerPos),size) / size

            if dis > 0 and ent:CanSee(localPlayer,localPlayerPos) then
                local className = ent:GetClass()

                if dis > (gasesCalculate[className] or 0) then gasesCalculate[className] = dis end
            end

            id = id + 1
        end
    end
end)


// Draw HUD

hook.Add("HUDPaint","Gas",function()
    local w,h,time = ScrW(),ScrH(),RealTime()

    for className,set in pairs(gasesSet) do
        gases[className] = LerpFT(0.25,gases[className] or 0,min(set * 2,1))
    end

    for className,dis in pairs(gases) do
        if not gasesSet[className] then gases[className] = LerpFT(0.25,gases[className],0) end
        //draw.SimpleText(className .. " " .. math.floor(dis * 100),"HS.12")
        if dis <= 0 then continue end

        local class = oop.listClass[className][1]

        class:DrawHUD(w,h,time,dis)
    end
end)

local GradientUp,GradientDown = draw.GradientUp,draw.GradientDown
local SetBG,BGScale = surface.SetBG,draw.BGScale

function ENT:DrawHUD(w,h,time,k)
    surface.SetDrawColor(25,25,25,150 * k)
    surface.DrawRect(0,0,w,h)

    for i = 4,5 do
        SetBG("points" .. i .. "0")

        BGScale(0,0,w,h,Clamp(abs(cos(time + Rand(-1,1))) * 25,10,25))
    end

    local size = h / 2

    surface.SetDrawColor(0,0,0,255 * k)

    GradientUp(0,0,w,size)
    GradientDown(0,h - size,w,size + 1)
end