local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

SWEP.CorrectiveDropInfo = {
    bone = "weapon",

    vec = Vector(),
    ang = Angle()
}

function SWEP:CreatePhysicsBox(ent)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS)

    local min,max = self.PhysicsBox[1],self.PhysicsBox[2]

    local x0 = min[1]
    local y0 = min[2]
    local z0 = min[3]

    local x1 = max[1]
    local y1 = max[2]
    local z1 = max[3]

    ent:PhysicsInitConvex({
        Vector( x0, y0, z0 ),
        Vector( x0, y0, z1 ),
        Vector( x0, y1, z0 ),
        Vector( x0, y1, z1 ),
        
        Vector( x1, y0, z0 ),
        Vector( x1, y0, z1 ),
        Vector( x1, y1, z0 ),
        Vector( x1, y1, z1 )
    },"weapon")

    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS)

    ent:EnableCustomCollisions(true)

    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function SWEP:DeterminateUse(ply,trace)
    if not self.PhysicsBox then return trace.Entity == self end
    
    if not util.IntersectRayWithOBB(trace.StartPos,trace.Normal * PlayerDisUse,self:GetPos(),self:GetAngles(),self.PhysicsBox[1],self.PhysicsBox[2]) then return false end

    return true
end