local vec_zero,ang_zero = Vector(),Angle()

local lerpHeadAng
local startCamera
local delayCameraStart = 0.33

local lerp = 0

local MatrixSet = Matrix()
local MatrixSetLocal = Matrix()
MatrixSetLocal:SetAngles(Angle(0,-83,-90))

local VecSet,AngSet = Vector(),Angle()

event.Add("PreCalcView","Ragdoll",function(ply,view)
	if not ply:Alive() then
		lerpHeadAng = nil
		startCamera = nil
		lerp = 0

		return
	end

	local dummy = ply:GetDummy()
	
	view.noSmooth = true

	local headBone = dummy:LookupBone("ValveBiped.Bip01_Head1")
	if not headBone then return end

	dummy:CopyBoneMatrixHash(headBone,MatrixSet)
	
	MatrixSet:Mul(MatrixSetLocal)

	MatrixSet:SetXYZ_PYR(VecSet,AngSet)

	if not lerpHeadAng then
		lerpHeadAng = AngSet
		startCamera = RealTime()
	else
		lerpHeadAng:LerpFT(0.5,AngSet)
	end

	local lerpSet = math.min(math.max(dummy:GetVelocity():Length() - 125,0) / 300,1)
	lerpSet = math.max(lerpSet - math.max(startCamera + delayCameraStart - RealTime(),0) / delayCameraStart,0)

	if dummy == ply then lerpSet = lerpSet * 0.1 end

	lerp = LerpFT(0.33,lerp,lerpSet)

	view.ang:Lerp(lerp,lerpHeadAng)
end,-10)