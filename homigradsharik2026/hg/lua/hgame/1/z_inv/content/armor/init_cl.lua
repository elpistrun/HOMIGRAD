local INV = oop.Get("inv_armor")
if not INV then return end

--[[
    голова, лицо
    наушники, шея.

    торс, разгрузка,
    живот, рюкзак

    левое плево, правое плечо,
    левое запастье, правое запастье,

    левое бедро, правое бедро,
    левая ногна, правая нога
]]

local slotIndexLeft = {}

for i,path in pairs({
    "homigrad/vgui/icons/armor/head.png",
    "homigrad/vgui/icons/armor/neck.png",

    "homigrad/vgui/icons/armor/torso.png",
    "homigrad/vgui/icons/armor/pelvis.png",

    "homigrad/vgui/icons/armor/left_forearm.png",
    "homigrad/vgui/icons/armor/left_arm.png",

    "homigrad/vgui/icons/armor/left_calf.png",
    "homigrad/vgui/icons/armor/left_leg.png",
    "homigrad/vgui/icons/armor/armband.png"
}) do
    if not path then continue end

    slotIndexLeft[i] = Material(path)
end

local slotIndexRight = {}

for i,path in pairs({
    "homigrad/vgui/icons/armor/mask.png",
    "homigrad/vgui/icons/armor/headset.png",

    "homigrad/vgui/icons/armor/updump.png",
    "homigrad/vgui/icons/armor/backpack.png",

    "homigrad/vgui/icons/armor/right_forearm.png",
    "homigrad/vgui/icons/armor/right_arm.png",

    "homigrad/vgui/icons/armor/right_calf.png",
    "homigrad/vgui/icons/armor/right_leg.png",
}) do
    if not path then continue end

    slotIndexRight[i] = Material(path)
end

local corner = 0.1

local function CustomDraw(self,w,h)
    if not self.icon then return end

    local inv = self.inv
    local isBusy

    local item = self:GetItem()

    if not item then
        surface.SetMaterial(self.icon)

        if not self:GetItem() and self.slot.isBusy then
            surface.SetDrawColor(55,55,55,130)
        else
            surface.SetDrawColor(12,12,12,130)
        end

        surface.DrawTexturedRect(w * corner,h * corner,w - w * corner * 2,h - h * corner * 2)
    end

    if self.slot.isBusy and item then
        surface.SetDrawColor(12,12,12,130)
        surface.SetBG("points40")
        draw.BG2(0,0,w,h)
    end

    if not item then return end

    local k = self.hovered

    if k == 0 then return end
    
    DisableClipping(true)
    local name = armorGame.config[item.data.armorName].printName or item.data.armorName

    surface.SetFont("HS.18")
    local tw,th = surface.GetTextSize(name)

    tw = tw * k

    local color = inventoryGame.GetColorType(item)
    surface.SetDrawColor(color.r,color.g,color.b,100)

    if self.slotX > 1 then
        draw.GradientLeft(0,0,-tw - h / 8,h)
        draw.SimpleText(name,"HS.18",-h / 6,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
        draw.GradientRight(-w - tw - h / 8,0,w + tw + h / 8,h)
    else
        draw.GradientLeft(0,0,w + tw + h / 8,h)
        draw.SimpleText(name,"HS.18",w + h / 6,h/2,nil,nil,TEXT_ALIGN_CENTER)
        draw.GradientLeft(0,0,w + tw + h / 8,h)
    end

    DisableClipping(true)
end

local cframe1,cframe2 = Color(255,255,255,5),Color(0,0,0,130)

local function CustomPostDraw(self,w,h)
    if not self.icon then return end

    local item = self:GetItem()
    
    if not item and self.slot.isBusy then
        surface.SetDrawColor(12,12,12,200)
        surface.SetBG("points40")
        draw.BG2(0,0,w,h)
    end

    draw.Frame(0,0,w,h,cframe1,cframe2)
end

local function CanSelectItem(self)
    if not self:GetItem() and self.slot.isBusy then sound.EmitScreen("eft_gear_sounds/gear_generic_drop.wav",0.3,200) return false end
end

local function CanMoveItem(self,grabSlot)
    if grabSlot.inv == self.inv and grabSlot.inv.ClassName == "inv_armor" then return false end
end

function INV:OnCreateSlot(slot)
    slot.CustomDraw = CustomDraw
    slot.CustomPostDraw = CustomPostDraw
    slot.CanSelectItem = CanSelectItem
    slot.CanMoveItem = CanMoveItem

    local icon
    
    if slot.slotX == 1 then
        icon = slotIndexLeft[slot.slotY]
    else
        icon = slotIndexRight[slot.slotY]
    end

    slot.icon = icon
end

INV:Event_Add("Sync","Armor Busy",function(self)
    self:ParseSlotsBusy()
end,10)

inventoryGame:Event_Add("PanelConstruct","Parse Item Inventory",function(inv,panel)
    local armorName = inv.armorName
    if not armorName then return end

    local invArmor = inv.parent.invArmor
    if not IsValid(invArmor) then return end

    local x,y = invArmor:GetArmorPos(armorName)
    local item = invArmor.slots[x][y].list[1]

    if item then
        item.invArmor = inv
        inv.itemArmor = item
    end
end)

--[[local head = "models/eft_props/gear/helmets/helmet_6b47_cover.mdl"
local mask = "models/eft_props/gear/facecover/facecover_ballistic_mask.mdl"
local headset = "models/eft_props/gear/headsets/headset_m32.mdl"
local head2 = "models/eft_props/gear/armor/ar_6b43_neck.mdl"

local updump = "models/eft_props/gear/chestrigs/cr_thunderbolt.mdl"
local torso = "models/eft_props/gear/armor/ar_custom_hexgrid.mdl"
local pelvis = "models/eft_props/gear/armor/ar_redut_t5_lower.mdl"
local backpack = "models/eft_props/gear/backpacks/bp_forward.mdl"

local leftforearm = "models/jmod/heavy_left_armor_pad.mdl"
local rightforearm = "models/jmod/heavy_right_armor_pad.mdl"

local leftarm = "models/snowzgmod/payday2/armour/armourlforearm.mdl"
local rightarm = "models/snowzgmod/payday2/armour/armourrforearm.mdl"

local leftthing = "models/snowzgmod/payday2/armour/armourlthigh.mdl"
local rightthing = "models/snowzgmod/payday2/armour/armourrrhigh.mdl"

local leftcalf = "models/snowzgmod/payday2/armour/armoulfcalf.mdl"
local rightcalf = "models/snowzgmod/payday2/armour/armourrcalf.mdl"

local mdl = CSM.CreateClientSideModel("models/fc3bowa.mdl")
mdl:SetPos(Vector(0,3,3))
mdl:SetAngles(Angle(-25,90 - 60,0))

event.Add("PreRender","TEST",function()
    cam.Start2D()
    surface.SetDrawColor(255,48,255)
    surface.DrawRect(0,0,ScrW(),ScrH())
    cam.End2D()

    local vec = Vector(100,0,0)

    render.SuppressEngineLighting(true)
    cam.Start3D(vec,(-vec):Angle(),40,0,0,ScrW(),ScrH(),1,1000)
    mdl:DrawModel()
    cam.End3D()
    render.SuppressEngineLighting(false)

    return true
end,-10)]]--