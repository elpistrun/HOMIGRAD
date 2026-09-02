local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

local box = Vector(1,1,1)

local tr = {
    mask = MASK_SOLID,
    mins = -box,
    maxs = box,
    filter = {}
}

SWEP.fraction = 0

SWEP:Event_Add("SetupDataTables","CloseWall",function(self)
    self:NetworkVar("Float","CloseWall")
end)

function SWEP:DoCloseFraction(pos,ang,len,dt)
    if self:IsLocal() then
        local owner = self:GetOwner()

        tr.filter[1] = owner:GetDummy()
        tr.filter[2] = nil

        if owner:InVehicle() then
            local eyePos,eyeAng = owner:Eye()

            tr.start = eyePos
            tr.endpos = Vector(len,0,0):Rotate(eyeAng):Add(eyePos)
            
            tr.filter[2] = owner:GetVehicle()
        else
            tr.start = Vector(-len,0,0):Rotate(ang):Add(pos)
            tr.endpos = pos
        end
      
        local result = util.TraceHull(tr)

        if result.Hit then
            self.fraction = math.max(self.fraction,1 - result.Fraction)
        end

        if SERVER then self:SetCloseWall(self.fraction) end
    else
        self.fraction = 0--self:GetCloseWall()
    end

    self.fraction = LerpFrameTimeLess(0.15,self.fraction,0,0.0001,dt)
end