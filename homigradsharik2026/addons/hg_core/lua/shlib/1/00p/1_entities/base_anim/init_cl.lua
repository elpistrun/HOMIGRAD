local ENT = oop.Reg("base_anim","lib_event",true)
if not ENT then return INCLUDE_BREAK end

local hg_dev_animation = false

cvars.CreateDevOption("hg_dev_animation","0",function(value)--EZ БОЖ ЧЕЛ ИЗИ утютютютютютютютютютютютю, вот так НАМНОГО ПРИЯТНЕЕ БЛЯДЬ СУКА а не эта ебаная залупа сука умри ОРА ОРА ОРА ОРА ОРА ОРА ОРАААА!!!
    hg_dev_animation = tonumber(value or 0) > 0
end)

local err = ErrorNoHaltWithStack

net.ReceiveTick("animation",function(data)
    if not data.entIndex then return end--WWWWWWWWWWWWWWWWWWWWWWWTFF
    
    coroutine.wrap(function()
        xpcall(function()
            local ent = EntityCoroutine(data.entIndex)
            if not IsValid(ent) then return end--lox
            if not ent.PlayAnimation then coroutine.Wait(TickInterval()) end
            if not ent.PlayAnimation then return end--WTF

            local result = ent:Event_Call("CanSequenceByServer",data)

            if result == false then
                if hg_dev_animation then print(ent,"CanSequenceByServer block anim",data.name) end

                return
            end

            if result != true and hg_dev_animation then print(ent,"animation",data.name) end
            
            if data.name then
                ent:PlayAnimation(data)
            else
                ent:ResetAnimation()
            end
        end,err)
    end)()
end)