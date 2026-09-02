classFastManager = classFastManager or {}

function classFastManager.RegCategory(category,name,data)
    local existsData = category[name]

    if not existsData then
        data = data or {}
        data.listIndex = {}
        data.name = name

        category[name] = data
    elseif data then
        util.tableLink(existsData,data)--ебаный dev 
    end
end

local empty = {}

function classFastManager.Reg(config,config_toggle,category,name,data)
    data.name = name
	config[name] = data

    local categoryName = data.category or "other"
    if not category[categoryName] then
        -- Lazily register a missing category so content files can load in any
        -- order without erroring (e.g. flashlight/laser before their *_sh.lua
        -- category file is included). RegCategory seeds listIndex for us.
        classFastManager.RegCategory(category,categoryName)
    end

	category[categoryName].listIndex[name] = data

    if config_toggle then
        for nameToggle,toggle in pairs(data.toggle or empty) do
            local newToggle = {}

            util.tableLink(newToggle,data)
            util.tableLink(newToggle,toggle)
            newToggle.toggle = nil

            config_toggle[name] = config_toggle[name] or {}
            config_toggle[name][nameToggle] = newToggle
        end
    end
    
    return data
end