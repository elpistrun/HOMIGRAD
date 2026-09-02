DEFAULT_SPEED = 125
DEFAULT_RUNSPEED = 380
DEFAULT_RUNSPEED_DELAYSPRING = 0.6

DEFAULT_HEALTH = 200

DEFAULT_SLOWWALK = 75
DEFAULT_LADDERSPEED = 75
DEFAULT_JUMPPOWER = 225

DEFAULT_VIEW_OFFSET = Vector(0,0,70)
DEFAULT_VIEW_OFFSET_DUCKED = Vector(0,0,32)

DEFAULT_JUMP_POWER = 185 --284
DEFAULT_STEP_SIZE = 18
DEFAULT_MASS = 80
DEFAULT_MODELSCALE = 1

DEFAULT_HULLSIZE = 9

function CreateTeams()
	team.SetUp(1,"Terrorists",Color(255,0,0))
	team.SetUp(2,"Counter Terrorists",Color(0,0,255))
	team.SetUp(3,"Other",Color(0,255,0))

	team.MaxTeams = 3
end

function OpposingTeam(team)
	if team == 1 then return 2 elseif team == 2 then return 1 end
end

function ReadPoint(point)
	if TypeID(point) == TYPE_VECTOR then
		return {point,Angle(0,0,0)}
	elseif type(point) == "table" then
		if type(point[2]) == "number" then
			point[3] = point[2]
			point[2] = Angle(0,0,0)
		end

		return point
	end
end

local team_GetPlayers = team.GetPlayers

function PlayersInGame()
    local newTbl = {}

    for i,ply in pairs(team_GetPlayers(1)) do newTbl[i] = ply end
    for i,ply in pairs(team_GetPlayers(2)) do newTbl[#newTbl + 1] = ply end
    for i,ply in pairs(team_GetPlayers(3)) do newTbl[#newTbl + 1] = ply end

    return newTbl
end

local white = Color(255,255,255)

function GetTeamColor(ply)
	local name,color = ply:GetTeamStatus()

	return color or white
end

event.Add("Player Spawn","Initial Values",function(ply)
	if not ply.init then return false end

	if SERVER then
		ply:SetModel("models/player/gman_high.mdl")

		for i = 0,ply:GetNumBodyGroups() - 1 do ply:SetBodygroup(i,0) end
		ply:SetSkin(0)//mdam
		ply:SetMaterial("")
		ply:SetColor(Color(255,255,255))

		ply:SetHealth(100)
		if SERVER then ply:SetMaxHealth(100) end

		ply:Give("weapon_hands")
		
		if ply:Team() == 1002 then
			ply:Give("weapon_physgun")
			ply:Give("gmod_tool")

			ply:GiveFlashlight()
		end
	end

	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER_MOVEMENT)
	ply:SetNotSolid(false)
	ply:SetNoDraw(false)

	timer.Simple(TickInterval(),function()
		if not IsValid(ply) or not ply:Alive() then return end

		local hullmin,hull,hullduck = Vector(-DEFAULT_HULLSIZE,-DEFAULT_HULLSIZE,0),Vector(DEFAULT_HULLSIZE,DEFAULT_HULLSIZE,DEFAULT_VIEW_OFFSET[3]),Vector(DEFAULT_HULLSIZE,DEFAULT_HULLSIZE,DEFAULT_VIEW_OFFSET_DUCKED[3])

		ply:SetHull(hullmin,hull)
		ply:SetHullDuck(hullmin,hullduck)

		ply:SetViewOffset(DEFAULT_VIEW_OFFSET)
		ply:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
	end)

	ply:SetCanZoom(false)
	ply:DrawShadow(false)

	ply:SetNoCollideWithTeammates(false)
	
	ply:SetWalkSpeed(DEFAULT_SPEED)
	ply:SetRunSpeed(DEFAULT_RUNSPEED)
	ply:SetSlowWalkSpeed(DEFAULT_SLOWWALK)
	ply:SetLadderClimbSpeed(DEFAULT_LADDERSPEED)
	ply:SetJumpPower(DEFAULT_JUMPPOWER)

	if SERVER then ply:SetMaxHealth(DEFAULT_HEALTH) end
	ply:SetHealth(DEFAULT_HEALTH)

	local phys = ply:GetPhysicsObject()
	if phys:IsValid() then phys:SetMass(DEFAULT_MASS) end
end,-100)

event.Add("Player Spawn","Homigrad Level",function(ply)
	if ply:Team() > 1000 or not levelActive then return end

	local func = levelActive.PlayerSpawn
	if func then func(levelActive,ply) end
end,10)