local ENT = oop.Reg("ent_resource_base",{"base_entity"},true)
if not ENT then return INCLUDE_BREAK end

ENT.PrintName = "Resource Base"
ENT.Category = L("entities_category_resources")
ENT.Spawnable = false

ENT.InvCountLimit = 10
ENT.InvCountIgnoreLimit = true

function ENT:InvMax() return self.InvCountLimit end
function ENT:GetInvCount() return self:GetNWInt("resource") end
function ENT:SetInvCount(value) return self:SetNWInt("resource",value) end

function ENT:Initialize()
    if self.WorldModel then self:SetModel(self.WorldModel) end
    if selfWorldMaterial then self:SetMaterial(self.WorldMaterial) end
    if self.SetModelScale then self:SetModelScale(self.WorldScale or 1) end
    if self.WorldColor then self:SetColor(self.WorldColor or white) end

    if SERVER then
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:DrawShadow(false)

        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        
        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:SetMass(20)
            phys:Wake()
        end
    end
    
    self:SetInvCount(1)

    self:Event_Call("Init")

    if self.OnInit then self:OnInit() end
end

function inventoryGame.TakeResource(item,count)
    if not item or not item.data or not item.data.count then return 0 end
    local sub = math.min(item.data.count,count)
    
    item.data.count = item.data.count - count

    if item.data.count <= 0 then
        inventoryGame.ItemDelete(item)
    else
        if SERVER then inventoryGame.SyncItem(item) end
    end

    return sub
end

if SERVER then return end

function ENT:invUI_Draw(panel,item)
    if not self.InventoryIcon or not IsValid(panel) then return end
    
	surface.SetMaterial(self.InventoryIcon)
	
	local w,h = panel:W(),panel:H()
	local size = h - 14 + (panel.hovered or 0) * 5

	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)

	if not panel.drawtype then
		if (item.count or 0) <= 0 then return end
		
		draw.SimpleText("x" .. item.count,"InvFont",4,2)
	end
end

local white = Color(255,255,255)

function ENT:HUDTarget(ply,k,w,h)
    white.a = 255 * k * (1 - inventoryGame.InterfaceAnim)

    draw.SimpleText(L(self.PrintName) .. " " .. (self.InvCountLimit and self:GetInvCount()),"H.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end