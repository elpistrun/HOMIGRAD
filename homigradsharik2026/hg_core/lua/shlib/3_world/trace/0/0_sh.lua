hitBoxGame = hitBoxGame or {}

hitBoxGame.AviableBones = {
    "ValveBiped.Bip01_Pelvis",
    "ValveBiped.Bip01_Spine",
    "ValveBiped.Bip01_Spine1",
    "ValveBiped.Bip01_Spine2",
    "ValveBiped.Bip01_Spine4",
    "ValveBiped.Bip01_Head1",

    "ValveBiped.Bip01_R_Thigh",
    "ValveBiped.Bip01_R_Calf",
    --"ValveBiped.Bip01_R_Foot",

    "ValveBiped.Bip01_L_Thigh",
    "ValveBiped.Bip01_L_Calf",
    --"ValveBiped.Bip01_L_Foot",

    "ValveBiped.Bip01_R_UpperArm",
    "ValveBiped.Bip01_R_Forearm",
    --"ValveBiped.Bip01_R_Hand",

    "ValveBiped.Bip01_L_UpperArm",
    "ValveBiped.Bip01_L_Forearm",
    --"ValveBiped.Bip01_L_Hand",
}

local chache = {}

event.Add("Model Setting Update","Chache Lag Compresion Hit Box",function(model)
    chache[model] = nil
end)

local function getManual(ent)
    local model = ent:GetModel()
    if not model then return end--WTTTTTFFFFVFF
    
    local listHitBox = chache[model]
    if listHitBox then return listHitBox end

    local modelSetting = modelSetting.listIndex[model] or {}
    local replaceHitBoxBounds = modelSetting.hitBoxBounds or {}

    listHitBox = {}

    local limbs = {}
    listHitBox.limbs = limbs

    local exists = {}
    
    for hitBox = 0,ent:GetHitBoxCount(0) - 1 do
        local bone = ent:GetHitBoxBone(hitBox,0)
        if exists[bone] then continue end

        local boneName = ent:GetBoneName(bone)

        if table.HasValue(hitBoxGame.AviableBones,boneName) then
            local mins,maxs = ent:GetHitBoxBounds(hitBox,0)

            if replaceHitBoxBounds[boneName] then
                mins,maxs = replaceHitBoxBounds[boneName][1],replaceHitBoxBounds[boneName][2]
            end

            limbs[#limbs + 1] = {bone,mins,maxs,boneName}

            exists[bone] = true
        end
    end

    chache[model] = listHitBox

    return listHitBox
end

local MatrixSet = Matrix()
local VecSet,AngSet = Vector(),Angle()

function hitBoxGame.GetInfo(ent,hitboxs)
    hitboxs = hitboxs or GetHashTable(ent,"m_hitboxs")

    if ent.CustomGetHitBox then
        ent:CustomGetHitBox(hitboxs)
    else
        local listHitBox = getManual(ent)
        local limbs = listHitBox.limbs

        for i = 1,#limbs do
            local info = limbs[i]
            local hitbox = hitboxs[i]
            
            if not hitbox then
                hitbox = {
                    pos = Vector(),
                    ang = Angle()
                }

                hitboxs[i] = hitbox

                hitbox.bone = info[1]
                
                hitbox.min = info[2]
                hitbox.max = info[3]
            end

            ent:CopyBoneMatrixHash(info[1],MatrixSet)

            MatrixSet:SetXYZ_PYR(hitbox.pos,hitbox.ang)

            --debugoverlayNet.BoxAngles(hitboxs[i].pos,hitboxs[i].min,hitboxs[i].max,hitboxs[i].ang,0.1,Color(255,255,255,0))
        end
    end

    return hitboxs
end

local IntersectRayWithOBB = util.IntersectRayWithOBB

local hits = {}
local hitsSort = {}
local hitCount = 0

for i = 1,256 do hits[i] = {} end

local sortStartPos

local sortFunction = function(a,b) return a[1]:Distance(sortStartPos) < b[1]:Distance(sortStartPos) end

local color_client = Color(255,125,0,0)
local color_server = Color(0,125,255,0)

function hitBoxGame.TraceLine(ent,hitboxs,hitboxsMax,tr,isDebug)
    if not IsValid(ent) or not hitboxs then return end
    
    local output = tr.output or tr

    local traceStart = tr.start
    local traceDir = (tr.endpos - tr.start)

    hitCount = 0

    for i = 1,hitboxsMax or #hitboxs do
        local hitbox = hitboxs[i]
        if not hitbox then break end

        local min,max = hitbox.min,hitbox.max
        local pos,ang = hitbox.pos,hitbox.ang

        if isDebug then debugoverlayNet.BoxAngles(pos,min,max,ang,3,CLIENT and color_client or color_server) end

        local isHit,normal = IntersectRayWithOBB(traceStart,traceDir,pos,ang,min,max)
        if not isHit then continue end

        hitCount = hitCount + 1

        local hitInfo = hits[hitCount]

        hitInfo[1] = isHit
        hitInfo[2] = normal
        hitInfo[3] = hitbox.bone
        hitInfo[4] = i
        hitInfo[5] = pos
        hitInfo[6] = ang
    end

    if hitCount == 0 then return end

    for i = 1,#hitsSort do hitsSort[i] = nil end
    for i = 1,hitCount do hitsSort[i] = hits[i] end

    sortStartPos = traceStart
    table.sort(hitsSort,sortFunction)

    local closeHit = hitsSort[1]

    output.Hit = true
    output.Entity = ent

    output.HitPos = closeHit[1]
    output.HitNormal = closeHit[2]
    output.HitBone = closeHit[3]
    output.HitBox = closeHit[4]

    output.HitBoxPos = closeHit[5]
    output.HitBoxAng = closeHit[6]

    output.HitSort = hitsSort

    output.SurfaceProps = util.GetSurfaceIndex(ent:GetBoneSurfaceProp(tr.HitBone))

    local hitbox = hitboxs[tr.HitBox]

    if isDebug then
        debugoverlayNet.BoxAngles(hitbox.pos,hitbox.min,hitbox.max,hitbox.ang,3,Color(0,255,0,125))
    end

    return tr
end

local IsOBBIntersectingOBB = util.IsOBBIntersectingOBB

function hitBoxGame.TraceHull(ent,hitboxs,hitboxsMax,tr,isDebug)--lag_compresion
    if not IsValid(ent) or not hitboxs then return end

    local output = tr.output or tr
    
    local dir = (tr.endpos - tr.start)
    local traceAng = dir:Angle()
    local traceStart = tr.start
    local traceMin,traceMax = tr.mins,tr.maxs
    
    hitCount = 0

    for i = 1,hitboxsMax or #hitboxs do
        local hitbox = hitboxs[i]
        if not hitbox then break end

        local min,max = hitbox.min,hitbox.max
        local pos,ang = hitbox.pos,hitbox.ang

        if isDebug then debugoverlayNet.BoxAngles(pos,min,max,ang,3,CLIENT and color_client or color_server) end

        local hit = IsOBBIntersectingOBB(traceStart,traceAng,traceMin,traceMax,pos,ang,min,max)
        if not hit then continue end

        hitCount = hitCount + 1

        local hitPos,dir = IntersectRayWithOBB(traceStart,pos - traceStart,pos,ang,min,max)

        local hitInfo = hits[hitCount]
        
        hitInfo[1] = hitPos or tr.endpos
        hitInfo[2] = dir
        hitInfo[3] = hitbox.bone
        hitInfo[4] = i
        hitInfo[5] = pos
        hitInfo[6] = ang
    end

    if hitCount == 0 then return end

    for i = 1,#hitsSort do hitsSort[i] = nil end
    for i = 1,hitCount do hitsSort[i] = hits[i] end

    sortStartPos = traceStart
    table.sort(hitsSort,sortFunction)

    local closeHit = hitsSort[1]

    output.Hit = true
    output.Entity = ent

    output.HitPos = closeHit[1]
    output.HitNormal = closeHit[2]
    output.HitBone = closeHit[3]
    output.HitBox = closeHit[4]

    output.HitBoxPos = closeHit[5]
    output.HitBoxAng = closeHit[6]

    output.HitSort = hitsSort

    output.SurfaceProps = util.GetSurfaceIndex(ent:GetBoneSurfaceProp(tr.HitBone))
    
    local hitbox = hitboxs[tr.HitBox]

    if isDebug then
        debugoverlayNet.BoxAngles(hitbox.pos,hitbox.min,hitbox.max,hitbox.ang,3,Color(0,255,0,125))
    end
    
    return tr
end

function hitBoxGame.FindBySphere(pos)

end