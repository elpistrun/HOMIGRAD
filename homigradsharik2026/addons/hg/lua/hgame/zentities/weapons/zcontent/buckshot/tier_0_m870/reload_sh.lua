local SWEP = oop.Get("wep_m870")
if not SWEP then return end

if CLIENT then
    function SWEP:Reload()
        if self:IsReloading() then return end

        if LocalPlayer():KeyDown(IN_WALK) then
            self:DoAction({name = "chamber"})
        elseif self:Clip1() < (self:GetMaxClip1() + (self.chamber and 1 or 0)) then
            self:DoAction({name = "pomp_insert",clip = self:Clip1()})
        elseif self.chamber == false or (self:Clip1() > 0 and self.chamber != true) then
            self:DoAction({name = "chamber"})
        end
    end
end

SWEP:ConstructAnimationAction("pomp_insert",
function(self,cmd)
    local ammo = self:FindAmmoInInv()
    if not ammo then
        local maxClip = self:GetMaxClip1() + (self.chamber and 1 or 0)
        if #self.chamberPump >= maxClip then return false,"tube full" end

        local ammoName = ammoGame.callibreIndex[self.Primary.AmmoCalibre]
        self.chamberPump[#self.chamberPump + 1] = ammoName
        self:SetClip1(#self.chamberPump)
        self:PlayAnimation({name = "pomp_insert",className = "base",sandboxFallback = true})
        if SERVER then self:SyncAnimation() end

        return true
    end
    
    self:PlayAnimationAction({name = "pomp_insert",ammo = ammo})
    if SERVER then self:SyncAnimation() end

    return true
end,function(self,anim)
    anim.Start = function(object)
        if object.isLocal then
            local chamberPump = object.parent.chamberPump

            for i = object.parent:Clip1() + 1,#chamberPump do
                chamberPump[i] = nil
            end
            if CLIENT and IsValid(object.parent.wm) and util.IsValidModel("models/weapons/arc9/darsu_eft/shells/patron_12x70_shell.mdl") then
                local shell = ClientsideModel("models/weapons/arc9/darsu_eft/shells/patron_12x70_shell.mdl", RENDERGROUP_VIEWMODEL)
                shell:SetNoDraw(true)
                shell:SetModelScale(0.9)
                object.shellModel = shell
            end
        end
    end

    anim.Step = function(object,cycle)
        if not object.isLocal then return end
        if object.sandboxFallback then return end
        if object.ammo and not IsValid(object.ammo) then object.parent:ResetAnimation() return end
    end

    anim.SetupModelPost = function(object,wm)
        wm:SetBodygroup(object.parent.wmData.chamberBodygroup,1)
        if CLIENT and IsValid(object.shellModel) and IsValid(wm) then
            local handBone = wm:LookupBone("ValveBiped.Bip01_L_Hand")
            if handBone then
                local mat = wm:GetBoneMatrix(handBone)
                if mat then
                    object.shellModel:SetPos(mat:GetTranslation() + Vector(2,0,0):Rotate(mat:GetAngles()))
                    object.shellModel:SetAngles(mat:GetAngles())
                    object.shellModel:DrawModel()
                end
            end
        end
    end

    anim.Load = function(object)
        if not object.isLocal or not object.ammo or not object.ammo.data then return end

        inventoryGame.TakeResource(object.ammo,1)

        local self = object.parent
        local max = self:GetMaxClip1() + (self.chamber and 1 or 0)

        self.chamberPump[#self.chamberPump+1] = object.ammo.data.ammoName
        self:SetClip1(#self.chamberPump)
        if CLIENT and IsValid(object.shellModel) then
            object.shellModel:Remove()
            object.shellModel = nil
        end
    end

    anim.Skip = function(object)
        if CLIENT and IsValid(object.shellModel) then
            object.shellModel:Remove()
            object.shellModel = nil
        end
    end
end)
