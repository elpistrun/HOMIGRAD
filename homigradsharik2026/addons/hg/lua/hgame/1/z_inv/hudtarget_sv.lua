util.AddNetworkString("use")

local nextUse = {}

net.Receive("use",function(_,ply)
	if not IsValid(ply) or not ply:Alive() or ply:InFake() then return end
	if (nextUse[ply] or 0) > CurTime() then return end
	nextUse[ply] = CurTime() + 0.1

	local ent = net.ReadEntity()
	if not IsValid(ent) then return end

	local maxDistance = (PlayerDisUse or 75) + 24
	if ply:EyePos():DistToSqr(ent:NearestPoint(ply:EyePos())) > maxDistance * maxDistance then return end

	-- Client-side Use handlers provide prediction/UI. The authoritative entity
	-- interaction still happens through the engine input on the server.
	ent:Fire("Use","",0,ply,ply)
end)

hook.Add("PlayerDisconnected","HG HUD target use cleanup",function(ply)
	nextUse[ply] = nil
end)
