local function setLeft(ply,pos,ang)
    local worldPos,worldAng = LocalToWorld(Vector(0,0,0),Angle(-45,0,90 - 25),pos,ang)
    
    local mat = Matrix()
    mat:SetTranslation(worldPos)
    mat:SetAngles(worldAng)

    BonesManager_ApplyMatrix(ply,ply:LookupBone("ValveBiped.Bip01_L_Hand"),mat)
end

local function setRight(ply,pos,ang)
    local worldPos,worldAng = LocalToWorld(Vector(0,0,0),Angle(-45,0,90 + 25),pos,ang)

    local mat = Matrix()
    mat:SetTranslation(worldPos)
    mat:SetAngles(worldAng)

    BonesManager_ApplyMatrix(ply,ply:LookupBone("ValveBiped.Bip01_R_Hand"),mat)
end

function TPIK_Hand_CarryObject(ply,link,tpikMatrix)
    --[[if not link or not link.GetCarryObject then return end
    local ent,bone,localPos,localAng = link:GetCarryObject()

    if not IsValid(ent) then return end

    local pos,ang = GetCarryMatrix(ent,bone,localPos,localAng)

    local eyePos,eyeAng = link:Eye()

    ang = eyeAng

    local posLeft = pos + Vector(-2,2,0):Rotate(ang)
    local posRight = pos + Vector(-2,-2,0):Rotate(ang)

    tpikMatrix.left = posLeft
    tpikMatrix.right = posRight

    setLeft(ply,posLeft,ang)
    setRight(ply,posRight,ang)]]--
end

hook.Add("StartCommand","CarryObject",function(ply,cmd)
	if not ply:Alive() or not IsValid(ply:GetNWEntity("carryObject")) then return end
	
	cmd:RemoveKey(IN_SPEED)
end)