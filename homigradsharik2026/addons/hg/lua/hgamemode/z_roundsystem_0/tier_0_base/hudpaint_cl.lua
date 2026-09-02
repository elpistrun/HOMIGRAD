local Level = oop.Get("level_base")
if not Level then return end

function Level:DrawRoundTime(time)
	if not roundTimeStart or not roundTime then return end

    time = time or math.Round(roundTimeStart + roundTime - CurTime())

    if time > 0 then
        local hour,minutes,second = math.floor(time / 60 / 60),math.floor(time / 60) % 60,math.floor(time) % 60

		if second ~= 0 and second < 9 then second = "0" .. second end

		if hour > 0 then
			if hour < 9 then hour = "0" .. hour end
			if minutes < 9 then minutes = "0" .. minutes end

        	draw.SimpleText(hour .. ":" .. minutes .. ":" .. second,"H.18",ScrW() / 2,ScrH() - 25,showRoundInfoColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		elseif minutes > 0 then
			if minutes < 9 then minutes = "0" .. minutes end

        	draw.SimpleText(minutes .. ":" .. second,"H.18",ScrW() / 2,ScrH() - 25,showRoundInfoColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else
        	draw.SimpleText(second,"H.18",ScrW() / 2,ScrH() - 25,showRoundInfoColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
    end
end

local colorRed = Color(255,0,0)

function Level:GetTeamName(ply)
	local team = self.teamEncoder[ply:Team()]

	if team then
		team = self[team]

		return team[1],team[2]
	end
end

function Level:AccurceTime(time)
	return string.FormattedTime(time,"%02i:%02i")
end

//

local red,blue = Color(200,0,10),Color(75,75,255)

cblue = Color(75,75,255)
cred = Color(255,75,75)
cgray = Color(255,255,255)
cgreen = Color(75,255,75)
cname = Color(0,0,0)

Level.LoadScreenTime = 5

function Level:DrawLoadScreen()
    local lply = LocalPlayer()
    if not lply:Alive() or lply:Team() == 1002 then return end

    local startRound = roundTimeStart + self.LoadScreenTime - CurTime()
    if startRound <= 0 then return end
    
    local k = math.Clamp(startRound - 0.5,0,1)

    local name,color = self:GetTeamName(lply)

	if not color then return true end//lol
	
    cname.r = color.r
    cname.g = color.g
    cname.b = color.b
    cname.a = k * 255

	cred.a = k * 255
	cgray.a = k * 255
    cgreen.a = k * 255

    surface.SetDrawColor(0,0,0,k * 245)
    surface.DrawRect(0,0,ScrW(),ScrH())

    self:DrawScreen(lply,k)

    return true
end