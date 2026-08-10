SphereRingEffects = SphereRingEffects or {}

local colorWhite = Color(255,255,255)

function DrawSphereRing(pos,radius,color,corner)
    SphereRingEffects[#SphereRingEffects + 1] = {
        pos = pos,
        radius = radius,
        color = color or Color(255,255,255),
        corner = corner or 1
    }
end

event.Add("PreRender","SphereRing",function()
    SphereRingEffects = {}
end,-100)

local colorEffect = Color(255, 10, 10, 70)

local function buildcylinder(detail)
    local vertices = {}
    local hvertices = {}
    local base = {}

    for i = 1, detail do
        local xyz = ((i - 1) / detail) * math.pi * 2
        local j = math.cos(xyz)
        local k = math.sin(xyz)

        base[i] = Vector(j,k, -1)
    end

    for i = 1, #base do
        local nextind = i % detail + 1
        vertices[(i - 1) * 6 + 1] = {pos = base[nextind]}
        vertices[(i - 1) * 6 + 2] = {pos = base[i]}
        vertices[(i - 1) * 6 + 3] = {pos = base[i] + Vector(0, 0, 2)}
        vertices[(i - 1) * 6 + 4] = {pos = base[i] + Vector(0, 0, 2)}
        vertices[(i - 1) * 6 + 5] = {pos = base[nextind] + Vector(0, 0, 2)}
        vertices[(i - 1) * 6 + 6] = {pos = base[nextind]}

        vertices[#base * 6 + (i - 1) * 3 + 1] = {pos = base[nextind] + Vector(0,0,2)}
        vertices[#base * 6 + (i - 1) * 3 + 2] = {pos = base[i] + Vector(0,0,2)}
        vertices[#base * 6 + (i - 1) * 3 + 3] = {pos = Vector(0,0,1)}

        vertices[#base * 9 + (i - 1) * 3 + 1] = {pos = Vector(0,0,-1)}
        vertices[#base * 9 + (i - 1) * 3 + 2] = {pos = base[i]}
        vertices[#base * 9 + (i - 1) * 3 + 3] = {pos = base[nextind]}

        hvertices[(i - 1) * 6 + 3] = {pos = base[nextind]}
        hvertices[(i - 1) * 6 + 2] = {pos = base[i]}
        hvertices[(i - 1) * 6 + 1] = {pos = base[i] + Vector(0, 0, 2)}
        hvertices[(i - 1) * 6 + 6] = {pos = base[i] + Vector(0, 0, 2)}
        hvertices[(i - 1) * 6 + 5] = {pos = base[nextind] + Vector(0, 0, 2)}
        hvertices[(i - 1) * 6 + 4] = {pos = base[nextind]}

        hvertices[#base * 6 + (i - 1) * 3 + 3] = {pos = base[nextind] + Vector(0,0,2)}
        hvertices[#base * 6 + (i - 1) * 3 + 2] = {pos = base[i] + Vector(0,0,2)}
        hvertices[#base * 6 + (i - 1) * 3 + 1] = {pos = Vector(0,0,1)}

        hvertices[#base * 9 + (i - 1) * 3 + 3] = {pos = Vector(0,0,-1)}
        hvertices[#base * 9 + (i - 1) * 3 + 2] = {pos = base[i]}
        hvertices[#base * 9 + (i - 1) * 3 + 1] = {pos = base[nextind]}
    end

    local msh = Mesh()
    msh:BuildFromTriangles(vertices)

    local hollow = Mesh()
    hollow:BuildFromTriangles(hvertices)

    return msh,hollow
end

local cylinderMesh, insideoutMesh = buildcylinder(1024)

local function drawSphereNice(v, color, ref, radius)
    render.SetStencilReferenceValue( ref )
    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.OverrideColorWriteEnable(true, false)

    local mat = Matrix()
    mat:Identity()
    mat:Translate(v.pos)
    mat:Scale(Vector(radius, radius, 512))

    cam.PushModelMatrix(mat)

    if radius < 0 then
        insideoutMesh:Draw()
    else
        cylinderMesh:Draw()
    end

    cam.PopModelMatrix()

    render.OverrideColorWriteEnable(false)
end

hook.Add("PostDrawTranslucentRenderables", "sentinel_ringer", function(d, sky)
    event.Call("Pre Draw Sphere Ring")
    
    for k, v in pairs(SphereRingEffects) do
        render.ClearStencil()
        render.SetStencilEnable(true)

        render.SetStencilTestMask(255)
        render.SetStencilWriteMask(255)
        render.SetColorMaterial()

        render.EnableClipping(true)

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation( STENCIL_REPLACE )
        drawSphereNice(v, colorZero, 1,-v.radius)

        render.SetStencilZFailOperation( STENCIL_DECR )
        drawSphereNice(v, colorZero, 1, v.radius)

        render.SetStencilZFailOperation( STENCIL_INCR )
        drawSphereNice(v, colorZero, 1, -v.radius + v.corner)

        render.SetStencilZFailOperation( STENCIL_DECR )
        drawSphereNice(v, colorZero, 1,v.radius - v.corner)

        render.EnableClipping(false)

        render.SetStencilCompareFunction( STENCIL_EQUAL )

        cam.IgnoreZ(true)
        
        render.SetStencilReferenceValue( 1 )
 
        local norm = EyeAngles():Forward()
        render.DrawQuadEasy(EyePos() + norm * 10, -norm,10000,10000,v.color,0)

        cam.IgnoreZ(false)

        render.SetStencilEnable(false)
    end

    render.SetStencilCompareFunction(0)
    render.SetStencilPassOperation(0)
    render.SetStencilFailOperation(0)
    render.SetStencilZFailOperation(0)
end)