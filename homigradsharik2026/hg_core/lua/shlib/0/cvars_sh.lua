function cvars.TransformationArgs(args)
	local newArgs = {}
	local waitClose,waitCloseText

	for i,text in pairs(args) do
		if not waitClose and (string.sub(text,1,1) == "'" or string.sub(text,1,1) == "\"") then
			waitClose = true

			if (string.sub(text,#text,#text) == "'" or string.sub(text,#text,#text) == "\'") then
				newArgs[#newArgs + 1] = string.sub(text,2,#text - 1)

				waitClose = nil
			else
				waitCloseText = string.sub(text,2,#text)
			end

			continue
		end

		if waitClose then
			if (string.sub(text,#text,#text) == "'" or string.sub(text,#text,#text) == "\'") then
				waitClose = nil

				newArgs[#newArgs + 1] = waitCloseText .. " " .. string.sub(text,1,#text - 1)
			else
				waitCloseText = waitCloseText .. " " .. string.sub(text,1,#text)
			end

			continue
		end

		newArgs[#newArgs + 1] = text
	end

	return newArgs
end

//

cvars.option = cvars.option or {}
local cvarsOptions = cvarsOptions or {}

local init = Initialize

function cvars.CreateOption(name,def,change,min,max,save)
	if save == nil then save = true end

    local function update(_,_,value)
		if not init then return end

        if change then change(value) end
    end

    cvarsOptions[name] = cvarsOptions[name] or {}
    cvarsOptions[name]["main"] = change

    cvars.AddChangeCallback(name,update,"option")

    local convar = CreateClientConVar(name,def,save,false,"",tonumber(min),tonumber(max))

    if Initialize then
		if change then change(convar:GetString(),"now") end
	end

    return convar
end

if CLIENT then
	function cvars.CreateDevOption(name,def,change,min,max)
		cvars.CreateOption(name,def,function(value)
			if not LocalPlayer():IsSuperAdmin() then return end
			
			change(value)
		end,min,max,false)
	end
end

function cvars.CreateServerOption(name,def,change,min,max)
    local function update(_,_,value)
		if not init then return end

		if CLIENT and cvars.serverOptions[name] ~= value then RunConsoleCommand(name,cvars.serverOptions[name] or def) return end

        if change then change(value) end
    end

    cvarsOptions[name] = cvarsOptions[name] or {}
    cvarsOptions[name]["main"] = change

    cvars.AddChangeCallback(name,update,"option")

	if SERVER then
		local convar = CreateConVar(name,def,FCVAR_ARCHIVE + FCVAR_NOTIFY,"",tonumber(min),tonumber(max))

		if Initialize then
			if change then change(convar:GetString(),"now") end
		end

		return convar
	end
end

function cvars.Hook(name,id,change)
    local function update(_,_,value)
		if not init then return end

		change(value)
	end

    cvarsOptions[name] = cvarsOptions[name] or {}
    cvarsOptions[name][id] = change

    cvars.AddChangeCallback(name,update,id)

    if Initialize then change(GetConVar(name):GetString()) end
end

hook.Add("InitPostEntity","CVars Option",function()//vgui в Initialize не загружены...
    print("setup cvars value")
	
	init = true
	
    for name,list in pairs(cvarsOptions) do
        local convar = GetConVar(name)
        if not convar then print("invalid convar " .. name) continue end
        
        local v = convar:GetString()
    
        for id,update in pairs(list) do
			if TypeID(update) != TYPE_FUNCTION then
				ErrorNoHalt("cvars type error " .. tostring(id) .. " " .. tostring(name) .. "\n")
			else
				update(v,"init")
			end
		end
    end

    print("done") 
end)

//

if CLIENT then
	cvars.serverOptions = cvars.serverOptions or {}

	gameevent.Listen("server_cvar")

	hook.Add("server_cvar","server_cvar_example",function(data)
		if not cvarsOptions[data.cvarname] then return end

		cvars.serverOptions[data.cvarname] = data.cvarvalue

		RunConsoleCommand(data.cvarname,data.cvarvalue)
	end)
end