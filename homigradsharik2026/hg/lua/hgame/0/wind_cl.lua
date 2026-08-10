function GetWind() return GetGlobalVector("Wind",Vector()) end

local hg_dev_wind

cvars.CreateDevOption("hg_dev_wind","0",function(value)
    hg_dev_wind = tonumber(value or 0) > 0
end,0,1)

hook.Add("HUDPaint","WindDev",function()
    if not hg_dev_wind then return end

    local arrow = CSM.GetByID("models/maxofs2d/lamp_flashlight.mdl","hg_dev_wind",false)
    arrow.RenderOverride = nil

    local cameraPos = Vector(-40,0,0)
    local size = 150
    
    local wind = GetWind()

    arrow:SetPos(Vector(0,0,0))
    arrow:SetAngles(wind:Angle() - EyeAngles())

    cam.Start3D(cameraPos,(-cameraPos):Angle(),45,ScrW() - size,0,size,size)
        arrow:DrawModel()
    cam.End3D()
    
    draw.SimpleText(math.floor(wind:Length() * 100) / 100 .. " м/c","HS.18",ScrW() - size / 2,size,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
end)

adminPanel.commandRegistry("wind_stop",{"bool"},"game")

event.Add("Think","ParticleGravity & Wind",function()
    local wind = GetWind()

    ParticleGravity:Set(wind):Div(UNITS_TO_METERS):Div(100)
    ParticleGravityWind:Set(ParticleGravity)

    ParticleGravity[3] = ParticleGravity[3] + ParticleGravitySet[3]
end)