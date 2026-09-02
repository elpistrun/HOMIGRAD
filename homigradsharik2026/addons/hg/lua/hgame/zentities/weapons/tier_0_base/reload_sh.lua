local SWEP = oop.Get("hg_wep")
if not SWEP then return end

-- The inventory part that used to receive unloaded cartridges is absent from
-- this addon set. Keep every weapon/revolver unload path valid; integrations
-- can override this method later and return the rounds to an inventory.
function SWEP:UnLoadAmmo(count)
    count = math.max(math.floor(tonumber(count) or 0),0)
    if count == 0 then return 0 end

    if SERVER and inventoryGame and inventoryGame.OnWeaponUnloadAmmo then
        local handled = inventoryGame.OnWeaponUnloadAmmo(self,self:GetOwner(),self:GetAmmoClass(),count)
        if handled != nil then return handled end
    end

    return count
end

SWEP.ReloadAnimationNames = {
    unload_magazine = true,
    unload_magazine_empty = true,
    load_magazine = true,
    load_magazine_chamber = true,
    chamber = true,
    chamber_out = true,
    pomp_insert = true,
    rev_unload = true,
    rev_uninsert = true,
    rev_insert = true,
    mr43_reload1 = true,
    mr43_reload2 = true
}

function SWEP:IsReloading()
    local seq = self.sequenceObject
    if seq and seq.name and self.ReloadAnimationNames[seq.name] then return true end

    return false
end

if CLIENT then
    local cmd = {}

    function SWEP:Reload()
        if not self.GetMagazineItem then return end

        if self:IsReloading() then return end
        
        if self:IsCooldown("Reload") then return end

        for k in pairs(cmd) do cmd[k] = nil end
        
        if self:GetOwner():KeyDown(IN_WALK) then
            cmd.name = "chamber"
        elseif self:GetMagazineItem() then
            cmd.name = "unload_magazine"
        else
            local ammo = self:FindAmmoInInv()
            if ammo then cmd.name = "load_magazine" end
        end

        if not cmd.name then return end--wtf
        
        self:DoAction(cmd)
    end

    keyboard.DefaultBindCode("checkmagazine",KEY_I,true)

    concommand.Add("checkmagazine",function(ply)
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.Actions or not wep.Actions["checkmagazine"] then return end

        wep:DoAction({name = "checkmagazine"})
    end)
end

SWEP:Event_Add("Action","Check Magazine",function(self,cmd)
    if not self.UseChamber or cmd.name != "checkmagazine" or not self.AnimationList.checkmagazine then return end

    self:PlayAnimation("checkmagazine",cmd.timeStamp)
    if SERVER then self:SyncAnimation() end

    return true
end)

function SWEP:FindAmmoInInv()
    local ammoItem

    local owner = self:GetOwner()
    if not IsValid(owner) or not isfunction(owner.GetAllAutoItems) then return end

    local curretAmmoClass = self:GetAmmoClass()

    for i,item in pairs(owner:GetAllAutoItems() or {}) do
        if not item.data or not item.data.ammoName then continue end--lol

        local ammoConfig = ammoGame.config[item.data.ammoName]
        if not ammoConfig then continue end
        if (curretAmmoClass and item.data.ammoName ~= curretAmmoClass) or ammoConfig.AmmoCalibre ~= self.Primary.AmmoCalibre then continue end

        ammoItem = item

        break
    end
    
    return ammoItem
end

function SWEP:ActionCMD_GetAmmoClient(cmd)
    local ammo

    if cmd.ammoClient then
        local ammoClient = cmd.ammoClient
        if TypeID(ammoClient) != TYPE_TABLE then return false end

        local inv = inventoryGame.listIndex[tonumber(ammoClient.inv) or 0]
        if not IsValid(inv) or (SERVER and not inv.playersConnect[cmd.ply]) then return false end

        ammo = inv.slots[tonumber(ammoClient.x) or 0]
        if not ammo then return false end

        ammo = ammo[tonumber(ammoClient.y) or 0]
        if not ammo then return false end

        ammo = ammo.list[tonumber(ammoClient.depth) or 0]
        if not ammo then return false end

        if ammoGame.config[ammo.data.ammoName].AmmoCalibre != self.Primary.AmmoCalibre then return false end
    else
        ammo = self:FindAmmoInInv()
    end

    return ammo
end

local UnloadMagazine = function(self,anim)
    anim.NetData = function(object,netData)
        netData.model = object.model
    end

    anim.Start = function(object)
        if CLIENT then
            object.magazineModel = object.parent:InitWorldModelMagazine(object.parent.wm,"animUnLoad",true,object.model)
        end
    end

    anim.Step = function(object,cycle)
        local self = object.parent

        if CLIENT and IsValid(self.wm) and IsValid(self.wm.magazineModel) then self.wm.magazineModel.dontDraw = true end
    end

    anim.Load = function(object)
        if not object.isLocal then return end
        
        local self = object.parent

        local less = self.chamber == true and 1 or 0

        if SERVER then
            self:UnLoadAmmo(self:Clip1() - less)
            inventoryGame.SyncItemByEntity(self)
        end

        self:SetClip1(less)

        if less == 0 then self:SetAmmoClass() end

        self:SetMagazineItem()
    end
    
    anim.Stop = function(object,callType)
        local self = object.parent
        
        if CLIENT then
            if IsValid(self.wm) and IsValid(self.wm.magazineModel) then self.wm.magazineModel.dontDraw = false end
            CSM.Delete(object.magazineModel)
        end
    end
end

SWEP:ConstructAnimationAction("unload_magazine",
function(self,cmd)
    local magazineItem = self:GetMagazineItem()
    if not magazineItem then return false,"no magazine" end

    self:PlayAnimationAction({
        name = self:IsGateDelay() and self.AnimationList.unload_magazine_empty and "unload_magazine_empty" or "unload_magazine",
        model = magazineItem.path
    })

    if SERVER then self:SyncAnimation() end

    return true
end,UnloadMagazine)

SWEP:ConstructAnimationAction("unload_magazine_empty",
function(self,cmd)

end,UnloadMagazine)

local LoadMagazine = function(self,anim)
    anim.NetData = function(object,netData)
        netData.model = object.model
    end

    anim.Start = function(object)
        if CLIENT then
            object.magazineModel = object.parent:InitWorldModelMagazine(object.parent.wm,"animLoad",true,object.model)
        end
    end

    anim.Step = function(object,cycle)
        local self = object.parent

        local ammo = object.ammo

        if object.isLocal then
            if not IsValid(ammo) then self:ResetAnimation() if SERVER then self:SyncAnimation() end return end
        end
    end
    
    anim.Load = function(object)
        if not object.isLocal then return end

        local self = object.parent

        local ammo = object.ammo

        local insert = math.min(self.Primary.ClipSize + (self.chamber and 1 or 0),ammo.data.count)

        self:SetAmmoClass(ammo.data.ammoName)
        self:SetClip1(insert)
        
        if object.name == "load_magazine_chamber" then
            self:SetChamber(true)
            self:SetGateDelay(false)
        end

        if SERVER then
            inventoryGame.TakeResource(ammo,insert - (self.chamber and 1 or 0))
            inventoryGame.SyncItemByEntity(self)
        else
            CSM.Delete(object.magazineModel)

            self:SetCooldown("Reload",TickInterval() * 10)--уёбище
        end

        self:SetMagazineItem({path = object.model})
    end

    anim.Stop = function(object)
        if CLIENT then
            CSM.Delete(object.magazineModel)
        end
    end
end


SWEP:ConstructAnimationAction("load_magazine",
function(self,cmd)
    if self:GetMagazineItem() then return false end

    local ammo = self:ActionCMD_GetAmmoClient(cmd)
    if not ammo then return false,"no ammo" end

    local sequenceObject = self:PlayAnimationAction({
        name = self:IsGateDelay() and "load_magazine_chamber" or "load_magazine",
        model = self.Primary.MagazineModel,
        ammo = ammo
    })
    
    if SERVER then self:SyncAnimation() end

    return true
end,LoadMagazine)

if CLIENT then
    SWEP:Event_Add("StopAction","Reload",function(self,cmd)
        if cmd.err == "no magazine" then
            self:SetMagazineItem(self.magazineItemServer)
        end
    end)
end

SWEP:ConstructAnimationAction("load_magazine_chamber",
function(self,cmd)

end,LoadMagazine)

local Chamber = function(self,anim)
    anim.Step = function(object,cycle)
        if not object.isLocal then return end
        
        local self = object.parent

        if object.rejectShell and object:GetMarkEmit("rejectShell") then
            if self.chamber ~= nil then
                local Pos,Ang = self:RejectShell(false)

                if Pos then self:EmitLocalSound(self.Primary.ShellSoundOut,60,0.1,100,Pos) end
            end
        end
    end

    anim.Load = function(object)
        if not object.isLocal then return end

        local self = object.parent

        if object.wasChamber then self:SetClip1(math.max(self:Clip1() - 1,0)) end

        if self:Clip1() > 0 then
            self:SetChamber(true)
        else
            self:SetChamber()
            self:SetAmmoClass()
        end

        self:SetGateDelay(false)
    end
end

SWEP:ConstructAnimationAction("chamber",
function(self,cmd)
    local sequenceObject = self:PlayAnimationAction(self:IsGateDelay() and self.AnimationList.chamber_out and "chamber_out" or "chamber")
    sequenceObject.wasChamber = self.chamber == true

    -- Record the accepted manual cycle immediately on both realms. The active
    -- sequence still blocks firing until the bolt/pump animation reaches its
    -- end, while a delayed/lost load marker can no longer leave chamber=false.
    if not self.Primary.ChamberAuto and self:Clip1() > 0 then
        self:SetChamber(true)
        self:SetGateDelay(false)
    end

    if SERVER then self:SyncAnimation() end

    return true
end,Chamber)

SWEP:ConstructAnimationAction("chamber_out",
function(self,cmd)

end,Chamber)

SWEP:Event_Add("Action","chamber_out",function(self,cmd)
    if cmd.name != "chamber_out" then return end

    self:PlayAnimationAction({name = "chamber_out"})

    return true
end)

SWEP:Event_Add("Action","unload",function(self,cmd)
    --[[if cmd.name != "unload" then return end

    if self:Clip1() == 1 and self.chamber == true then
        self:PlayAnimationAction({name = "chamber"})
        if SERVER then self:SyncAnimation() self:UnLoadAmmo(1) end
    else
        local magazineItem = self:GetMagazineItem()
        if not magazineItem then return false,"no magazine" end

        self:PlayAnimationAction({
            name = self:IsGateDelay() and self.AnimationList.unload_magazine_empty and "unload_magazine_empty" or "unload_magazine",
            model = magazineItem.path
        })

        if SERVER then self:SyncAnimation() end
    end

    return true]]--
end)
