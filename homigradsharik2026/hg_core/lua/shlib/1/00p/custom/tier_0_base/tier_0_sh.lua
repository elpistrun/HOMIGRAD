local ENT = oop.Reg("custom_entity","lib_event",true)
if not ENT then return INCLUDE_BREAK end

-- Нужно для (Инвентаря, Loop источников звуков, Гилз и партиклов)\

function ENT:Initialize()
    self:Event_Call("Init")
end

function ENT:Spawn()
    self:Initialize()
end

function ENT:OnRemove()
    self:Event_Call("Remove")
end

-- List

customEnts = customEnts or {}

customEnts.list = customEnts.list or {}
customEnts.listIndex = customEnts.listIndex or {}

local customEntsList,customEntsListIndex = customEnts.list,customEnts.listIndex

customEntsList.all = customEntsList.all or {}
customEntsListIndex.all = customEntsListIndex.all or {}

function ENT:SetList(name,value)
    customEntsList[name] = customEntsList[name] or {}
    customEntsListIndex[name] = customEntsListIndex[name] or {}
    
    if value then
        if customEntsListIndex[name][self.id] then return end
        customEntsListIndex[name][self.id] = self

        customEntsList[name][#customEntsList[name] + 1] = self
        self.listHas[name] = #customEntsList[name]
    else
        if not customEntsListIndex[name][self.id] then return end
        customEntsListIndex[name][self.id] = nil

        local id = self.listHas[name]
        
        if id then
            table.remove(customEntsList[name],id)

            for i = id,#customEntsList[name] do
                local ent = customEntsList[name][i]
                
                if ent then ent.listHas[name] = i end
            end

            self.listHas[name] = nil
        end
    end
end

function ENT:IsValid() return self.id and customEntsListIndex["all"][self.id] and not self.removed end

local errHandler = function(err) ErrorNoHaltWithStack(err) end

function ENT:Remove()
    if self.removed then return end
    self.removed = true

    xpcall(function()
        if self.OnRemove then self:OnRemove() end

        for name in pairs(self.listHas) do
            self:SetList(name,false)
        end
    end,errHandler)

    self.fullRemoved = true

    for name in pairs(self.listHas) do self:SetList(name,false) end--на всякий
end

function ENT:CallOnRemove(id,func)
    self:Event_Add("Remove","CallOnRemove_" .. id,func)
end

function customEnts.Create(className,id,isServerCreated)
    local class = oop.listClass[className]
    if not class then error("customEnts.Create->" .. tostring(className) .. " is not exists.") end

    local ent = {__index = class[1]}
    setmetatable(ent,ent)
    ent.event = util.tableCopy(ent.event)--bruh

    if not id then
        id = 0

        if SERVER or isServerCreated then
            for i = 1,1000000 do
                if not customEntsListIndex["all"][i] then id = i break end
            end
        else
            for i = 1,1000000 do
                i = -i

                if not customEntsListIndex["all"][i] then id = i break end
            end
        end
    end

    ent.isServerCreated = isServerCreated
    ent.id = id
    ent.listHas = {}

    ent:SetList("all",true)
    ent:SetList("class_" .. ent.ClassName,true)

    ent:Event_Call("Create")

    return ent
end

function customEnts.Delete(id)
    if not id then return end--WTFFF

    local ent = customEntsListIndex["all"][id]

    if IsValid(ent) then ent:Remove() end
end

ENT:Event_Add("Construct","Update Game Entities",function(class)
    for id,ent in pairs(customEntsListIndex["class_" .. class[1].ClassName] or {}) do
        ent.__index = class[1]
        setmetatable(ent,ent)

        ent:Event_Call("Construct Object")
    end
end)

customEntsList["think"] = customEntsList["think"] or {}
local listThink = customEntsList.think

local IsValid = IsValid

event.Add("Think","Custom Entity Think",function()
    GarbageLock("think")

    local iteration = 0

    for i = 1,#listThink do
        iteration = iteration + 1

        local ent = listThink[iteration]
        
        if not IsValid(ent) then
            customEnts.Delete(ent and ent.id)
            table.remove(listThink,iteration)
            iteration = iteration - 1 continue
        end

        if ent.Think then ent:Think() end
    end

    GarbageFree("think")
end,2)

if SERVER then
    concommand.Add("hg_customentity_list_sv",function(ply,cmd,args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end

        if args[1] then
            for id,ent in pairs(customEntsListIndex[args[1]]) do
                print(id .. ": " .. ent.ClassName)
            end
        else
            for name,list in pairs(customEntsList) do
                print(name .. ": " .. #list .. " >")
            end
        end
    end)
    
else
    concommand.Add("hg_customentity_list_cl",function(ply,cmd,args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end

        if args[1] then
            for id,ent in pairs(customEntsListIndex[args[1]]) do
                print(id .. ": " .. ent.ClassName)
            end
        else
            for name,list in pairs(customEntsList) do
                print(name .. ": " .. #list .. " >")
            end
        end
    end)
end

customEntsList["cleanup"] = customEntsList["cleanup"] or {}
customEntsListIndex["cleanup"] = customEntsListIndex["cleanup"] or {}

hook.Add("PostCleanupMap","Custom Entities",function()
    for id,ent in pairs(customEntsListIndex.cleanup) do
        ent:Remove()
    end
end)
--[[for nane,list in pairs(customEntsList) do
    for k,v in pairs(list) do list[k] = nil end
end

for nane,list in pairs(customEnts.listIndex) do
    for k,v in pairs(list) do list[k] = nil end
end]]--