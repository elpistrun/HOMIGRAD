-- https://music.youtube.com/watch?v=rjfVx1QagcI&si=_QFqcJJBQHT4bsZu

local clamp,deg,acos,atan2 = math.Clamp,math.deg,math.acos,math.atan2
local NormalizeAngle = math.NormalizeAngle
local sqrt = math.sqrt

local joint0_ang = Angle()
local joint1_ang = Angle()

function TPIK_Solve2PartIK(start_pos, end_pos, length0, length1, sign, aim_ang,elbowDown,twist)
    local dir = end_pos - start_pos

    local total_length = dir:Length()
    dir:Normalize()

    length0 = length0 * 2
    
    -- Вычисляем углы с помощью закона косинусов
    local cosAngle0 = clamp((total_length^2 + length0^2 - length1^2) / (2 * total_length * length0), -1, 1)
    local angle0 = -deg(acos(cosAngle0))
    
    local cosAngle1 = clamp((length1^2 + length0^2 - total_length^2) / (2 * length1 * length0), -1, 1)
    local angle1 = -deg(acos(cosAngle1))
    
    -- Вычисляем направление к цели
    
    local angle2 = deg(atan2(-sqrt(dir.x^2 + dir.y^2), dir.z)) - 90 
    local angle3 = -deg(atan2(dir.x,dir.y)) - 90
    angle3 = NormalizeAngle(angle3)
    
    -- Корректируем углы с учетом ориентации туловища
    
    joint0_ang[1] = angle0 + angle2
    joint0_ang[2] = angle3
    joint0_ang[3] = 0

    joint0_ang:RotateAroundAxis(joint0_ang:Forward(),90 + twist)
    joint0_ang:RotateAroundAxis(dir, angle3 - (aim_ang.y + elbowDown * sign))
    
    joint1_ang[1] = angle0 + angle2 + 180 + angle1
    joint1_ang[2] = angle3
    joint1_ang[3] = 0

    joint1_ang:RotateAroundAxis(joint1_ang:Forward(),(sign > 0 and 45 or 90) + twist)
    joint1_ang:RotateAroundAxis(dir, angle3 - (aim_ang.y + elbowDown * sign))
    
    local joint0_pos = start_pos + joint0_ang:Forward() * length0
    
    return joint0_pos, joint0_ang, joint1_ang
end

--local BonesManager_ApplyMatrix = BonesManager_ApplyMatrix

local startPos = Vector()

function TPIK_DoSolveEntity(ent,link,targetPosLeft,targetPosRight,leftElbownDown,rightElbownDown,leftTwist,rightTwist)
    if not targetPosLeft and not targetPosRight then return end
    
    link = IsValid(link) and link or ent

    //

    local eye_pos, eye_ang = link:Eye()

    if targetPosRight then
        local bone_upperarm = ent:LookupBone("ValveBiped.Bip01_R_UpperArm")
        if not bone_upperarm then return end

        local bone_forearm = ent:LookupBone("ValveBiped.Bip01_R_Forearm")
        local bone_hand = ent:LookupBone("ValveBiped.Bip01_R_Hand")

        local matrixUpperArm = ent:GetBoneMatrix(bone_upperarm)
        local matrixForeArm = ent:GetBoneMatrix(bone_forearm)
        local matrixHand = ent:GetBoneMatrix(bone_hand)

        matrixUpperArm:SetXYZ(startPos)

        local lenghtUpperArm = ent:BoneLength(bone_upperarm) or 12
        local lenghtForeArm = ent:BoneLength(bone_forearm) or 12

        local upperArmPos, upperArmAng, foreArmAng = TPIK_Solve2PartIK(startPos,targetPosRight,lenghtUpperArm,lenghtForeArm,-1,eye_ang,rightElbownDown,rightTwist)

        --debugoverlay.Sphere(startPos,1,0.1,Color(0,0,255,0),true)
        --debugoverlay.Sphere(upperArmPos,1,0.1,Color(0,255,0,0),true)
        --debugoverlay.Sphere(targetPosRight,1,0.1,Color(255,0,0,0),true)

        matrixUpperArm:SetAngles(upperArmAng)
        BonesManager_ApplyMatrix(ent,bone_upperarm,matrixUpperArm,bone_forearm)

        matrixForeArm:SetAngles(foreArmAng)
        matrixForeArm:SetTranslation(upperArmPos)
        BonesManager_ApplyMatrix(ent,bone_forearm,matrixForeArm,bone_hand)
    end
    
    if targetPosLeft then
        local bone_upperarm = ent:LookupBone("ValveBiped.Bip01_L_UpperArm")
        if not bone_upperarm then return end
        
        local bone_forearm = ent:LookupBone("ValveBiped.Bip01_L_Forearm")
        local bone_hand = ent:LookupBone("ValveBiped.Bip01_L_Hand")

        local matrixUpperArm = ent:GetBoneMatrix(bone_upperarm)
        local matrixForeArm = ent:GetBoneMatrix(bone_forearm)
        local matrixHand = ent:GetBoneMatrix(bone_hand)

        matrixUpperArm:SetXYZ(startPos)

        local lenghtUpperArm = ent:BoneLength(bone_upperarm) or 12
        local lenghtForeArm = ent:BoneLength(bone_forearm) or 12

        local upperArmPos, upperArmAng, foreArmAng = TPIK_Solve2PartIK(startPos,targetPosLeft,lenghtUpperArm,lenghtForeArm,1,eye_ang,leftElbownDown,leftTwist)

        --debugoverlay.Sphere(startPos,1,0.1,Color(0,0,255,0),true)
        --debugoverlay.Sphere(upperArmPos,1,0.1,Color(0,255,0,0),true)
        --debugoverlay.Sphere(targetPosLeft,1,0.1,Color(255,0,0,0),true)

        matrixUpperArm:SetAngles(upperArmAng)
        BonesManager_ApplyMatrix(ent,bone_upperarm,matrixUpperArm,bone_forearm)

        matrixForeArm:SetAngles(foreArmAng)
        matrixForeArm:SetTranslation(upperArmPos)
        BonesManager_ApplyMatrix(ent,bone_forearm,matrixForeArm,bone_hand)
    end
end

--
--
--

function DrawHitBox(ply,time)
    time = time or 0.05

    for i = 0,ply:GetHitBoxCount(0) - 1 do
        local mins,maxs = ply:GetHitBoxBounds(i,0)
        local bone = ply:GetHitBoxBone(i,0)
        
        local mat = ply:GetBoneMatrix(bone)
        if not mat then continue end
        
        debugoverlayNet.BoxAngles(mat:GetTranslation(),mins,maxs,mat:GetAngles(),time,CLIENT and Color(255,125,0,0) or Color(0,0,255,0))
    end
end