local Page = donatPanel:Page_Reg(1)

local PageSub = Page.Reg_Page(1)
PageSub.Name = "Account"

function PageSub.Open(frame)
    local y = 0

    local function addBlock(text,height)
        local Y = y
        local panel = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,height):setPos(0,Y) end)
        y = y + panel:H()

        function panel:Draw(w,h)
            draw.SimpleText(text,"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
        end

        return panel
    end

    local function checkSuccess(panel,success)
        if not LocalPlayer():HasSuccess(success) then
            function panel:DrawOver(w,h)
                surface.SetDrawColor(0,0,0,200)
                surface.DrawRect(0,0,w,h)

                draw.SimpleText(L("donat_ui_not_access"),"HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            panel:SetLock(false)
        end
    end

    local profile = Profiles[AccountSteamID64] or outfitManager.listData[AccountSteamID64] or {}

    local switch = oop.CreatePanel("v_switch",addBlock(L("donat_ui_profile_hide_role"),60)):ad(function(self,w,h) self:setSize(h * 2,h):setPos(w - self:W(),0) end)
    function switch:OnValue(value) RunConsoleCommand("hg_dontshowmyperms",value and 1 or 0) end
    switch:SetValue(GetConVar("hg_dontshowmyperms"):GetBool())

    local switch = oop.CreatePanel("v_switch",addBlock(L("donat_ui_profile_hide_discord"),60)):ad(function(self,w,h) self:setSize(h * 2,h):setPos(w - self:W(),0) end)
    function switch:OnValue(value) RunConsoleCommand("hg_dontshowmydiscord",value and 1 or 0) end
    switch:SetValue(GetConVar("hg_dontshowmydiscord"):GetBool())

    local steamPoster = addBlock(L("donat_ui_profile_steam_poster"),60)
    checkSuccess(steamPoster,"ProfileSteamBackground")
    local switch = oop.CreatePanel("v_switch",steamPoster):ad(function(self,w,h) self:setSize(h * 2,h):setPos(w - self:W(),0) end)
    function switch:OnValue(value) RunConsoleCommand("hg_profile_showsteambackground",value and 1 or 0) end
    switch:SetValue(profile.backgroundSteam)

    local backgroundOpacity = addBlock(L("donat_ui_profile_poster_opacity"),60)
    checkSuccess(backgroundOpacity,"ProfileSteamBackground","ProfileChangeBackground")
    local slider = oop.CreatePanel("v_slider",backgroundOpacity):ad(function(self,w,h) self:setSize(w/2.5,h):setPos(w - self:W(),0) end)
    slider:SetMin(0)
    slider:SetMax(1)
    slider:SetValue(profile.backgroundOpacity or 0)
    slider.round = 100
    function slider:OnValue(value)
        local sid = LocalPlayer():SteamID64()
        Profiles[sid] = Profiles[sid] or {}
        Profiles[sid].backgroundOpacity = value
        Page.avatarHTML:Update()

        timer.Create("hg_profile_background_opacity",1,1,function()
            RunConsoleCommand("hg_profile_background_opacity",value)
        end)
    end

    local backgroundY = addBlock(L("donat_ui_profile_poster_y"),60)
    checkSuccess(backgroundY,"ProfileSteamBackground","ProfileChangeBackground")
    local slider = oop.CreatePanel("v_slider",backgroundY):ad(function(self,w,h) self:setSize(w/2.5,h):setPos(w - self:W(),0) end)
    slider:SetMin(0)
    slider:SetMax(1)
    slider.round = 100
    slider:SetValue(profile.backgroundY or 0)
    
    function slider:OnValue(value)
        local sid = LocalPlayer():SteamID64()
        Profiles[sid] = Profiles[sid] or {}
        Profiles[sid].backgroundY = value
        Page.avatarHTML:Update()

        timer.Create("hg_profile_background_y",1,1,function()
            RunConsoleCommand("hg_profile_background_y",value)
        end)
    end

    local backgroundPoster = addBlock(L("donat_ui_profile_poster"),90)
    if checkSuccess(backgroundPoster,"ProfileChangeBackground") then
        function backgroundPoster:DrawOver(w,h)
            if profile.backgroundContentType == "image/gif" and not ply:HasSuccess("ProfileBackgroundAnimated") then
                surface.SetDrawColor(255,0,0)
                draw.GradientRight(w/2 + 1,0,w/2,60)
                draw.SimpleText(L("donat_ui_profile_poster_anim_need_access",adminPanelRole.GetName(adminPanelRole.GetSuccessNeedRole("ProfileBackgroundAnimated") or "NULL")),"HS.18",w - h/2,30,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            end
        end
    end

    local textEntry = oop.CreatePanel("v_textentry",backgroundPoster):ad(function(self,w,h) self:setSize(w,h - 60):setPos(w - self:W(),h-self:H()) end)
    textEntry:SetPlaceholderText("URL Image")
    textEntry:SetValue(profile.background or "")
    function textEntry:OnEnter()
        local value = string.Trim(self:GetValue())
        if value ~= "" and not string.match(string.lower(value),"^https?://") then
            notification.AddLegacy("Banner URL должен начинаться с http:// или https://",NOTIFY_ERROR,4)
            return
        end
        if string.find(value,"[\"'<>\r\n]") then
            notification.AddLegacy("Banner URL содержит недопустимые символы",NOTIFY_ERROR,4)
            return
        end
        value = string.gsub(value,"cdn%.discordapp%.com","media.discordapp.net")
        self:SetValue(value)

        local sid = LocalPlayer():SteamID64()
        Profiles[sid] = Profiles[sid] or {}
        Profiles[sid].background = value
        if outfitManager and outfitManager.listData then
            outfitManager.listData[sid] = outfitManager.listData[sid] or {}
            outfitManager.listData[sid].background = value
        end
        Page.avatarHTML:Update()

        Homigrad_RulesPublishContent("hg_rpc_profile",function()
            RunConsoleCommand("hg_profile_background",value)
        end)
    end

    local color = addBlock(L("color"),200)
    checkSuccess(color,"ProfileChangeColor")

    local mixer = oop.CreatePanel("v_colormixer",color):ad(function(self,w,h) self:setSize(w,h - 60):setPos(0,h - self:H()) end)
    mixer:SetPalette(false)
    mixer:SetAlphaBar(false)

    local colorProfile = profile.color
    if colorProfile then mixer:SetColor(Color(colorProfile[1],colorProfile[2],colorProfile[3])) end

    function mixer:ValueChanged(color)
        local sid = LocalPlayer():SteamID64()
        Profiles[sid] = Profiles[sid] or {}
        Profiles[sid].color = color

        timer.Create("hg_profile_color",1,1,function()
            if colorProfile and color.r == colorProfile[1] and color.g == colorProfile[2] and color.b == colorProfile[3] then return end
            
            RunConsoleCommand("hg_profile_color",util.TableToJSON({color.r,color.g,color.b}))
        end)
    end

    local switch = oop.CreatePanel("v_switch",color):ad(function(self,w,h) self:setSize(120,60):setPos(w - self:W(),0) end)

    function switch:OnValue(value)
        local color = mixer:GetColor()
        Page.Wating = true

        RunConsoleCommand("hg_profile_color",value and util.TableToJSON({color.r,color.g,color.b}) or "")
    end
    switch:SetValue(GetConVar("hg_profile_color"):GetString() != "")
end

cvars.CreateReplicateOption("hg_profile_color","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_background","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_showsteambackground","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_background_opacity","",nil,nil,nil,true)
cvars.CreateReplicateOption("hg_profile_background_y","",nil,nil,nil,true)

CreateClientConVar("hg_rpc_profile","0")

profileManager:Event_Add("Update","UI Profile",function(steamid64,data)
    if steamid64 != AccountSteamID64 then return end

    if IsValid(Page.avatarHTML) then Page.avatarHTML:Update() end
end)

if Initialize then scoreboard:Open() end
