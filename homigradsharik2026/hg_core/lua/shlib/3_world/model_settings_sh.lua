modelSetting = ManagerCreate("modelSetting","node")
modelSetting.listIndex = modelSetting.listIndex or {}
modelSetting.Fast = modelSetting.Fast or {}

local Fast = modelSetting.Fast

function modelSetting.Reg(model,data)
    modelSetting.listIndex[model] = data or {}
    
    if Initialize then
        timer.Create("modelSetting.Update",0,1,function()
            modelSetting:Event_Call("Update")
        end)
    end
    
    for key,value in pairs(data) do
        Fast[key] = Fast[key] or {}
        Fast[key][model] = value
    end

    return data
end

if CLIENT then
    modelSetting:Event_Add("Update","CSM Chache Clear",function()
        RunConsoleCommand("hg_csm_chache_clear")
    end)
end