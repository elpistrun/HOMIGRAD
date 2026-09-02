/*
	PermaProps
	Created by Entoros, June 2010
	Facepunch: http://www.facepunch.com/member.php?u=180808
	Modified By Malboro 28 / 12 / 2012
	
	Ideas:
		Make permaprops cleanup-able
		
	Errors:
		Errors on die

	Remake:
		By Malboro the 28/12/2012
*/

TOOL.Category		=	"Props Tool"
TOOL.Name			=	"PermaProps"
TOOL.Command		=	nil
TOOL.ConfigName		=	""

if CLIENT then
	language.Add("Tool.permaprops.name", "PermaProps")
	language.Add("Tool.permaprops.desc", "Save a props permanently")
	language.Add("Tool.permaprops.0", "LeftClick: Add RightClick: Remove Reload: Update")

	surface.CreateFont("PermaPropsToolScreenFont", { font = "Arial", size = 40, weight = 1000, antialias = true, additive = false })
	surface.CreateFont("PermaPropsToolScreenSubFont", { font = "Arial", size = 30, weight = 1000, antialias = true, additive = false })
end

local function create(ply,ent,shared)
	if ent.removed then return end
	if not PermaProps then ply:ChatPrint( "ERROR: Lib not found" ) return end

	if !PermaProps.HasPermission( ply, "Save") then return end

	if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end
	if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
	if ent.PermaProps then ply:ChatPrint( "That entity is already permanent !" ) return end

	local newId = 0

	local list = shared and PermaPropsDataShared or PermaPropsData

	for i = 1,1024 do
		if not list[i] then newId = i break end
	end

	local save = duplicator.Copy(ent)

	local entities = {}

	for entid,ent in pairs(save.Entities) do
		local ent = Entity(entid)

		entities[entid] = ent

		ent.PermaProps = true
		ent.PermaProps_ID = newId

		ent.saveEntities = entities
	end

	list[newId] = {save.Entities,save.Constraints}
	PermaProps.WriteDB(shared)

	ply:ChatPrint("Write on " .. (shared and "shared" or "comminuty") .. " db")
end

local function remove(ply,ent)
	if not PermaProps then ply:ChatPrint( "ERROR: Lib not found" ) return end

	if !PermaProps.HasPermission( ply, "Delete") then return end

	if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end
	if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
	if not ent.PermaProps and not ent.PermaPropsShared then ply:ChatPrint( "That is not a PermaProp !" ) return end

	local id = ent.PermaProps_ID
	if not id then ply:ChatPrint( "ERROR: ID not found" ) return end
	
	for entid,ent in pairs(ent.saveEntities) do
		if IsValid(ent) then ent:Remove() end
	end

	if ent.PermaPropsShared then
		PermaPropsDataShared[id] = nil
	else
		PermaPropsData[id] = nil
	end

	ply:ChatPrint("Delete from " .. (ent.PermaPropsShared and "shared" or "comminuty") .. " db")

	PermaProps.WriteDB(ent.PermaPropsShared and true)
end

if SERVER then
	util.AddNetworkString("permaprop create")
	util.AddNetworkString("permaprop remove")

	net.Receive("permaprop create",function(len,ply) create(ply,net.ReadEntity(),net.ReadBool()) end)
	net.Receive("permaprop remove",function(len,ply) remove(ply,net.ReadEntity()) end)
else

end

local delay = 0

function TOOL:LeftClick(trace)
	if CLIENT then
		if delay > CurTime() then return end

		local ent = trace.Entity
		if not IsValid(ent) then return true end

		net.Start("permaprop create")
		net.WriteEntity(ent)
		net.WriteBool(false)
		net.SendToServer()

		delay = CurTime() + 0.1
	end

	return true
end

function TOOL:RightClick(trace)
	if CLIENT then
		if delay > CurTime() then return end

		local ent = trace.Entity
		if not IsValid(ent) then return true end

		net.Start("permaprop create")
		net.WriteEntity(ent)
		net.WriteBool(true)
		net.SendToServer()

		delay = CurTime() + 0.1
	end

	return true
end

function TOOL:Reload(trace)
	if CLIENT then
		if delay > CurTime() then return end

		local ent = trace.Entity
		if not IsValid(ent) then return true end

		net.Start("permaprop remove")
		net.WriteEntity(ent)
		net.SendToServer()

		delay = CurTime() + 0.1
	end

	return true
end

function TOOL.BuildCPanel(panel)

	panel:AddControl("Header",{Text = "PermaProps", Description = "PermaProps\n\nSaves entities across map changes\n"})
	panel:AddControl("Button",{Label = "Open Configuration Menu", Command = "pp_cfg_open"})

end

function TOOL:DrawToolScreen(width, height)

	if SERVER then return end

	surface.SetDrawColor(17, 148, 240, 255)
	surface.DrawRect(0, 0, 256, 256)

	surface.SetFont("PermaPropsToolScreenFont")
	local w, h = surface.GetTextSize(" ")
	surface.SetFont("PermaPropsToolScreenSubFont")
	local w2, h2 = surface.GetTextSize(" ")

	draw.SimpleText("PermaProps", "PermaPropsToolScreenFont", 128, 100, Color(224, 224, 224, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, Color(17, 148, 240, 255), 4)
	draw.SimpleText("By Malboro", "PermaPropsToolScreenSubFont", 128, 128 + (h + h2) / 2 - 4, Color(224, 224, 224, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, Color(17, 148, 240, 255), 4)

end
