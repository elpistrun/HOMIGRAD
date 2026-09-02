local SWEP = oop.Get("wep_tablet_traitor")
if not SWEP then return end

local catchView = Angle()
local mouseX,mouseY = 0,0

function SWEP:OnDeploy()
    self:PlayAnimation("deploy")
end

function SWEP:OnDeployEnd()
    if self:IsLocal() then
        catchView = LocalPlayer():EyeAngles()

        mouseX = ScrW() / 2
        mouseY = ScrH() / 2
    end
end

function SWEP:OnThink(owner)
    
end

function SWEP:DrawHUD()
    if self.stateHandling or self.stateHandling == "deploy" then return end

    surface.DrawCircle(mouseX,mouseY,3,255,255,255)
end

function SWEP:OnCreateMove(cmd)
    if self.stateHandling or self.stateHandling == "deploy" then return end

    local diff = catchView - cmd:GetViewAngles()

    diff:Mul(15)

    mouseX = mouseX + diff[2]
    mouseY = mouseY - diff[1]

    cmd:SetViewAngles(catchView)
end

function SWEP:CreateWorldModelPost(wm)
    if not wm.isWorldModel or not self:IsLocal() then return end

end

function SWEP:PostRenderWM(wm)
    if not self:IsLocal() then return end

    local matrix = wm:GetBoneMatrix(wm:LookupBone("weapon"))

    local ang = matrix:GetAngles()

    local pos = matrix:GetTranslation()
    pos:Add(Vector(3,0.18,-4.68):Rotate(ang))

    ang:RotateAroundAxis(ang:Forward(),90)
    ang:RotateAroundAxis(ang:Up(),90)
    ang:RotateAroundAxis(ang:Forward(),-180)

    cam.Start3D2D(pos,ang,1 / 54.3)
        surface.SetDrawColor(0,0,0)
        surface.DrawRect(0,0,512,324)

        draw.SimpleText("HELLO","H20",0,0)
    cam.End3D2D()
end