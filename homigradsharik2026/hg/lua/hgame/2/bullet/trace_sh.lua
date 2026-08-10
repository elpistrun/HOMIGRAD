local BULLET = oop.Get("bullet")
if not BULLET then return end

BULLET.LifeTime = 60
BULLET.RemoveOnHit = true

local AIR_DENSITY = 1.225
local GRAVITY_VEC = Vector(0,0,-9.81)

local DRAG_TABLE = {
    ["G1"] = {
        {0.00,0.180},
        {0.25,0.175},
        {0.50,0.160},
        {0.75,0.170},
        {0.90,0.270},
        {0.95,0.400},
        {1.00,0.550},
        {1.05,0.580},
        {1.10,0.510},
        {1.20,0.500},
        {1.30,0.470},
        {1.40,0.440},
        {1.50,0.420},
        {2.00,0.365},
        {3.00,0.310},
        {4.00,0.270}
    },
    ["G7"] = {
        {0,0,0.088},
        {0.5,0.085},
        {0.75,0.090},
        {0.90,0.170},
        {0.95,0.240},
        {1.00,0.380},
        {1.05,0.350},
        {1.10,0.300},
        {1.20,0.285},
        {1.30,0.270},
        {1.40,0.250},
        {1.50,0.235},
        {2.00,0.195},
        {3.00,0.175},
        {5.00,0.165}
    },
    ["G5"] = {
        {0.00,0.165},
        {0.50,0.160},
        {0.75,0.175},
        {0.90,0.300},
        {0.95,0.420},
        {1.00,0.610},
        {1.05,0.750},
        {1.10,0.450},
        {1.20,0.430},
        {1.30,0.395},
        {1.40,0.360},
        {1.50,0.340},
        {2.00,0.280},
        {3.00,0.235}
    },
    ["GS"] = {
        {0.00,0.100},
        {0.50,0.100},
        {0.80,0.120},
        {0.90,0.200},
        {1.00,0.400},
        {1.10,0.380},
        {1.20,0.350},
        {1.50,0.300},
        {2.00,0.250},
        {3.00,0.210},
        {4.00,0.200},
        {5.00,0.190}
    }
}

function BULLET:GetTransformDir(ft)
    local velocity = self.dir:Clone()
    local speed = velocity:Length()

    local area = math.pi * ((self.diameter / 1000 / 2) ^ 2)
    local massKg = self.mass / 1000

    local dragCoeff = self.dragCoeff or 1

    if self.dragModelName then
        dragCoeff = math.EvalGraph(speed / SOUND_SPEED,DRAG_TABLE[self.dragModelName])
    end

    -- Сопротевление воздуха
    local dragForceMag = 0.5 * AIR_DENSITY * (speed ^ 2) * area * dragCoeff

    if self.dragModelName then
        dragForceMag = (dragForceMag / massKg) / self.balisticCoeff
    else
        dragForceMag = (dragForceMag / massKg)
    end

    local dragAccel = -velocity:GetNormalized() * dragForceMag

    -- Сила Ветра
    local windVec = GetWind(self.startTick)
    local windSpeed = windVec:Length()
    local windAccel = Vector(0,0,0)

    if windSpeed > 0 then
        local windForceMag = 0.5 * AIR_DENSITY * (windSpeed ^ 2) * area

        windAccel = windVec:GetNormalized() * (windForceMag / massKg * dragCoeff)
    end

    -- Результат

    ft = ft / BALISTIC_SCALE * self.multiplySpeed

    local totalAccel = GRAVITY_VEC * BALISTIC_SCALE + dragAccel + windAccel
    
    return velocity:Mul(ft):Div(UNITS_TO_METERS) * BALISTIC_SCALE, totalAccel:Mul(-ft)
end

function BULLET:ThinkPhysics()
    if (self.startTime or 0) + self.LifeTime < CurTime() then self:Remove() return end

    local ft = TickInterval() * HostTimeScale

    if CLIENT then
        self:PhysicalSimulation(FrameTime())
    else
        self:PhysicalSimulation(ft)
    end
end

BULLET.AlwaysThinkLocalPhysics = true

function BULLET:Think()
    if not self:GetPVSVar("Hit") and (self.AlwaysThinkLocalPhysics or self:IsLocal()) then self:ThinkPhysics() end

    self:Event_Call("Think")
end

function BULLET:SetDir(dir)
    self.startDir = dir:Clone()
    self.dir = dir
end

function BULLET:SetAngularDir(dir)
    self.angularDir = dir:Clone()
end

local empty = {}
local tr = hitBoxGame.CreateTraceTable()

local VecSetStart,VecSetEnd = Vector(),Vector()

function BULLET:DoTrace(dir)
    tr.ClearFilterTrace()
    
    for key,value in pairs(self.filterTrace or empty) do
        tr.filterTrace[key] = value
    end

    VecSetStart:Set(self.pos)
    VecSetEnd:Set(self.pos):Add(dir)

    tr.start = VecSetStart
    tr.endpos = VecSetEnd

    return self:DoTraceLine(tr)
end

local VecSetStart,VecSetEnd = Vector(),Vector()
local VecSet = Vector()

function BULLET:DoTraceLine(tr)
    local manual = self.traceManual

    if manual then
        local start,endpos = tr.start,tr.endpos

        VecSetStart:Set(start)
        VecSetEnd:Set(endpos)

        for i = 1,#manual do
            start:Set(VecSetStart):Add(manual[i])
            endpos:Set(VecSetEnd):Add(manual[i])

            --debugoverlay.Line(start,endpos,0.1)

            local result = hitBoxGame.LagTraceLine(tr,self.renderTime,self.debug)

            if result.Hit then return result end
        end

        start:Set(VecSetStart)
        endpos:Set(VecSetEnd)

        return tr
    else
        return hitBoxGame.LagTraceLine(tr,self.renderTime,self.debug)
    end
end

function BULLET:DoPenetration(result,add,sub)
    if result.StartPos:Distance(result.HitPos) <= 0.0001 then return true end
    
    local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)

    if IsValid(result.Entity) and (util.EntityIsGlass(result.Entity) or surfaceName == "glass") and result.Entity:Health() <= 100 then
        self.filterTrace[result.Entity] = true

        if SERVER then
            local dmgTab = CreateDamageTab(result.Entity,self.attacker,self.weapon,result.Entity:Health() + 10000,DMG_BLAST)

            result.Entity:TakeDamageTab(dmgTab)
        end

        result.Entity = nil
        
        self.pos:Set(result.HitPos)
        self.dir:Sub(result.StartPos - result.HitPos)

        return false
    end

    if IsValid(result.Entity) and result.Entity:GetCollisionGroup() == COLLISION_GROUP_DEBRIS then
        self.filterTrace[result.Entity] = true
        
        self.pos:Set(result.HitPos)
        self.dir:Sub(result.StartPos - result.HitPos)

        return false
    end

    return true
end

function BULLET:DoHitEnd(traceResult)
    self:Event_Call("HitEnd",traceResult)
end
