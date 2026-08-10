oop = oop or {}--sasi
--эт лиш регистрация классов
--уоопъ

oop.listClass = oop.listClass or {}
local OOP_listClass = oop.listClass

function oop.Inherit(class,listClass)
    listClass = listClass or OOP_listClass
    
    local oldBase = class.oldBase

    if oldBase then
        class.oldBase = nil

        for i,base in pairs(oldBase) do
            base = listClass[base]
            base.baseChildrens[class.ClassName] = nil--shut the fuck up!
        end
    end

    local content = class[1]
    local base = class.base
    if not base then return end

    local copyContent = util.tableCopy(content)

    for i,base in pairs(base) do
        base = listClass[base]
        base.baseChildrens[class.ClassName] = class

        util.tableLink(content,base[1])
    end

    if not content._OOP_ContentInherit_NoClear then
        util.tableLink(content,copyContent)
    end
end--veru simple.. maybe,я на таком чиле это делаю🤙

function oop.InheritChildren(base,listClass)
    local contentBase = base[1]

    for className,class in pairs(base.baseChildrens) do
        oop.Get(className,listClass)
    end
end

function oop.RegEx(className,base,listClass)
    if type(base) ~= "table" then base = {base} end--hihihah

    listClass = listClass or OOP_listClass

    local class = listClass[className]
    
    if not class then
        class = {
            {}, --content
            {}, --non inherit content
            {}, --files includd
            baseChildrens = {}
        }

        class.ClassName = className
        listClass[className] = class
    end

    class.oldBase = class.base
    class.base = base
    class.LastRealTimeRegistry = RealTime()

    local content = class[1]

    if not content._OOP_ContentInherit_NoClear then
        for k in pairs(content) do content[k] = nil end
        
        local nonInheritContent = class[2]
        for k in pairs(nonInheritContent) do nonInheritContent[k] = nil end
    end
    
    util.tableLink(content,class[2])

    content.ClassName = className
    content.LastRealTimeRegistry = class.LastRealTimeRegistry
    
    oop.Inherit(class,listClass)

    return class
end

--

function oop.InsertFile(class,isFolder,add)
    local pathInsert = GetPath(1 + (add or 0))
    local listFiles = class[3]

    if isFolder then pathInsert = string.GetPathFromFilename(pathInsert) end

    for i,path in pairs(listFiles) do
        if path == pathInsert then return end
    end

    listFiles[#listFiles + 1] = pathInsert
end

oop.override = {}
local override = oop.override

local overflow = {}

--timer.Create("OOP Overflow reset",30,0,function() for k in pairs(overflow) do overflow[k] = nil end end)

function oop.Construct(class)
    local func = class[1].Construct
    if func then func(class) end

    if Initialize then//DEV
        for name,class in pairs(class.baseChildrens) do
            oop.Construct(class)
        end
    end
end

function oop.Include(class,isFirst,listClass)
    local className = class.ClassName
   --overflow[className] = (overflow[className] or 0) + 1

    --[[if overflow[className] > 1024 then
        error("wtf is going on? with " .. className)
    end]]--

    for i,path in pairs(class[3]) do
        if string.sub(path,#path - 3,#path) == ".lua" then
            include(path)
        else
            IncludeDir(path)
        end

        if isFirst then override[className] = nil return end
    end

    oop.Construct(class)
    oop.InheritChildren(class,listClass)

    override[className] = nil
end

function oop.GetClassName(className)
    if not className then
        return string.gsub(string.GetFileFromFilename(GetPath(2)),".lua","")
    else
        return className
    end
end

--

function oop.Reg(className,base,isFolder,add,listClass)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass[2] end

    local class = oop.RegEx(className,base,listClass)
    oop.InsertFile(class,isFolder,add)
    override[className] = class
    timer.Create("unoverride_" .. tostring(className),0,1,function() override[className] = nil end)//если произошла ошибка в коде, нехочу через pcall делать (для dev)
    oop.Include(class,nil,listClass)
end

function oop.RegConnect(className,isFolder,listClass,add)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass[2] end

    listClass = listClass or OOP_listClass

    local class = listClass[className]
    if not class then error("invalid class " .. className) end

    override[className] = class
    oop.InsertFile(class,isFolder,add)
    oop.Include(class,true,listClass)
    override[className] = nil
end

function oop.Get(className,listClass)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass[2] end

    listClass = listClass or OOP_listClass

    local class = listClass[className]
    if not class then error("invalid class " .. className) end

    override[className] = class
    oop.Include(class,true,listClass)
    override[className] = nil
end

local DefaultIsValid = function() return true end--XXX333333

function oop.Create(className,listClass,...)
    local class = (listClass or OOP_listClass)[className]

    local obj = util.tableCopy(class[1])
    util.tableLink(obj,class[2])

    if obj.Create then obj:Create(...) end
    if obj.IsValid == nil then obj.IsValid = DefaultIsValid end

    return obj
end

function oop.CreateFromTable(class,...)
    local obj = util.tableCopy(class[1])
    util.tableLink(obj,class[2])

    if obj.Create then obj:Create(...) end

    return obj
end

//

function GetClassFromName(spawnname)
	local class = oop.listClass[spawnname]
	return class and class[1] or scripted_ents.Get(spawnname) or weapons.Get(spawnname)
end