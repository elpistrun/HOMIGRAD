local LERP = 0.8

FindMetaTable("Player").OnPickupObjectChange = function(self,oldEnt,newEnt)
	if IsValid(oldEnt) then
		oldEnt.RenderOverride = nil
		oldEnt.CalcAbsolutePosition = nil

		oldEnt.oldPlyPos = nil
		oldEnt.lerpPos = nil

		oldEnt:SetRenderOrigin()
		oldEnt:SetRenderAngles()

		oldEnt:SetRenderBounds(oldEnt:GetModelRenderBounds())
	end

	if IsValid(newEnt) then
		newEnt.oldPlyPos = self:GetPos()
		newEnt.lerpPos = newEnt:GetPos()

		if self == LocalPlayer() then
			newEnt:SetRenderBounds(-Vector(512,512,512),Vector(512,512,512))
		end

		newEnt.CalcAbsolutePosition = function()
			return newEnt:GetRenderOrigin(),newEnt:GetAngles()
		end

		newEnt.RenderOverride = function()
			if not IsValid(self) or not IsValid(newEnt) then return end--wtf

			if IsFirstFrame(newEnt,"pickupRender") then
				newEnt:SetRenderOrigin()
				
				if EyePos():Distance(newEnt:GetPos()) > 750 then
					newEnt.oldPlyPos = self:GetPos()

					newEnt:SetRenderOrigin()
					newEnt:SetRenderAngles()

					newEnt:DrawModel()
					
					return
				end

				local pickupAngle = newEnt:GetAngles()
				
				local pos,ang = self:Eye()

				local pos = pos + Vector(PickupTPIK_Lenght,0,0):Rotate(self:EyeAngles()) - newEnt:OBBCenter():Rotate(pickupAngle)
				pos[3] = pos[3] - 2

				local plyPos = self:GetPos()

				local diff = newEnt.oldPlyPos - plyPos
				newEnt.oldPlyPos = plyPos
				diff:Mul(2)
				pos:Sub(diff)

				newEnt.lerpPos:LerpFT(LERP,pos)
				newEnt:SetRenderOrigin(newEnt.lerpPos)
			end

			newEnt:DrawModel()
		end
	end
end

for i,ply in pairs(player.GetAll()) do
	ply:ProxyPVSVar("holdPickupObject",function(_,old,new)
		coroutine.wrap(function()
			if TypeID(new) == TYPE_NUMBER then new = EntityCoroutine(new) else new = nil end

			ply:OnPickupObjectChange(ply.oldHoldPickupObject,new)

			ply.oldHoldPickupObject = new
		end)()
	end)
end

event.Add("Player Create","holdPickupObject",function(ply)
	ply:ProxyPVSVar("holdPickupObject",function(_,old,new)
		coroutine.wrap(function()
			if TypeID(new) == TYPE_NUMBER then new = EntityCoroutine(new) else new = nil end
			
			ply:OnPickupObjectChange(ply.oldHoldPickupObject,new)

			ply.oldHoldPickupObject = new
		end)()
	end)
end)

hook.Add("CreateMove","PropPickup",function(cmd)
	local lply = LocalPlayer()

	if lply:Alive() and IsValid(Entity(lply:GetPVSVar("holdPickupObject") or -100)) and lply:KeyDown(IN_USE) then
		net.Start("prop_pickup_rotate",true)
		net.WriteString(tostring(cmd:GetMouseX() / 100))
		net.WriteString(tostring(cmd:GetMouseY() / 100))
		net.SendToServer()
	end
end)

event.Add("Use","PropPickup",function(ply,ent)
	if ply:GetPVSVar("holdPickupObject") == ent:EntIndex() then return false end
end)

hook.Add("InputMouseApply","Prop Pickup",function(cmd)
	local lply = LocalPlayer()

	if lply:Alive() and IsValid(Entity(lply:GetPVSVar("holdPickupObject") or -100)) and lply:KeyDown(IN_USE) then
		return true
	end
end)