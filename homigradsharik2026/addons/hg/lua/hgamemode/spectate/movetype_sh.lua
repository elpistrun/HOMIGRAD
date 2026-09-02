event.Add("Move","Noclip",function(ply,mv)
	if ply:GetNWFloat("DeadStart",0) + 1 > CurTime() or ply:Alive() or ply:GetMoveType() ~= MOVETYPE_NOCLIP then return end

    local move = Vector()

	if mv:KeyDown(IN_FORWARD) then move:Add(Vector(1,0,0)) end
	if mv:KeyDown(IN_BACK) then move:Add(Vector(-1,0,0)) end
	if mv:KeyDown(IN_MOVERIGHT) then move:Add(Vector(0,-1,0)) end
	if mv:KeyDown(IN_MOVELEFT) then move:Add(Vector(0,1,0)) end

	move:Rotate(ply:EyeAngles())

	if mv:KeyDown(IN_JUMP) then move:Add(Vector(0,0,1)) end

	move:Mul(750 * FrameTime())

	if mv:KeyDown(IN_DUCK) then move:Div(5) end
	if mv:KeyDown(IN_SPEED) then move:Mul(5) end

	local pos = mv:GetOrigin()
	pos:Add(move)

	mv:SetOrigin(pos)

	return true
end)
