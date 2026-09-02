afkStart = CurTime()

local afkTime = 60 * 3
local afkStart = RealTime()

local oldX,oldY = 0,0

local time
hook.Add("CreateMove","afk",function(moveData)
	local time = RealTime()

	if roundActiveName == "level_event" then afkStart = time return end

	local ply = LocalPlayer()
	
	local x,y = moveData:GetMouseX(),moveData:GetMouseY()
	
	if x ~= oldX then
		oldX = x
		afkStart = time
	end

	if x ~= oldY then
		oldY = y
		afkStart = time
	end

	if ply:IsAdmin() or moveData:GetButtons() > 0 or not ply:Alive() or ply:Team() == 1002 then afkStart = time end

	if afkStart + afkTime < time then
		net.Start("afk")
		net.SendToServer()
		RunConsoleCommand("say","афк 9999999")
	end
end)

local oldX,oldY = 0,0
hook.Add("HUDPaint","AFK",function()
	local ply = LocalPlayer()

	local x,y = gui.MouseX(),gui.MouseY()

	if oldX ~= x then
		oldX = x
		afkStart = RealTime()
	end

	if oldY ~= y then
		oldY = y
		afkStart = RealTime()
	end

	local time = afkStart + afkTime - RealTime()

	if time <= 30 then 
		draw.SimpleText("AFK SYSTEM " .. math.floor(time),"HS.45",ScrW() / 2,ScrH() / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end)

adminPanel.commandRegistry("afk",{},"game")