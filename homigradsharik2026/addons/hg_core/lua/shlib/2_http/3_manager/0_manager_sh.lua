ManagerListClass = ManagerListClass or {}
ManagerListClass["lib_event_noself"] = util.tableCopy(oop.listClass["lib_event_noself"])
ManagerListClass["lib_event"] = util.tableCopy(oop.listClass["lib_event"])

ManagerList = ManagerList or {}

local DefaultIsValid = function() return true end

function ManagerRegistry(name,base,isFolder)
    base = base or "lib_event_noself"

    local content,nonInheritContent = oop.Reg(name,base,isFolder,1,ManagerListClass)
    if not content then return end

    content.IsValid = DefaultIsValid
    
    content:Event_Add("Construct","Update Objects",function(self)
        local content = self[1]

        for name,manager in pairs(ManagerList) do
            if not table.HasValue(manager.baseInherit,content.ClassName) then continue end
            util.tableLink(manager,content)
        end
    end)

    return content,nonInheritContent
end

function ManagerGet(name)
    local content,nonInheritContent = oop.Get(name,ManagerListClass,1)
    if not content then return end

    return content,nonInheritContent
end

function ManagerCreate(name,base,...)
    if ManagerList[name] then return ManagerList[name] end
    
    local manager = {}

    base = base or {"node"}
    if TypeID(base) == TYPE_STRING then base = {base} end

    ManagerList[name] = manager
    _G[name] = manager

    for i,base in pairs(base) do
        util.tableLink(manager,ManagerListClass[base][1])
    end

    manager.name = name
    manager.baseInherit = base

    manager:Event_Construct()

    if manager.Initialize then manager:Initialize(...) end

    return manager
end