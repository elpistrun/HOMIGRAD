local SWEP = oop.Reg("wep_lib_attachment",{"lib_event","lib_duplicate"},true)
if not SWEP then return INCLUDE_BREAK end

attachmentGame.Init(SWEP)

local override

function SWEP:OnAttachmentUpdate()
    if override then return end

    self:Event_Call("Attachment Update")

    self:SetNWTable("Attachments",attachmentGame.GetPkgData(self.attachments))
    if SERVER then inventoryGame.SyncItemByEntity(self) end
end

SWEP:Event_Add("Attachment Update","Upate",function(self)
    attachmentGame.UpdateHooks(self)
end)

SWEP:Event_Add("Init","Attachment",function(self)
    override = true
    attachmentGame.InitParse(self)

    self:SetupNWTable("Attachments")
    override = nil
end,-100)

SWEP:Event_Add("Init","Attachment",function(self)
    self:OnAttachmentUpdate()
end,100)

SWEP:Event_Add("Construct Object","Attachment",function(self)--DEV
    attachmentGame.InputPkgData(self,attachmentGame.GetPkgData(self.attachments))

    self:OnAttachmentUpdate()
end)--DEV

event.Add("AttachmentGameUpdate","Weapon",function()
    oop.Construct(oop.listClass.hg_wep)
end)

if CLIENT then
    concommand.Add("hg_dev_weapon_attachment_get",function()
        local wep = LocalPlayer():GetActiveWeapon()

        for path,key in SortedPairs(wep.attachments) do
            print(path,key[1].keyName,key[1].cosmetic)
        end
    end)
else
    concommand.Add("hg_dev_weapon_attachment_get_sv",function(ply)
        local wep = ply:GetActiveWeapon()

        for path,key in SortedPairs(wep.attachments) do
            print(path,key[1].keyName,key[1].cosmetic)
        end
    end)
end

SWEP:AttUpdate("AttachmentTPIK",function(self,class)
    self.tpik_left_wm_attachment = nil
    self.tpik_right_wm_attachment = nil
end,function(self,att,key)
    if att.tpikLeft then self.tpik_left_wm_attachment = key.path end
    if att.tpikRight then self.tpik_right_wm_attachment = key.path end
end)

function SWEP:GetModelForTPIKLeftHand()
    if self.tpik_left_wm_attachment then
        if SERVER then
            return self.wm
        else
            return self:IsGrabLeftHand() and self.wm and self.wm.attachments[self.tpik_left_wm_attachment] or self.wm
        end
    else
        return self.wm
    end
end

function SWEP:GetModelForTPIKRightHand()
    if self.tpik_right_wm_attachment then
        if SERVER then
            return self.wm
        else
            return self:IsGrabRightHand() and self.wm and self.wm.attachments[self.tpik_right_wm_attachment] or self.wm
        end
    else
        return self.wm
    end
end

SWEP:Event_Add("Construct","Attachment Zero",function(class)
    local class = class[1]
    if not class.MainAttachment then return end

    class.MainAttachment.slots["0"] = class.MainAttachment.slots["0"] or {}

    local slot = class.MainAttachment.slots["0"]
    slot.name = "Main Weapon"
    slot.icon = class.IconOverride
    slot.slots = {[0] = {false}}
end)