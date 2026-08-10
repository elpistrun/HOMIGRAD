BonesManager_SimpleNameToFullName = {
    ["rclavicle"] = "ValveBiped.Bip01_R_Clavicle",
    ["rupperarm"] = "ValveBiped.Bip01_R_UpperArm",
    ["rforearm"] = "ValveBiped.Bip01_R_Forearm",
    ["rhand"] = "ValveBiped.Bip01_R_Hand",

    ["lclavicle"] = "ValveBiped.Bip01_L_Clavicle",
    ["lupperarm"] = "ValveBiped.Bip01_L_UpperArm",
    ["lforearm"] = "ValveBiped.Bip01_L_Forearm",
    ["lhand"] = "ValveBiped.Bip01_L_Hand",

    ["spine"] = "ValveBiped.Bip01_Spine",
    ["spine2"] = "ValveBiped.Bip01_Spine2",
    ["spine4"] = "ValveBiped.Bip01_Spine4",

    ["rthigh"] = "ValveBiped.Bip01_R_Thigh",

    ["head"] = "ValveBiped.Bip01_Head1"
}

local ang_zero = Angle()

function PlayerBones_PreManipulation(ent,tag,link)
    ent.manipulationBones = ent.manipulationBones or {}
end

function PlayerBones_PostManipulation(ent,tag,link)
    ApplyManipulationBones(ent)
end

function ApplyManipulationBones(ent)
    ent.manipulationBones = ent.manipulationBones or {}

    local manipulationBones = ent.manipulationBones

    for bone,ang in pairs(manipulationBones) do
        ent:ManipulateBoneAngles(bone,ang or ang_zero,false)

        if manipulationBones[bone] == false then
            manipulationBones[bone] = nil
        else
            manipulationBones[bone] = false
        end
    end
end

function ManipulationBonesReset(ent)
    local manipulationBones = ent.manipulationBones

    for bone,ang in pairs(manipulationBones) do
        manipulationBones[bone] = false
        ent:ManipulateBoneAngles(bone,ang or ang_zero,false)
    end
end

local BonesManager_SimpleNameToFullName = BonesManager_SimpleNameToFullName
local ENTITY = FindMetaTable("Entity")

function ENTITY:AddBoneAng(name,ang)
    name = self:LookupBone(BonesManager_SimpleNameToFullName[name])
    if not name then ErrorNoHaltWithStack("invalid bone name for model " .. tostring(self:GetModel()) .. "\n") return end
    self.manipulationBones[name] = (self.manipulationBones[name] or Angle()):Add(ang)
end

function ENTITY:SetBoneAng(name,ang)
    name = self:LookupBone(BonesManager_SimpleNameToFullName[name])
    self.manipulationBones[name] = ang
end

function ENTITY:GetBoneAng(name)
    return self.manipulationBones[self:LookupBone(BonesManager_SimpleNameToFullName[name])]
end

function ENTITY:AddBoneAngEx(bone,ang)
    self.manipulationBones[bone] = (self.manipulationBones[bone] or Angle()):Add(ang)
end

function ENTITY:SetBoneAngEx(bone,ang)
    self.manipulationBones[bone] = ang
end

function ENTITY:GetBoneAngEx(bone)
    return self.manipulationBones[bone]
end

if Initialize then
    for i,ply in pairs(player.GetAll()) do
        for i = 0,ply:GetBoneCount() do
            ply:ManipulateBoneAngles(i,Angle(),false)
        end
    end
end