local SWEP,CLASS = oop.Reg("wep_invicible",{"weapon_hands"})
if not SWEP then return end

SWEP.PrintName = "Invicible Swep"

function SWEP:SetupBones_OnChange(tpikMatrix,Pos,Ang,wmVector,wmAngle)

end

if SERVER then
    local function damageSelf(owner,entity,dmgPain,dmg)
  
    end

    local function damageEntity(result,hitEntity,owner,self,force,impulse)
        if not IsValid(hitEntity) then return end

        local diff = Vector()
        
        if result.HitBoxPos and hitEntity:GetMoveType() == MOVETYPE_VPHYSICS then
            diff = hitEntity:GetPos() - result.HitBoxPos

            hitEntity:SetPos(result.HitBoxPos)
            hitEntity:SetAngles(result.HitBoxAng)
        end

        local controller = hitEntity.controller or hitEntity

        local wep = controller.GetActiveWeapon and controller:GetActiveWeapon()

        if IsValid(wep) and wep.GetFightBlockState and wep:GetFightBlockState() then
            local _,eyeController = controller:Eye()
            local _,eyeOwner = owner:Eye()

            if math.abs(math.AngleDifference(eyeController[2],eyeOwner[2])) > 130 then
                wep:SetFightBlockStart(CurTime())
                
                sound.Emit(wep:EntIndex(),"physics/rubber/rubber_tire_impact_bullet" .. math.random(1,3) .. ".wav",75,1,70,wep:GetPos())

                controller.stamina = controller.stamina - 2
                
                return
            end
        end

        local dmgTab = CreateDamageTab(hitEntity,owner,self,30,DMG_CLUB)
        dmgTab.bone = result.HitBone
        dmgTab.pos = result.HitPos + diff

        local configModel = HandModelConfig[hitEntity:GetModel()]
        
        dmgTab.fakeDown = true
        dmgTab.force = result.Normal * (configModel and configModel.handPunchForce or force)
        dmgTab.forcePhys = dmgTab.force

        if configModel and configModel.handPunchFunction then configModel.handPunchFunction(self,hitEntity) end

        sound.EmitGunShoot(dmgTab.pos,"none2f","explosive",1)

        hitEntity:TakeDamageTab(dmgTab)

        local rag = owner:GetDummy()

        Explosive_WreckBuildings(rag,result.HitPos,1,300,true,true)
        Explosive_BlastDoors(rag,result.HitPos,1,300,true)
    
        Explosive_BlastThatDoor(hitEntity,result.Normal * 1000)
    end

    local Fast = surfaceWorld.Fast.sound.bullet

    function SWEP:HitPrimary(result)
        local owner = self:GetOwner()
        local hitEntity = result.Entity
        local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)
        
        if self:SurfaceIsFlesh(surfaceName,hitEntity) then
            sound.EmitNET(hitEntityy,"physics/body/body_medium_impact_hard" .. math.random(5,6) .. ".wav",75,1,90,result.HitPos)
            net.SendOmit(owner)
        else
            sound.EmitNET(hitEntity,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,result.HitPos)
            net.SendOmit(owner)
            
            local surfaceInfo = Fast[surfaceName]

            if surfaceInfo then
                sound.EmitNET(hitEntity,surfaceInfo.list[math.random(1,#surfaceInfo.list)],75,1,surfaceInfo.pitch,result.HitPos)
                net.SendOmit(owner)
            end

            damageSelf(owner,hitEntity,0.5,0)
        end

        if not hitEntity then return end

        damageEntity(result,hitEntity,owner,self,200,0.5)
    end

    function SWEP:HitSecondary(result)
        local owner = self:GetOwner()
        local hitEntity = result.Entity
        local surfaceName = surfaceWorld.GetSurfaceName(result.SurfaceProps)

        if self:SurfaceIsFlesh(surfaceName,hitEntity) then
            sound.EmitNET(hitEntity,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,result.HitPos)
            net.SendOmit(owner)
        else
            sound.EmitNET(hitEntity,"physics/body/body_medium_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,result.HitPos)
            net.SendOmit(owner)

            local surfaceInfo = Fast[surfaceName]

            if surfaceInfo then
                sound.EmitNET(hitEntity,surfaceInfo.list[math.random(1,#surfaceInfo.list)],75,1,surfaceInfo.pitch,result.HitPos)
                net.SendOmit(owner)
            end

            damageSelf(owner,hitEntity,0.25,0)
        end

        damageEntity(result,hitEntity,owner,self,200)
    end

    SWEP:Event_Add("Think","Gravity",function(self)
        local owner = self:GetOwner()

        if owner.fake then
            local ent = owner:GetDummy()

            local move = Vector()

            if owner:KeyDown(IN_FORWARD) then move[1] = move[1] + 1 end
            if owner:KeyDown(IN_BACK) then move[1] = move[1] - 1 end
            if owner:KeyDown(IN_MOVELEFT) then move[2] = move[2] + 1 end
            if owner:KeyDown(IN_MOVERIGHT) then move[2] = move[2] - 1 end

            if owner:KeyDown(IN_JUMP) then move[3] = move[3] + 1 end
            if owner:KeyDown(IN_DUCK) then move[3] = move[3] - 1 end

            move:Mul(300)
            move:Rotate(owner:EyeAngles())

            for i = 0, ent:GetPhysicsObjectCount() - 1 do
                local phys = ent:GetPhysicsObjectNum(i)
                if not IsValid(phys) then continue end

                phys:EnableGravity(false)
                
                phys:Wake()

                if move:Length() > 0 then
                    phys:SetVelocity(LerpVector(FrameTime(),phys:GetVelocity(),move))
                end
            end
        end

        owner.pain = 0
        owner.impulse = 0

        if not self.music then
            self.music = CreateSound(self,"homigrad/estilo_horizonte diamante_super slower.mp3")
            self.music:SetSoundLevel(40)
        end

        if not self.music:IsPlaying() then
            self.music:PlayEx(0.8,100)
        end
    end)

    SWEP:Event_Add("Off","Music",function(self)
        if self.music then self.music:Stop() self.music = nil end

        local owner = self:GetOwner()
    end)
    
    event.Add("Damage","wep_invicible",function(dmgTab)
        local target = dmgTab.target
        if not target.GetActiveWeapon then return end

        local wep = target:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() != "wep_invicible" then return end

        if dmgTab.isPhysicsDamage then dmgTab.dmg = dmgTab.dmg / 10 end

        if dmgTab.isBullet then dmgTab.dmg = dmgTab.dmg / 40 end

        dmgTab.noHeadshot = true
    end,-1)
end