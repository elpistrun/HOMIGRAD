local slotPos,oldSlotPos = 3,3
local slotDepth,oldSlotDepth = 1,1

local MaxSlot = 6

local wheelDelay = 0
local alphaStart = 0

local IsButtonDown = input.IsButtonDown

local replaceDefaultWeapons = {
    ["weapon_physgun"] = {
        slot = 0,
        icon = Material("homigrad/weapon_icon/physgun.png","smooth mips"),
        PrintName = "Phys Gun"
    },
    ["gmod_tool"] = {
        slot = 5,
        icon = Material("homigrad/weapon_icon/toolgun.png","smooth mips"),
        PrintName = "Tool Gun"
    },
}

local sortFunc = function(a,b) return (a.SlotPos or 0) < (b.SlotPos or 0) end

local function getListSlots(slot)
    local list = {}

    for i,wep in pairs(LocalPlayer():GetWeapons()) do
        local replace = replaceDefaultWeapons[wep:GetClass()]
        if (replace and replace.slot or wep.Slot or 0) + 1 != slot then continue end

        list[#list + 1] = wep
    end
    
    table.sort(list,sortFunc)

    return list
end

local oldInput
local oldAttack

local sndWheel = "homigrad/vgui/buttonclick.wav"
local sndSelectWeapon = "homigrad/vgui/panorama/itemtile_click_02.wav"
local sndSelectIsBeen = "homigrad/vgui/csgo_ui_contract_type2.wav"

local volume = 1

local DEV = false

local addDelay = DEV and 10000 or 1

event.Add("StartCommand","Weapon Selector",function(ply,cmd)
    if not ply:Alive() or gui.IsConsoleVisible() or IsValid(vgui.GetKeyboardFocus()) or vgui.CursorVisible() then return end
    if ply:InVehicle() and ply:KeyDown(IN_WALK) then return end

    if event.Call("Prevent Weapon Selector",cmd) == false then return end

    local wheel = cmd:GetMouseWheel()

    local time = RealTime()

    if wheelDelay < time then
        if wheel < 0 then
            wheelDelay = time + 1 / 24

            if alphaStart > RealTime() then
                local list = getListSlots(slotPos)

                if #list <= 1 then
                    slotPos = slotPos + 1
                else
                    slotDepth = slotDepth + 1
                    if slotDepth > #list then slotPos = slotPos + 1 slotDepth = 1 end
                end

                if slotPos > MaxSlot then slotPos = 1 end
            end

            alphaStart = RealTime() + addDelay
        elseif wheel > 0 then
            if alphaStart > RealTime() then
                wheelDelay = time + 1 / 24

                local list = getListSlots(slotPos)

                if #list <= 1 then
                    slotPos = slotPos - 1
                else
                    slotDepth = slotDepth - 1
                    if slotDepth <= 0 then slotPos = slotPos - 1 slotDepth = 1 end
                end

                if slotPos < 1 then slotPos = MaxSlot end
            end

            alphaStart = RealTime() + addDelay
        end
    end

    local inputSlot

    for i = 1,MaxSlot do
        if IsButtonDown(_G["KEY_" .. i]) then inputSlot = i end
    end

    if inputSlot then slotPos = inputSlot end

    //

    local emitSNDWheel

    if oldSlotDepth != slotDepth then
        oldSlotDepth = slotDepth
        emitSNDWheel = true
    end

    if oldSlotPos != slotPos then
        oldSlotPos = slotPos
        emitSNDWheel = true
        oldInput = inputSlot

        local list = getListSlots(inputSlot)
        if slotDepth > #list then slotDepth = 1 end
        oldSlotDepth = slotDepth

        alphaStart = RealTime() + addDelay
    end
    
    if oldInput != inputSlot then
        oldInput = inputSlot

        if inputSlot then
            local list = getListSlots(inputSlot)
            if alphaStart > RealTime() then slotDepth = slotDepth + 1 end
            if slotDepth > #list then slotDepth = 1 end
            oldSlotDepth = slotDepth

            alphaStart = RealTime() + addDelay

            if #list != 1 then
                emitSNDWheel = true
            else
                sound.EmitScreen(sndSelectIsBeen,volume,255)
            end
        end
    end

    if emitSNDWheel then sound.EmitScreen(sndWheel,volume,255) end
    
    if alphaStart - RealTime() > 0 then
        local active = cmd:KeyDown(IN_ATTACK)
        cmd:RemoveKey(IN_ATTACK)

        if oldAttack != active then
            oldAttack = active

            if active then
                local list = getListSlots(slotPos)

                local wep = list[slotDepth]

                if wep then
                    timer.Simple(0,function()
                        if wep.SupportSecondarSlot then
                            input.SelectSecondaryWeapon(LocalPlayer():GetActiveSecondaryWeapon() != wep and wep)
                        else
                            input.SelectWeapon(wep)
                        end
                    end)

                    sound.EmitScreen(sndSelectWeapon,volume,100)

                    alphaStart = RealTime() + 0.1
                else

                end
            end
        end
    end
end)

local colorBackground = Color(0,0,0,200)
local colorBackground2 = Color(128,128,128,200)
local colorBackground3 = Color(255,255,255,200)

local colorWhite = Color(255,255,255)
local colorBlack = Color(0,0,0)

local function DrawWeaponIcon(wep,x,y,w,h)
    if not wep then return end

    local replace = replaceDefaultWeapons[wep:GetClass()]

    if replace or wep.IconWeaponSelection then
        local size = math.min(w,h)

        surface.SetDrawColor(0,0,0)
        surface.SetMaterial(replace and replace.icon or wep.IconWeaponSelection)
        surface.DrawTexturedRect(x + w / 2 - size / 2,y,size,size)
    elseif wep.DrawWeaponSelection then
        if DEV then
            surface.SetDrawColor(60,60,60)
            surface.DrawRect(x,y,w,h)
        end
        
        wep:DrawWeaponSelection(x,y,w,h,255)
    elseif wep.WepSelectIcon then
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material(surface.GetTextureNameByID(wep.WepSelectIcon)))
        surface.DrawTexturedRect(x,y,w,h)
    end
end

local colorBackgroundBlue = Color(128,128,255,100)
local colorBackgroundBlue2 = Color(160,160,255,200)

hook.Add("HUDPaint","Weapon Selector",function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local k = math.Clamp(alphaStart - RealTime(),0,1)

    k = math.min(k * 15,1)

    if k <= 0 then slotDepth = 1 return end

    surface.SetAlphaMultiplier(k)
    render.SetBlend(k)

    local w,h = ScrW() * 0.5,ScrH() * 0.1
    local font = "HS.25"
    local fontSelect = "H.25"
    local corner = h * 0.1

    local x = ScrW() / 2 - w / 2
    local y = math.floor(ScrH() * 0.02)

    local wideSlotOpen = w / 4
    local heightSlotOpen = wideSlotOpen * 0.8

    local iconSize = math.floor(w / MaxSlot - corner)
    
    local cornerRadius = 6

    local wepPrimary = LocalPlayer():GetActiveWeapon()
    local wepSecondary = LocalPlayer():GetActiveSecondaryWeapon()
    
    for i = 1,MaxSlot do
        if i == slotPos then
            do
                local y = y
                local x = x - wideSlotOpen / 2 + iconSize / 2

                local list = getListSlots(i)
                
                for i = 1,math.max(#list,1) do
                    local isSecondary = wepSecondary and list[i] == wepSecondary

                    if i == slotDepth or isSecondary then
                        if isSecondary then
                            draw.RoundedBox(cornerRadius,x,y,wideSlotOpen,heightSlotOpen,i == slotDepth and colorBackgroundBlue2 or colorBackgroundBlue)
                        else
                            draw.RoundedBox(cornerRadius,x,y,wideSlotOpen,heightSlotOpen,colorBackground3)
                        end

                        draw.SimpleText(slotPos,fontSelect,x + corner,y + corner,colorBlack)

                        local wep = list[i]

                        if wep then
                            DrawWeaponIcon(wep,x + corner,y + corner,wideSlotOpen - corner * 2,heightSlotOpen - corner * 2)

                            local wep = replaceDefaultWeapons[wep:GetClass()] or wep
                            draw.SimpleText(wep.PrintName,"HS.25",x + wideSlotOpen / 2,y + heightSlotOpen + (corner * 5) / 2,colorWhite,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                        end

                        y = y + heightSlotOpen + corner * 5
                    else
                        draw.RoundedBox(cornerRadius,x,y,wideSlotOpen,iconSize / 4,colorBackground)
                        y = y + iconSize / 4 + corner
                    end
                end
            end

            x = x + iconSize + (wideSlotOpen / 2 - iconSize / 2) + corner
        else
            local wep = getListSlots(i)[1]
            
            local isSecondary = IsValid(wepSecondary) and wep == wepSecondary
            
            local color = (isSecondary and colorBackgroundBlue) or (wep == wepPrimary and colorBackground3) or (wep and colorBackground2 or colorBackground)

            if i + 1 == slotPos then
                local size = iconSize - (wideSlotOpen - iconSize) / 2

                draw.RoundedBox(cornerRadius,x,y,size,iconSize,color)
                draw.SimpleText(i,font,x + corner * 1.5,y + corner,wep and colorBlack or colorWhite,TEXT_ALIGN_CENTER)

                DrawWeaponIcon(wep,x + corner,y + corner,size - corner * 2,iconSize - corner * 2)
                
                x = x + (iconSize) + corner
            else
                draw.RoundedBox(cornerRadius,x,y,iconSize,iconSize,color)
                draw.SimpleText(i,font,x + corner,y + corner,wep and colorBlack or colorWhite)

                DrawWeaponIcon(wep,x + corner,y + corner,iconSize - corner * 2,iconSize - corner * 2)
                
                x = x + (iconSize) + corner
            end
        end
    end

    surface.SetAlphaMultiplier(1)
    render.SetBlend(1)
end)

event.Add("Prevent Weapon Selector","Physgun",function(cmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not IsValid(wep) or wep:GetClass() != "weapon_physgun" then return end

    if ply:KeyDown(IN_ATTACK) then return false end
end)