local IsFirstFrame = IsFirstFrame

local DrawModel = FindMetaTable("Entity").DrawModel

local hg_dev_dontsetupplayer
cvars.CreateDevOption("hg_dev_dontsetupplayer","0",function(value) hg_dev_dontsetupplayer = tonumber(value or 0) > 0 end)

function PlayerDeterminate(ent,tag,link,flags)
    if tag then return true end
    if flags == -2147483639 then return end

    DeterminateLODFirst(link)

    ent.renderLOD0 = link.renderLOD0
    ent.renderLOD1 = link.renderLOD1
    ent.renderLOD2 = link.renderLOD2
    ent.renderLOD2_5 = link.renderLOD2_5
    ent.renderLOD3 = link.renderLOD3
    ent.renderLOD4 = link.renderLOD4

    if ent.InFake and ent:InFake() then return end
    if not ent.renderLOD2 and (flags ~= 1 and flags ~= 9 and flags ~= 0) then return end

    if link:IsPlayer() and not link.InVehicle then return end--wtf
    
    if not hg_dev_dontsetupplayer and IsFirstFrame(ent,"r_fSetupBones") then
        ent.r_headPop = nil
        
        if link == LocalPlayer() then
            ent.r_headPop = link == LocalPlayer() and RenderIsMe() and GetViewEntity() == link and event.Call("RenderLocalPlayerHead",link) != false
        end

        PlayerBones(ent,tag,link,flags)
    end

    return true
end

local function PlayerRender(ent,tag,link,flags)
    if link.renderLOD1 then
        RenderPlayer_BackWeapons(ent,tag,link,flags)
    end

    if link.renderLOD3 then
        RenderPlayer_Weapon(ent,tag,link,flags)
    end

    if link.renderLOD4 then
        RenderPlayer_Armor(ent,tag,link,flags)
    end

    if link == LocalPlayer() then
        RenderPlayer_Armor_Camera(ent,tag,link,flags)
    end

    if link.GetAimVector then ent:SetEyeTarget(link:GetAimVector()) end
end

local hg_dev_dontdrawplayer = false
cvars.CreateDevOption("hg_dev_dontdrawplayer","0",function(value) hg_dev_dontdrawplayer = tonumber(value or 0) > 0 end)

local IsValidModel = util.IsValidModel

local listIndex = {}

function PlayerBones_PopHead(ent)
    ent.headPop = true
    listIndex[ent] = true
end

event.Add("PreRender","listIndex",function()
    for ent in pairs(listIndex) do
        if IsValid(ent) then ent.headPop = nil end

        listIndex[ent] = nil
    end
end)

local render_SetBlend = render.SetBlend

function RenderPlayer(ent,tag,link,flags)
    if hg_dev_dontdrawplayer then return end
    
    link = link or ent--wtf
    
    local success = PlayerDeterminate(ent,tag,link,flags)
    if not success then return end

    if link[RenderLODTPIK] then
        ent:SetupBones()

        BonesManager_SetupMatrix(ent,tag,link)
    end
    
    DrawModel(ent)
    
    PlayerRender(ent,tag,link,flags)
end

function RenderLocalPlayer(ent,tag,link,flags)
    if hg_dev_dontdrawplayer then return end
    
    local success = PlayerDeterminate(ent,tag,link,flags)
    if not success then return end
    
    if event.Call("RenderLocalPlayerModel") == false then return end

    ent:SetupBones()
    BonesManager_SetupMatrix(ent,tag,link)

    DrawModel(ent)
    PlayerRender(ent,tag,link,flags)

    event.Call("RenderLocalPlayerModelPost")
end