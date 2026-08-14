local PLAYER = FindMetaTable("Player")

local fakePlayers = {}
local standMins = Vector(-16,-16,0)
local standMaxs = Vector(16,16,72)

local function SetFakeState(ply,rag)
    local active = IsValid(rag)

    ply:SetDummy(active and rag or nil)
    ply:SetNWBool("fake",active)
    ply:SetNWBool("Fake",active)
    ply:SetNoDraw(active)
    ply:SetNotSolid(active)
    ply:DrawViewModel(not active)

    if active then
        ply:SetMoveType(MOVETYPE_NONE)
    else
        ply:SetMoveType(MOVETYPE_WALK)
    end
end

local function CopyPlayerPose(ply,rag)
    for physID = 0,rag:GetPhysicsObjectCount() - 1 do
        local phys = rag:GetPhysicsObjectNum(physID)
        local bone = rag:TranslatePhysBoneToBone(physID)

        if not IsValid(phys) or not bone then continue end

        local pos,ang = ply:GetBonePosition(bone)
        if pos and ang then
            phys:SetPos(pos,true)
            phys:SetAngles(ang)
        end

        phys:SetVelocity(ply:GetVelocity())
        phys:Wake()
    end
end

function PLAYER:EnterFake(force)
    if not self:Alive() or self:InVehicle() or self:InFake() then return false end
    if not util.IsValidRagdoll(self:GetModel()) then return false end

    local rag = ents.Create("prop_ragdoll")
    if not IsValid(rag) then return false end

    rag:SetModel(self:GetModel())
    rag:SetPos(self:GetPos())
    rag:SetAngles(self:GetAngles())
    rag:SetSkin(self:GetSkin())
    rag:SetColor(self:GetColor())
    rag:SetNW2Vector("modelcolor",self:GetPlayerColor())

    for id = 0,self:GetNumBodyGroups() - 1 do
        rag:SetBodygroup(id,self:GetBodygroup(id))
    end

    rag:Spawn()
    rag:Activate()

    if not IsValid(rag:GetPhysicsObject()) then rag:Remove() return false end

    CopyPlayerPose(self,rag)

    rag:SetController(self)
    rag:SetPVSVar("IsFakeRagdoll",true)
    rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    rag:CallOnRemove("HG_FakeOwner",function(ent)
        local ply = ent:GetController()
        if IsValid(ply) and ply:GetDummy() == ent then
            fakePlayers[ply] = nil
            SetFakeState(ply)
        end
    end)

    self.hgFakeRagdoll = rag
    fakePlayers[self] = rag
    SetFakeState(self,rag)

    if force then
        local phys = rag:GetPhysicsObject()
        if IsValid(phys) then phys:ApplyForceCenter(force) end
    end

    return true
end

function PLAYER:ExitFake(force)
    local rag = self:GetDummy()
    if not IsValid(rag) or rag == self then
        fakePlayers[self] = nil
        SetFakeState(self)
        return false
    end

    if not force and rag:GetVelocity():LengthSqr() > 62500 then return false end

    local pos = rag:GetPos()
    local pelvis = rag:LookupBone("ValveBiped.Bip01_Pelvis")
    if pelvis then
        local matrix = rag:GetBoneMatrix(pelvis)
        if matrix then pos = matrix:GetTranslation() end
    end

    local tr = util.TraceHull({
        start = pos + Vector(0,0,8),
        endpos = pos + Vector(0,0,40),
        mins = standMins,
        maxs = standMaxs,
        filter = {self,rag},
        mask = MASK_PLAYERSOLID
    })

    if not force and tr.Hit then return false end

    fakePlayers[self] = nil
    self.hgFakeRagdoll = nil
    rag:RemoveCallOnRemove("HG_FakeOwner")
    SetFakeState(self)
    self:SetPos(tr.HitPos)
    self:SetVelocity(rag:GetVelocity())
    rag:Remove()

    return true
end

concommand.Add("fake",function(ply)
    if not IsValid(ply) then return end

    if ply:InFake() then
        ply:ExitFake(false)
    else
        ply:EnterFake()
    end
end)

concommand.Add("fake_dead",function(ply,cmd,args)
    if not IsValid(ply) or not ply:InFake() then return end
    ply:SetNWBool("FakeDeath",tonumber(args[1] or "0") > 0)
end)

hook.Add("Think","HG Fake Movement",function()
    for ply,rag in pairs(fakePlayers) do
        if not IsValid(ply) or not ply:Alive() or not IsValid(rag) then
            fakePlayers[ply] = nil
            if IsValid(rag) then rag:Remove() end
            continue
        end

        local phys = rag:GetPhysicsObjectNum(0)
        if not IsValid(phys) then continue end

        local ang = ply:EyeAngles()
        ang.p = 0
        ang.r = 0

        local wish = Vector()
        if ply:KeyDown(IN_FORWARD) then wish:Add(ang:Forward()) end
        if ply:KeyDown(IN_BACK) then wish:Sub(ang:Forward()) end
        if ply:KeyDown(IN_MOVERIGHT) then wish:Add(ang:Right()) end
        if ply:KeyDown(IN_MOVELEFT) then wish:Sub(ang:Right()) end

        if not wish:IsZero() and not ply:InFakeDeath() then
            wish:Normalize()
            phys:ApplyForceCenter(wish * phys:GetMass() * 180)
            phys:Wake()
        end

        ply:SetPos(rag:GetPos())
        ply:SetLocalVelocity(vector_origin)
    end
end)

local function RemoveFake(ply)
    if not IsValid(ply) then return end

    local rag = fakePlayers[ply] or ply.hgFakeRagdoll
    fakePlayers[ply] = nil
    ply.hgFakeRagdoll = nil

    if IsValid(rag) then
        rag:RemoveCallOnRemove("HG_FakeOwner")
        rag:Remove()
    end

    SetFakeState(ply)
    ply:SetNWBool("FakeDeath",false)
end

hook.Add("PlayerSpawn","HG Fake Reset",RemoveFake)
hook.Add("PlayerDeath","HG Fake Death",RemoveFake)
hook.Add("PlayerDisconnected","HG Fake Disconnect",RemoveFake)
