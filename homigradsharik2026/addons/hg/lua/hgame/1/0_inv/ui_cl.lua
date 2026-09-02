inventoryGame.soundUI = inventoryGame.soundUI or {}
local soundUI = inventoryGame.soundUI

soundUI.move = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/concrete/rock_impact_soft1.wav",
        "physics/concrete/rock_impact_soft2.wav",
        "physics/concrete/rock_impact_soft3.wav",

        "physics/concrete/rock_impact_soft1.wav",
        "physics/concrete/rock_impact_soft2.wav"
    }
}

soundUI.granade = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/metal/metal_grenade_impact_hard1.wav",
        "physics/metal/metal_grenade_impact_hard1.wav",
        "physics/metal/metal_grenade_impact_hard1.wav"
    }
}

soundUI.fast = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/concrete/rock_impact_soft1.wav",
        "physics/concrete/rock_impact_soft2.wav",
        "physics/concrete/rock_impact_soft3.wav",

        "physics/concrete/rock_impact_soft1.wav",
        "physics/concrete/rock_impact_soft2.wav"
    }
}

soundUI.weapon = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/metal/weapon_impact_soft1.wav",
        "physics/metal/weapon_impact_soft2.wav",
        "physics/metal/weapon_impact_soft3.wav"
    }
}

soundUI.plastic = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/plastic/plastic_box_impact_soft1.wav",
        "physics/plastic/plastic_box_impact_soft2.wav",

        "physics/plastic/plastic_box_impact_soft1.wav",
        "physics/plastic/plastic_box_impact_soft2.wav",
        "physics/plastic/plastic_box_impact_soft1.wav",
    }
}

soundUI.body = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/body/body_medium_impact_soft1.wav",
        "physics/body/body_medium_impact_soft2.wav",
        "physics/body/body_medium_impact_soft3.wav",
        "physics/body/body_medium_impact_soft4.wav",
        "physics/body/body_medium_impact_soft5.wav"
    }
}

soundUI.ammo = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/metal/metal_grenade_impact_soft1.wav",
        "physics/metal/metal_grenade_impact_soft2.wav",
        "physics/metal/metal_grenade_impact_soft3.wav"
    }
}

soundUI.wood = {
    pitch = 100,
    volume = 1,
    list = {
        "physics/wood/wood_furniture_impact_soft1.wav",
        "physics/wood/wood_furniture_impact_soft2.wav",
        "physics/wood/wood_furniture_impact_soft3.wav"
    }
}

inventoryGame.colorTypeIndex = {
    weapon = Color(80,0,255),
    weaponSecondary = Color(80,80,200),
    meleePrimary = Color(0,200,70),
    other = Color(0,100,0),
    granade = Color(190,75,0),
    medical = Color(200,0,0),
    ["resource"] = Color(0,0,75),
    armor = Color(0,0,125),
    ammo = Color(125,125,0),

    mine = Color(255,125,200),
}

local color_back = Color(0,0,0)

function inventoryGame.GetColorType(item)
    local class = GetClassFromName(item.spawnname)

    if class.InvGetColorType then
        local color = class:InvGetColorType(item)
        if color != nil then return color end
    end

    return class.itemType and inventoryGame.colorTypeIndex[class.itemType] or color_back
end

local hg_dev_dontsounduiinv

cvars.CreateDevOption("hg_dev_dontsounduiinv","0",function(value)
    hg_dev_dontsounduiinv = tonumber(value or 0) > 0
end,0,1)

function inventoryGame.PlaySound(item,sndNameList,pitch,volume)
    if hg_dev_dontsounduiinv or not item then return end

    local class = GetClassFromName(item.spawnname)
    if not class then return end
    
    local soundList

    if class.GetInvSnd then
        soundList = class:GetInvSnd(item,sndNameList) or soundUI.move
    else
        soundList = class[sndNameList] or class.InvSnd or soundUI.move
    end

    LocalPlayer():EmitSound(
        soundList.list[math.random(1,#soundList.list)],
        75,
        (soundList.pitch or 100) + (pitch or 0) + math.random(-1,1),
        (soundList.volume or 0.5) + (volume or 0) + math.random(-0.05,0.05)
    )
end

function inventoryGame.PlaySoundDecay(item,sndNameList,pitch,volume)
    inventoryGame.PlaySound(item,sndNameList,pitch,volume)

    if 1 + volume <= 0 then return end

    timer.Simple(math.Rand(0.05,0.1) * math.Rand(0.8,1.25),function()
        inventoryGame.PlaySound(item,sndNameList,pitch - 1,volume - 0.1)
    end)
end

inventoryGame.SlotSize = math.floor(math.max(ScrH() * 0.063,32))

event.Add("Screen Size","inventoryGame",function()
    inventoryGame.SlotSize = math.floor(math.max(ScrH() * 0.063,32))
end)

function inventoryGame.SetSelectItem(item)
    if inventoryGame.SelectItem == item then return end
    
    local result = inventoryGame:Event_Call("SetSelectItem",inventoryGame.SelectItem,item)
    
    if result != nil then
        item = result

        if inventoryGame.SelectItem == item then return end
    end
    
    inventoryGame.SelectItem = item
    
    inventoryGame:Event_Call("ChangeSelectItem",item)
end