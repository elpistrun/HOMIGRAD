local SWEP = oop.Get("hg_wep")
if not SWEP then return end

-- Chamber state is gameplay state too: reload animations call this on the
-- server. Previously the setter only existed clientside, which broke reload as
-- soon as an animation reached its load marker.
function SWEP:SetChamber(value)
	self.chamber = value
end

if CLIENT then
	function SWEP:SetChamberFromServer(data)
		if data == "2" then self.chamber = true end
		if data == "1" then self.chamber = false end
		if data == "0" then self.chamber = nil end
	end
end

SWEP:Event_Add("SetupDataTables","Empty",function(self)
	self:NetworkVar("Bool","_GateDelay")
end)

function SWEP:SetGateDelay(value) self:Set_GateDelay(value) end

SWEP:Event_Add("Init","MagazineItem",function(self)
	self:SetupNWTable("MagazineItem")
end,-10)

local override

function SWEP:OnNWTable_MagazineItem(item)
	if not override then self:SetMagazineItem(item) end

	if CLIENT then
		if IsValid(self.wm) then
			if IsValid(self.wm.magazineModel) then CSM.Delete(self.wm.magazineModel) end

			if item and item.path then
				self.wm.magazineModel = self:InitWorldModelMagazine(self.wm,nil,true,item.path)
			end
		end
	end
end

function SWEP:SetMagazineItem(item)
	if item and table.IsEmpty(item) then item = nil end
	
	self.magazineItem = item
	self.magazineItemServer = item

	override = true
	self:SetNWTable("MagazineItem",item)
	override = nil
end

function SWEP:GetMagazineItem() return self.magazineItem end

function SWEP:SetAmmoClass(class)
	self.ammoClass = class ~= "" and class or nil
end

function SWEP:GetAmmoClass()
	return self.ammoClass
end

SWEP:Event_Add("CreateFakeSelfFromItem","GetMagazineItem",function(self,item)
	if item.data and item.data.magazineItem then self.magazineItem = item.data.magazineItem end
end)

function SWEP:IsGateDelay() return self.Primary.ChamberAutoReload and self:Get_GateDelay() end
