local ENTITY = FindMetaTable("Entity")

function ENTITY:CallOnRemove(id,func,...)
    self._callondeletelist = self._callondeletelist or {}
    self._callondeletelist[id] = {func,{...}}
end

function ENTITY:RemoveCallOnRemove(id,func)
    if not IsValid(self) then return end--WTF
    
    self._callondeletelist = self._callondeletelist or {}
    self._callondeletelist[id] = nil
end

local err = function(err) ErrorNoHaltWithStack(err) end

function ENTITY:CallHooksOnRemove()--you should kill yourself, now
    local tbl = self._callondeletelist
    if not tbl then return end

    self._callondeletelist = nil

    for id,info in pairs(tbl) do xpcall(info[1],err,self,unpack(info[2])) end
end

event.Add("EntityRemove","Really call when remove",function(ent)
    ent:CallHooksOnRemove()
end)