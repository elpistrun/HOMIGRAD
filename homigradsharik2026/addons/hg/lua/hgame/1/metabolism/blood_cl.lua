adminPanel.commandRegistry("fullup",{"players^"},"game",nil,"admin_operator")

local math_Clamp = math.Clamp
local tab2 = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

local max = math.max

hook.Add("RenderScreenspaceEffects","Blood",function()
	local ply = LocalPlayer()
	if not ply:Alive() then return end

	if hook.Run("Should Draw Screenspace") == false then return end

	tab2["$pp_colour_colour"] = math.Clamp(ply:Health() / ply:GetMaxHealth(),0,1)

	DrawColorModify(tab2)

	local fraction = 1 - math_Clamp(ply:GetNW2Float("blood",5000) / 5000,0,1)
	fraction = math.max(fraction - 0.15,0) / 0.85
	
	RenderScreenspaceEffects_DrawBlur(fraction / 10)
end)

hook.Add("ScalePlayerDamage","no_effects",function(ent,dmginfo) return true end)

local cvar

cvars.CreateOption("hg_organisminfo","0",function(value)
	if not IsValid(LocalPlayer()) or not LocalPlayer():IsSuperAdmin() then return end

	cvar = (tonumber(value or 0) or 0) > 0
end)

local white = Color(255,255,255)

local function drawStates(ply,x,y,align)
	draw.SimpleText("health: " .. ply:Health(),"ChatFont",x,y,white,align)
	draw.SimpleText("pain: " .. ply:GetNW2Float("pain",0),"ChatFont",x,y + 25 * 1,white,align)
	draw.SimpleText("painlosing: " .. ply:GetNW2Float("painlosing",0),"ChatFont",x,y + 25 * 2,white,align)
	draw.SimpleText("adrenaline: " .. ply:GetNW2Float("adrenaline",0),"ChatFont",x,y + 25 * 3,white,align)
	draw.SimpleText("stamina: " .. ply:GetNW2Float("stamina",0),"ChatFont",x,y + 25 * 4,white,align)
	draw.SimpleText("bleed: " .. ply:GetNW2Float("bleed",0),"ChatFont",x,y + 25 * 5,white,align)
	draw.SimpleText("blood: " .. ply:GetNW2Float("blood",0),"ChatFont",x,y + 25 * 6,white,align)
	draw.SimpleText("impulse: " .. ply:GetNW2Float("impulse",0),"ChatFont",x,y + 25 * 7,white,align)
	draw.SimpleText("pulse: " .. 1 / ply:GetNW2Float("pulse",0),"ChatFont",x,y + 25 * 8,white,align)
	draw.SimpleText("otrub: " .. tostring(ply:GetNW2Bool("Otrub",false)),"ChatFont",x,y + 25 * 9,white,align)
	draw.SimpleText("hungry: " .. tostring(ply:GetNW2Float("hungry",0)),"ChatFont",x,y + 25 * 10,white,align)
	draw.SimpleText("o2: " .. tostring(ply:GetNW2Float("o2",0)),"ChatFont",x,y + 25 * 11,white,align)
	draw.SimpleText("brain: " .. tostring(ply:GetNW2Float("brain",0)),"ChatFont",x,y + 25 * 12,white,align)
	draw.SimpleText("poison: " .. tostring(ply:GetNW2Float("poison",0)),"ChatFont",x,y + 25 * 13,white,align)
	draw.SimpleText("healthreg: " .. tostring(ply:GetNW2Float("HealthReg",0)),"ChatFont",x,y + 25 * 14,white,align)
end

hook.Add("HUDPaint","Dev",function()
	if not cvar then return end
	
	local ply = LocalPlayer()

	drawStates(ply,45,45)

	local trace = ply:EyeTrace()
	ply = trace.Entity:GetDummy() or trace.Entity
	
	if not IsValid(ply) then return end

	ply = ply:GetNW2Entity("Controller",ply)
	if not ply:IsPlayer() then return end

	drawStates(ply,scrw - 45,45,TEXT_ALIGN_RIGHT)
end)