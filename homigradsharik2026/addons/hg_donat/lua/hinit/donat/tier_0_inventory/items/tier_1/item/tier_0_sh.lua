local ITEM = inventoryManager:ItemReg("item",{"base","base_use"},true)
if not ITEM then return INCLUDE_BREAK end

DonatItemSpawnDelay = 5

ITEM.category = "4_items"

DonatItemsList = DonatItemsList or {}

function ITEM:GetItemInfo()
    return DonatItemsList[self.type or ""]
end

local scripted_ents_Get = scripted_ents.Get
local weapons_Get = weapons.Get

function ITEM:GetItemEntityClass()
    local info = self:GetItemInfo()
    if not info then return end

    local ent = info.ent
    if ent then return scripted_ents_Get(ent),ent end

    ent = info.swep
    if ent then return weapons_Get(ent),ent end
end

function ITEM:GetPrintName()
    local ent,ClassName = self:GetItemEntityClass()
    if not ent then return "Missing Item" end

    return ent.PrintName or ClassName
end

local empty = {}

function ITEM:GetCountUse()
    return self.data.countUse or (self:GetItemInfo() or empty).countUse or 250
end

function ITEM:GetDesc()
    return (self:GetItemEntityClass() or empty).Instructions or ""
end

function ITEM:GetRaryType()
    return (self:GetItemInfo() or empty).raryType or "common"
end

if SERVER then return end

donatPanel.startLockSpawnItem = 0

local _cameraPos = Vector(0,100,0)

function ITEM:DrawObject(w,h,panel,desc)
    local itemInfo = self:GetItemInfo()
    if not itemInfo then draw.SimpleText(self.type,"HS.12",0,h/2,Color(255,0,0)) return end
    
    if itemInfo.WorldModel then
        local mdl = self:GetCSM(itemInfo.WorldModel)

        self:OpenScene(w,h,panel,20)
            mdl:SetPos(itemInfo.WorldVec)
            mdl:SetAngles(itemInfo.WorldAng)
            mdl:DrawModel()
        self:CloseScene(w,h,panel)
    else
        local ent,ClassName = self:GetItemEntityClass()
        if not ent then return end

        if ent.WorldModel and ent.dwsItemPos then
            local x,y = panel:LocalToScreen(0,0)

            self:ScissorSceneStart(panel)

            DrawWeaponSelectionEX({
                self = ent,
                x = x ,
                y = y,
                w = w,
                h = h
            })

            self:ScissorSceneEnd()
        elseif ent.IconOverride then
            surface.SetMaterial(ent.IconOverride)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(0,0,w,h)
        else
            local mat = EntityIcon(ClassName)

            if not mat:IsError() then
                surface.SetMaterial(mat)
                surface.SetDrawColor(255,255,255)
                surface.DrawTexturedRect(0,0,w,h)
            end
        end
    end
    
    self:DrawCountUse(w,h,panel,desc)
end

local colorBlack = Color(0,0,0,245)
local colorWhite = Color(255,255,255,245)

function ITEM:CreateDescPanelItem(panel)
    local item = self
    local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,h/3) end)
    function butt:Draw(w,h)
        local k = math.max((item.errorStart or 0) - RealTime() + 3,0) / 3

        if k > 0 then
            self:SetLock(true)

            surface.SetDrawColor(255,0,0,75)
            surface.DrawRect(0,0,w,h)

            surface.SetDrawColor(255,0,0,200)
            draw.GradientDown(0,0,w,h)

            draw.SimpleText(L(tostring(item.error)),"H.25",w/2,h/2,self:IsHovered() and colorWhite or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            return
        end

        if not LocalPlayer():Alive() then
            self:SetLock(true)

            surface.SetDrawColor(255,0,0,75)
            surface.DrawRect(0,0,w,h)

            surface.SetDrawColor(255,0,0,200)
            draw.GradientDown(0,0,w,h)

            draw.SimpleText("ВЫ МЕРТВЫ","H.45",w/2,h/2,self:IsHovered() and colorWhite or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        elseif donatPanel.startLockSpawnItem + DonatItemSpawnDelay > RealTime() then
            self:SetLock(true)

            surface.SetDrawColor(125,125,125,75)
            surface.DrawRect(0,0,w,h)

            surface.SetDrawColor(125,125,125,200)
            draw.GradientDown(0,0,w,h)

            draw.SimpleText(math.floor((donatPanel.startLockSpawnItem + DonatItemSpawnDelay - RealTime()) * 10) / 10 .. "s","H.45",w/2,h/2,colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            self:SetLock(false)

            surface.SetDrawColor(0,255,0,75)
            surface.DrawRect(0,0,w,h)

            surface.SetDrawColor(0,255,0,200)
            draw.GradientDown(0,0,w,h)

            draw.SimpleText("ВЫДАТЬ","H.45",w/2,h/2,self:IsHovered() and colorWhite or colorBlack,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end

    function butt.OnClick()
        MainThread:CoroutineWrap(function()
            butt:SetLock(true)
            self:SendUse()
            butt:SetLock(false)
        end):Send()
    end
end

function ITEM:CreateDescPanel(panel)
    if panel.type == "shop" then return end
    
    self:CreateDescPanelItem(panel)
end