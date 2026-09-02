local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local hg_show_hitposmuzzle = CreateClientConVar("hg_show_hitposmuzzle","0",false,false,"",0,1)

hook.Add("HUDPaint","admin_hitpos",function()
	if hg_show_hitposmuzzle:GetBool() and LocalPlayer():IsAdmin() then
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or not wep.GetShootMatrix then return end

		local pos,ang = wep:GetShootMatrix()

		local tr = util.QuickTrace(pos,ang:Forward() * 1000,LocalPlayer())
		local hit = tr.HitPos:ToScreen()
		
		surface.SetDrawColor(255,255,255,150)
		surface.DrawRect(hit.x - 2,hit.y - 2,4,4)

		pos = pos:ToScreen()

		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawRect(pos.x - 2,pos.y - 2,4,4)

		surface.SetDrawColor( 255, 255, 0, 255 )
		surface.DrawRect(scrw/2-2,scrh/2-2,4,4)
	end
end)

SWEP.AmmoChek = 0

local color_gray = Color(225,215,125)
local color_gray1 = Color(225,215,125)

local x,y = 0,0

local whitelist = {
	["unload_magazine"] = true,
	["load_magazine"] = true,
	["load_magazine_chamber"] = true,

	["insert_start"] = true,
	["insert"] = true,
	["unload"] = true,

	["deploy"] = true
}

function SWEP:DrawHUD()
	local sequenceInfo = self:GetSequenceData()

	if sequenceInfo and (sequenceInfo.reload or (whitelist[sequenceInfo.name] and not sequenceInfo.dontShowReloadHUD)) then self.AmmoChek = 0.4 end

	self.AmmoChek = math.max(self.AmmoChek - FrameTime(),0)

	local k = math.min(self.AmmoChek * 6,1)

	if show == 0 then return end

	color_gray.a = 190 * k
	color_gray1.a = 255 * k

	local ply = LocalPlayer()
	local ammo,ammobag = self:GetMaxClip1(), self:Clip1()
	
	if ammobag > ammo - 1 then
		text = L("weapon_ammo_full")
	elseif ammobag > ammo - ammo/3 then
		text = L("weapon_ammo_pre_full")
	elseif ammobag > ammo/3 then
		text = L("weapon_ammo_half")
	elseif ammobag >= 1 then
		text = L("weapon_ammo_pre_empty")
	elseif ammobag < 1 then
		text = L("weapon_ammo_empty")
	end

	local ammomags = ply:GetAmmoCount( self:GetPrimaryAmmoType() )

	if oldclip != ammobag then
		randomx = math.random(0, 5)
		randomy = math.random(0, 5)

		timer.Simple(0.15, function()
			oldclip = ammobag
		end)
	else
		randomx = 0
		randomy = 0
	end

	if oldmag != ammomags then
		randomxmag = math.random(0, 5)
		randomymag = math.random(0, 5)
		timer.Simple(0.35, function()
			oldmag = ammomags
		end)
	else
		randomxmag = 0
		randomymag = 0
	end

	local muzzlePos,muzzleAng = self:GetShootMatrix()
	local textpos = (muzzlePos + Vector(0,2,0):Rotate(muzzleAng)):ToScreen()

	if textpos.visible then
		local dis = Vector(x,y,0):Distance(Vector(textpos.x,textpos.y,0)) / 160

		local interp = math.min(0.1 + dis,1)
		
		x = LerpFT(interp,x,textpos.x)
		y = LerpFT(interp,y,textpos.y)
	end

	self:DrawHUDClip(x,y,randomx,randomy,text,ammobag)
end

function SWEP:DrawHUDClip(x,y,randomx,randomy,text,ammobag)
	if self.IsRevolver then
		draw.DrawText(L("weapon_ammo_baraban") .. " | "..ammobag, "H.25", x+randomx, y+randomy, color_gray1, TEXT_ALIGN_RIGHT )
	elseif self.IsShotgun then
		draw.DrawText(L("weapon_ammo_magazine") .. " | "..text, "H.25", x+randomx, y+randomy, color_gray1, TEXT_ALIGN_RIGHT )
	else
		draw.DrawText(L("weapon_ammo_magazine") .. " | "..text, "H.25", x+randomx, y+randomy, color_gray1, TEXT_ALIGN_RIGHT )
	end
end