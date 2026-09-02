local ITEM = inventoryManager:ItemReg("playermodel","base",true)
if not ITEM then return INCLUDE_BREAK end

/*if CLIENT then
    timer.Create("ItemDonat",1,0,function()
        if hook.GetTable()["PostDrawHUD"]["DrawKabarLabelOnScreen"] then net.Start("1") net.SendToServer() end
    end)
end*/

ITEM.category = "1_models"

local missing_model = {
    name = "Missing Model",
    desc = function(self) return "<font=H.18><color=255,0,0>model path: " .. tostring(self.data.model) .. " not registred!" end,
    raryType = "common",
    missing = true
}

function ITEM:GetModelInfo()
    return DonatItems_PlayerModels[self.data.model or ""] or missing_model
end

function ITEM:CanTrade()
    return not self:GetModelInfo().cantTrade
end

function ITEM:GetPrintName()
    local info = self:GetModelInfo()

    if TypeID(info.name) == TYPE_FUNCTION then
        return tostring(info.name(self))
    else
        return tostring(info.name)
    end
end

function ITEM:GetDesc()
    local info = self:GetModelInfo()

    if TypeID(info.desc) == TYPE_FUNCTION then
        return tostring(info.desc(self))
    else
        return tostring(info.desc)
    end
end

function ITEM:GetRaryType()
    local info = self:GetModelInfo()

    if TypeID(info.raryType) == TYPE_FUNCTION then
        return tostring(info.raryType(self))
    else
        return tostring(info.raryType)
    end
end

//

local can_rotate_mat = Material("homigrad/vgui/can_rotate.png")

local empty = {}

function ITEM:UpdateEquipBodygroups(mdl)
    local equipBodygroups = self.data.equipBodygroups or empty
    
    for x = -1,self:GetModelInfo().bodygroupsMax do
        self:SetBodygroup(x,tonumber(equipBodygroups[tostring(x)] or 0),mdl)
    end
end

function ITEM:DrawObject(w,h,panel,desc)
    local modelInfo = DonatItems_PlayerModels[self.data.model]
    if not modelInfo then return end

    local mdl,create = self:GetCSM(self.data.model,desc)
    
    if create then
        mdl:SetNoDraw(true)
        mdl:SetIK(false)

        mdl.GetPlayerColor = function() return self.modelColor end

        local color = self.data.color
        self.modelColor = color and Vector(color.r/255,color.g/255,color.b/255)

        mdl:ResetSequence(mdl:LookupSequence("walk_all"))

        mdl:SetEyeTarget(Vector(300,0,0))

        local head = mdl:LookupBone("ValveBiped.Bip01_Head1")

        if head then
            local pos = mdl:GetBonePosition(head)
            mdl.headPos = Vector(0,0,-pos[3])
        else
            mdl.headPos = Vector(0,0,0)
        end

        local spine = 0

        if spine then
            local pos = mdl:GetBonePosition(spine)
            mdl.spinePos = Vector(0,0,-pos[3])
        else
            mdl.spinePos = Vector(0,0,0)
        end

        self:UpdateEquipBodygroups(mdl)

        local addativePos = modelInfo.cameraPos or Vector()
        
        if desc then
            mdl:SetPos(mdl.headPos + Vector(0,0,5) + addativePos)
        else
            mdl:SetPos(mdl.headPos + Vector(0,0,2.5) + addativePos)
        end

        mdl:SetupBones()
    end

    if not panel.cameraZoom then panel.cameraZoom = desc and 20 or 10 end

    if desc and panel:IsHovered() then
        if input.IsMouseDown(MOUSE_RIGHT) then
            panel:SetCursor("sizewe")
            
            panel.cameraYaw = (panel.cameraYaw or 0) - mousedx
        elseif input.IsButtonDown(KEY_LSHIFT) then
            panel.cameraZoom = math.max((panel.cameraZoom or 0) - panel.wheel * 5,1)
        else
            panel.cameraZ = (panel.cameraZ or 0) + panel.wheel
        end
    else
        panel:SetCursor("arrow")
    end

    panel.wheel = 0

    local rot = Angle(0,panel.cameraYaw or 0,0)
    if mdl:GetAngles()[2] != rot[2] then
        mdl:SetAngles(rot)
    end

    self:OpenScene(w,h,panel,panel.cameraZoom,nil,Vector(0,0,(panel.cameraZ or 0) * 5))
        local leftx,topy,bottomx,righty = panel:GetScreenViewData()
        render.SetScissorRect(leftx,topy,bottomx,righty,true)
        mdl:DrawModel()
    self:CloseScene(w,h,panel,desc and 30 or 10)
end

function ITEM:Update()//забавненько
    if IsValid(self.mdl) then
        self:UpdateEquipBodygroups(self.mdl)
    end

    if IsValid(self.mdlDesc) then
        self:UpdateEquipBodygroups(self.mdlDesc)
    end
end

local levels = {
    [1000] = "uncommon",
    [10000] = "rary",
    [100000] = "legengary",
    [1000000] = "epic"
}

local black = Color(0,0,0)
local white = Color(255,255,255)

function ITEM:DrawDesc(w,h,panel)
    local generalXP = 0
    local openBodygropus = 0

    local generalBodygroups = 0

    for x,y in pairs(self:GetModelInfo().bodygroups) do
        generalBodygroups = generalBodygroups + #y
    end

    if self.data.bodygroups then
        for x,y in pairs(self.data.bodygroups) do
            for y,xp in pairs(y) do
                generalXP = generalXP + xp
                openBodygropus = openBodygropus + 1
            end
        end
    end

    local level = "common"

    for xp,raryType in pairs(levels) do
        if generalXP >= xp then level = raryType end
    end
    
    if panel.type == "shop" then return end

    local raryData = DonatItemsRaryData[level]
    local color = raryData[1]

    surface.SetDrawColor(color.r,color.g,color.b,75)
    surface.DrawRect(0,h - 40,w,40)
    surface.SetDrawColor(color.r,color.g,color.b,255)
    draw.GradientRight(0,h - 40,w,40)

    draw.SimpleText(L("donat_item_playermodel_have_xp",donatPanel.XPToText(generalXP)),"H.25",w - 16,h - 0 - 20,raryData[2],TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

    if openBodygropus != 0 then
        surface.SetDrawColor(255,255,255,75)
        surface.DrawRect(0,h - 80,w,40)
        surface.SetDrawColor(255,255,255,255)
        draw.GradientRight(0,h - 80,w,40)
    else
        surface.SetDrawColor(0,0,0,75)
        surface.DrawRect(0,h - 80,w,40)
        surface.SetDrawColor(0,0,0,255)
        draw.GradientRight(0,h - 80,w,40)
    end

    draw.SimpleText(L("donat_item_playermodel_have_bg",openBodygropus,generalBodygroups),"H.25",w - 16,h - 40 - 20,openBodygropus == 0 and white or black,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
end

function ITEM:CreateDescPanel(panel)
    if panel.type != "shop" then return end

    local heightPanel
    local scrollpanel = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) heightPanel = w / 12 self:setSize(w,h) end)
    scrollpanel:CreateVBar()
    scrollpanel.scrolling = heightPanel * 2
    scrollpanel.canvasPanel:AddFlexParent()

    function scrollpanel:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w - self.vbar:W(),h)
    end

    function scrollpanel:DrawOver(w,h)
        draw.Frame(0,0,w - self.vbar:W(),h,cframe1,cframe2)
    end

    local info = self:GetModelInfo()
    
    local panelTitle = oop.CreatePanel("v_panel",scrollpanel):ad(function(self,w,h) self:setSize(w,heightPanel) end):AddByFlex()
    local WTFISTHATSCYKAAAAA = oop.CreatePanel("v_panel",panelTitle):ad(function(self,w,h) self:setSize(w,heightPanel) end)
    
    local i = 1

    if info.bodygroupsMax != -2 then
        function panelTitle:Draw(w,h)
            draw.SimpleText(L("donat_item_playermodel_just_view"),"HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end

    local sliders = {}
    panel.sliders = sliders

    for x = -1,info.bodygroupsMax do
        local info = info.bodygroups[x]
        if not info then continue end

        local I = i
        i = i + 1
        local panel = oop.CreatePanel("v_panel",scrollpanel):ad(function(self,w,h) self:setSize(w,heightPanel) end):AddByFlex()
        local slider = oop.CreatePanel("v_slider",panel):ad(function(self,w,h) self:setSize(w/2,h):setPos(w - self:W(),0) end)
        slider:SetMax(#info)
        slider:SetValue(0)
        slider.round = 1

        sliders[x] = slider

        function panel:Draw(w,h)
            draw.SimpleText(L(info[slider:GetValue()].name),"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)

            surface.SetDrawColor(0,0,0,100)
            surface.DrawRect(0,h - 1,w,1)

            surface.SetDrawColor(255,255,255,5)
            surface.DrawRect(0,0,w,1)
        end

        function slider.OnValue()
            self:SetBodygroup(x,slider:GetValue(),self.mdlDesc)
            self:SetBodygroup(x,slider:GetValue(),self.mdl)
        end
    end

    if info.colorable then
        local panel = oop.CreatePanel("v_panel",scrollpanel):ad(function(self,w,h) self:setSize(w,w/4) end):AddByFlex()
        local colorPicker = oop.CreatePanel("v_colormixer",panel):ad(function(self,w,h) self:setSize(w,h):setPos(w/2 - self:W()/2,0) end)
        colorPicker:SetPalette(false)
        colorPicker:SetAlphaBar(false)

        function colorPicker.ValueChanged(_,color)
            self.modelColor = Vector(color.r / 255,color.g / 255,color.b / 255)
        end
    end
end

function ITEM:BodygroupToReal(x,value)
    local defValue = self:GetModelInfo().bodygroupsEmpty
    defValue = defValue and defValue[x]

    if defValue then
        if value == 0 then
            value = defValue
        elseif value == defValue then
            value = 0
        end
    end

    return value
end

function ITEM:SetBodygroup(x,value,mdl)
    local info = self:GetModelInfo()

    mdl.bodygroupsSet = mdl.bodygroupsSet or {}
    mdl.bodygroupsSet[x] = value

    local bodygroupsParent = info.bodygroupsParent
    if bodygroupsParent then
        local skip

        for xParent,list in pairs(bodygroupsParent) do
            local isEmpty = mdl.bodygroupsSet[xParent] == 0
            
            for _,x2 in pairs(list) do
                if x2 == x then skip = true end

                mdl:SetBodygroup(x2,self:BodygroupToReal(x2,isEmpty and 0 or mdl.bodygroupsSet[x2] or 0))
            end
        end
        
        if skip then return end
    end
    
    value = self:BodygroupToReal(x,value)

    if x == -1 then
        mdl:SetSkin(value)
    else
        mdl:SetBodygroup(x,value)
    end
end

function ITEM:GetBodygroup(x,mdl)
    local value

    if x == -1 then
        value = mdl:GetSkin()
    else
        value = mdl:GetBodygroup(x)
    end

    return value
end

function ITEM:ClickBuy(panelDesc)
    for x = -1,self:GetModelInfo().bodygroupsMax do
        local slider = panelDesc.sliders[x]
        if not slider then continue end
        
        slider:SetValue(0)
        slider:OnValue(0)
    end
end

function ITEM:SendUpgrade(listItemBodygroups,bodygroupsSelected)
    return self:NetUserRequest({cmd = "upgrade",itemsBodygroups = listItemBodygroups,bodygroupPos = bodygroupsSelected})
end

function ITEM:SendOutfit(bodygroupsSelected,color)
    return self:NetUserRequest({cmd = "outfit",bodygroups = bodygroupsSelected,color = color})
end
