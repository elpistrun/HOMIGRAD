GetMap = game.GetMap

function pointManager:GetPage() return GetGlobalString("PointPage","main") end

pointManager.listClass = pointManager.listClass or {}
pointManager.listCategory = pointManager.listCategory or {}
pointManager.listCategoryIndex = pointManager.listCategoryIndex or {}

function pointManager:Registry(name,color,category)
	pointManager.listClass[name] = {
		name = name,
        color = color,
		category = category
	}

    pointManager.listCategory[category] = pointManager.listCategory[category] or {}
    pointManager.listCategory[category][name] = true

    pointManager.listCategoryIndex[name] = category
end

pointManager:Registry("bhop",Color(255,125,125),"general")
pointManager:Registry("red",Color(255,0,0),"general")
pointManager:Registry("blue",Color(0,0,255),"general")

pointManager:Registry("police",Color(175,175,255),"general")
pointManager:Registry("exit",Color(0,255,0),"general")

pointManager:Registry("red_car",Color(255,0,25),"general")
pointManager:Registry("blue_car",Color(025,0,255),"general")

pointManager:Registry("red_tank",Color(255,0,25),"general")
pointManager:Registry("blue_tank",Color(025,0,255),"general")

pointManager:Registry("red_helicopter",Color(255,0,25),"general")
pointManager:Registry("blue_helicopter",Color(025,0,255),"general")

pointManager:Registry("red_car_fast",Color(255,0,25),"general")
pointManager:Registry("blue_car_fast",Color(025,0,255),"general")

//

pointManager:Registry("cantbreak",Color(255,175,0),"anchor")
pointManager:Registry("center",Color(255,255,255),"anchor")
pointManager:Registry("script_zone",Color(175,0,255),"anchor")
pointManager:Registry("redzone",Color(255,0,0),"anchor")

function pointManager:GetList(name)
    local data = pointManager.listData[pointManager:GetPage()]
    if not data or not data[name] then return end

    if #data[name] > 0 then
        local list = {}

        for id,point in pairs(data[name]) do
            list[id] = point
        end

        return list
    end
end