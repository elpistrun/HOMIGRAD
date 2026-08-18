hook.Add("HUDShouldDraw","HideHUD_ammo",function(name)
	if name == "CHudAmmo" then return false end
end)

hook.Add("DrawDeathNotice","no",function() return false end)
hook.Add("HUDDrawTargetID","no",function() return false end)

RunConsoleCommand("cl_showhints","0")

local tr = {
	mask = MASK_SOLID
}

local delay = 0

local trace

hook.Add("HUDPaint","Show If Spectate",function()
	local time = RealTime()

	if delay < time then
		delay = time + 1 / 24

		local wep = LocalPlayer():GetActiveWeapon()

		if IsValid(wep) and wep.GetShootMatrix then
			local pos,ang = wep:GetShootMatrix()

			if pos then
				tr.start = pos
				tr.endpos = pos + Vector(32000,0,0):Rotate(ang)
				tr.filter = LocalPlayer():GetDummy()

				trace = util.TraceLine(tr)
			end
		else
			trace = LocalPlayer():EyeTrace(32000)
		end
	end

	if not trace then return end

	local ent = trace.Entity

	if IsValid(ent) and ent:IsPlayer() and ent:Team() == 1002 then
		local pos = ent:GetPos():Add(ent:OBBCenter()):ToScreen()
		
		draw.SimpleText("SPECTATOR","HS.12",pos.x,pos.y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end)

local yellow = Color(75,255,75)

hook.Add("DrawOverlay","HOMIGRAD DONAT INVENTORY TEST",function()
	if not InitPostEntity then return end

	--draw.SimpleText("ТЕХНИЧЕСКИЕ РАБОТЫ ПРЯМО СЕЙЧАС, ЧТО-ТО МОЖЕТ НЕ РАБОТАТЬ","HS.12",ScrW() / 2,0,Color(255,255,255,100),TEXT_ALIGN_CENTER)
	--draw.SimpleText("ЕСЛИ КТО-ТО БУДЕТ ИСПОЛЬЗОВАТЬ SPAWNMENU, ИЛИ КАК-ТО МЕШАТЬ, ОН БУДЕТ ЗАБАНЕН","HS.12",ScrW() / 2,12,Color(255,255,255,100),TEXT_ALIGN_CENTER)

    local start = GetGlobalVar("Addon Version Start",0)
    local new =  GetGlobalVar("Addon Version",start)

    if start == new then
        draw.SimpleText("KOPIGRAD.COM " ..  GetGlobalVar("Addon Version",0) .. " COMMIT","H.12",scrw,scrh,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
    else
        draw.SimpleText("KOPIGRAD.COM AVIABLE NEW " ..  GetGlobalVar("Addon Version",0) .. " COMMIT, CURRET " .. start,"H.12",scrw,scrh,yellow,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
    end
end)