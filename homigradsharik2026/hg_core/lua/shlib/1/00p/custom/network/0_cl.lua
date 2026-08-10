local ENT = oop.Reg("custom_network","lib_event",true)
if not ENT then return INCLUDE_BREAK end

local err = function(err) ErrorNoHaltWithStack(err) end

function CustomEntity_InputPKG(pkg)
    local id = pkg.id
    
    if pkg.class then
        coroutine.wrap(function()
            xpcall(function()
                local running = coroutine.running()
                local isCreate
                
                if event.Call("PreCustomEntityCreate",pkg) == false then return end
                
                local ent = customEnts.listIndex["all"][id]

                if not IsValid(ent) or ent.ClassName != pkg.class then
                    ent = customEnts.Create(pkg.class,id,true)
                    isCreate = true
                end

                ent:InputSync(pkg)

                if isCreate then ent:Spawn() end

                event.Call("PostCustomEntityCreate",ent,pkg)

                event.Call("CustomEntitySync",ent,pkg)

                
            end,err)
        end)()
    else
        coroutine.wrap(function()
            xpcall(function()
                local ent = customEnts.listIndex["all"][id]

                if not IsValid(ent) then
                    if pkg.remove then return end

                    ErrorNoHalt("cuent_stream: this entity does't exists [" .. id .. "]\n")
                    PrintTable(pkg)

                    return
                end

                if pkg.remove then
                    ent:Remove(pkg)
                else
                    ent:InputSync(pkg)

                    event.Call("CustomEntitySync",ent,pkg)
                end
            end,err)
        end)()
    end

    return customEnts.listIndex["all"][id]
end

net.ReceiveTick("cuent_stream",function(data)
    CustomEntity_InputPKG(data)
end)

function ENT:InputSync(pkg)
    self:Event_Call("Sync",pkg)
end

function ENT:IsLocal() return not self.isServerCreated end