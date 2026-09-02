local function hooked(name,nameFunc)
	hook.Add(name,"level",function(...)
		if not levelActive then return end//lol

		local func = levelActive[nameFunc]
		if func then return func(levelActive,...) end
	end,-1)
end

local function evented(name,nameFunc,prio)
	event.Add(name,"level",function(...)
		if not levelActive then return end//lol
		
		local func = levelActive[nameFunc]
		if func then return func(levelActive,...) end
	end,prio or -1)
end

evented("PlayerSpawn","PlayerSpawn")
evented("Player Death","PlayerDeath")
evented("PreCalcView","PreCalcView",-10)
evented("Move","Move")

hooked("PlayerSwitchWeapon","PlayerSwitchWeapon")
hooked("OnContextMenuOpen","OnContextMenuOpen")
hooked("OnContextMenuClose","OnContextMenuClose")
hooked("CanUseSpectateHUD","CanUseSpectateHUD")

hooked("Think","Think")

hooked("OnPhysgunFreeze","OnPhysgunFreeze")
hooked("PhysgunDrop","PhysgunDrop")
hooked("PhysgunPickup","PhysgunPickup")
hooked("PostDrawTranslucentRenderables","PostDrawTranslucentRenderables")
hooked("Paint Content Icon","PaintContentIcon")
hooked("Scoreboard DMenu","ScoreboardDMenu")

hooked("Should Draw Screenspace","DrawScreenspace")

hooked("BodyCam","BodyCam")
hooked("SetupFog","SetupFog")

event.Add("View Back Weapon","level",function(ply,list)
	if not ply.IsPlayer or not ply:IsPlayer() then return end

	local level = levelActive
	local func = level.VBWHide
	if func then return func(level,ply,list) end
end)

evented("Can Use Spawn","CanUseSpawnMenu",9)
evented("Can Properties","CanUseContextMenu",9)

evented("Scoreborad Inventoru UI Create","ScoreboradInventoruUICreate")
evented("Pre Draw Sphere Ring","PreDrawSphereRing")

evented("Eye Mode","EyeMode")