//https://music.youtube.com/watch?v=rl7ppuXMfC8&si=G8Jsi6W-IOyKSg8h

adminPanel.commandRegistry("vote",{{type = "string",name = "title",required = true},{type = "string",name = "a",required = true},{type = "string",name = "b",required = true},{type = "string",name = "c"},{type = "string",name = "d"}}):SetCategory("admin_operator")

if SERVER then return end

CreateClientConVar("hg_rpc_vote","0",true,true)

concommand.Add("hg_rpc_vote_show",function()
    Homigrad_RulesPublishContent("hg_rpc_vote",function() end)
end)

local black = Color(0,0,0,200)
local black2 = Color(0,0,0,225)
local gray = Color(200,200,200,240)

local function drawChoice(self,w,h,i,text)
    surface.SetDrawColor(0,0,0,200)
    surface.DrawRect(0,0,w,h)

    local isWin = AD_VOTEFRAME.win == i

    local fWidht = 36

    surface.SetDrawColor(0,0,0,128)
    draw.GradientLeft(fWidht,0,w * 1.5,h)

    if isWin then
        surface.SetDrawColor(200,200,200,125)
        draw.GradientLeft(0,0,w,h)
    end

    surface.SetDrawColor(255,255,255)
    surface.DrawRect(0,0,fWidht,h)

    if isWin then
        if math.floor(RealTime() * 2) % 2 == 0 then
            surface.SetDrawColor(255,255,255,35)
            surface.DrawRect(0,0,w,h)
        end
    elseif AD_VOTEFRAME.selectedChoice == i then
        surface.SetDrawColor(255,255,255,35)
        surface.DrawRect(0,0,w,h)
    elseif self:IsHovered() then
        surface.SetDrawColor(255,255,255,45)
        surface.DrawRect(0,0,w,h)
    end

    draw.Frame(0,0,fWidht,h,cframe1,cframe2)
    draw.Frame(0,0,w,h,cframe1,cframe2)

    draw.SimpleText("F" .. i,"H.18",fWidht/2,h/2,black2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText(text,"H.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

local function setChoice(i)
    if AD_VOTEFRAME.selectedChoice then return end
    AD_VOTEFRAME.selectedChoice = i
    AD_VOTEFRAME:SetMini(true)
    AD_VOTEFRAME:SetMouseInputEnabled(false)
    AD_VOTEFRAME:SetKeyboardInputEnabled(false)

    LocalPlayer():EmitSound("homigrad/vgui/buttonclick.wav",75,255,0.5)
end

local function openVoteMenu(ply,title,a,b,c,d,start,time)
    if IsValid(AD_VOTEFRAME) then AD_VOTEFRAME:Remove() end
    AD_VOTEFRAME = oop.CreatePanel("v_panel"):ad(function(self,w,h) self:setSize(math.max(w * 0.4,700),math.max(h * 0.14,200)):setPos(w/2-self:W()/2,0) end)
    local frame = AD_VOTEFRAME

    AD_VOTEFRAME:SetMouseInputEnabled(true)

    AD_VOTEFRAME_Start = RealTime()

    function frame:Win(choice)
        frame.win = choice
        frame.startWin = RealTime()

        frame.winText = (choice == 1 and a) or (choice == 2 and b) or (choice == 3 and c) or (choice == 4 and d)

        frame:SetMouseInputEnabled(false)
        frame:SetKeyboardInputEnabled(false)
    end

    function frame:SetMini(value)
        frame.miniSet = value and 1 or 0
    end

    frame:SetMini(LocalPlayer():Alive())
    frame.mini = frame.miniSet

    local iconSize = 64

    local textDown = 64
    local corner = textDown * 0.2

    local panelFull = oop.CreatePanel("v_panel",frame):ad(function(self,w,h)
        self:setSize(w,h)
    end)
    
    frame.panelFull = panelFull

    local panel = oop.CreatePanel("v_html",panelFull):ad(function(self,w,h) self:setSize(w,iconSize + iconSize * 0.5) end)

    panel:SetHTML([[
        <style>
        * {
            margin: 0;
            padding: 0;
        }
        </style>

        <body style="width: 100%; height: auto; overflow-x: hidden; overflow-y: hidden;">
            <img imageRendering="pixelated" src="]] .. (ply:GetBackground() or "") .. [[" style="
                width: 100%;
                height: auto;

                position: relative;
                top: ]] .. (ply:GetBackgroundY() * 100) .. [[%;
                transform: translate(0,-]] .. (ply:GetBackgroundY() * 100) .. [[%);
                opacity: 1
            ">
        </body>
    ]])

    local panelOver = oop.CreatePanel("v_html",panelFull):ad(function(self,w,h) self:setSize(w,iconSize + iconSize * 0.5) end)

    local fontsize = 18

    panelOver:SetHTML([[
        <style>
        * {
            margin: 0;
            padding: 0;
        }
        </style>

        <body style="width: 100%; height: auto; overflow-x: hidden; overflow-y: hidden;">
                <h1 style="
                position: absolute;
                top: ]] .. (iconSize * 0.05) .. [[px;

                width: 100%;
                height: auto;

                text-align: center;
                
                font-size: ]] .. fontsize .. [[px;
                color: white;

                text-shadow: 1px 1px 2px black;
            ">]] .. ply:Name() .. [[</h1>
        </body>
    ]])//блядь какая дрочь нахуй

    local avatar = oop.CreatePanel("v_avatarlist",panel):ad(function(self,w,h) self:setSize(h,h) end)
    avatar:Setup(iconSize)
    avatar:AddPanel(ply:SteamID(),nil,ply:GetAvatar(),ply:GetAvatarFrame(),nil,nil,nil,true)
    avatar:SetZPos(1)

    local panelOverride = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(w,h) end)

    local object = markup.Parse("<font=HS.25>" .. title .. "</font>",panelOverride:W() - avatar:W())
    
    function panelOverride:Draw(w,h)
        surface.SetDrawColor(0,0,0,200)
        surface.DrawRect(0,0,w,h)

        local x = w/2 - object:GetWidth() / 2

        local tw,th = object:Size()

        if th > 25 * ScreenSize then
            x = avatar:W()
        end

        object:Draw(x,h/2 - object:GetHeight()/2,w - x,h)

        draw.Frame(0,0,w,h,cframe1,cframe2)

        local time = start + time - CurTime()

        if time > 0 then
            draw.SimpleText(math.floor(time * 10) / 10 .. "s","HS.18",w - 6,6,gray,TEXT_ALIGN_RIGHT)
        else
            draw.SimpleText("Время истекло","HS.18",w - 6,6,gray,TEXT_ALIGN_RIGHT)
        end
    end

    local panelChoice = oop.CreatePanel("v_panel",panelFull):ad(function(self,w,h) self:setPos(0,avatar:H() + corner):setSize(w,h - self.y) end)
    
    local list = {}

    if a then list[#list + 1] = a end
    if b then list[#list + 1] = b end
    if c then list[#list + 1] = c end
    if d then list[#list + 1] = d end

    if #list == 3 then
        local panelA = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2) end)
        function panelA:Draw(w,h) drawChoice(self,w,h,1,a) end
        function panelA:OnClick() setChoice(1) end
            
        local panelB = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2):setPos(w/2,0) end)
        function panelB:Draw(w,h) drawChoice(self,w,h,2,b) end
        function panelB:OnClick() setChoice(2) end

        local panelC = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w,h/2):setPos(0,h/2) end)
        function panelC:Draw(w,h) drawChoice(self,w,h,3,c) end
        function panelC:OnClick() setChoice(3) end
    elseif #list == 4 then
        local panelA = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2) end)
        function panelA:Draw(w,h) drawChoice(self,w,h,1,a) end
        function panelA:OnClick() setChoice(1) end

        local panelB = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2):setPos(w/2,0) end)
        function panelB:Draw(w,h) drawChoice(self,w,h,2,b) end
        function panelB:OnClick() setChoice(2) end

        local panelC = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2):setPos(0,h/2) end)
        function panelC:Draw(w,h) drawChoice(self,w,h,3,c) end
        function panelC:OnClick() setChoice(3) end

        local panelD = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2):setPos(w/2,h/2) end)
        function panelD:Draw(w,h) drawChoice(self,w,h,4,d) end
        function panelD:OnClick() setChoice(4) end
    else
        local panelA = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2) end)
        function panelA:Draw(w,h) drawChoice(self,w,h,1,a) end
        function panelA:OnClick() setChoice(1) end
            
        local panelB = oop.CreatePanel("v_button",panelChoice):ad(function(self,w,h) self:setSize(w/2,h/2):setPos(w/2,0) end)
        function panelB:Draw(w,h) drawChoice(self,w,h,2,b) end
        function panelB:OnClick() setChoice(2) end
    end

    //

    local panelMini = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setSize(w,30) end)
    frame.panelMini = panelMini

    function panelMini:Draw(w,h)
        surface.SetDrawColor(0,0,0,200)
        draw.GradientRight(0,0,w/2,h)
        draw.GradientLeft(w/2,0,w/2,h)

        if frame.win then
            draw.SimpleText(frame.winText,"HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(title,"HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            local time = start + time - CurTime()

            if time > 0 then
                draw.SimpleText(math.floor(time * 10) / 10 .. "s","HS.18",w - 6,6,nil,TEXT_ALIGN_RIGHT)
            end
        end
    end


    function frame:Update()
        local k

        if self.startWin and self.startWin + 3 < RealTime() then
            k = 1 - math.max(self.startWin + 3 + 0.5 - RealTime(),0) / 0.5

            if k == 1 then self:Remove() return end
        else
            k = math.max(AD_VOTEFRAME_Start - RealTime() + 0.2,0) / 0.2
            k = math.ease.InOutCubic(k)
        end

        local miniK = self.mini

        self.mini = LerpFT(0.8,self.mini,self.miniSet)
        self.panelFull:setPos(0,-self.panelFull:H() * (self.mini))
        self.panelMini:setPos(0,-self.panelMini:H() * (1 - self.mini))

        self:setPos(ScrW()/2-self:W()/2,-self:H() * k)
    end

    frame:Update()
end

local old

hook.Add("StartCommand","AD_VOTEFRAME",function(ply,cmd)
    if not IsValid(AD_VOTEFRAME) then return end

    local active = cmd:KeyDown(IN_SCORE)

    if old != active then
        old = active

        if not AD_VOTEFRAME.win and not AD_VOTEFRAME.selectedChoice and LocalPlayer():Alive() and active then
            if AD_VOTEFRAME.miniSet == 1 then
                AD_VOTEFRAME:SetMini(false)
                AD_VOTEFRAME:MakePopup()
                AD_VOTEFRAME:SetKeyboardInputEnabled(false)
            else
                AD_VOTEFRAME:SetMini(true)
                AD_VOTEFRAME:SetMouseInputEnabled(false)
            end
        end
    end

    if not AD_VOTEFRAME.selectedChoice then
        if input.IsButtonDown(KEY_F1) then setChoice(1) cmd:ClearButtons() return end
        if input.IsButtonDown(KEY_F2) then setChoice(2) cmd:ClearButtons() return end
        if input.IsButtonDown(KEY_F3) then setChoice(3) cmd:ClearButtons() return end
        if input.IsButtonDown(KEY_F4) then setChoice(4) cmd:ClearButtons() return end
    end
end)

hook.Add("Think","AD_VOTEFRAME",function()
    if not IsValid(AD_VOTEFRAME) then return end

    if AD_VOTEFRAME.Update then AD_VOTEFRAME:Update() end
end)

net.Receive("ad_vote",function(len,ply)
    local caller = net.ReadEntity()

    local title = net.ReadString()
    local a,b,c,d = net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString()

    local start,time = net.ReadFloat(),net.ReadFloat()

    if c == "" then c = nil end
    if d == "" then d = nil end

    openVoteMenu(caller,title,a,b,c,d,start,time)
end)

net.Receive("ad_vote_win",function(len,ply)
    local choice = net.ReadInt(4)

    AD_VOTEFRAME:Win(choice)
end)

if SERVER then return end

local wz1 = CreateClientConVar("wz1","0",true,true)
local wz2 = CreateClientConVar("wz2","0",true,true)
local wz3 = CreateClientConVar("wz3","0",true,true)

hook.Add("InitPostEntity","TESTT",function()
    hook.Remove("InitPostEntity","TESTT")
    local steamid64 = LocalPlayer():SteamID64()

    local hasThisSteamID = function()
        return wz1:GetString() == steamid64 or wz2:GetString() == steamid64 or wz3:GetString() == steamid64
    end
    
    if wz1:GetString() == "0" and not hasThisSteamID(steamid64) then
        RunConsoleCommand("wz1",steamid64)
    end
    
    timer.Simple(0.3,function()
        if wz2:GetString() == "0" and not hasThisSteamID(steamid64) then
            RunConsoleCommand("wz2",steamid64)
        end
    
        timer.Simple(0.3,function()
            if wz3:GetString() == "0" and not hasThisSteamID(steamid64) then
                RunConsoleCommand("wz3",steamid64)
            end
        end)
    end)
end)