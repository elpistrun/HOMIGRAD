texture_uv = texture_uv or {}

texture_uv.chache = texture_uv.chache or {}

local chache = texture_uv.chache

function texture_uv.GetOriginal(name)
    local texture = chache[name]

    if not texture then
        texture = MaterialHash(name):GetTexture("$basetexture")

        chache[name] = texture
    end

    return texture
end

function texture_uv.CanvasClear(rt)
    render.PushRenderTarget(rt,0,0,rt:Width(),rt:Height())
    render.Clear(0,0,0,0,true,true)
    render.PopRenderTarget()
end

local textureFlagsDefault = bit.bor(2,256)

function texture_uv.CreateRenderTarget(nameRT,w,h,rtSize,depthMode,textureFlags,rtFlags,imageFormat)
    return GetRenderTargetEx(
        nameRT,
        w,
        h,
        rtSize or RT_SIZE_NO_CHANGE,
        depthMode or MATERIAL_RT_DEPTH_SEPARATE,
        textureFlags or textureFlagsDefault,
        rtFlags or 0,
        imageFormat or IMAGE_FORMAT_RGBA8888
    )
end

function texture_uv.GetLayer(rt,layerName)
    local w,h = rt:Width(),rt:Height()

    local layer = GetRenderTarget("texture_uv_layer_" .. w .. "_" .. h .. "_" .. (layerName or "default"),w,h)

    texture_uv.CanvasClear(layer)

    return layer
end

function texture_uv.Start()
    cam.Start2D()
    render.SetScissor(0,0,0,0,false)

    render.SuppressEngineLighting(true)
    render.SetWriteDepthToDestAlpha(false)
    cam.IgnoreZ(true)
end

function texture_uv.End()
    cam.End2D()

    render.SuppressEngineLighting(false)
    render.SetWriteDepthToDestAlpha(true)
    cam.IgnoreZ(false)
    
end

local verts = {
    {},{},{},{}
}

local function GetRotatedVertices(x, y, w, h, u1, v1, u2, v2, angle)
    local x2, y2 = x + w, y + h
    
    verts[1].x = x
    verts[2].x = x2
    verts[3].x = x2
    verts[4].x = x

    verts[1].y = y
    verts[2].y = y
    verts[3].y = y2
    verts[4].y = y2

    verts[1].x = x
    verts[2].x = x2
    verts[3].x = x2
    verts[4].x = x

    verts[1].u = u1
    verts[2].u = u2
    verts[3].u = u2
    verts[4].u = u1

    verts[1].v = v1
    verts[2].v = v1
    verts[3].v = v2
    verts[4].v = v2

    if angle == 90 then
        verts[1].u, verts[1].v = u1, v2
        verts[2].u, verts[2].v = u1, v1
        verts[3].u, verts[3].v = u2, v1
        verts[4].u, verts[4].v = u2, v2
    elseif angle == 180 then
        verts[1].u, verts[1].v = u2, v2
        verts[2].u, verts[2].v = u1, v2
        verts[3].u, verts[3].v = u1, v1
        verts[4].u, verts[4].v = u2, v1
    elseif angle == 270 then
        verts[1].u, verts[1].v = u2, v1
        verts[2].u, verts[2].v = u2, v2
        verts[3].u, verts[3].v = u1, v2
        verts[4].u, verts[4].v = u1, v1
    end

    return verts
end

function texture_uv.PaintUV(layer,uvZones,material)
    if not uvZones then return end

    local w,h = layer:Width(),layer:Height()

    render.PushRenderTarget(layer,0,0,w,h)
        texture_uv.Start()

        material:SetFloat("$noclamp","1")
        material:Recompute()
        
        surface.SetMaterial(material)
        surface.SetDrawColor(255,255,255)
    
        for i,zone in pairs(uvZones) do
            if zone.uiHide then continue end

            local transform = zone.transform
            
            local x, y = transform[1] * w, transform[2] * h
            local width, height = transform[3] * w, transform[4] * h
            local x2, y2 = x + width, y + height

            local u1, v1, u2, v2 = zone.uvScale[1], zone.uvScale[2], zone.uvScale[3], zone.uvScale[4]

            surface.DrawPoly(GetRotatedVertices(x,y,width,height,u1,v1,u2,v2,zone.rotate or 0))
        end
        
        texture_uv.End()
    render.PopRenderTarget()
end

function texture_uv.PaintTexture(rt,texture)
    local w,h = rt:Width(),rt:Height()

    render.PushRenderTarget(rt,0,0,w,h)
        texture_uv.Start()

        render.DrawTextureToScreen(texture)

        texture_uv.End()
    render.PopRenderTarget()
end

local mat_alphatest = CreateMaterial("texture_uv_alpha_test" .. os.time(),"UnlitGeneric",{
    ["$basetexture"] = "vgui/white",
    ["$alphatest"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1
})

local mat_layer = CreateMaterial("texture_uv_layer" .. os.time(),"UnlitGeneric",{
    ["$basetexture"] = "vgui/white",
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1
})

local colorModify = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = -0.2,
    ["$pp_colour_contrast"] = 3,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

function texture_uv.PaintLayer(rt,layer,alpha)
    local w,h = rt:Width(),rt:Height()

    mat_layer:SetFloat("$alpha",alpha / 255)
    mat_layer:SetTexture("$basetexture",layer)
    mat_layer:Recompute()

    mat_alphatest:SetTexture("$basetexture",layer)
    mat_alphatest:Recompute()
    
    render.PushRenderTarget(rt,0,0,w,h)
        texture_uv.Start()

        render.SetStencilEnable(true)
        render.ClearStencil()

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilReferenceValue(1)

        render.OverrideColorWriteEnable(true, false)
            render.SetMaterial(mat_alphatest)
            render.DrawScreenQuad()
        render.OverrideColorWriteEnable(false)

        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)

        DrawColorModify(colorModify)

        render.SetStencilEnable(false)

        render.SetMaterial(mat_layer)
        render.DrawScreenQuad()

        texture_uv.End()
    render.PopRenderTarget()
end

texture_uv.config = texture_uv.config or {}

function texture_uv.RegUV(textureName,name,uvZones)
    texture_uv.config[textureName] = texture_uv.config[textureName] or {}
    texture_uv.config[textureName][name] = uvZones
end

function texture_uv.GetUV(textureName,name)
    return texture_uv.config[textureName] and texture_uv.config[textureName][name]
end

texture_uv.hash = texture_uv.hash or {}
local hash = texture_uv.hash

texture_uv.hashIndex = texture_uv.hashIndex or {}
local hashIndex = texture_uv.hashIndex

function texture_uv.ClaimHashRT(textureName,id,forceRTName)
    local iteration = hashIndex[id]

    if not iteration then
        local texture = texture_uv.GetOriginal(textureName)
        if not texture then error("texture_uv.ClaimHashRT texture" .. tostring(textureName) .. " is not exists!") end

        hash[textureName] = hash[textureName] or {}
        iteration = #hash[textureName] + 1

        local rt = texture_uv.CreateRenderTarget(
            textureName .. "_" .. iteration .. "_rt",
            texture:Width(),
            texture:Height(),
            RT_SIZE_NO_CHANGE,
            MATERIAL_RT_DEPTH_SEPARATE,
            bit.bor(2, 256),
            0,
            IMAGE_FORMAT_RGBA8888
        )
        
        hash[textureName][iteration] = {rt,id}

        hashIndex[id] = iteration
    end

    return hash[textureName][iteration][1],iteration
end

function texture_uv.ClaimHashRTEx(nameRT,id,w,h,rtSize,depthMode,textureFlags,rtFlags,imageFormat)
    local iteration = hashIndex[id]

    if not iteration then
        hash[nameRT] = hash[nameRT] or {}

        for i = 1,4096 do
            if not hash[nameRT][i] then iteration = i break end
        end

        local rt = texture_uv.CreateRenderTarget(
            nameRT .. "_" .. iteration .. "_rt",
            w,
            h,
            rtSize or RT_SIZE_NO_CHANGE,
            depthMode or MATERIAL_RT_DEPTH_SEPARATE,
            textureFlags or bit.bor(2, 256),
            rtFlags or 0,
            imageFormat or IMAGE_FORMAT_RGBA8888
        )
        
        hash[nameRT][iteration] = {rt,id}

        hashIndex[id] = iteration
    end

    return hash[nameRT][iteration][1],iteration
end

function texture_uv.PopHashRT(nameRT,id)
    local iteration = hashIndex[id]
    if not iteration then return end

    hash[nameRT][iteration] = nil

    hashIndex[id] = nil
end

concommand.Add("hg_dev_texture_uv",function()
    print("hash:")
    
    for textureName,list in pairs(hash) do
        print(textureName,#list)

        for id,i in pairs(list) do
            print("\t" .. id,i[1],i[2])
        end
    end

    print("hashIndex: " .. table.Count(hashIndex))
end)

concommand.Add("hg_dev_texture_uv_clear",function()
    for textureName,list in pairs(hash) do
        print(textureName,table.Count(list))

        hash[textureName] = nil
    end
    print("hashIndex: " .. table.Count(hashIndex))

    for id,iteration in pairs(hashIndex) do
        hashIndex[id] = nil
    end
end)

local checkStatus = texture_uv.CreateRenderTarget("checkStatus",64,64,RT_SIZE_NO_CHANGE,MATERIAL_RT_DEPTH_NONE,0,0,IMAGE_FORMAT_RGB888)

event.Add("RTRefresh","Main",function()
    render.PushRenderTarget(checkStatus)
    render.Clear(0,0,0,0,true,true)
    cam.Start2D()
    surface.SetDrawColor(255,255,255)
    surface.DrawRect(0,0,64,64)
    cam.End2D()
    render.PopRenderTarget()
end,-100)

local start = RealTime()

local override

local function check()
    local result

    cam.Start2D()
        render.DrawTextureToScreen(checkStatus)
        render.CapturePixels()
        local r,g,b = render.ReadPixel(0,0)

        print("texture_uv: check render target status - " .. r .. " " .. g .. " " .. b)

        if r == 0 then
            print("texture_uv: detect missing textures, reload.")
            
            event.Call("RTRefresh")

            result = true
        end
    cam.End2D()

    return result
end

timer.Create("checkRTStatus",0,0,function()
    if not system.HasFocus() then return end

    local diff = RealTime() - start
    start = RealTime()

    if diff > 1 / 10 then
        if override then return end

        override = true

        if not check() then
            timer.Simple(0,function()
                if not check() then
                    timer.Simple(TickInterval(),function()
                        if not check() then

                        else override = false end
                    end)
                else override = false end
            end)
        else override = false end
    end
end)

event.Add("Initialize","Render Targer Reload",function()
    event.Call("RTRefresh")
end)

concommand.Add("hg_dev_texture_refresh",function()
    event.Call("RTRefresh")
end)

local back = function()
    if GetConVar("mat_antialias"):GetFloat() >= 2 then return end
    print("texture_uv: fix mat_antialias < 2, set to 2")

    RunConsoleCommand("mat_antialias",2)
end

cvars.AddChangeCallback("mat_antialias",back,"back")

hook.Add("InitPostEntity","fix antialas",function()
    timer.Simple(3,back)
end)