local SHELL = oop.Reg("shell","custom_entity",true)
if not SHELL then return INCLUDE_BREAK end

local MAX = 100

SHELL.airFriction = 2.6

SHELL:Event_Add("Init","Main",function(self)
    local mdl = CSM.CreateClientSideModel(self.ShellModel)
    mdl:CallOnRemove("custom_entity_shell",function() self:Remove() end)
    mdl:SetPos(self.pos)

    self.mdl = mdl

    self:SetList("think",true)
    self:SetList("cleanup",true)

    self.start = RealTime()

    self.startPos = self.pos:Clone()
end)

temporary.Create("shell",
function(data)
    net.WriteString(data[1])
    net.WriteVector(data[2])
    net.WriteVector(data[3])
end,
function(data)
    data[1] = net.ReadString()
    data[2] = net.ReadVector()
    data[3] = net.ReadVector()
end,
function(data)
    CreateShell(data[1],data[2],data[3])
end)

customEnts.list["class_shell"] = customEnts.list["class_shell"] or {}

local Fast = surfaceWorld.Fast.sound

function CreateShell(name,pos,dir,filter)
    if CLIENT and #customEnts.list["class_shell"] > MAX then
        customEnts.list["class_shell"][1]:Remove()
    end

    if CLIENT then
        local shell = customEnts.Create("shell")

        name = ammoGame.callibreIndex[name]

        local config = ammoGame.config[name]

        shell.ShellModel = config.ShellModel
        shell.ShellSound = Fast["shell_" .. config.ShellSound]

        shell.pos = pos
        shell.dir = dir

        shell:Spawn()
        shell:Think(0)
    else
        if filter == false then return end
        
        temporary.OutputFilter("shell",filter,name,pos,dir)
    end
end

local skinWidth = 0.001

function SHELL:SetMatrix()
    local time = RealTime()

    local pos = self.pos
    local mdl = self.mdl

    self.lerpPos = self.lerpPos or self.startPos:Clone()
    self.lerpPos:LerpFT(0.5,self.pos)

    --self.lerpPos = LerpFT(0.5,self.lerpPos or pos,Lerp(1 - math.max(time - self.start + self.delay,0) / self.delay,self.startPos,self.pos))
    mdl:SetPos(self.lerpPos)

    local ang = self.dir:Angle()
    ang:RotateAroundAxis(ang:Up(),90)
    ang:RotateAroundAxis(ang:Right(),360 * math.cos(self.id + (pos[1] + pos[2] + pos[3]) / 100))
    mdl:SetAngles(ang)
end

local abs = math.abs

local tr = {
    mask = MASK_SOLID,
    filter = function(ent)
        if ent:IsPlayer()  or ent:IsNPC() or ent:IsRagdoll() then return false end

        return true
    end,
    output = {}
}

function SHELL:Think(deltaTime)
    if not IsValid(self.mdl) then self:Remove() return end

    local time = RealTime()

    local pos = self.pos
    local mdl = self.mdl

    if abs(pos[1]) > 32000 or abs(pos[2]) > 32000 or abs(pos[3]) > 32000 then self:Remove() return end

    --if not pass and time < self.start + self.delay then self:SetMatrix() return end

    deltaTime = deltaTime or time - self.start
    if deltaTime == 0 then deltaTime = 1 / 60 end

    self.start = time
    self.delay = math.Rand(1 / 29,1 / 31)
    self.startPos = pos:Clone()

    local dir = self.dir

    dir:Add(Vector(0,0,-600):Mul(deltaTime))

    local airFriction = self.airFriction * deltaTime
    dir[1] = dir[1] - dir[1] * airFriction
    dir[2] = dir[2] - dir[2] * airFriction

    local dirDelta = dir * deltaTime

    tr.start = pos
    tr.endpos = pos + dirDelta

    local result = util.TraceLine(tr)

    pos:Set(result.HitPos)

    if result.Hit then
        local hitNormal = result.HitNormal
        
        pos:Add(hitNormal * skinWidth)

        hitNormal = hitNormal:Add(dirDelta:GetNormalized():Mul(math.Rand(0.5,0.8)))
        hitNormal:Normalize()

        self.dir = (hitNormal * self.dir:Length() * math.Rand(0.4,0.6))

        self:Collide(result)
    end

    if result.Fraction <= 0.1 then
        self:SetList("think",false)
    end

    self:SetMatrix()
end

function SHELL:OnRemove()
    if IsValid(self.mdl) then self.mdl:Remove() end
end

function SHELL:Collide(tr)
    if RenderView.origin:Distance(self.pos) > 800 then return end

    if not self.ShellSound or (self.delayEmit or 0) > RealTime() then return end
    self.delayEmit = RealTime() + 0.2

    local surfaceName = surfaceWorld.GetSurfaceName(tr.SurfaceProps)
    if surfaceName == "no_decal" then return end
    
    local list = self.ShellSound[surfaceName]
    if not list then print("missing shell surface->" .. tostring(surfaceName)) return end

    list = list.list

    sound.Emit(self.mdl,list[math.random(1,#list)],55,0.8,100,self.pos,nil,nil,CHAN_ITEM)
end