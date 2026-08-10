local Level = oop.Reg("level_dm","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.ShouldSpawnLoot = true
Level.PropBreakLoot = true
Level:SetEndType("player")

Level.red = {
	"Operator",Color(125,125,125),
	weapons = {"weapon_transmitter","weapon_hands","med_band","med_band","med_kit","med_painkiller","wep_melee_6x5"},
    classes = {
        {
            "class_solder",
            main_weapon = {"wep_ak74","wep_ar15","wep_vss","wep_asval","wep_dvl10","wep_vpo215"},
        },
        {
            "class_scout",
            main_weapon = {"wep_mp5","wep_mp9","wep_p90","wep_vector45","wep_vector9"},
        },
        {
            "class_support",
            main_weapon = {"wep_m870","wep_m60","wep_mr43","wep_mr43_sawed","wep_saiga12k","wep_saiga12fa"},
        }
    },
	secondary_weapon = {"wep_m9a3","wep_rsh12"},
	models = Level.StandardPlayerModels,
    armors = {
        {"helmet_ops_fast_black"},
        {"headset_m32"},
        {"vest_thor_crv"},
        {"updump_thunderbolt"}
    }
}

Level.teamEncoder = {
	[1] = "red",
}

if SERVER then return end

function Level:DrawScreen(lply,k)
    local name,color = self:GetTeamName(lply)

    local w,h = ScrW(),ScrH()

    draw.DrawText(L("you",L(lply:GetNWString("ClassName"))),"H.45",w / 2,h / 2,cname,TEXT_ALIGN_CENTER)
 
    draw.DrawText("Death Match","H.45",w / 2,h / 8,cgray,TEXT_ALIGN_CENTER)
    draw.DrawText("Убей всех, останься в живых.","H.25",w / 2,h - h / 8,cgray,TEXT_ALIGN_CENTER)
end

local oldTime
local k = 0

function Level:DrawGodMod()
    local time = GetGlobalVar("God Time",0) - CurTime()
    if time <= 0 then return end

    time = math.floor(time)

    if oldTime ~= time then
        oldTime = time

        LocalPlayer():EmitSound("homigrad/vgui/menu_accept.wav",75,100,0.5)

        k = 1
    end

    surface.SetDrawColor(255,255,255,169 * k)

    local x,y = ScrW() / 2,ScrH() * 0.2
    surface.SetFont("HS.45")
    local tw,th = surface.GetTextSize(time)

    draw.GradientRight(x - tw,y - th / 2,tw,th)
    draw.GradientLeft(x,y - th / 2,tw,th)

    draw.SimpleText(time,"HS.45",x,y,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    k = LerpFT(0.25,k,0)
end

function Level:HUDPaint()
    local lply = LocalPlayer()

    self:DrawLoadScreen()
	self:DrawRoundTime()
    self:DrawCenter()
    self:DrawGodMod()
end