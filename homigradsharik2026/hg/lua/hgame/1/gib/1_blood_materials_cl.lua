gibParticles.bloodSeparate = gibParticles.bloodSeparate or {}
local bloodSeparate = gibParticles.bloodSeparate
bloodSeparate.unlitGeneric = {}
bloodSeparate.decalModulate = {}

for i = 1,3 do
    local mat = CreateMaterial("blood_separate_unlitgeneric" .. i .. os.time(),"UnlitGeneric",{
        ["$basetexture"] = "homigrad/decals/blood_separate_" .. i,

        ["$vertexcolor"] = 1,
        ["$vertexcolormodulate"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
        ["$translucent"] = 1,
        ["$allowalphatocoverage"] = 1
    })

    mat:Recompute()

    bloodSeparate.unlitGeneric[i] = mat

    local mat = CreateMaterial("blood_separate_decalmodulate" .. i .. os.time(),"DecalModulate",{
        ["$basetexture"] = "homigrad/decals/blood_separate_" .. i,

        ["$vertexcolor"] = 1,
        ["$vertexcolormodulate"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
        ["$translucent"] = 1,
        ["$allowalphatocoverage"] = 1,

        ["$decal"] = 1,
        ["$decalscale"] = 0.1,
    })

    mat:Recompute()

    bloodSeparate.decalModulate[i] = mat
end

gibParticles.bloodPoint = gibParticles.bloodPoint or {}
local bloodPoint = gibParticles.bloodPoint
bloodPoint.unlitGeneric = {}
bloodPoint.decalModulate = {}

for i = 1,11 do
    local mat = CreateMaterial("blood_point_unlitgeneric" .. i .. os.time(),"UnlitGeneric",{
        ["$basetexture"] = "homigrad/decals/blood_point_" .. i,
        
        ["$vertexcolor"] = 1,
        ["$vertexcolormodulate"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
        ["$translucent"] = 1,
        ["$allowalphatocoverage"] = 1,

        ["$nocull"] = 1,
    })

    mat:Recompute()

    bloodPoint.unlitGeneric[i] = mat

    local mat = CreateMaterial("blood_point_decalmodulate" .. i .. os.time(),"DecalModulate",{
        ["$basetexture"] = "homigrad/decals/blood_point_" .. i,
        
        ["$vertexcolor"] = 1,
        ["$vertexcolormodulate"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
        ["$translucent"] = 1,
        ["$allowalphatocoverage"] = 1,

        ["$decal"] = 1,
        ["$decalscale"] = 0.1,
    })

    mat:Recompute()

    bloodPoint.decalModulate[i] = mat
end

gibParticles.bloodDrop = gibParticles.bloodDrop or {}
local bloodDrop = gibParticles.bloodDrop
bloodDrop.unlitGeneric = {}
bloodDrop.decalModulate = {}

for i = 1,8 do
    local mat = CreateMaterial("blood_drop_unlitgeneric" .. i .. os.time(),"UnlitGeneric",{
        ["$basetexture"] = "homigrad/decals/blood_drop_" .. i,

        ["$vertexcolor"] = 1,
        ["$vertexcolormodulate"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
        ["$translucent"] = 1,
        ["$allowalphatocoverage"] = 1
    })

    mat:Recompute()

    bloodDrop.unlitGeneric[i] = mat

    local mat = CreateMaterial("blood_drop_decalmodulate" .. i .. os.time(),"DecalModulate",{
        ["$basetexture"] = "homigrad/decals/blood_drop_" .. i,

        ["$vertexcolor"] = 1,
        ["$vertexcolormodulate"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
        ["$translucent"] = 1,
        ["$allowalphatocoverage"] = 1,

        ["$decal"] = 1,
        ["$decalscale"] = 1,
    })

    mat:Recompute()

    bloodDrop.decalModulate[i] = mat
end