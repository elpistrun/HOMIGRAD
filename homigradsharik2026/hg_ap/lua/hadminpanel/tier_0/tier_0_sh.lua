adminPanel = ManagerCreate("adminPanel")

adminPanel.success = adminPanel.success or {}
adminPanel.successCategory = adminPanel.successCategory or {}

local successIndex,successCategory = adminPanel.success,adminPanel.successCategory

function adminPanel.successRegistry(name,desc,category)
    category = category or "other"
    desc = desc or "no desc"
    
    local old = successIndex[name]
    
    if old and successCategory[old.category] then
        successCategory[old.category][name] = nil
    end

    successIndex[name] = successIndex[name] or {}
    
    local success = successIndex[name]
    success.desc = desc or success.desc
    success.category = category or success.category

    successCategory[category] = successCategory[category] or {}--FOR UI
    successCategory[category][name] = success

    return success
end