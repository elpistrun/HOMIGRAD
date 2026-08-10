local SWEP = oop.Get("weapon_transmitter")
if not SWEP then return end

net.Receive("radio_menu",function()
    local pkg = net.ReadTable()

    local wep = LocalPlayer():GetActiveWeapon()
    
    if wep ~= pkg.entity then
        gui.EnableScreenClicker(false)
        targetSettingsRadio.entity = nil

        return
    end

    if not targetSettingsRadio or targetSettingsRadio.entity ~= pkg.entity then
        targetSettingsRadioStart = RealTime()

        SWEP:OpenLED()
    end

    targetSettingsRadio = pkg
end)

SWEP:Event_Add("Off","Main",function(self)
    if targetSettingsRadio then gui.EnableScreenClicker(false) end
    
    targetSettingsRadio = nil
end)

//

local black,gray = Color(0,0,0),Color(0,0,0,100)

local drawButtonInputs = {}
local drawButtonHover = {}
local i

local delayHoveredSound = 0

local function drawButton(x,y,size,color,desc,callbackDown,callbackOut)
    i = i + 1
    size = size or 32

    local mx,my = gui.MouseX(),gui.MouseY()

    if math.sqrt((mx - x)^2 + (my - y)^2) <= size then
        size = size + 6
        color.a = color.a * 1.5

        if not drawButtonHover[i] then
            drawButtonHover[i] = true

            if delayHoveredSound < RealTime() then
                delayHoveredSound = RealTime() + 0.025
                LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_type" .. math.random(1,10) .. ".wav",75,200,0.5)
            end
        end

        if input.IsMouseDown(MOUSE_LEFT) then
            color.a = color.a / 2
            size = size - 2

            if not drawButtonInputs[i] then
                drawButtonInputs[i] = true
                LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_type" .. math.random(1,10) .. ".wav",75,100,0.5)
                callbackDown()
            end
        else
            if drawButtonInputs[i] then
                drawButtonInputs[i] = nil
                if callbackOut then callbackOut() end
            end
        end

        if desc then
            local x,y = x + size/1.5,y - size/1.5

            surface.SetFont("HS.18")
            local tw,th = surface.GetTextSize(desc)
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(x,y,tw,th)

            draw.SimpleText(desc,"HS.18",x,y,nil)
        end
    else
        if drawButtonHover[i] then
            drawButtonHover[i] = nil
        end
    end

    draw.RoundedBox(size/2,x - size/2,y - size/2,size,size,color)
end

local numpadValue = 1

function SWEP:OpenLED()
    numpadValue = 1
end

local function sendCMD(name,args)
    net.Start("radio_menu")
    net.WriteString(tostring(targetSettingsRadio.entity:EntIndex()))
    net.WriteString(name)
    net.WriteTable(args)
    net.SendToServer()
end

local function numpadInput(value)
    if value == false then
        numpadValue = 0
    elseif value == "." then
        numpadValue = tostring(numpadValue) .. value
    else
        numpadValue = tonumber(tostring(numpadValue) .. value) or 0
    end
end

hook.Add("HUDPaint","Radio Transmitter",function()
    if not targetSettingsRadio or not IsValid(targetSettingsRadio.entity) or not IsValid(targetSettingsRadio.entity.wm) then
        if translate then
            translate = nil

            RunConsoleCommand("-attack2")//mdam
        end

        return
    end

    if not vgui.CursorVisible() then gui.EnableScreenClicker(true) end

    i = 0
    local target = targetSettingsRadio.entity
    local ang = target.wm:GetAngles()
    ang:RotateAroundAxis(ang:Right(),-90)

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-5,4):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,64,Color(255,255,255,125),L("weapon_radio_transmit"),function() translate = not translate end)
    RunConsoleCommand((translate and "+" or "-") .. "attack2")

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,0.25,6.5):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,125),"FM-",function() 
        if tonumber(numpadValue) then sendCMD("fm",{-tonumber(numpadValue)}) end
    end)

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-1.2,6.5):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,125),"FM+",function()
        if tonumber(numpadValue) then sendCMD("fm",{tonumber(numpadValue)}) end
    end)

    // NUMPAD

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-0.1,-2.3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(1) end)
    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-1.3,-2.3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(2) end)
    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-2.5,-2.3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(3) end)
    
    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-0.1,-3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(4) end)
    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-1.3,-3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(5) end)
    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-2.5,-3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(6) end)

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-0.1,-3.75):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(7) end)
    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-1.3,-3.75):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(8) end)
    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-2.5,-3.75):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(9) end)

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-3.65,-3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),nil,function() numpadInput(0) end)

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-3.65,-2.3):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),"CLEAR",function() numpadInput(false) end)

    local pos = target.wm:GetPos()
    pos:Add(Vector(3.2,-3.65,-3.75):Rotate(ang)) pos = pos:ToScreen()
    drawButton(pos.x,pos.y,32,Color(255,255,255,5),".",function() numpadInput(".") end)
end)

surface.CreateFont("DigitalCyrilic_25",{
    font = "DigitalCyrillic1",
    size = 25,
})

surface.CreateFont("DigitalCyrilic_45",{
    font = "DigitalCyrillic1",
    size = 45,
})

function SWEP:DrawLED(w,h)
    surface.SetDrawColor(0,151,255)
    surface.DrawRect(0,0,w,h)
    
    draw.SimpleText("TRANSMIT","DigitalCyrilic_45",w/2,h/2,self:GetNWBool("TransmitLine") and black or gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText("LISEN","DigitalCyrilic_25",w/2,h/1.25,self:GetNWBool("EnableSound") and black or gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    if targetSettingsRadio and IsValid(targetSettingsRadio.entity) then
        draw.SimpleText("FM: " .. tostring(targetSettingsRadio.fm),"DigitalCyrilic_25",w/2,h/4/2.5,black,TEXT_ALIGN_CENTER)
        local tw,th = surface.GetTextSize(numpadValue)
        draw.SimpleText(numpadValue,"DigitalCyrilic_25",w-8,h/4/2,black,TEXT_ALIGN_RIGHT)
        draw.SimpleText("±","H.25",w-8 - tw - 5,h/4/2,black,TEXT_ALIGN_RIGHT)
    end
end

//https://music.youtube.com/watch?v=OSbn_8vnY6s&list=OLAK5uy_lpFH3M9q8-rs69NCpSDvaliZvEGOym0Y0