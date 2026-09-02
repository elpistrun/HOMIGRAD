local Plugin = EventPlugin_Reg("breakable_prop","base")
if not Plugin then return end

Plugin.PrintName = "Breakable Props"

function Plugin:Sync(data)
    if SERVER then
        data.multiply_health = self.multiply_health
    else
        self.multiply_health = data.multiply_health
    end
end

if SERVER then
    Plugin.EventPlug = {
        ["Damage"] = "Damage"
    }

    local function makeHP(self,ent)
        local hp = ent:GetPhysicsObject():GetMass() * 10 * (self.multiply_health or 1)
        ent:SetMaxHealth(hp)
        ent:SetHealth(hp)
    end

    function Plugin:Damage(dmgTab)
        local ent = dmgTab.target

        if ent:GetClass() == "prop_physics" then
            if ent:GetMaxHealth() <= 1 then makeHP(self,ent) end

            ent:SetHealth(math.max(ent:Health() - dmgTab.dmg,0))
            
            if ent:Health() <= 0 then
                ent:Fire("Break")
            end
        end
    end

    Plugin:AddCMD("multiply_health",function(self,ply,args)
        self.multiply_health = math.max(tonumber(args[1] or 10) or 10,0)

        return true,tostring(value)
    end)

    Plugin:AddCMD("fullup",function(self,ply,value)
        local count = 0

        for i,ent in pairs(ents.FindByClass("prop_physics")) do
            makeHP(self,ent)
            count = count + 1
        end
        
        return true,count .. " objects."
    end)
else
    Plugin.HookPlug = {
        ["OnEntityCreated"] = "OnEntityCreated"
    }

    function Plugin:OnEntityCreated(ent)
        if IsValid(ent) and ent:GetClass() == "prop_physics" then
            ent.RenderOverride = function()
                self:RenderProp(ent)
            end
        end
    end

    local SetColorModulation = render.SetColorModulation
    function Plugin:RenderProp(ent)
        if ent:GetMaxHealth() != 1 then
            local hp = ent:Health() / ent:GetMaxHealth()

            SetColorModulation(1,hp,hp)
            ent:DrawModel()
            SetColorModulation(1,1,1)
        else
            ent:DrawModel()
        end
    end

    function Plugin:Create(page)
        page:AddEdit("multiply_health")
        local butt = page:AddEdit("fullup")
        butt.GetText = function() return "" end
        butt.OnClick = function() page.plugin:SendCMD("fullup",{}) end
    end
end