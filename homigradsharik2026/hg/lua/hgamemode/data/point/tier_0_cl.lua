pointManager = ManagerCreate("pointManager",{"node","node_network"},DataBaseGeneral)

function pointManager:InputServer()
    local cmd = net.ReadString()

    if cmd == "update" then
        local data = net.ReadTable()

        pointManager.listData= data

        pointManager:Event_Call("Update",page,data)
    end
end

local hg_drawspawn = CreateClientConVar("hg_drawspawn","0",false,false)

local white = Color(255,255,255,15)

hook.Add("HUDPaint","DrawSpawns",function()
	if not hg_drawspawn:GetBool() or not LocalPlayer():HasSuccess("command_point") then return end

	local lply_pos = EyePos()

	for name,list in pairs(pointManager.listData[pointManager:GetPage()] or {}) do
		local centerPos = Vector()

		local color = pointManager.listClass[name].color

		for i,point in pairs(list) do
			local pos = point.pos
			
			centerPos:Add(pos)

			local dis = pos:Distance(lply_pos)
			if dis > 1000 then continue end

			pos = pos:ToScreen()
			if not pos.visible then continue end

			draw.SimpleText(name,"DefaultFixedDropShadow",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			if dis > 250 then continue end

			draw.SimpleText("id:" .. i,"DefaultFixedDropShadow",pos.x,pos.y + 15,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			if point.dis then draw.SimpleText("3: " .. tostring(point.dis),"DefaultFixedDropShadow",pos.x,pos.y + 30,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
			if point.add then draw.SimpleText("add: " .. tostring(point.add),"DefaultFixedDropShadow",pos.x,pos.y + 55,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
		end

		if #list > 1 then
			centerPos:Div(#list)

			if centerPos:Distance(lply_pos) > 1000 then continue end

			centerPos = centerPos:ToScreen()

			draw.SimpleText(#list,"H.25",centerPos.x,centerPos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local x,y = ScrW() - 5,ScrH() - 50 - 15

	for name,list in pairs(pointManager.listCategory) do
		local color = Color(255,255,255)

		//draw.SimpleText(name,"HS.18",x,y,color,TEXT_ALIGN_RIGHT)

		//y = y - 20

        for name in pairs(list) do
			local listPoint = (pointManager.listData[pointManager:GetPage()] and pointManager.listData[pointManager:GetPage()][name] or {})
			if #listPoint == 0 then continue end

			local color = pointManager.listClass[name].color

            draw.SimpleText(name,"HS.18",x,y,color,TEXT_ALIGN_RIGHT)
            draw.SimpleText(#listPoint,"HS.18",x - 250,y,color,TEXT_ALIGN_RIGHT)
			
			y = y - 20
		end
	end

	local page = pointManager:GetPage()

	if page then draw.SimpleText("'" .. page .. "' page","HS.18",x,ScrH() - 30,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER) end
end)

local red,blue = Color(255,0,0),Color(0,0,255)
local ebalgmod = Color(0,0,0)

hook.Add("PostDrawTranslucentRenderables","DrawSpawns",function()
	if not hg_drawspawn:GetBool() or not LocalPlayer():HasSuccess("command_point") then return end

	render.SetColorMaterial()

	for name,list in pairs(pointManager.listData[pointManager:GetPage()] or {}) do
		local color = pointManager.listClass[name].color
		ebalgmod.r = color.r
		ebalgmod.g = color.g
		ebalgmod.b = color.b
		ebalgmod.a = 255

		for i,point in pairs(list) do
			render.DrawWireframeSphere(point.pos,point.dis or 6,16,16,ebalgmod)
		end
	end
end)