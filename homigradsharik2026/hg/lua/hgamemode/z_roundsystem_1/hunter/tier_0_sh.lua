local Level = oop.Reg("level_hunter","level_base",true)
if not Level then return INCLUDE_BREAK end

pointManager:Registry("cant_hunter",Color(165,165,165),"anchor")

Level:SetEndType("team")
Level.ShouldSpawnLoot = true
 
local bodygroups = {}
bodygroups[0] = 7
bodygroups[1] = 3
bodygroups[2] = 1

local models = {}

for i = 1,6 do
    models[#models + 1] = {"models/monolithservers/mpd/female_01.mdl"}
end

for i = 1,9 do
    models[#models + 1] = {"models/monolithservers/mpd/male_01.mdl"}
end

Level.red = {"cyberathlete",Color(55,55,55),
    weapons = {"weapon_transmitter","wep_melee_6x5","med_band_big","med_band_small","med_kit","med_kit","wep_gnade_rgd5"},
    main_weapon = {"wep_m870"},
    secondary_weapon = {"wep_m9a3"},
    armors = {
        "mask_balistic",
        "helmet_ops_fast_black",
        "headset_m32",
        "vest_thor_crv",
        "updump_thunderbolt"
    },
	models = Level.StandardPlayerModels,
}

Level.green = {"schoolboy",Color(55,255,55),
    models = Level.StandardPlayerModels
}

Level.teamEncoder = {
    [1] = "red",
    [2] = "green"
}

if SERVER then return end

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)

	local w,h = ScrW(),ScrH()

    draw.DrawText(L("you",L(name)),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER)
    draw.DrawText(L("level_hunter"),"H.45",w / 2,h / 8,cred,TEXT_ALIGN_CENTER)

    if lply:Team() == 1 then
        draw.DrawText(L("schoolshoot_loadscreen_roleT"),"H.25",w / 2,h / 1.2,cred,TEXT_ALIGN_CENTER)
    else
        draw.DrawText(L("schoolshoot_loadscreen_roleCT"),"H.25",w / 2,h / 1.2,cgreen,TEXT_ALIGN_CENTER)
    end
end

local green = Color(55,155,55)
local white = Color(255,255,255)

function Level:HUDPaint(k)
	local lply = LocalPlayer()

    self:DrawLoadScreen()
    self:DrawRoundTime()
    self:DrawCenter()

    local w,h = ScrW(),ScrH()

	green.a = 255 * k

	if lply:Team() == 3 or lply:Team() == 2 or not lply:Alive() and police then
		for i,point in pairs(pointManager.listData[pointManager:GetPage()].exit) do
			local pos = point.pos:ToScreen()

			draw.SimpleText("EXIT","ChatFont",pos.x,pos.y,green,TEXT_ALIGN_CENTER)
		end
	end

    if lply:Team() != 1 then return end

    Levels.level_homicide.DrawScan(self)
end

function Level:PlayerClientSpawn()
	if LocalPlayer():Team() ~= 3 then return end

	showRoundInfo = RealTime() + 10
end

Level.DelayScanTime = 120
Level.ScoreboradInventoruUICreate = function(self,frame)
    Levels.level_homicide.ScoreboradInventoruUICreate(self,frame,true)
end

Level.PreDrawSphereRing = Levels.level_homicide.PreDrawSphereRing