local Level = oop.Reg("level_tdm","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.ShouldSpawnLoot = true
Level.PropBreakLoot = true
Level:SetEndType("team")

Level.red = {
	"terrorist",Color(255,75,75),
	weapons = {"weapon_transmitter","weapon_hands","med_band","med_band","med_kit","med_painkiller","wep_melee_6x5"},
	classes = {
		{
			"class_solder",
			main_weapon = {"wep_ak74","wep_ar15","wep_vss","wep_asval","wep_dvl10","wep_vpo215"},
			armors = {
				"helmet_ops_fast_black",
				"headset_m32",

				"vest_slick_b",
				"updump_thunderbolt"
			}
		},
		{
			"class_scout",
			main_weapon = {"wep_mp5","wep_mp9","wep_p90","wep_vector45","wep_vector9"},
			armors = {
				"helmet_ops_fast_black",
				"headset_m32",
				
				"dump_plate_carrier",
				"backpack_forward"
			}
		},
		{
			"class_support",
			main_weapon = {"wep_m870","wep_m60","wep_mr43","wep_mr43_sawed","wep_saiga12k","wep_saiga12fa"},
			armors = {
				"headset_m32",
				"helmet_ops_fast_black",

				"vest_slick_b",
				"updump_thunderbolt"
			}
		}
	},
	selectLink = 1,
	secondary_weapon = {"wep_m9a3"},
	models = Level.StandardPlayerModels
}

Level.blue = {
	"contr_terrorist",Color(75,75,255),
	weapons = Level.red.weapons,
	classes = Level.red.classes,
	selectLink = 1,
	secondary_weapon = Level.red.secondary_weapon,
	armors = Level.red.armors,
	models = Level.red.models
}

Level.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

if SERVER then return end

function Level:HUDPaint(white)
    local lply = LocalPlayer()
	local name,color = self:GetTeamName(lply)

    self:DrawLoadScreen()
	self:DrawRoundTime()
	self:DrawCenter()
end

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)

    local w,h = ScrW(),ScrH()

	draw.DrawText(L("you",L(lply:GetNWString("ClassName"))),"H.25",w / 2,h / 2 - h / 6,cname,TEXT_ALIGN_CENTER)
 
    draw.DrawText(L("you_team",L(name)),"H.25",w / 2,h / 2,cname,TEXT_ALIGN_CENTER)
    draw.DrawText(L("level_tdm"),"H.45",w / 2,h / 8,cblue,TEXT_ALIGN_CENTER)

    draw.DrawText(L("tdm_loadscreen"), "H.25",w / 2,h / 1.2,cgray,TEXT_ALIGN_CENTER)
end