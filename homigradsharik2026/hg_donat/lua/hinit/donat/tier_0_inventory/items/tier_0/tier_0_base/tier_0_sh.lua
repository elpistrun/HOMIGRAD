local ITEM,NoInherit = inventoryManager:ItemReg("base",nil,true)
if not ITEM then return INCLUDE_BREAK end

NoInherit.doNotShowInUI = true

ITEM.desc = "desc_base\nsomething else??"
ITEM.raryType = "common"

function ITEM:GetPrintName() return self.PrintName or self.class end
function ITEM:GetDesc() return self.desc or "" end
function ITEM:GetRaryType() return self.raryType or "common" end

function ITEM:Construct()
    local type = self[1].type

    if type and not DonatCategories[type] then
        DonatCategories[type] = name
    end

    timer.Create("inventoryManager_Items_Construct",0,1,function()
        for steamid64,items in pairs(inventoryManager.listGame) do
            for id,item in pairs(items) do
                inventoryManager:LinkItemObjectByClass(item)
            end
        end
    end)
end

if SERVER then return end

function ITEM:NetUserStart()
    net.Start("donatinventory_item_cmd")
    net.WriteString(AccountSteamID64)
    net.WriteString(tostring(self.id))
end

function ITEM:NetUserRequest(data)
    self:NetUserStart()
    net.WriteTable(data)
    
    return self:NetWait()
end

function ITEM:NetWait()
    net.CoroutineSend("donatinventory_item_cmd")

    local success,data = net.ReadBool(),net.ReadTable()
    if not success then chat.AddText(Color(200,0,0),"item " .. self.ClassName .. " failed: " .. tostring(data.msg or "unkown")) end

    return success,data
end

net.Receive("donatinventory_item_cmd",function(len,ply)
    local item = inventoryManager.listGame[net.ReadString()][net.ReadString()]
    if not item then return end

    if not net.CoroutineResume("donatinventory_item_cmd") then
        if item.InputUserCommand then item:InputUserCommand() end
    end
end)

// Draw

local delaySoundHover = 0
local delaySoundClick = 0

function ITEM:GetColor()
    return DonatItemsRaryData[self:GetRaryType()][1]
end

function ITEM:DrawIcon(w,h,panel,fontText)
    panel.zoom = LerpFTLess(0.8,panel.zoom or 0,panel:IsHovered() and 1 or 0,0.01)

    local raryType = self:GetRaryType()
    local raryData = DonatItemsRaryData[raryType]
    if raryType != "common" then
        surface.SetDrawColor(0,0,0,200)
        surface.DrawRect(0,0,w,h)
    end

    local color = self:GetColor()
    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,125)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,raryType != "common" and 190 or 100)
    surface.SetBG(raryData[4])
    draw.BG2(2,2,w - 4,h - 4)

    local size = h / 1.2
    if raryType != "common" then
        size = size * (1 - math.cos(RealTime()) * 0.25)
    end
    surface.SetDrawColor(color.r,color.g,color.b,64)
    draw.GradientDown(0,h - size + 1,w,size)

    local HBar = (fontText == "H.12" and 20 or 28) + panel.zoom * 4

    self:DrawObject(w,h - HBar,panel)

    if self.DrawBar then
        self:DrawBar(w,h,panel,HBar)
    else
        HBar = (fontText == "H.12" and 20 or 28) + panel.zoom * 4
        surface.SetDrawColor(color.r,color.g,color.b,255)
        surface.DrawRect(0,h - HBar,w,HBar)

        surface.SetDrawColor(125,125,125,32 * panel.zoom)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText(L(self:GetPrintName()),fontText or "H.18",w/2,h - HBar/2,raryData[2],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.Frame(0,h - HBar,w,HBar,cframe1,cframe2)
    end

    draw.Frame(0,0,w,h,cframe1,cframe2)

    if panel:IsHovered() then
        if not panel.hover then
            panel.hover = true

            if delaySoundHover < RealTime() then
                delaySoundHover = RealTime() + 0.025

                self:EmitSoundHover()
            end
        end
    else
        panel.hover = nil
    end

    if panel:IsDown() then
        if not panel.isDown then
            panel.isDown = true

            if delaySoundClick < RealTime() then
                delaySoundClick = RealTime() + 0.1

                self:EmitSoundClick()
            end
        end
    else
        panel.isDown = nil
    end

    if self.DrawOver then self:DrawOver(w,h,panel) end
end

function ITEM:DrawObject(w,h)

end

local colorGray = Color(125,125,125,125)

function ITEM:DrawBigIcon(w,h,panel)
    local raryType = self:GetRaryType()
    local raryData = DonatItemsRaryData[raryType]

    local color = self:GetColor()
    surface.SetDrawColor(color.r / 2.5,color.g / 2.5,color.b / 2.5,raryType != "common" and 190 or 100)
    surface.SetBG(raryData[4])
    draw.BG2(2,2,w - 4,h - 4)

    local size = h / 1.2
    if raryType != "common" then
        size = size * (1 - math.cos(RealTime()) * 0.25)
    end
    surface.SetDrawColor(color.r,color.g,color.b,64)
    draw.GradientDown(0,h - size + 1,w,size)

    self:DrawObject(w,h,panel,true)
    
    draw.SimpleText(self:GetPrintName(),"HS.25",w/2,h * 0.075,raryData[3],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    if self.id then
        draw.SimpleText("#" .. self.id,"HS.12",8,8,colorGray)
        draw.SimpleText("#" .. raryData[7],"HS.12",8,24,colorGray)
    else
        draw.SimpleText("#" .. raryData[7],"HS.12",8,8,colorGray)
    end
end

function ITEM:DrawDesc(w,h,panel)

end

function ITEM:EmitSoundHover()
    local snds = DonatItemsRaryData[self:GetRaryType()][5]

    LocalPlayer():EmitSound(TypeID(snds) == TYPE_TABLE and snds[math.random(1,#snds)] or snds,45,math.random(243,255),0.1)
end

function ITEM:EmitSoundClick()
    local snds = DonatItemsRaryData[self:GetRaryType()][6]

    LocalPlayer():EmitSound(TypeID(snds) == TYPE_TABLE and snds[math.random(1,#snds)] or snds,45,math.random(243,255),0.1)
end


local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)

function ITEM:ScissorSceneStart(panel)
    local leftx,topy,bottomx,righty = panel:GetScreenViewData()
    render.SetScissorRect(leftx,topy,bottomx,righty,true)
end

function ITEM:ScissorSceneEnd()
    render.SetScissorRect(0,0,0,0,false)
end

function ITEM:OpenScene(w,h,panel,fov,ang,pos,cameraPos)
    local size = math.min(w,h)
    local x,y = panel:LocalToScreen(0,0)
    
    y = math.max(y,0)
    ang = Angle(0,180,0):Add(ang or angZero)

    render.ClearDepth()
    render.SetColorModulation(1,1,1)
    
    cam.Start3D(Vector(125,0,0) + (pos or vecZero),ang,fov - (panel.zoom or 0),x + w/2 - size/2,y + h/2 - size/2,size,size,1,512)
    render.SuppressEngineLighting(true)
    render.SetLightingOrigin(vecZero)
    render.ResetModelLighting(0.4,0.4,0.4)
    render.SetModelLighting(0,1,1,1)

    self:ScissorSceneStart(panel)
end

function ITEM:CloseScene(w,h,panel)
    render.SuppressEngineLighting(false)
    cam.End3D()
    self:ScissorSceneEnd()
end

function ITEM:GetCSM(model,addID)
    local mdl,isCreated = CSM.GetByID(model,tostring(self) .. tostring(addID or ""))
    mdl:SetNoDraw(true)

    if addID == true then
        self.mdlDesc = mdl
    else
        self.mdl = mdl
    end

    return mdl,isCreated
end

function ITEM:ConnectPanel(panel)
    function panel:OnWheel(wheel)
        panel.wheel = (panel.wheel or 0) + wheel
    end
end