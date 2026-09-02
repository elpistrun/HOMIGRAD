net.Receive("loadscreen",function()
	roundScreenName = net.ReadString()
	roundScreenName2 = net.ReadString()

	roundStart = true
end)

net.Receive("loadscreen_end",function()
	roundStart = false
end)

local white = Color(255,255,255)

hook.Add("PostDrawHUD","Start Round",function()
	if not roundStart then return end

	local w,h = ScrW(),ScrH()
	surface.SetDrawColor(0,0,0,225)
	surface.DrawRect(0,0,w,h)

	draw.SimpleText(L(roundScreenName,L(roundScreenName2)),"H.45",w / 2,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end)