local PANEL = oop.Reg("v_sceneworld","v_scene")
if not PANEL then return end

PANEL:Event_Add("Init","Main2",function(self)
    self.speed = 1
end)

function PANEL:ThinkTransform()
    if self.mouse[MOUSE_RIGHT] then
        local movePos = Vector()

        if input.IsButtonDown(KEY_W) then movePos:Add(Vector(1,0,0)) end
        if input.IsButtonDown(KEY_S) then movePos:Add(Vector(-1,0,0)) end
        if input.IsButtonDown(KEY_A) then movePos:Add(Vector(0,1,0)) end
        if input.IsButtonDown(KEY_D) then movePos:Add(Vector(0,-1,0)) end

        movePos:Rotate(self.cameraAng)

        if input.IsButtonDown(KEY_SPACE) then movePos:Add(Vector(0,0,1)) end
        if input.IsButtonDown(KEY_LCONTROL) then movePos:Add(Vector(0,0,-1)) end

        movePos:Mul(self.speed)

        if input.IsButtonDown(KEY_LSHIFT) then movePos:Div(10) end

        self.cameraPos:Add(movePos)
        
        local moveAng = Angle(-mousedy,mousedx,0)
        self.cameraAng:Add(moveAng)
    end
end

function PANEL:Draw(w,h)
    self:ThinkTransform()

    self:OpenScene(w,h)
    self:DrawObjects()
    self:CloseScene()
end