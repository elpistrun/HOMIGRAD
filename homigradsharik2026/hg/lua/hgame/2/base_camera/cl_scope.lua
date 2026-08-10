local SWEP = oop.Get("wep_lib_camera")
if not SWEP then return end

local rtRenderTarget = GetRenderTarget("weapon_scope_renderscene" .. os.time(),ScrW(),ScrH())

local rtRenderTarget_mat = CreateMaterial("weapon_scope_renderscene_mat" .. os.time(),"UnlitGeneric")
rtRenderTarget_mat:SetTexture("$basetexture",rtRenderTarget)
rtRenderTarget_mat:Recompute()

DeterminateLODAlways = nil

event.Add("PreRenderScene","ZWeapon RT",function()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or not wep.PreRenderScene then return end

    wep:PreRenderScene()
end,1000)

local pp_cc_tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0.07,
    ["$pp_colour_contrast"] = 1.05,
    ["$pp_colour_colour"] = 1.27,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

local hg_fast_scope

cvars.CreateOption("hg_fast_scope","0",function(value)
    hg_fast_scope = tonumber(value or 0) > 0
end,0,1)

function SWEP:PreRenderScene()
    local scopeConfig = self:GetScopeInfoForRender()
    if not scopeConfig or (scopeConfig.ScopeZoom or 0) == 0 then return end

    local oldFOV = RenderView.fov
    local fov = scopeConfig.ScopeZoom
    fov = fov / RenderView.aspectratio

    local znear = 3

    if hg_fast_scope then
        RenderView.preScopeFov = RenderView.fov
        RenderView.fov = Lerp(ScopeLerp,RenderView.fov,fov)
        RenderView.znear = znear

        return
    end

    if ScopeLerp <= 0.0075 then return end
    
    DeterminateLODAlways = true

    render.PushRenderTarget(rtRenderTarget)
    render.Clear(0,0,0,255,true,true)

    local rView = {}
    for k,v in pairs(RenderView) do rView[k] = v end

    if scopeConfig.RenderSceneForward then
        rView.origin = rView.origin + Vector(scopeConfig.RenderSceneForward,0,0):Rotate(rView.angles)
    end

    rView.drawviewer = false
    rView.drawviewmodel = false

    rView.drawhud = false
    rView.fov = fov
    --rView.x = ScrW()/2 - ScrH()/2
    rView.w = ScrW()
    rView.h = ScrH()
    rView.viewid = 2
    rView.znear = znear
    --rView.aspectratio = 1

    RenderScope = true
    render.RenderView(rView)
    RenderScope = nil

    DrawColorModify(pp_cc_tab)

    surface.DrawRect(200,0,1,100)
    render.PopRenderTarget()

    DeterminateLODAlways = nil
    RenderView.fov = oldFOV
end

concommand.Add("hg_dev_draw_stencil",function(ply,cmd,args)
    if not ply:IsSuperAdmin() then return end

    hg_dev_draw_stencil = tonumber(args[1] or 0) > 0 and tonumber(args[1])

    if hg_dev_draw_stencil == 1 then
        hook.Add("HUDPaint","hg_dev_draw_stencil",function()
            local wep = LocalPlayer():GetActiveWeapon()
            if not IsValid(wep) or not wep.AttachmentScope then return end

            local key = wep.attachments[wep.AttachmentScope]
            local scopeConfig = attachmentGame.config[key[2][1]]
            local mdl = wep.wm.attachments[wep.AttachmentScope]
            
            if not scopeConfig.FarSightPos then return end

            cam.Start2D()
                local diffPos,diffAng,focusSightPos,farSightPos = wep:GetDiffMatrixScope(mdl,scopeConfig)

                farSightPos = farSightPos:ToScreen()
                
                surface.SetDrawColor(255,255,255)
                surface.DrawRect(farSightPos.x - 1,farSightPos.y - 1,2,2)
            cam.End2D()
        end)
    else
        hook.Remove("HUDPaint","hg_dev_draw_stencil")
    end
end)

local renderTargetScope = GetRenderTarget("renderTargetScope" .. os.time(),ScrH(),ScrH())

local renderTargetScope_mat = CreateMaterial("renderTargetScope_mat" .. os.time(),"UnlitGeneric")
renderTargetScope_mat:SetTexture("$basetexture",renderTargetScope)
renderTargetScope_mat:Recompute()

function SWEP:IsStencilScope(scopeConfig)
    return scopeConfig.StencilScopeAlways or ScopeLerp > 0.001
end

local blurEnvLerp = 0

function SWEP:StencilScope(mdl,scopeConfig)
    if not IsValid(mdl) then return end--WTTTFFF
    
    if scopeConfig.PreStencilScope then scopeConfig.PreStencilScope(self,mdl,scopeConfig) end

    --blurEnvLerp = LerpFT(0.3,blurEnvLerp,scopeConfig.BlurEnv or 0)
    --if blurEnvLerp > 0.0001 then RenderScreenspaceEffects_DrawBlur(blurEnvLerp * math.ease.InSine(ScopeLerp)) end

    if not self:IsStencilScope(scopeConfig) then mdl:DrawModel() return end

    local scopeSubIndex = scopeConfig.ScopeSubIndex or 0
    local scopeBodySubIndex = scopeConfig.ScopeBodySubIndex or 1
    
    if scopeConfig.Optic then mdl:SetSubMaterial(scopeBodySubIndex,"phoenix_storms/black_chrome") end
    
    local stencilModel = CSM.GetByID(mdl:GetModel(),"StencilModel" .. mdl:GetModel())
    stencilModel:SetNoDraw(true)
    stencilModel:DrawShadow(false)

    stencilModel:SetPos(mdl:GetPos())
    stencilModel:SetAngles(mdl:GetAngles())
    stencilModel:SetupBones()

    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)

    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)

    cam.Start3D(nil,nil,nil,nil,nil,nil,nil,nil,300)

    render.SetStencilReferenceValue(1)

    render.SetBlend(0)
    render.SetColorModulation(0,0,0)
    if scopeConfig.Optic then render.OverrideDepthEnable(true,true) end

    stencilModel:SetSubMaterial(scopeBodySubIndex,nil)
    stencilModel:SetSubMaterial(scopeSubIndex,"null")
    stencilModel:DrawModel()

    render.SetStencilReferenceValue(2)

    stencilModel:SetSubMaterial(scopeSubIndex,nil)
    stencilModel:SetSubMaterial(scopeBodySubIndex,"null")
    stencilModel:DrawModel()

    render.SetBlend(1)
    render.SetColorModulation(1,1,1)
    render.OverrideDepthEnable(false,false)

    render.SetStencilReferenceValue(1)

    render.SetStencilPassOperation(STENCIL_ZERO)
    render.SetStencilCompareFunction(STENCIL_NOTEQUAL)

    if scopeConfig.Holosight then render.SetStencilEnable(false) end
    
    mdl:DrawModel()
    cam.End3D()

    render.SetStencilEnable(true)
    
    render.SetStencilReferenceValue(1)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    
    if hg_dev_draw_stencil == 2 or hg_dev_draw_stencil == 3 then render.SetStencilEnable(false) end

    if hg_dev_draw_stencil == 1 then
        cam.Start2D()
        cam.IgnoreZ(true)
        surface.SetDrawColor(145,0,0)
        surface.DrawRect(0,0,ScrW(),ScrH())

        surface.SetMaterial(Material("vgui/arc9_eft_shared/reticles/elcan_specter_close.png"))
        surface.DrawTexturedRect(0,0,ScrW(),ScrH())
        cam.End2D()
        cam.IgnoreZ(false)
    else
        self:StencilRenderScope(mdl,scopeConfig)
    end

    render.SetStencilEnable(false)
    render.ClearStencil()
end

local matrixScope = {}

function SWEP:GetDiffMatrixScope(mdl,scopeConfig)
    local ang = mdl:GetAngles()

    local ScopeHeight = scopeConfig.ScopeHeight

    local startPos = mdl:GetPos():Add(Vector(scopeConfig.StartSightValue,scopeConfig.ScopeRight,ScopeHeight):Rotate(ang))
    local endPos = mdl:GetPos():Add(Vector(scopeConfig.EndSightValue,scopeConfig.ScopeRight,ScopeHeight):Rotate(ang))

    if scopeConfig.BackCamera then
        local focusPos = mdl:GetPos():Add(Vector(-scopeConfig.BackCamera,0,ScopeHeight):Rotate(ang))

        diffPos,diffAng = WorldToLocal(focusPos,(endPos - startPos):Angle(),RenderView.origin,RenderView.angles)
    else
        diffPos = Vector()
        diffAng = Vector()
    end

    local viewDir = (RenderView.origin - endPos):Normalize()

    matrixScope.offsetRight = viewDir:Dot(ang:Right())
    matrixScope.offsetUp = viewDir:Dot(ang:Up())

    matrixScope.diffAng = diffAng
    matrixScope.diffPos = diffPos
    matrixScope.startPos = startPos
    matrixScope.endPos = endPos

    return matrixScope
end

function SWEP:StencilRenderScope(mdl,scopeConfig)
    if scopeConfig.Optic and ScopeLerp < 0.1 then
        cam.Start3D()
        mdl:DrawModel()
        cam.End3D()

        cam.Start2D()

        surface.SetDrawColor(0,0,0,255 * (ScopeLerp / 0.1))
        surface.DrawRect(0,0,ScrW(),ScrH())
        
        cam.End2D()

        return
    end

    local matrixScope = self:GetDiffMatrixScope(mdl,scopeConfig)

    local ang = mdl:GetAngles()
    ang:RotateAroundAxis(ang:Right(),90)
    ang:RotateAroundAxis(ang:Up(),-90)
    
    if hg_dev_draw_stencil == 4 then render.SetStencilEnable(false) end

    local scale = 2048
    matrixScope.scale = scale

    matrixScope.cam3d2dAng = ang
    matrixScope.cam3d2dPos = matrixScope.endPos
    matrixScope.hitPos = util.IntersectRayWithPlane(RenderView.origin, mdl:GetAngles():Forward(), matrixScope.cam3d2dPos, mdl:GetAngles():Forward())

    cam.Start3D2D(matrixScope.cam3d2dPos,ang,scopeConfig.Cam3D2DSize)

    render.FogMode(MATERIAL_FOG_NONE)
    cam.IgnoreZ(true)

    if scopeConfig.Optic then
        self:DrawScope2D(mdl,scopeConfig,matrixScope)
        self:DrawScopeSwitchAnimation(matrixScope)
    else
        self:DrawHolosight2D(mdl,scopeConfig,matrixScope)
    end

    cam.IgnoreZ(false)
    cam.End3D2D()
end

local shadow = Material("homigrad/scopes/shadow3.png","smooth mips")

local abs = math.abs
local floor = math.floor
local max = math.max

local function drawAroundBox(x,y,size)
    if hg_dev_draw_stencil == 4 then return end

    surface.DrawRect(
        -size * 10,
        -size * 10,
        size * 10 - size/2 + 2,
        size * 20
    )--left

    surface.DrawRect(
        size / 2 - 2,
        -size * 10,
        size * 20,
        size * 20
    )--right

    surface.DrawRect(
        -size / 2,
        -size * 10,
        size,
        size * 10 - size / 2 + 2
    )--up

    surface.DrawRect(
        -size / 2,
        size / 2 - 2,
        size,
        size * 10
    )--down
end

function SWEP:DrawScope2D(mdl,scopeConfig,matrixScope)
    local blackMul = 0

    if scopeConfig.ScopeZoom != 0 and hg_dev_draw_stencil != 4 then
        cam.IgnoreZ(false)

        if hg_fast_scope then
            render.SetStencilEnable(false)
        
            if ScopeLerp < 0.8 then
                blackMul = ScopeLerp / 0.1
            else
                blackMul = 1 - (ScopeLerp - 0.8) / 0.2
            end
        else
            render.DrawTextureToScreen(rtRenderTarget)
            --RenderScreenspaceEffects_DrawBlur(0.0005)
        end
        cam.IgnoreZ(true)
    end

    local size = matrixScope.scale

    if not hg_fast_scope or scopeConfig.ScopeZoom == 0 or ScopeLerp > 0.8 then
        surface.SetDrawColor(0,0,0,255)
        surface.SetMaterial(shadow)
        surface.DrawTexturedRectRotated(0,0,size,size,0)
        drawAroundBox(0,0,size)

        if scopeConfig.RetricleMaterial then
            surface.SetDrawColor(255,255,255)
            surface.SetMaterial(scopeConfig.RetricleMaterial)

            local size = size * (scopeConfig.RetricleSize or 1)
            surface.DrawTexturedRectRotated(0,0,size,size,0)
        end

        local diffysionScale = scopeConfig.DiffysionScale or 1
        local zoomDiffysionScale = scopeConfig.ZoomDiffysionScale or 1
        local diffysion = math.Clamp(abs(diffPos[1]) * zoomDiffysionScale + abs(diffAng[2]) / 6 * diffysionScale + abs(diffAng[1]) / 6 * diffysionScale,0,1)
        
        diffysion = math.max(diffysion - 0.15,0)
        RenderScreenspaceEffects_DrawBlur(diffysion / 30)
        cam.IgnoreZ(true)

        surface.SetDrawColor(0,0,0,255 * diffysion)
        surface.DrawRect(-size*10,-size*10,size*20,size*20)
    end

    if hg_fast_scope then
        surface.SetDrawColor(0,0,0,255 * blackMul)
        surface.DrawRect(-size*10,-size*10,size*20,size*20)
    end
end

local angle_zero = Angle()

function SWEP:DrawHolosight2D(mdl,scopeConfig,matrixScope)
    surface.SetDrawColor(255,255,255)

    if scopeConfig.DrawHolosight then
        scopeConfig.DrawHolosight(self,mdl,scopeConfig,matrixScope)
    else
        if scopeConfig.pp_cc_tab then
            DrawColorModify(scopeConfig.pp_cc_tab)
            cam.IgnoreZ(true)
        end

        local size = matrixScope.scale * scopeConfig.RetricleSize

        if scopeConfig.RetricleMaterial then
            surface.SetDrawColor(255,255,255)
            surface.SetMaterial(scopeConfig.RetricleMaterial)

            local Paralaxx = scopeConfig.Paralaxx or 0
            
            local hitPos = matrixScope.hitPos

            if hitPos then
                local localPos = WorldToLocal(hitPos, angle_zero, matrixScope.cam3d2dPos, matrixScope.cam3d2dAng)

                surface.DrawTexturedRectRotated(localPos.x / scopeConfig.Cam3D2DSize,-localPos.y / scopeConfig.Cam3D2DSize,size,size,0)
            end
        end
    end
end

function SWEP:DrawScopeSwitchAnimation(matrixScope)
    local scopeSwitchStart = (self.scopeSwitchStart - RealTime() + 0.3) / 0.3

    local scale = matrixScope.scale

    if scopeSwitchStart > 0 then
        scopeSwitchStart = math.min(scopeSwitchStart * 2,1)

        surface.SetDrawColor(0,0,0,255 * scopeSwitchStart)
        surface.DrawRect(-scale * 10,-scale * 10,scale * 20,scale * 20)
    end
end

--[[-function SWEP:PreDrawHUD()
    local scopeConfig,mdl = self:GetScopeInfo()
    if not scopeConfig then return end
    
    RenderScope = true
    self:StencilScope(mdl,scopeConfig)
    RenderScope = nil
end]]--

function SWEP:GetScopeInfo() end
function SWEP:GetScopeInfoForRender() end