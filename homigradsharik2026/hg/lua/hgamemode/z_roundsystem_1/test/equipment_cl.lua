local Level = oop.Get("level_test")
if not Level then return end

function Level:OpenEquipmentMenu()
    if IsValid(Level.EquipmentFrame) then Level.EquipmentFrame:Remove() end

    local frame = oop.CreatePanel("v_frame"):ad(function(self,w,h) self:setSize(w,h) end)
    Level.EquipmentFrame = frame
    frame:MakePopup()

    local scene = CSM.GetByID("models/homigrad/scenes/rp_nycity_day_d_police.mdl","scene1")

    local cameraPoint = Vector(-220,0,-215)

    local eyeAng,eyeAngSet = Angle(0,0,0),Angle(0,0,0)

    function frame:RenderScene(fov)
        render.Clear(0,0,0,0,true,true)
        render.SetColorModulation(1,1,1)
        
        eyeAng:LerpFT(0.8,eyeAngSet)

        local pos = cameraPoint

        render.SuppressEngineLighting(true)
        render.SetLightingMode(1)
        
        cam.Start3D(pos - Vector(32,0,0):Rotate(eyeAng),eyeAng,fov,0,0,ScrW(),ScrH(),0.1,1000)
            scene:DrawModel()
        cam.End3D()

        render.SuppressEngineLighting(false)
        render.SetLightingMode(0)
    end

    local grabX,grabY,grabAng

    function frame:OnMouse(key,value)
        if key == MOUSE_RIGHT then
            if value then
                grabX = gui.MouseX()
                grabY = gui.MouseY()
                grabAng = eyeAngSet:Clone()

            end
        end
    end

    function frame:Step()
        if self.mouse[MOUSE_RIGHT] then
            self:SetCursor("sizeall")

            eyeAngSet[2] = grabAng[2] + (grabX - gui.MouseX()) / 3
            eyeAngSet[1] = grabAng[1] - (grabY - gui.MouseY()) / 3
        else
            self:SetCursor("arrow")

            grabX = nil
            grabY = nil
        end
    end
end

event.Add("RenderScene","Equipment Menu",function(pos,ang,fov)
    if not IsValid(Level.EquipmentFrame) then return end

    Level.EquipmentFrame:RenderScene(fov)

    return true
end,-1)

//Level:OpenEquipmentMenu()