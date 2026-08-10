local SWEP = oop.Get("wep_bow")
if not SWEP then return end

SWEP.CameraPos = Vector(-14,5.19,-1.5)
SWEP.CameraAng = Angle(0.87,-2,0)

function SWEP:PreCalcView(ply,view)
    local wm = self:GetWorldModel()
    if not IsValid(wm) then return end

    local cameraWM = self:GetCameraWM(ply)
    if not IsValid(cameraWM) then return end

    local cameraPos,cameraAng

	local matrix = cameraWM:GetBoneMatrix(40)
	if not matrix then return end

    local muzzleAng = matrix:GetAngles()

    cameraPos = matrix:GetTranslation():Add(self.CameraPos:Clone():Rotate(muzzleAng))
    cameraAng = muzzleAng:Rotate(self.CameraAng)

    cameraAng[3] = 0
    
    self:CalcViewScope(ply,view,cameraPos,cameraAng)
end