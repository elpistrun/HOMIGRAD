local PANEL = oop.Reg("v_scene","v_panel")
if not PANEL then return end

function PANEL:OnInit()
    self.scene = {}

    self.cameraPos = Vector(15,15,15)
    self.cameraAng = (-self.cameraPos):Angle()

    self.cameraFOV = 90
end

PANEL:Event_Add("Remove","Main",function(self)
    for i,ent in pairs(self.scene) do
        if IsValid(ent) then ent:Remove() end
    end
end)

function PANEL:InsertInScene(ent)
    if not IsValid(ent) then return end
    
    ent:SetNoDraw(true)

    self.scene[#self.scene + 1] = ent
    
    if self.OnInsertInScene then self:OnInsertInScene(#self.scene,ent) end

    return #self.scene
end

function PANEL:DrawObjects()
    local i = 1
    local scene = self.scene

    while true do
        local ent = scene[i]
        if not ent then break end
        if not IsValid(ent) then table.remove(scene,i) continue end

        if self.DrawObject then
            self:DrawObject(ent)
        else
            ent:DrawModel()
            ent:FrameAdvance(1)
        end

        i = i + 1
    end
end

function PANEL:OpenScene(w,h)
    local x,y = self:LocalToScreen(0,0)

    self:EnableScissor()
    render.ClearDepth()
    CreateScrene(x,y,w,h,self.cameraFOV,self.cameraPos,self.cameraAng,0.1,512)
        self:DrawObjects()
end

function PANEL:CloseScene()
    CloseScene()
    self:DisableScissor()
end

function PANEL:DrawScene(w,h,noClose)
    self:OpenScene(w,h)
    self:DrawObjects()
    self:CloseScene()
end

function PANEL:Draw(w,h) self:DrawScene(w,h) end