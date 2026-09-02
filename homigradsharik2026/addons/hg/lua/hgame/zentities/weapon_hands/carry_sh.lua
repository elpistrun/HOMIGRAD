local PLAYER = FindMetaTable("Player")

function PLAYER:SetCarryObject(ent,bone,localPos,localAng)
    if ent then
        self:SetNWEntity("carryObject",ent)
        self:SetNWInt("carryObject_Bone",bone)
        self:SetNWVector("carryObject_Pos",localPos)
        self:SetNWAngle("carryObject_Ang",localAng)
    else
        self:SetNWEntity("carryObject",NULL)
        self:SetNWInt("carryObject_Bone",0)
        self:SetNWVector("carryObject_Pos",Vector())
        self:SetNWAngle("carryObject_Ang",Angle())
    end
end

function PLAYER:GetCarryObject()
    local ent = self:GetNWEntity("carryObject")
    if not IsValid(ent) then return end

    return ent,self:GetNWInt("carryObject_Bone",0),self:GetNWVector("carryObject_Pos"),self:GetNWAngle("carryObject_Ang")
end

function GetCarryMatrix(carryEnt,bone,localPos,localAng)
    local mat = carryEnt:GetBoneMatrix(math.max(carryEnt:TranslatePhysBoneToBone(bone),0))
    return LocalToWorld(localPos,localAng,mat:GetTranslation(),mat:GetAngles())
end

local lerp = 0
local delay = 0
local glow = Material("homigrad/vgui/vignette.png","smooth")

hook.Add("PreDrawHUD","CarryCheckPulse",function()
    local ply = GetViewEntity()
    if not IsValid(ply) or not ply.GetNWBool then lerp = 0 return end

    lerp = LerpFT(0.33,lerp,ply:GetNWBool("CarryCheckPulse") and 1 or 0)

    if lerp <= 0.001 then return end

    local carry = ply:GetNWEntity("carryObject")

    if IsValid(carry) then
        local controller = carry:GetController()

        local pulse = 0

        if IsValid(controller) then
            pulse = controller:GetNWFloat("pulse",1 / 60) * 60
            
            if delay + pulse < RealTime() then
                delay = RealTime()

                surface.PlaySound("snd_jack_hmcd_heartpound.wav")
            end
        end
    end

    cam.Start2D()

    surface.SetDrawColor(0,0,0,200 * lerp)
    surface.SetMaterial(glow)
    surface.DrawTexturedRect(0,0,ScrW(),ScrH())

    cam.End2D()
end)

event.Add("DSP","CarryCheckPulse",function(viewEntity)
    if IsValid(viewEntity) and viewEntity:GetNWBool("CarryCheckPulse") then
        return 30
    end
end)