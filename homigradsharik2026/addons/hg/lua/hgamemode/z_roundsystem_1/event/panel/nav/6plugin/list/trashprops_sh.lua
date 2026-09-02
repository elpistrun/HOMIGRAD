local Plugin = EventPlugin_Reg("trashprops","base")
if not Plugin then return end

Plugin.PrintName = "Trash Props"

function Plugin:Sync(data)
    if SERVER then
        data.time = self.time
    else
        self.removetime = data.time
    end
end

if SERVER then
    Plugin.Garbage = Plugin.Garbage or {}
    Plugin.Time = Plugin.Time or 10

    Plugin:AddCMD("removetime",function(self,ply,args)
        value = math.max(tonumber(args[1] or 10) or 10,0)

        self.time = value

        return true,tostring(value)
    end)

    Plugin:AddCMD("clear",function(self,ply,value)
        local count = 0

        for ent in pairs(self.Garbage) do
            if not IsValid(ent) then continue end
            ent:Remove()
            count = count + 1
        end

        self.Garbage = {}
        
        return true,count .. " objects."
    end)

    Plugin.EventPlug = {
        ["Spawn Object"] = "SpawnObject"
    }

    function Plugin:SpawnObject(ply,type,ent)
        Plugin.Garbage[ent] = true
        timer.Simple(Plugin.time,function()
            Plugin.Garbage[ent] = nil
            if not IsValid(ent) then return end
            ent:Remove()
        end)
    end
else
    function Plugin:Create(page)
        page:AddEdit("removetime")
        local butt = page:AddEdit("clear")
        butt.GetText = function() return "" end
        butt.OnClick = function() page.plugin:SendCMD("clear",{}) end
    end
end