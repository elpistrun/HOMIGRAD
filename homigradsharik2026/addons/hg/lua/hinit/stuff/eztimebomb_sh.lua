local ENT = oop.Reg("ent_jack_gmod_eztimebomb","base_entity")
if not ENT then return end

ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Time Bomb"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZscannerDanger = true
ENT.JModPreferredCarryAngles = Angle(-90, 0, 0)
ENT.JModEZstorable = true

ENT.itemType = "mine"

---
local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Int", 1, "Timer")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self.Entity:SetModel("models/jmod/explosives/bombs/c4/w_c4_planted.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(ONOFF_USE)

		---

		self:GetPhysicsObject():SetMass(25)
		self:GetPhysicsObject():Wake()
	

		---
		self:SetState(STATE_OFF)
		self.NextStick = 0
		self.DisarmProgress = 0
		self.DisarmNeeded = 20
		self.NextDisarmFail = 0
		self.NextDisarm = 0
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			if self:GetTimer() < 10 then
				self:SetTimer(10)
			end

			self:SetState(STATE_ARMED)
		elseif iname == "Time" and value >= 10 and self:GetState() == STATE_OFF then
			self:SetTimer(value)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				self.Entity:EmitSound("snd_jack_claythunk.wav", 55, math.random(80, 120))
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if dmginfo:GetInflictor() == self then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		local Pos, State = self:GetPos(), self:GetState()

		if State == STATE_ARMED then
			self:Detonate()
		elseif not (State == STATE_BROKEN) then

		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude, Time = activator or activatorAgain, CurTime()
		local Time = CurTime()

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end

            local Alt = activator:KeyDown(IN_WALK)

			if State == STATE_OFF then
				if Alt then
					if self.NextDisarmFail < Time then
						net.Start("JMod_EZtimeBomb")
						net.WriteEntity(self)
						net.Send(Dude)
					end
				else
					constraint.RemoveAll(self)
					self.StuckStick = nil
					self.StuckTo = nil
					Dude:PickupObject(self)
					self.NextStick = Time + .5
				end
			else
				if Alt then
					if self.NextDisarm < Time then
						self.NextDisarm = Time + .2
						self.DisarmProgress = self.DisarmProgress
						self.NextDisarmFail = Time + 1
						Dude:PrintMessage(HUD_PRINTCENTER, "disarming: " .. math.floor(self.DisarmProgress) .. "/" .. math.ceil(self.DisarmNeeded))

						if self.DisarmProgress >= self.DisarmNeeded then
							self:SetState(STATE_OFF)
							self:EmitSound("weapons/c4/c4_disarm.wav", 60, 120)
							self.DisarmProgress = 0
						end
					end
				else
					constraint.RemoveAll(self)
					self.StuckStick = nil
					self.StuckTo = nil
					Dude:PickupObject(self)
					self.NextStick = Time + .5
				end
			end
		else -- player just released the USE key
			if self:IsPlayerHolding() and (self.NextStick < Time) then
				local Tr = util.QuickTrace(Dude:GetShootPos(), Dude:GetAimVector() * 80, {self, Dude})

				if Tr.Hit then
					if IsValid(Tr.Entity:GetPhysicsObject()) and not Tr.Entity:IsNPC() and not Tr.Entity:IsPlayer() then
						self.NextStick = Time + .5
						local Ang = Tr.HitNormal:Angle()
						Ang:RotateAroundAxis(Ang:Right(), -90)
						Ang:RotateAroundAxis(Ang:Up(), 180)
						self:SetAngles(Ang)
						self:SetPos(Tr.HitPos)

						-- crash prevention
						if Tr.Entity:GetClass() == "func_breakable" then
							timer.Simple(0, function()
								self:GetPhysicsObject():Sleep()
							end)
						else
							local Weld = constraint.Weld(self, Tr.Entity, 0, Tr.PhysicsBone, 3000, false, false)
							self.StuckTo = Tr.Entity
							self.StuckStick = Weld
						end

						self.Entity:EmitSound("snd_jack_claythunk.wav", 65, math.random(80, 120))
						Dude:DropObject()
					end
				end
			end
		end
	end

	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true

		timer.Simple(math.Rand(0, .1), function()
            local explosive = oop.Create("explosive_base")
            explosive:SetPos(self:GetPos())
            explosive:SetParent(self)
            explosive:SetAttacker(self.Attacker)
            explosive.Power = 3
			explosive.RadiusDamage = 400
			explosive.RadiusStun = 700
			explosive.Damage = 1000
			explosive.FragCount = 0
            explosive:Emit()
			
			event.Run("Construct Explosive",self:GetPos(),500)
		end)
	end

	function ENT:Think()
		if self.NextDisarmFail < CurTime() then
			self.DisarmProgress = 0
		end

		if self:GetState() == STATE_ARMED then
            sound.Emit(self:EntIndex(),"weapons/c4/c4_beep1.wav",75,1,100)
			self:SetTimer(self:GetTimer() - 1)

			if self:GetTimer() <= 0 then
				self:Detonate()

				return
			end

			self:NextThink(CurTime() + 1)

			return true
		end
	end

    util.AddNetworkString("JMod_EZtimeBomb")

    net.Receive("JMod_EZtimeBomb", function(ln, ply)
        local ent = net.ReadEntity()
        local tim = net.ReadInt(16)
    
        if (ent:GetState() == 0) and ply:Alive() and (ply:GetPos():Distance(ent:GetPos()) <= 150) then
            ent:SetTimer(math.min(tim, 600))
            ent.DisarmNeeded = math.Round(math.min(tim, 600) / 4)
            ent:NextThink(CurTime() + 1)
            ent:SetState(1)
            ent:EmitSound("weapons/c4/c4_plant.wav", 60, 120)
            ent:EmitSound("snd_jack_minearm.wav", 60, 100)

            ent.Attacker = ply
        end
    end)
elseif CLIENT then
    net.Receive("JMod_EZtimeBomb", function()
        local ent = net.ReadEntity()
        local frame = vgui.Create("DFrame")
        frame:SetSize(300, 120)
        frame:SetTitle("Time Bomb")
        frame:SetDraggable(true)
        frame:Center()
        frame:MakePopup()
    
        function frame:Paint(w,h)
            surface.SetDrawColor(0,0,0,200)
            surface.DrawRect(0,0,w,h)

            surface.SetMaterial(Material("homigrad/achivment/radio_anime.png"))
            surface.SetDrawColor(255,255,255,25)
            surface.DrawTexturedRect(0,0,w,h)
        end
    
        local bg = vgui.Create("DPanel", frame)
        bg:SetPos(90, 30)
        bg:SetSize(200, 25)
    
        function bg:Paint(w, h)
            surface.SetDrawColor(Color(255, 255, 255, 100))
            surface.DrawRect(0, 0, w, h)
        end
    
        local tim = vgui.Create("DNumSlider", frame)
        tim:SetText("Set Time")
        tim:SetSize(280, 20)
        tim:SetPos(10, 30)
        tim:SetMin(10)
        tim:SetMax(600)
        tim:SetValue(10)
        tim:SetDecimals(0)
        local apply = vgui.Create("DButton", frame)
        apply:SetSize(100, 30)
        apply:SetPos(100, 75)
        apply:SetText("ARM")
    
        apply.DoClick = function()
            net.Start("JMod_EZtimeBomb")
            net.WriteEntity(ent)
            net.WriteInt(tim:GetValue(), 16)
            net.SendToServer()
            frame:Close()
        end
    end)
    
	function ENT:Initialize()
	end

	--
	local function GetTimeString(seconds)
		local Minutes, Seconds = math.floor(seconds / 60), math.floor(seconds % 60)

		if Minutes < 10 then
			Minutes = "0" .. Minutes
		end

		if Seconds < 10 then
			Seconds = "0" .. Seconds
		end

		return Minutes .. ":" .. Seconds
	end

	function ENT:Draw()
		self:DrawModel()

		if self:GetState() == STATE_ARMED then
			local ang, SelfPos = self:GetAngles(), self:GetPos()
			ang:RotateAroundAxis(ang:Up(), -90)
			local Up, Right, Forward, FT = ang:Up(), ang:Right(), ang:Forward(), FrameTime()
			local Amb = render.GetLightColor(SelfPos)
			local Brightness = (Amb.x + Amb.y + Amb.z) / 3
			local Opacity = math.random(50, 255) * Brightness
			cam.Start3D2D(SelfPos + Up * 13.3 - Right * 6 - Forward * -6.8, ang, .1)
			draw.SimpleTextOutlined(GetTimeString(self:GetTimer()), "HS.25", 0, 0, Color(255, 200, 200, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(200, 0, 0, Opacity))
			cam.End3D2D()
		end
	end

	language.Add("ent_jack_gmod_eztimebomb", "EZ Time Bomb")
end