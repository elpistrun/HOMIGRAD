HG_ERRLOG = HG_ERRLOG or { list = {}, sync = {} }

local string_find = string.find
local string_match = string.match

local function IsHGPath(path)
    return string_find(path,"addons/hg",1,true) or string_find(path,"addons/!",1,true) or string_find(path,"/hg_",1,true)
end

local function GetErrorFile(trace)
    local file = string_match(trace,"addons/!+/lua/[%w_/%.]+") or string_match(trace,"addons/hg+[%w_/%.]*/lua/[%w_/%.]+")
    if file then return file end

    file = string_match(trace,"[%w_/%.]-hinit/[%w_/%.]+") or string_match(trace,"[%w_/%.]-shlib/[%w_/%.]+") or string_match(trace,"[%w_/%.]-hgame/[%w_/%.]+")
    return file or "unknown"
end

hook.Add("LuaError","HG_ERRLOG",function(error_add,traceback,main,meta)
    if not IsHGPath(traceback) then return end

    if HG_ERRLOG and HG_ERRLOG.Add then
        HG_ERRLOG:Add("code",GetErrorFile(traceback),error_add)
    end
end)

if SERVER then
    util.AddNetworkString("hg_errlog_request")
    util.AddNetworkString("hg_errlog_clear")

    net.Receive("hg_errlog_request",function(len,ply)
        if not IsValid(ply) then return end

        net.Start("hg_errlog_sync")
        net.WriteTable(HG_ERRLOG.list)
        net.Send(ply)
    end)

    net.Receive("hg_errlog_clear",function(len,ply)
        if not IsValid(ply) then return end

        HG_ERRLOG.list = {}
    end)

    concommand.Add("hg_errlog",function()
        print("[HG_ERRLOG] server entries: " .. #HG_ERRLOG.list)
        for i,entry in ipairs(HG_ERRLOG.list) do
            print(string.format("[%s] %s | %s | %s",entry.cat,os.date("%H:%M:%S",entry.time),entry.path,entry.text))
        end
    end)

    concommand.Add("hg_errlog_classes",function()
        local registered = 0
        local skipped = {}

        print("[HG_ERRLOG] oop classes: " .. table.Count(oop.listClass or {}))

        for name,class in pairs(oop.listClass or {}) do
            local content = class[1]
            local isWeapon = istable(content.Primary) or istable(content.Secondary)
            local isEntity = content.Base == "base_entity" or content.Base == "base_anim" or content.Base == "base_nextbot"

            local inGMod = weapons.GetStored(name) or scripted_ents.GetStored(name)

            if class[2].NonRegisterGMOD then
                print(string.format("  [BASE] %s (skip)",name))
            elseif inGMod then
                registered = registered + 1
                print(string.format("  [REG ] %s",name))
            else
                skipped[#skipped + 1] = name
                print(string.format("  [MISS] %s",name))
            end
        end

        print("[HG_ERRLOG] registered: " .. registered .. ", missing: " .. #skipped)
    end)
end

if CLIENT then
    util.AddNetworkString("hg_errlog_request")
    util.AddNetworkString("hg_errlog_clear")

    net.Receive("hg_errlog_sync",function()
        HG_ERRLOG.sync = net.ReadTable() or {}
        if HG_ERRLOG.OnSync then HG_ERRLOG.OnSync() end
    end)

    function HG_ERRLOG:RequestSync()
        net.Start("hg_errlog_request")
        net.SendToServer()
    end

    function HG_ERRLOG:ClearAll()
        self.list = {}
        self.sync = {}

        net.Start("hg_errlog_clear")
        net.SendToServer()
    end
end
