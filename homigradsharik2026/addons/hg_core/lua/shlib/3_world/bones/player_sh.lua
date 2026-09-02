local vector_zero = Vector(0,0,0)

function PlayerTPIK(tpikMatrix)
    local ent,link = tpikMatrix.ent,tpikMatrix.link

    TPIK_Pipeline(ent,link,tpikMatrix)

    TPIK_DoSolveEntity(
        ent,
        link,

        tpikMatrix.left != vector_zero and tpikMatrix.left,
        tpikMatrix.right != vector_zero and tpikMatrix.right,
        
        tpikMatrix.leftDown,
        tpikMatrix.rightDown,

        tpikMatrix.leftTwist,
        tpikMatrix.rightTwist
    )
    
    if not ent.tpik_targetPosLeft then
        ent.tpik_targetPosLeft = Vector()
        ent.tpik_targetPosRight = Vector()
    end

    ent.tpik_targetPosLeft:Set(tpikMatrix.left)
    ent.tpik_targetPosRight:Set(tpikMatrix.right)
    
    /*
    if targetPosLeft then debugoverlay.Sphere(targetPosLeft,1,0.1,SERVER and Color(0,0,200) or Color(255,125,0),true) end
    if targetPosRight then debugoverlay.Sphere(targetPosRight,1,0.1,SERVER and Color(0,0,200) or Color(255,125,0),true) end
    */
end

local fps = 24

if CLIENT then
	cvars.CreateOption("hg_tpik_fast","0",function(value)
		hg_tpik_fast = tonumber(value or 0) > 0
	end,0,1)

    cvars.CreateOption("hg_tpik_fps","24",function(value)
        fps = tonumber(value or 24)
    end,0,120)

	cvars.CreateOption("hg_tpik_lerp","1",function(value)
		hg_tpik_lerp = tonumber(value or 0) > 0
	end,0,1)
else
    hg_tpik_fast = false
    hg_tpik_lerp = false
end

RenderLODTPIK = "renderLOD2"

if CLIENT then
    FindMetaTable("Entity").IsTPIKAviable = function(self) return self == GetViewEntity() or not hg_tpik_fast and self[RenderLODTPIK] end
else
    FindMetaTable("Entity").IsTPIKAviable = function() return true end
end

local listIndex = {}
local countCalculate = 0

event.Add("PreRender","TPIK",function()
    local tableCount = table.Count(listIndex)

    if tableCount <= 1 or tableCount >= countCalculate then
        for ply in pairs(listIndex) do
            listIndex[ply] = nil
        end
    end

    countCalculate = 0
end,-9)

TPIK_DEFAULT_INTERPOLATION = 0.999

function PlayerBones_TPIK(ent,link)
    local tpikMatrix = GetHashTable(link,"tpikMatrix")

    if not tpikMatrix.left then
        tpikMatrix.left = Vector(0,0,0)
        tpikMatrix.right = Vector(0,0,0)
    else
        tpikMatrix.left:Set(vector_zero)
        tpikMatrix.right:Set(vector_zero)
    end

    tpikMatrix.leftDown = 120
    tpikMatrix.rightDown = 120

    tpikMatrix.ent = ent
    tpikMatrix.link = link

    tpikMatrix.interp = TPIK_DEFAULT_INTERPOLATION
    tpikMatrix.reset = nil
    tpikMatrix.instant = nil

    --

    if SERVER or link == GetViewEntity() or fps == 0 then
        tpikMatrix.deltaTime = FrameTime()
        tpikMatrix.reset = true
        tpikMatrix.instant = true
        tpikMatrix.isLocal = true

        PlayerTPIK(tpikMatrix)
    else
        tpikMatrix.interp = 1

        local time = RealTime()
        local deltaTime = 1 / fps
        tpikMatrix.deltaTime = deltaTime

        countCalculate = countCalculate + 1

        if (ent.bones_tpik_delay or 0) <= time and not listIndex[ent] then
            listIndex[ent] = true
            
            ent.bones_tpik_delay = time + deltaTime + deltaTime * math.Rand(-1 / 3.5,1 / 3.5)
            
            tpikMatrix.reset = true
            tpikMatrix.instant = true

            PlayerTPIK(tpikMatrix)
        end
    end

    PlayerTPIK_Lerp(tpikMatrix)
end

function PlayerBones_TPIKFast(ent,link)
    local tpikMatrix = GetHashTable(link,"tpikMatrix")

    TPIKFast_Pipeline(ent,link,tpikMatrix)
end

function PlayerTPIK_Lerp(tpikMatrix)
    local ent,link = tpikMatrix.ent,tpikMatrix.link

    if hg_tpik_lerp then
        TPIK_Lerp_Pipeline(ent,link,tpikMatrix)
    end

    if hg_tpik_lerp or tpikMatrix.interp == 1 then
        local matrixRespect,matrixRespectInverse = PlayersBones_MatrixRespect(link)
        TPIKLerp_DoSolveEntity(ent,matrixRespect,matrixRespectInverse,tpikMatrix.reset,tpikMatrix.interp)
    end
end