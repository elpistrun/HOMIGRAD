LoadScreenRequestList = LoadScreenRequestList or {}

local max = 0

event.Add("Token Read","LoadScreen",function(req)
    if InitNET then return end

    LoadScreenRequestList[#LoadScreenRequestList + 1] = req
    max = math.max(max,#LoadScreenRequestList)
end)

event.Add("Setup World","LoadScreen",function(req)
    for k in pairs(LoadScreenRequestList) do LoadScreenRequestList[k] = nil end--ok?
end)

net.LoadScreenTastAdd("Token",function()
    for i,req in pairs(LoadScreenRequestList) do
        if IsValid(req) then return false,"wait token",req:GetName(),#LoadScreenRequestList,max end
    end
end,-1)