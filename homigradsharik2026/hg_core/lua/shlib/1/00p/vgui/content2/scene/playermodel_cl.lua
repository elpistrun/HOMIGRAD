local PANEL = oop.Reg("v_playermodel","v_scene")
if not PANEL then return end

VGUIPlayerModel = {}

PANEL:Event_Add("Init","PlayerModel",function(self)
    self.fovMin = 7
    self.fovMax = 20

    self.cameraFOV = self.fovMax

    self.cameraAng = Angle(0,180,0)
    self.cameraPos = Vector(125,0,0)

    self.znear = 1

    VGUIPlayerModel[self] = true

    self.fakePly = customEnts.Create("player_fake")
end)

PANEL:Event_Add("Remove","Remove Link VGUI",function(self)
    if IsValid(self.fakePly) then self.fakePly:Remove() end

    VGUIPlayerModel[self] = nil
end)

function PANEL:SetModel(mdl) self.fakePly:SetModel(mdl) end

function PANEL:SetPlayer(ply)
    self.ply = ply

    local fakePly = self.fakePly

    fakePly:SetModel(ply:GetModel())

    for id = 0,ply:GetNumBodyGroups() - 1 do fakePly:SetBodygroup(id,ply:GetBodygroup(id)) end
    fakePly:SetSkin(ply:GetSkin())
    fakePly:SetPlayerColor(ply.GetPlayerColor and ply:GetPlayerColor() or Vector(1,1,1))

    fakePly.link = ply

    self.mdl = fakePly:GetCSM()

    return mdl
end

local vecDown = Vector(0,0,-35)
function PANEL:Draw(w,h)
    if self.PreDraw then self:PreDraw(w,h) end
    
    local mdl = self.fakePly:GetCSM()
    self.mdl = mdl
    if not IsValid(mdl) then return end

    mdl:SetPos(vecDown)

    local ply = self.ply

    mdl:SetEyeTarget(Vector(300,0,0))
    
    if IsValid(ply) then
        for i = 0,ply:GetFlexNum() - 1 do
            mdl:SetFlexWeight(i,ply:GetFlexWeight(i))
        end
    end

    self:OpenScene(w,h)
    self:DrawObjects()

    if IsValid(self.fakePly) then
        self.fakePly:Render()
    end

    self:CloseScene()
end

function PANEL:OnWheel(wheel)
    if input.IsButtonDown(KEY_LSHIFT) then
        self.cameraFOV = math.Clamp(self.cameraFOV - wheel * 2,self.fovMin,self.fovMax)
    else
        self.cameraPos[3] = self.cameraPos[3] + wheel * 5
    end
end

function PANEL:Step()
    if self.mouse[MOUSE_RIGHT] then
        local mdl = self.mdl
        if not IsValid(mdl) then return end
        
        local ang = mdl:GetAngles()
        ang[2] = ang[2] - mousedx
        ang:Normalize()

        mdl:SetAngles(ang)
        
        self:SetCursor("sizewe")
    else
        self:SetCursor("arrow")
    end
end