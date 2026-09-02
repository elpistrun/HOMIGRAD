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

-- Bone name aliases for different model skeletons
-- Some models use ValveBiped names, others use bip_* or different conventions
local boneAliases = {
    Head = {"ValveBiped.Bip01_Head1","bip_head"},
    Neck = {"ValveBiped.Bip01_Neck1","bip_neck"},
    Spine4 = {"ValveBiped.Bip01_Spine4","ValveBiped.Bip01_Spine3","bip_spine_3"},
    Spine2 = {"ValveBiped.Bip01_Spine2","bip_spine_2"},
    Spine1 = {"ValveBiped.Bip01_Spine1","bip_spine_1"},
    Spine = {"ValveBiped.Bip01_Spine","bip_spine_0"},
    Pelvis = {"ValveBiped.Bip01_Pelvis","bip_pelvis"},
    CalfR = {"ValveBiped.Bip01_R_Calf","bip_r_calf"},
    CalfL = {"ValveBiped.Bip01_L_Calf","bip_l_calf"},
    FArmL = {"ValveBiped.Bip01_L_Forearm","bip_l_forearm"},
    FArmR = {"ValveBiped.Bip01_R_Forearm","bip_r_forearm"},
    HandL = {"ValveBiped.Bip01_L_Hand","bip_l_hand"},
    HandR = {"ValveBiped.Bip01_R_Hand","bip_r_hand"},
}

local function resolvePhysBone(rag,key)
    local aliases = boneAliases[key]
    if not aliases then return nil end
    for _,name in ipairs(aliases) do
        local boneId = rag:LookupBone(name)
        if boneId then
            local physBone = rag:TranslateBoneToPhysBone(boneId)
            if physBone and physBone >= 0 then
                local phys = rag:GetPhysicsObjectNum(physBone)
                if IsValid(phys) then return phys end
            end
        end
    end
    return nil
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
    if (self.fakeCooldownAt or 0) > CurTime() then return false end
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

    -- Body physics. Whole ragdoll is scaled lighter (0.65) so grabbing and
    -- climbing (W pull) can actually lift it. All limbs (shoulder/arm/hand,
    -- thigh/calf/foot) get full relative mass, strong angular damping and no
    -- fluid drag, so they track the torso rigidly ("like sticks") instead of
    -- lagging and whipping around like jelly when the ragdoll gets yanked.
    -- Neck stays light and flexible. Torso keeps its default play.
    -- Pelvis is lighter so the ragdoll is easier to lift when climbing walls.
    local globalMassMul = 0.65

    for i = 0, rag:GetPhysicsObjectCount() - 1 do
        local phys = rag:GetPhysicsObjectNum(i)
        if IsValid(phys) then
            local bone = rag:TranslatePhysBoneToBone(i)
            local boneName = bone and rag:GetBoneName(bone) or ""

            local massMul = globalMassMul
            local lDamp, aDamp = 0.2, 0.5
            local drag = true

            if boneName:find("Pelvis") or boneName:find("pelvis") then
                massMul = massMul * 0.7
            elseif boneName:find("Clavicle") or boneName:find("clav") or
                   boneName:find("UpperArm") or boneName:find("upperarm") or
                   boneName:find("Forearm") or boneName:find("forearm") or
                   boneName:find("Hand") or boneName:find("hand") or
                   boneName:find("Thigh") or boneName:find("thigh") or
                   boneName:find("UpperLeg") or boneName:find("upperleg") or
                   boneName:find("Calf") or boneName:find("calf") or
                   boneName:find("Foot") or boneName:find("foot") then
                massMul = globalMassMul
                lDamp, aDamp = 0.1, 2.5
                drag = false
            elseif boneName:find("Neck") or boneName:find("neck") then
                massMul = globalMassMul * 0.55
                lDamp, aDamp = 0.3, 0.85
            end

            phys:SetMass(phys:GetMass() * massMul)
            phys:SetDamping(lDamp, aDamp)
            phys:EnableDrag(drag)
            phys:SetDragCoefficient(1, 1)
        end
    end

    CopyPlayerPose(self,rag)

    rag:SetController(self)
    rag:SetPVSVar("IsFakeRagdoll",true)
    rag:SetPVSVar("PlayerColor",self:GetPlayerColor())
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

    self.fakeCooldownAt = CurTime() + 3

    return true
end

function PLAYER:ExitFake(force)
    local rag = self:GetDummy()
    if not IsValid(rag) or rag == self then
        fakePlayers[self] = nil
        SetFakeState(self)
        return false
    end

    if not force and (self.fakeCooldownAt or 0) > CurTime() then return false end
    if not force and rag:GetVelocity():LengthSqr() > 62500 then return false end

    local pos = rag:GetPos()
    local pelvis = rag:LookupBone("ValveBiped.Bip01_Pelvis") or rag:LookupBone("bip_pelvis")
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

    self.fakeCooldownAt = CurTime() + 3
    self.fakeFallMaxZ = nil
    self.fakeFallCd = nil

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
    local value = tonumber(args[1])
    ply:SetNWBool("FakeDeath",value == nil and not ply:InFakeDeath() or (value or 0) > 0)
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

        -- Fake fall: detect landing after a free-fall and apply damage/effects
        -- based on the actual drop height (ragdoll drag caps velocity below the
        -- old threshold so a velocity-based check misses even big falls).
        local z = rag:GetPos().z
        local speed = rag:GetVelocity():Length()

        if speed < 60 then
            ply.fakeFallMaxZ = nil
        else
            local vy = rag:GetVelocity().z

            if vy < -150 then
                ply.fakeFallMaxZ = math.max(ply.fakeFallMaxZ or z,z)
            end

            if ply.fakeFallMaxZ and vy >= -150 and (ply.fakeFallCd or 0) <= CurTime() then
                local dropH = math.max(ply.fakeFallMaxZ - z,0)

                if dropH >= 350 then
                    ply.fakeFallCd = CurTime() + 0.75

                    local gravity = GetConVar("sv_gravity"):GetFloat()
                    if gravity <= 0 then gravity = 600 end
                    local impactSpeed = math.sqrt(2 * gravity * dropH)
                    local impactK = math.Clamp((impactSpeed - 700) / 1200,0,1)
                    local pos = rag:GetPos()

                    sound.Emit(nil,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",80,0.4 + impactK * 0.6,90 + impactK * 25,pos)
                    util.ScreenShake(pos,14 * impactK,10,0.4,350)

                    if not ply:InFakeDeath() then
                        if impactK > 0.2 then
                            gibParticles.bloodHitCreate(pos + Vector(0,0,10),Vector(0,0,1),ply)
                        end

                        local damage = (impactSpeed - 700) * 0.15
                        if damage >= 5 then
                            local dmgTab = CreateDamageTab(ply,ply,rag,damage,DMG_GENERIC)
                            dmgTab.isFall = true
                            dmgTab.pos = pos
                            ply:TakeDamageTab(dmgTab)
                        end
                    end
                end

                ply.fakeFallMaxZ = nil
            end
        end

        if ply:InFakeDeath() then
            ply:SetPos(rag:GetPos())
            ply:SetLocalVelocity(vector_origin)
            continue
        end

        -- Get bone physics objects (with fallback for different model skeletons)
        local Head = resolvePhysBone(rag,"Head")
        local Neck = resolvePhysBone(rag,"Neck")
        local Spine4 = resolvePhysBone(rag,"Spine4")
        local Spine2 = resolvePhysBone(rag,"Spine2")
        local Spine1 = resolvePhysBone(rag,"Spine1")
        local Spine = resolvePhysBone(rag,"Spine")
        local Pelvis = resolvePhysBone(rag,"Pelvis")
        local CalfR = resolvePhysBone(rag,"CalfR")
        local CalfL = resolvePhysBone(rag,"CalfL")
        local FArmL = resolvePhysBone(rag,"FArmL")
        local FArmR = resolvePhysBone(rag,"FArmR")
        local HandL = resolvePhysBone(rag,"HandL")
        local HandR = resolvePhysBone(rag,"HandR")

        local ismoving = (ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH)) or (ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH))

        -- E key: shadow control on Spine4 + Spine2 (torso orientation)
        if ply:KeyDown(IN_USE) then
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(),0)
            angs:RotateAroundAxis(angs:Up(),-90)
            angs:RotateAroundAxis(angs:Right(),90)

            local sp = {
                secondstoarrive = 0.3,
                pos = Spine4:GetPos() + ((ply:KeyDown(IN_ATTACK) and ply:KeyDown(IN_ATTACK2)) and ply:EyeAngles():Forward() * 0.5 or Vector()),
                angle = angs,
                maxangular = 360 * 3,
                maxangulardamp = 35,
                dampfactor = 1,
                maxspeeddamp = 5,
                maxspeed = 400,
                teleportdistance = 0,
                deltatime = FrameTime(),
            }

            local angs2 = ply:EyeAngles()
            angs2:RotateAroundAxis(angs2:Forward(),0)
            angs2:RotateAroundAxis(angs2:Up(),-90)
            angs2:RotateAroundAxis(angs2:Right(),90)

            local sp2 = {
                secondstoarrive = 0.7,
                pos = Spine2:GetPos() + ((ply:KeyDown(IN_ATTACK) and ply:KeyDown(IN_ATTACK2)) and ply:EyeAngles():Forward() * 0.5 or Vector()),
                angle = angs2,
                maxangular = 360 * 3,
                maxangulardamp = 60,
                dampfactor = 1,
                maxspeeddamp = 10,
                maxspeed = 200,
                teleportdistance = 0,
                deltatime = FrameTime(),
            }

            if IsValid(Spine4) then
                Spine4:Wake()
                Spine4:ComputeShadowControl(sp)
            end

            if IsValid(Spine2) then
                Spine2:Wake()
                Spine2:ComputeShadowControl(sp2)
            end
        end

        -- W key with grabbed objects: pull body forward via Spine2
        if ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH) then
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(),0)
            angs:RotateAroundAxis(angs:Up(),-90)
            angs:RotateAroundAxis(angs:Right(),90)

            if IsValid(rag.ZacConsLH.Ent2) and rag.ZacConsLH.Ent2:GetVelocity():LengthSqr() < 750 then
                local ang = ply:EyeAngles()
                local sp = {
                    secondstoarrive = 0.4,
                    pos = HandL:GetPos() + ang:Forward() * 13 + ang:Up() * 40 + (IsValid(rag.ZacConsRH) and vector_up * 4 or Vector()),
                    angle = Spine2:GetAngles(),
                    maxangular = 360 * 3,
                    maxangulardamp = 3,
                    dampfactor = 1,
                    maxspeeddamp = 20,
                    maxspeed = 500,
                    teleportdistance = 0,
                    deltatime = FrameTime(),
                }

                -- Lifting the body: pull Spine2 up toward the hand so W
                -- actually climbs instead of just sliding the torso forward.
                local lift = ang:Up() * 600
                sp.pos = sp.pos + lift * FrameTime()

                if IsValid(Spine2) then
                    Spine2:Wake()
                    Spine2:ComputeShadowControl(sp)
                end

                if IsValid(Pelvis) then
                    Pelvis:Wake()
                    Pelvis:ApplyForceCenter(lift)
                end
            end
        end

        if ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH) then
            local dist = HandL:GetPos():Distance(Spine4:GetPos())
            local mul = math.Clamp(1 - dist / 30,0,0.6)

            if IsValid(rag.ZacConsRH.Ent2) and rag.ZacConsRH.Ent2:GetVelocity():LengthSqr() < 750 then
                local ang = ply:EyeAngles()
                local sp = {
                    secondstoarrive = 0.4,
                    pos = HandR:GetPos() + ang:Forward() * 13 + ang:Up() * 40 + (IsValid(rag.ZacConsLH) and vector_up * 4 or Vector()),
                    angle = Spine2:GetAngles(),
                    maxangular = 360 * 3,
                    maxangulardamp = 3,
                    dampfactor = 1,
                    maxspeeddamp = 20,
                    maxspeed = 500,
                    teleportdistance = 0,
                    deltatime = FrameTime(),
                }

                -- Lifting the body: pull Spine2 up toward the hand so W
                -- actually climbs instead of just sliding the torso forward.
                local lift = ang:Up() * 600
                sp.pos = sp.pos + lift * FrameTime()

                if IsValid(Spine2) then
                    Spine2:Wake()
                    Spine2:ComputeShadowControl(sp)
                end

                if IsValid(Pelvis) then
                    Pelvis:Wake()
                    Pelvis:ApplyForceCenter(lift)
                end
            end
        end

        -- LMB: left arm reach (shadow control on HandL)
        if ply:KeyDown(IN_ATTACK) then
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(),90)
            angs:RotateAroundAxis(angs:Right(),0)
            angs:RotateAroundAxis(angs:Up(),50)
            local sp = {
                secondstoarrive = 0.35,
                pos = Head:GetPos() + ply:EyeAngles():Forward() * 30 + ply:EyeAngles():Right() * -9,
                angle = angs,
                maxangular = 120,
                maxangulardamp = 60,
                maxspeeddamp = 60,
                maxspeed = 300,
                dampfactor = 1,
                teleportdistance = 0,
                deltatime = FrameTime(),
            }

            if IsValid(HandL) then
                HandL:Wake()
                HandL:ComputeShadowControl(sp)
            end
        end

        -- RMB: right arm reach (shadow control on HandR)
        if ply:KeyDown(IN_ATTACK2) then
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(),90)
            angs:RotateAroundAxis(angs:Right(),0)
            angs:RotateAroundAxis(angs:Up(),50)
            local sp = {
                secondstoarrive = 0.35,
                pos = Head:GetPos() + ply:EyeAngles():Forward() * 30 + ply:EyeAngles():Right() * 9,
                angle = angs,
                maxangular = 120,
                maxangulardamp = 60,
                maxspeeddamp = 60,
                maxspeed = 300,
                dampfactor = 1,
                teleportdistance = 0,
                deltatime = FrameTime(),
            }

            if IsValid(HandR) then
                HandR:Wake()
                HandR:ComputeShadowControl(sp)
            end
        end

        -- SHIFT: left hand grab (weld constraint to world)
        if ply:KeyDown(IN_SPEED) then
            local phys = resolvePhysBone(rag,"HandL")
            if IsValid(phys) and not IsValid(rag.ZacConsLH) and (not rag.ZacNextGrLH or rag.ZacNextGrLH <= CurTime()) then
                rag.ZacNextGrLH = CurTime() + 0.01
                local handBoneId = rag:LookupBone("ValveBiped.Bip01_L_Hand") or rag:LookupBone("bip_l_hand")
                local handPhysBone = handBoneId and rag:TranslateBoneToPhysBone(handBoneId) or 0
                for i = 1, 3 do
                    local offset = phys:GetAngles():Up() * 5
                    if i == 2 then offset = phys:GetAngles():Right() * 5 end
                    if i == 3 then offset = phys:GetAngles():Right() * -5 end
                    local trace = util.TraceLine({
                        start = phys:GetPos(),
                        endpos = phys:GetPos() + offset,
                        filter = rag,
                    })
                    if trace.Hit and not trace.HitSky then
                        local cons = constraint.Weld(rag, trace.Entity, handPhysBone, trace.PhysicsBone, 0, false, false)
                        if IsValid(cons) then
                            rag.ZacConsLH = cons
                        end
                        break
                    end
                end
            end
        else
            if IsValid(rag.ZacConsLH) then
                rag.ZacConsLH:Remove()
                rag.ZacConsLH = nil
            end
        end
        ply:SetNWBool("LeftArm",IsValid(rag.ZacConsLH))

        -- ALT: right hand grab (weld constraint to world)
        if ply:KeyDown(IN_WALK) then
            local phys = resolvePhysBone(rag,"HandR")
            if IsValid(phys) and not IsValid(rag.ZacConsRH) and (not rag.ZacNextGrRH or rag.ZacNextGrRH <= CurTime()) then
                rag.ZacNextGrRH = CurTime() + 0.01
                local handBoneId = rag:LookupBone("ValveBiped.Bip01_R_Hand") or rag:LookupBone("bip_r_hand")
                local handPhysBone = handBoneId and rag:TranslateBoneToPhysBone(handBoneId) or 0
                for i = 1, 3 do
                    local offset = phys:GetAngles():Up() * 5
                    if i == 2 then offset = phys:GetAngles():Right() * 5 end
                    if i == 3 then offset = phys:GetAngles():Right() * -5 end
                    local trace = util.TraceLine({
                        start = phys:GetPos(),
                        endpos = phys:GetPos() + offset,
                        filter = rag,
                    })
                    if trace.Hit and not trace.HitSky then
                        local cons = constraint.Weld(rag, trace.Entity, handPhysBone, trace.PhysicsBone, 0, false, false)
                        if IsValid(cons) then
                            rag.ZacConsRH = cons
                        end
                        break
                    end
                end
            end
        else
            if IsValid(rag.ZacConsRH) then
                rag.ZacConsRH:Remove()
                rag.ZacConsRH = nil
            end
        end
        ply:SetNWBool("RightArm",IsValid(rag.ZacConsRH))

        -- WASD movement: push body in camera direction (works without hand grabs for crawling)
        local eyeAng = ply:EyeAngles()
        local camFwd = Vector(eyeAng:Forward().x, eyeAng:Forward().y, 0):GetNormalized()
        local camRight = Vector(eyeAng:Right().x, eyeAng:Right().y, 0):GetNormalized()
        local moveDir = vector_origin

        if ply:KeyDown(IN_FORWARD) then moveDir = moveDir + camFwd end
        if ply:KeyDown(IN_BACK) then moveDir = moveDir - camFwd end
        if ply:KeyDown(IN_MOVELEFT) then moveDir = moveDir - camRight end
        if ply:KeyDown(IN_MOVERIGHT) then moveDir = moveDir + camRight end

        if moveDir:LengthSqr() > 0 and not ismoving then
            moveDir:Normalize()
            local crawlForce = 110
            if IsValid(Pelvis) then
                Pelvis:Wake()
                Pelvis:ApplyForceCenter(moveDir * crawlForce)
            end
            if IsValid(Spine1) then
                Spine1:Wake()
                Spine1:ApplyForceCenter(moveDir * crawlForce * 0.6)
            end
            if IsValid(Spine2) then
                Spine2:Wake()
                Spine2:ApplyForceCenter(moveDir * crawlForce * 0.35)
            end
        end

        -- Weapon holding: push hands forward when weapon is equipped
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() ~= "weapon_hands" then
            local fwd = ply:EyeAngles():Forward()

            -- Right hand (grip hand) — pushed forward
            local angsR = ply:EyeAngles()
            angsR:RotateAroundAxis(angsR:Forward(),90)
            angsR:RotateAroundAxis(angsR:Up(),50)
            local spR = {
                secondstoarrive = 0.3,
                pos = Head:GetPos() + fwd * 35 + ply:EyeAngles():Right() * 6,
                angle = angsR,
                maxangular = 360,
                maxangulardamp = 35,
                maxspeeddamp = 300,
                maxspeed = 300,
                dampfactor = 1,
                teleportdistance = 0,
                deltatime = FrameTime(),
            }

            if IsValid(HandR) and not ply:KeyDown(IN_ATTACK2) then
                HandR:Wake()
                HandR:ComputeShadowControl(spR)
            end

            -- Left hand (support hand) — slightly forward and offset
            local angsL = ply:EyeAngles()
            angsL:RotateAroundAxis(angsL:Forward(),90)
            angsL:RotateAroundAxis(angsL:Up(),50)
            local spL = {
                secondstoarrive = 0.3,
                pos = Head:GetPos() + fwd * 30 + ply:EyeAngles():Right() * -6,
                angle = angsL,
                maxangular = 360,
                maxangulardamp = 35,
                maxspeeddamp = 300,
                maxspeed = 300,
                dampfactor = 1,
                teleportdistance = 0,
                deltatime = FrameTime(),
            }

            if IsValid(HandL) and not ply:KeyDown(IN_ATTACK) then
                HandL:Wake()
                HandL:ComputeShadowControl(spL)
            end
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
    ply.fakeCooldownAt = nil
    ply.fakeFallMaxZ = nil
    ply.fakeFallCd = nil
end

hook.Add("PlayerSpawn","HG Fake Reset",RemoveFake)
hook.Add("PlayerDeath","HG Fake Death",RemoveFake)
hook.Add("PlayerDisconnected","HG Fake Disconnect",RemoveFake)
