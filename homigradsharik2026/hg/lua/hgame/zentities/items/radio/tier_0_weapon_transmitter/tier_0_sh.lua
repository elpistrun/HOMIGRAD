local SWEP = oop.Reg("weapon_transmitter","hg_wep_base",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName 				= L("weapon_transmitter")
SWEP.Author 				= "0oa"
SWEP.Instructions			= L("weapon_transmitter_desc")
SWEP.Category 				= L("weapon_category_item")

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 0
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP:TableLink("wmFastData",{model = "models/radio/w_radio.mdl",vec = Vector(6,-2,-1),ang = Angle(90,180,-90)})

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(1.8,-42,0)
SWEP.dwiPos = Vector(1.8,-30,1.5)
SWEP.dwiSelectPos = Vector(2,-130,0)
SWEP.dwiAng = Angle(180 + 45,0,-90)
SWEP.dwsAng = Angle(-90,-90,0)

SWEP.EnableTransformModel = true

SWEP.vbw = true
SWEP.vbwIsHolster = true
SWEP.vbwPos = Vector(-1,2,7)
SWEP.vbwAng = Angle(0,90,90)
SWEP.vbwModelScale = Vector(1,1,1)

SWEP.itemType = "other"

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

SWEP.HoldType = "normal"

SWEP.RadioDistanceTransmit = 64
SWEP.RadioLimit = {65,145}
SWEP.RadioLimitRound = 0.1

function SWEP:GetTransmitPos()
    local owner = self:GetOwner()

    if IsValid(owner) then return owner:EyePos() else return self:GetPos() end
end

function SWEP:GetTransmit(value)
    return self:GetNWBool("TransmitLine",false)
end

function SWEP:GetLisen(value)
    return self:GetNWBool("LisenLine",false)
end

if SERVER then return end

SWEP:Event_Add("Think","Sounds",function(self,ply)
    if EyePos():Distance(self:GetPos()) <= 512 then
        if not IsValid(self.radioEmbient) then
            self.radioEmbient = sound.CreatePoint(self,"homigrad/radio/line/player_voice.wav",65)
        end

        if self.radioEmbient:Play() then
            self.radioEmbient.pitch = math.Rand(0.9,1.1)
        end

        self.radioEmbient.volume = self:GetNWBool("EnableSound") and 1 or 0
    else
        if IsValid(self.radioAmbient) then self.radioEmbient:Stop() end
    end
end)

function SWEP:DoBones(ply,link,tpikMatrix)
    local wm = self:GetWorldModel()
    if not IsValid(wm) then return end

    self:SetupBones_WorldModel_ByHand(ply,link)

    self.playerAnim = LerpFT(0.8,self.playerAnim or 0,self:GetNWFloat("PlayerAnim",0))
    local anim = self.playerAnim

    if CLIENT and self:IsLocal() and RenderIsMe() then
        ply:AddBoneAng("rupperarm",Angle(0,-25,20):Mul(anim))
        ply:AddBoneAng("rforearm",Angle(-24,-100,20):Mul(anim))
        ply:AddBoneAng("rhand",Angle(-20,0,70))
    else
        ply:AddBoneAng("rupperarm",Angle(0,-25,20):Mul(anim))
        ply:AddBoneAng("rforearm",Angle(-30,-120,0):Mul(anim))
        ply:AddBoneAng("rhand",Angle(-0,0,90):Mul(anim))
    end
end

function SWEP:Render(wm)
    wm:DrawModel()
    
    if not self.GetNWBool then return end
    
    local pos,ang = wm:GetPos(),wm:GetAngles()

    ang:RotateAroundAxis(ang:Up(),-90)
    pos:Add(Vector(0.54,3.89,0.89):Rotate(ang))
    
    cam.Start3D2D(pos,ang,0.009)
        local w,h = 310,120

        self:DrawLED(w,h)
    cam.End3D2D()
end

local k = 0
local oldVec,oldAng = Vector(),Angle()

event.Add("PreCalcView","Radio Transmitter",function(ply,view)
    if not targetSettingsRadio then return end

    local target = targetSettingsRadio.entity
    if not IsValid(target) or not IsValid(target.wm) then
        local k = math.max(targetSettingsRadioStart - RealTime() + 0.3,0) / 0.7

        if k <= 0 then return end

        view.vec:Lerp(k,oldVec)
        view.ang:Lerp(k,oldAng)
        view.fov = Lerp(k,view.fov,90)

        return
    end

    local k = math.ease.InCubic(1 - math.max(targetSettingsRadioStart - RealTime() + 0.3,0) / 0.7)

    local vec,ang = view.vec,view.ang
    local targrtAng = target.wm:GetAngles()

    targrtAng:RotateAroundAxis(targrtAng:Right(),-90)

    view.ang:Lerp(k,targrtAng)

    local targetPos = target.wm:GetPos()
    targetPos:Add(Vector(1,-2,8):Rotate(target.wm:GetAngles()))
    
    view.vec:Lerp(k,targetPos)
    view.fov = Lerp(k,view.fov,90)

    oldVec = view.vec
    oldAng = view.ang

    return view
end,10)

function SWEP:DrawInvPost(inv,panel,item)
    draw.SimpleText((item.fm or 0) .. ".fm","InvFont",4,2)

    return true
end