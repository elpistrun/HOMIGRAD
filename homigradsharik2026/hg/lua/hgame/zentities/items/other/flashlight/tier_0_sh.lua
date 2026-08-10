local SWEP = oop.Reg("weapon_flashlight",{"hg_wep_base","tpik_animate"},true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = "Фонарик"
SWEP.Category = L("weapon_category_item")
SWEP.Spawnable = true

SWEP.Slot = 5
SWEP.SlotPos = 6
SWEP.SupportSecondarSlot = true
SWEP.IsSecondaryWeapon = true

SWEP.CorrectiveDropInfo = {
    bone = "Main",

    ang = Angle(-90,0,0),
    vec = Vector(0,0.5,2)
}

SWEP.PhysicsBox = {-Vector(4,1,1),Vector(5,1,1)}

SWEP:TableLink("wmData",{model = "models/weapons/c_slog_vm_flashlight.mdl",vec = Vector(12,5,-3),ang = Angle(0,0,0),center = {Vector(-17.5,-6.5,2),Angle(-3,-10,0)}})

SWEP.dwiPos = Vector(-13.6,12,-9.5)
SWEP.dwiAng = Angle(-45,0,0)

SWEP.dwsPos = Vector(-13.6,12,-9.5)
SWEP.dwsAng = Angle(-45,0,0)

SWEP.itemType = "other"

SWEP.TPIK_UseRightHand = false
SWEP.fake_blockLHand = true
SWEP.SupportLinkWeapon = true

if SERVER then
    SWEP.TPIKBonesL = {
        {"Main","ValveBiped.Bip01_L_Hand"},
    }
end

SWEP.TPIKLerpWhitelist["Main"] = true

function SWEP:CreateWorldModelPost(wm)
    wm:SetSubMaterial(1,"models/rendertarget")--lol?
end

function SWEP:OnDeploy()
    self:PlayAnimation("deploy")
end

function SWEP:OnHolster()
    self:PlayAnimation("holster")
end

function SWEP:GetShootMatrix(wm)
    local mat = wm:GetBoneMatrix(40)
    if not mat then return wm:GetPos(),wm:GetAngles() end
    
    local pos,ang = mat:GetTranslation(),mat:GetAngles()
    ang:RotateAroundAxis(ang:Right(),90)

    pos:Add(Vector(12,0,0):Rotate(ang))

    return pos,ang
end

if SERVER then return end

local hg_best_flashlight = 0

cvars.CreateOption("hg_best_flashlight","0",function(value)
    hg_best_flashlight = tonumber(value)
end,-1,1)

local tr = {
    filter = function(ent) return not util.IsHumanoid(ent) end
}

function SWEP:ThinkFlashlight(link)
    if SERVER then return end

    if hg_best_flashlight == 1 or hg_best_flashlight == 0 and self:IsLocal() then
        local projectLight = self.projectLight

        if not IsValid(projectLight) then
            projectLight = ProjectedTexture()
            self.projectLight = projectLight
        end

        local pos,ang = link:Eye()

        local wm = self.wm

        if IsValid(wm) then
            local mat = wm:GetBoneMatrix(40)

            pos,ang = self:GetShootMatrix(wm)
        end
        
        projectLight:SetPos(pos)
        projectLight:SetAngles(ang)
        projectLight:SetFarZ(1000)
        projectLight:SetTexture("effects/flashlight001")
        projectLight:Update()
    else
        local eyePos,eyeAng = link:Eye()
        tr.start = eyePos
        tr.endpos = eyePos + Vector(200,0,0):Rotate(eyeAng)
        
        local result = util.TraceLine(tr)

        local dlight = DynamicLight(self:EntIndex())
		dlight.pos = result.HitPos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 2
		dlight.decay = 1000
		dlight.size = 256
		dlight.dietime = CurTime() + 1
    end
end

SWEP:Event_Add("Off","Flashlight",function(self) if IsValid(self.projectLight) then self.projectLight:Remove() end end)

function SWEP:DoIKPost(ent,link)
    self:ThinkFlashlight(link)
end

local sprite = Material("particle/particle_glow_04_additive")

local color = Color(255,255,255)
local size = 8

function SWEP:PostRenderWM(wm)
    if not IsValid(self.projectLight) then return end

    local dot = 1 - EyeVector():Dot(Vector(1,0,0):Rotate(self.projectLight:GetAngles()))

    dot = math.max(dot - 0.5,0) / 0.5

    if dot > 0 then
        render.SetMaterial(sprite)
        render.DrawSprite(self.projectLight:GetPos(),size * dot,size * dot,color)
    end
end

if SERVER then return end

keyboard.DefaultBindCode("flashlight",KEY_F,true)

concommand.Add("flashlight",function(ply)
    local wep = ply:GetWeapon("weapon_flashlight")
    if not IsValid(wep) then return end

    if ply:GetActiveSecondaryWeapon() == wep then
        input.SelectSecondaryWeapon()
    else
        input.SelectSecondaryWeapon(wep)
    end
end)