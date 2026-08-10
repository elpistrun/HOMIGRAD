local Plugin = EventPlugin_Get("base")
if not Plugin then return end

function Plugin:AddEdit(name,panel)
    panel = panel or self
    local i = #panel:GetChildren()

    local param = oop.CreatePanel("v_parametr",panel):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * i) end)
    param.text = name
    param.font = "HS.25"
    param.GetText = function() return tostring(self.plugin[name]) end
    param.Callback = function(value) self.plugin:SendCMD(name,{value}) end

    return param
end

local green,red = Color(0,255,0),Color(255,0,0)
function Plugin:AddEditBool(name,panel)
    panel = panel or self
    local i = #panel:GetChildren()

    local param = oop.CreatePanel("v_parametr",panel):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * i) end)
    param.text = name
    param.font = "HS.25"
    param.GetText = function() return tostring(self.plugin[name]) end
    param.OnClick = function()
        local value = tostring(self.plugin[name])
        
        if value == "true" then
            value = 0
        else
            value = 1
        end

        self.plugin:SendCMD(name,{value})
    end

    function param.Update()
        local value = tostring(self.plugin[name])
        
        if value == "true" then
            param.color = green
        else
            param.color = red
        end
    end

    param:Update()

    panel.listUpdate[#panel.listUpdate + 1] = param

    return param
end
