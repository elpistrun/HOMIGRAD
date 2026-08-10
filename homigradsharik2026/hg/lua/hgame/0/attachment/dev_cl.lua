local color = Color(255,0,0)
attachmentGameAng = attachmentGameAng or Angle()
attachmentGameLen = attachmentGameLen or 30

local NAME = "laser"

event.Add("PreRender","attachmentGame.WeaponExample",function()
    if true or gui.IsGameUIVisible() then return end
    
    gui.EnableScreenClicker(true)

    if system.HasFocus() and input.IsMouseDown(MOUSE_LEFT) then
        attachmentGameAng[1] = attachmentGameAng[1] - mousedy
        attachmentGameAng[2] = attachmentGameAng[2] + mousedx
    end
   
    attachmentGameLen = attachmentGameLen - (input.IsButtonDown(KEY_W) and 1 or input.IsButtonDown(KEY_S) and -1 or 0) * FrameTime() * 60

    render.SuppressEngineLighting(true)
    cam.Start3D(Vector(-attachmentGameLen,0,0):Rotate(attachmentGameAng),attachmentGameAng,90)

    for path,att in pairs(attachmentGame.weaponManual[NAME]) do
        local mdl = CSM.GetByID(att.mdl,att.mdl .. "attachmentGame.WeaponExample")
        mdl:SetPos(att.vec)
        mdl:SetAngles(att.ang)
        mdl:DrawModel()
    end

    render.SetColorMaterial()

    render.DrawSphere(Vector(),0.1,16,16,color)

    render.SuppressEngineLighting(false)
    cam.End3D()

    return true
end)