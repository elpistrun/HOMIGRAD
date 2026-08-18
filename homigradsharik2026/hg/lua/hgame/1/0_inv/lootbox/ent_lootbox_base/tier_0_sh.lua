local ENT,CLASS = oop.Reg("ent_lootbox_base","base_entity",true)
if not ENT then return INCLUDE_BREAK end

CLASS.NonRegisterGMOD = true

ENT.Type = "anim"
ENT.Author = "0oa"
ENT.Spawnable = true
ENT.AdminSpawnable = false

ENT.PrintName = "LootBox Base"
ENT.Category = "Homigrad"

ENT.WorldModel = "models/homigrad/creates/low.mdl"
ENT.WorldSkin = 3

ENT.Name = "lootbox_low"
ENT.w = 4
ENT.h = 1

function ENT:GetRandomCount() return math.random(2,4) end

if SERVER then
    local function GetInventoryManager()
        -- Some hgame loaders register entity folders before the root tier file.
        -- Recover the missing server backend on first use instead of crashing.
        if not inventoryGame then
            include("hgame/1/0_inv/tier_0_sh.lua")
        end
        if inventoryGame and not inventoryGame.CreateWorldInventory then
            include("hgame/1/0_inv/inv_base/backend_sv.lua")
        end
        return inventoryGame
    end

    local function FillLootbox(self)
        if self.hgLootCreated then return end

        local manager = GetInventoryManager()
        if not manager or not manager.CreateWorldInventory then
            ErrorNoHalt("[HG inventory] server backend is not available for lootbox\n")
            return
        end

        local inv = manager.CreateWorldInventory(
            self,
            "inv_storage",
            math.max(tonumber(self.w) or 1,1),
            math.max(tonumber(self.h) or 1,1),
            self.PrintName or self.Name or "Контейнер"
        )
        if not IsValid(inv) then return end

        self.hgLootCreated = true
        self.inv = inv
        if self.CreateLoot then
            local ok,err = pcall(self.CreateLoot,self)
            if not ok then ErrorNoHalt("[HG inventory] lootbox fill failed: " .. tostring(err) .. "\n") end
        else
            for i = 1,math.min(self:GetRandomCount(),(self.w or 1) * (self.h or 1)) do
                local spawnname = self.GetRandom and self:GetRandom()
                if not spawnname and istable(self.InvRandomLoot) and #self.InvRandomLoot > 0 then
                    spawnname = self.InvRandomLoot[math.random(1,#self.InvRandomLoot)]
                end
                if spawnname then inv:AddEnt({spawnname = spawnname,data = {}}) end
            end
        end
    end

    function ENT:OpenInventory(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return false end
        if ply:EyePos():DistToSqr(self:NearestPoint(ply:EyePos())) > 14400 then return false end

        FillLootbox(self)
        if not IsValid(self.inv) then return false end

        self.inv.viewers[ply] = true
        local manager = GetInventoryManager()
        if not manager or not manager.ServerSendInventory then return false end
        manager.ServerSendInventory(self.inv,ply,true)
        return true
    end

    function ENT:Use(activator,caller)
        self:OpenInventory(IsValid(activator) and activator or caller)
    end

    function ENT:AcceptInput(name,activator,caller)
        if string.lower(name or "") ~= "use" then return end
        return self:OpenInventory(IsValid(activator) and activator or caller)
    end
end

local fallbackModel = "models/props_junk/wood_crate001a.mdl"

function ENT:Initialize()
    local model = self.WorldModel

    if not model or not util.IsValidModel(model) then
        ErrorNoHalt("[HG] Invalid lootbox model for " .. tostring(self:GetClass()) .. ": " .. tostring(model) .. "; using " .. fallbackModel .. "\n")
        model = fallbackModel
    end

    self:SetModel(model)
    self:SetSkin(self.WorldSkin or 0)

    if self.WorldMaterial then self:SetMaterial(self.WorldMaterial) end
    if self.WorldScale then self:SetModelScale(self.WorldScale) end
    if self.WorldColor then self:SetColor(self.WorldColor) end

    if SERVER then
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end

    self:Event_Call("Init")
    if self.OnInit then self:OnInit() end
end

if CLIENT then
    local white = Color(255,255,255)

    function ENT:HUDTarget(ply,k,w,h)
        white.a = 255 * k * (1 - inventoryGame.InterfaceAnim)

        draw.SimpleText(L(self:GetNWString("OverrideName",self.Name)),"HS.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

--[[function ENT:Draw()
    self:DrawModel()
    render.DrawWireframeBox(self:GetPos(),self:GetAngles(),self.WorldPhysicsBox[1],self.WorldPhysicsBox[2])
end]]--
