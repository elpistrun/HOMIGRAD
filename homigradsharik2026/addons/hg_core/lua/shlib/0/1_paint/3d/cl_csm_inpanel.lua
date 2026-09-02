local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)

local cam_Start3D = cam.Start3D
local cam_IgnoreZ = cam.IgnoreZ

local render_SuppressEngineLighting = render.SuppressEngineLighting
local render_SetLightingOrigin = render.SetLightingOrigin
local render_ResetModelLighting = render.ResetModelLighting
local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend
local render_SetModelLighting = render.SetModelLighting

local cam_End3D = cam.End3D

local DrawModel = ClientsideModel("models/hunter/plates/plate.mdl",RENDERGROUP_OPAQUE)
DrawModel:SetNoDraw(true)

function DrawModelInFrame(x,y,w,h,mdl,fov,cameraPos,cameraAng,itemPos,itemAng,doNotClose)
    cameraPos = cameraPos or vecZero
    itemAng = itemAng or angZero
    itemPos = itemPos or vecZero
    itemPos = Vector(itemPos[1],itemPos[2],itemPos[3])
    
    if TypeID(mdl) == TYPE_ENTITY then
        drawModel = mdl
    else
        drawModel = DrawModel
        drawModel:SetModel(mdl)
    end

    itemPos:Sub(drawModel:OBBCenter())

    cam_Start3D(cameraPos,cameraAng,fov or 45,x,y,w,h)
        --cam_IgnoreZ(true)
        render_SuppressEngineLighting(true)

        render_SetLightingOrigin(vecZero)
        render_ResetModelLighting(50 / 255,50 / 255,50 / 255)
        render_SetColorModulation(1,1,1)
        render_SetBlend(255)

        render_SetModelLighting(4,1,1,1)

        drawModel:SetRenderAngles(itemAng)
        local dir = itemPos
        dir:Rotate(itemAng)

        drawModel:SetRenderOrigin(dir)
        drawModel:DrawModel()

        render_SetColorModulation(1,1,1)
        render_SetBlend(1)
        render_SuppressEngineLighting(false)
        --cam_IgnoreZ(false)
    if not doNotClose then cam_End3D() end
end

function CreateScrene(x,y,w,h,fov,cameraPos,cameraAng,znear,zfar)
    render.ClearDepth(true)--я в ахуе
    
    cam_Start3D(cameraPos,cameraAng,fov or 45,x,y,w,h,znear or 0.01,zfar)
        render_SuppressEngineLighting(true)

        render_SetLightingOrigin(vecZero)
        render_ResetModelLighting(50 / 255,50 / 255,50 / 255)
        render_SetColorModulation(1,1,1)
        render_SetBlend(255)

        render_SetModelLighting(4,1,1,1)
end

function CloseScene()
        render_SetColorModulation(1,1,1)
        render_SetBlend(1)
        render_SuppressEngineLighting(false)
    cam_End3D()
end