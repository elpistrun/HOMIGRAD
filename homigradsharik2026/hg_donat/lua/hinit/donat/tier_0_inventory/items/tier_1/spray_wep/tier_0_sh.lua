local SWEP = oop.Reg("wep_spray","weapon_per4ik",true)
if not SWEP then return INCLUDE_BREAK end

SWEP.PrintName = "Spray"
SWEP.Author = "0oa"
SWEP.Instructions = "На одно использование"
SWEP.Spawnable = false

SWEP:Event_Add("SetupDataTables","Spray",function(self)
    self:NetworkVar("String","URL")
    self:NetworkVar("String","CreatorSteamID")

    self:NetworkVar("Float","Width")
    self:NetworkVar("Float","Height")
end)

function SWEP:GetTrace()
    local trace = self:GetOwner():EyeTrace(PlayerDisUse)
    
    if not trace or not trace.Hit or not trace.HitWorld then return end

    local pos,ang = trace.HitPos,trace.HitNormal:Angle()

    ang:RotateAroundAxis(ang:Right(),-90)
    ang:RotateAroundAxis(ang:Up(),90)

    return pos,ang
end

if SERVER then return end

function SWEP:Render(wm)
    wm:DrawModel()

    if not self.GetNWBool then return end

    if not self:IsLocal() or LocalPlayer():GetActiveWeapon() != self then return end

    local pos,ang = self:GetTrace()
    if not pos then return end

    ImageTool:Start3D2D({
        position = pos,
        angles = ang,
        url = self:GetURL(),

        width = self:GetWidth(),
        height = self:GetHeight(),

        alpha = 125
    })
end

function SWEP:DrawHUD()
    local pos,ang = self:GetTrace()

    local w,h = ScrW(),ScrH()

    if not pos then
        draw.SimpleText("Стены не найдено","HS.25",w/2,h * 0.9,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        
        return
    else
        draw.SimpleText("Нанести рисунок","HS.25",w/2,h * 0.9,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end