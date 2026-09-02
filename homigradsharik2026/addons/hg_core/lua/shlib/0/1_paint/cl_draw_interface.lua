hook.Add("Initialize","ScrWscrH",function()
    scrw = ScrW()
    scrh = ScrH()
end)

scrw = ScrW()
scrh = ScrH()

ScreenR = ScrW() / ScrH()

hook.Add("OnScreenSizeChanged","Fuck",function(oldw,oldh,w,h)
    scrw = ScrW()
    scrh = ScrH()

    ScreenR = ScrW() / ScrH()
end)

concommand.Add("hg_fakescreenwh",function(ply,cmd,args)
    scrw = tonumber(args[1] or ScrW()) or ScrW()
    scrh = tonumber(args[2] or ScrH()) or ScrH()
end)

FindMetaTable("Vector").ToScreen2 = function(self)
    local pos = self:ToScreen()

    pos.x = pos.x * (ScrW() / scrw)
    pos.y = pos.y * (ScrH() / scrh)

    return pos
end

local oldX,oldY = gui.MouseX(),gui.MouseY()
local oldFocus = false
local delay = 0

mousedx = 0
mousedy = 0

mousex = 0
mousey = 0

wheel = 0

event.Add("Think","Interface PrePare Input",function()
    IsWindow = not system.HasFocus()

    local x,y = gui.MouseX(),gui.MouseY()
    local focus = system.HasFocus()
    local time = CurTime()

    if oldFocus ~= focus then
        if focus then delay = time + 0.25 end

        InWindowTime = time
        InWindow = focus
        
        hook.Run("Window",focus)

        oldFocus = focus
    end

    if focus and delay < time then
        mousedx = oldX - x
        mousedy = oldY - y

        mousex = x
        mousey = y
    end

    oldX = x
    oldY = y
end,-10)

hook.Add("InputMouseApply","!Interface PrePare Input",function(cmd, x, y, ang)
    if wheel == 0 then wheel = cmd:GetMouseWheel() end
end)//когда vgui открыто он заглатывает хуи в рот, ну сука это пиздец я не хочу цеплдять к каждой панели функцию захвата ебаного колёсиука мышкивыпащльыхвыфх0

hook.Add("PostRender","Reset Interface",function()
    wheel = 0
end)

EntityIconChache = {}

function EntityIcon(name)
    local mat = EntityIconChache[name]

	if not mat then
        mat = Material("entities/" .. tostring(name) .. ".png","GAME")

        if not mat:IsError() then
            EntityIconChache[name] = mat
        else
            mat = Material("vgui/entities/" .. tostring(name) .. ".png","GAME")

            if not mat:IsError() then
                EntityIconChache[name] = mat
            else
                mat = Material("vgui/entities/" .. tostring(name),"GAME")

                EntityIconChache[name] = mat
            end
        end
	end

	return mat
end

hook.Add("HUDPaint","Homigrad",function()
    event.Call("HUDPaint",LocalPlayer(),CurTime())
end)

local blurmat = Material("pp/blurscreen")
local UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local DrawTexturedRect = surface.DrawTexturedRect

function DrawBlur(amount,x,y)
    surface.SetMaterial(blurmat)

    local i = 0

    ::start::
    i = i + 1
   
    blurmat:SetFloat("$blur",(i / 3) * amount)
    blurmat:Recompute()

    x,y = x or 0,y or 0
    
    UpdateScreenEffectTexture()
    DrawTexturedRect(-x,-y,ScrW(),ScrH())

    if i >= amount then return end
    
    goto start
end

function DrawBlurByPanel(amount,panel)
    local x,y = panel:LocalToScreen(0,0)
    DrawBlur(amount,x,y)
end

function IsKeyboardFree(panel)
    return not gui.IsGameUIVisible() and (not IsValid(vgui.GetKeyboardFocus()) or (panel and panel == vgui.GetKeyboardFocus()))
end

local chache = {}

local function createMaterial(nameMat,namePNG)
    return CreateMaterial(nameMat,"UnlitGeneric",{
        ["$basetexture"] = namePNG,
        ["$alphatest"] = 1,
        ["$translucent"] = 1,
        ["$vertexcolor"] = 1
    })
end

local queue = {}

function CreateMaterialPNG(nameMat,namePNG,callback)
    local mat = chache[nameMat]
    
    if mat == nil then
        chache[nameMat] = false

        if not InitPostEntity then
            queue[#queue + 1] = {nameMat,namePNG,callback}
        else
            timer.Simple(0,function()
                Material(namePNG)

                chache[nameMat] = createMaterial(nameMat,namePNG)

                callback(chache[nameMat])
            end)
        end
    elseif mat == false then
        timer.Simple(0,function()
            Material(namePNG)

            chache[nameMat] = createMaterial(nameMat,namePNG)

            callback(chache[nameMat])
        end)
    else
        if mat then callback(mat) end
    end
end

event.Add("InitPostEntity","Create Material PNG",function()
    for i,task in pairs(queue) do
        queue[i] = nil

        CreateMaterialPNG(task[1],task[2],task[3])
    end
end)

local materials = {}

function MaterialHash(path,flags,force)
    local mat = materials[path]
    if mat and not force then return mat end

    mat = Material(path,flags)
    materials[path] = mat--ЧТОО

    return mat
end