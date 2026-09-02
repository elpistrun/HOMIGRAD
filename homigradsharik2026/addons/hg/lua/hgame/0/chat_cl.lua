net.Receive("msg ply connect",function()
	local userid,name = net.ReadString(),net.ReadString()
	if StreamMode then name = userid end
	
	chat.AddText(Color(255,255,125),L("chat_player_connect",name,net.ReadString()))
end)

net.Receive("msg ply init",function()
	//chat.AddText(Color(255,210,125),L("chat_player_spawninit",net.ReadString(),net.ReadString()))
end)

net.Receive("msg ply join",function()
	local userid,name = net.ReadString(),net.ReadString()
	if StreamMode then name = userid end

	chat.AddText(Color(125,255,125),L("chat_player_spawnjoin",name,net.ReadString()))
end)

net.Receive("msg ply disconnect",function()
	local userid,name = net.ReadString(),net.ReadString()
	if StreamMode then name = userid end

	local steamid,reason = net.ReadString(),net.ReadString()

	if reason and reason ~= "" then
		chat.AddText(Color(255,125,125),L("chat_player_disconnect_reason",name,steamid,reason))
	else
		chat.AddText(Color(255,125,125),L("chat_player_disconnect",name,steamid))
	end
end)

hook.Add("CanEmbedCustomChat","Homigrad",function(ply)
	if ply:HasSuccess("CanEmbedCustomChat") then return true end

	return L("buy_sponsor"),Color(255,0,255)
end)

local color = {
	microsponsor = Color(140,0,0),
	sponsor = Color(173,20,87),
	megasponsor = Color(231,76,60),
	["megasponsоr"] = Color(231,76,60),

	doperator = Color(58,152,219),
	dadmin = Color(31,139,76),

	operator = Color(155,89,152),
	admin = Color(242,52,59),

	stadmin = Color(255,255,0),

	dsuperadmin = Color(26,184,93),
	superadmin = Color(46,204,113),
	owner = Color(46,204,113)
}

local matStar = Material("icon16/star.png")
local matBomb = Material("icon16/bomb.png")

local icons = {
	operator = matStar,
	admin = matStar,
	superadmin = matStar,
	dsuperadmin = matStar,
	stadmin = matStar,

	dadmin = matBomb,
	doperator = matBomb
}

hook.Add("CustomChat_NameColor","Homigrad",function(ply) return ply:GetUserColor() end)

local hide = {
	["joinleave"] = true
}

hook.Add("ChatText","!!Hide",function(_,_,_,_,type)
	if hide[type] then return false end
end)