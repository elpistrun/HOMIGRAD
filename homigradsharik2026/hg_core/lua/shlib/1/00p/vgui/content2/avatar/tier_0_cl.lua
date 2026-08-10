local PANEL = oop.Reg("v_avatarlist","v_panel")
if not PANEL then return end

PANEL.Base = "DHTML"

function PANEL:OnInit()
    self.listID = {}
    self.list = {}

    self:SetAllowLua(true)
    self:SetZPos(-100)

    self.htmlTop = oop.CreatePanel("v_html",self):ad(function(self,w,h) self:setSize(w,h) end)--avaatrs layout
    self.htmlTop:SetZPos(100)
    self.htmlTop:SetAllowLua(true)
    self.htmlTop:SetMouseInputEnabled(false)
end

function PANEL:GetThread() return queueManager.thread.Create(tostring(self)) end

function PANEL:RunScriptTop(code)
    if IS64BIT and IsValid(self.htmlTop) then
        self.htmlTop:RunJavascript(code)
    end
end

function PANEL:RunScript(code)
    if IS64BIT then
        self:RunJavascript(code)
    end
end

function PANEL:Setup(iconSize)
    if iconSize == self.iconSize then return end
    
    if self.fontSize == nil then self.fontSize = math.max(math.floor(iconSize/4.5),12) .. "px" end

    local wide = iconSize * 0.25
    if self.iconSize == iconSize and self.wide == wide then return end

    self.iconSize = iconSize
    self.wide = wide

    self:SetupHTML()
end

function PANEL:SetScrollPanel(scroll,dontSize)--Должно быть внутри scrollpanel!!!
    self.dontClear = true

    if not dontSize then
        self:ad(function(_,w,h)
            local vbar = scroll.vbar

            self:setSize(scroll:W() - scroll.subX,scroll:H())
        end)
    end

    self:SetMouseInputEnabled(false)
    
    function self:Step()
        if not self.Ready then return end

        local y = scroll.scrollY

        if self.scrollY ~= y then
            self.scrollY = y

            self:RunScript("setScrollY(" .. y .. ")")--ну и пиздец....
            self:RunScriptTop("setScrollY(" .. y .. ")")
            self:SetY(self.scrollY)--https://www.youtube.com/watch?v=p5INcNQWuX0
        end
    end

    self.scrollPanel = scroll
end

function PANEL:SetupHTML()
    if not IS64BIT then
        self.Ready = true

        return
    end

    self.Ready = false

    local readyBackground,readyTop

    local htmlCodetop = self:GetHTMLCodeTop()

    readyTop = not htmlCodetop

    self.OnFinishLoadingDocument = function()
        readyBackground = true

        if readyBackground and readyTop then
            self.Ready = true
            
            if self.OnReady then self:OnReady() end
        end
    end

    self:SetHTML(self:GetHTMLCode())

    if htmlCodetop then
        self.htmlTop.OnFinishLoadingDocument = function()
            readyTop = true

            if readyBackground and readyTop then
                self.Ready = true

                if self.OnReady then self:OnReady() end
            end
        end

        self.htmlTop:SetHTML(htmlCodetop)
    end
end

function PANEL:GetHTMLCodeTop()
    return [[
    <html>
        <head>
            <meta charset="utf-8">
        </head>
        <body style="
            margin: 0;
            padding: 0;
            
            overflow-x: hidden;
            overflow-y: hidden;

            position: relative;
        ">
        </body>
        
        <script>
            let height = ]] .. math.floor(self.iconSize) .. [[;
            let wide = height * 0.25

            setScrollY = function(value) {
                document.body.style.bottom = value + "px"
            }

            let list = {}

            addPanel = async (id,avatar,avatarFrame,title) => {
                let panel = await document.createElement("div")
                document.body.appendChild(panel)
                panel.style = `
                    width: auto;
                    height: ` + height + `px;
                    margin: ` + wide + `px;
                `

                list[id] = panel

                let avatarPanel = document.createElement("div")
                panel.appendChild(avatarPanel)
                avatarPanel.style = `
                    background-size: cover;
                    background-image: url("` + avatar + `");
                    width: ` + height + `px;
                    height: 100%;
                `

                let avatarFrameAnchor = document.createElement("div")
                avatarPanel.appendChild(avatarFrameAnchor)
                avatarFrameAnchor.style = `
                    width: 0px;
                    height: 0px;

                    position: absolute;
                `

                let avatarFramePanel = document.createElement("div")
                avatarFrameAnchor.appendChild(avatarFramePanel)
                avatarFramePanel.style = `
                    background-size: cover;
                    background-image: url("` + avatarFrame + `");

                    width: ` + (height + wide) + `px;
                    height: ` + (height + wide) + `px;

                    position: relative;
                    left: ` + (-wide / 2) + `px;
                    top: ` + (-wide / 2) + `px;
                `

                if (title) {
                    let h1 = document.createElement("h1")
                    panel.appendChild(h1)
                    h1.textContent = title
                    h1.style = `
                        margin: 0;
                        padding: 0;

                        position: relative;
                        top: -100%;

                        width: calc(100% - ` + (height + wide * 1) + `px);
                        left: ` + (height + wide) + `px;
                        height: 100%;

                        display: flex;
                        justify-content: center;
                        align-items: center;

                        font-size: ]] .. self.fontSize .. [[;
                        color: rgb(255,255,255);

                        text-shadow: 1px 1px 2px black;
                    `
                }
            }

            removePanel = function(id) {
                list[id].remove()

                delete list[id]
            }

            setAlpha = function(id,k) {
                if (!list[id] || !list[id].style) {return}

                list[id].style.opacity = k
            }

            clear = function() {
                for (let id in list) {
                    list[id].parentNode.removeChild(list[id])
                }

                list = {}
            }
        </script>
    </html>
    ]]
end

function PANEL:GetHTMLCode()
    return [[
    <html>
        <head>
        <head><meta charset="utf-8"></head>
        <style>
            img[src=""] {
            display: none;
            }
        </style>
        </head>
        <body style="
            margin: 0;
            padding: 0;
            
            overflow-x: hidden;
            overflow-y: hidden;

            position: relative;
        ">
        </body>
        
        <script>
            let height = ]] .. math.floor(self.iconSize) .. [[;
            let wide = height * 0.25
        
            setScrollY = function(value) {
                document.body.style.bottom = value + "px"
            }

            let list = {}

            addPanel = function(id,background,opacity,y) {
                y = y || 0.5

                let panel = document.createElement("div")
                document.body.appendChild(panel)
                panel.style = `
                    width: auto;
                    height: ` + height + `px;
                    margin: ` + wide + `px;
                `

                list[id] = panel

                let backgroundPanel = document.createElement("div")
                panel.appendChild(backgroundPanel)
                backgroundPanel.style = `
                    position: relative;

                    overflow: hidden;
       
                    width: calc(100% - ` + (height + wide * 1) + `px);
                    left: ` + (height + wide) + `px;
                    height: 100%;

                    opacity: ` + opacity + `;
                `

                let image = document.createElement("img")
                backgroundPanel.appendChild(image)
                image.src = background
                image.imageRendering = "pixelated"

                image.style = `
                    width: 100%;
                    height: auto;

                    position: relative;
                    top: ` + (100 * y) + `%;
                    transform: translate(0,-` + (100 * y) + `%);
                `
            }

            removePanel = function(id) {
                list[id].remove()

                delete list[id]
            }

            setAlpha = function(id,k) {
                if (!list[id] || !list[id].style) {return}

                list[id].style.opacity = k
            }

            clear = function() {
                for (let id in list) {
                    list[id].parentNode.removeChild(list[id])
                }

                list = {}
            }
        </script>
    </html>
    ]]
end

local list = {
    "&lt;"
}

function PANEL:AddPanel(id,title,avatar,avatarFrame,background,opacity,backgroundY,dontCreate)
    local info = {
        id = id
    }

    local iteration = #self.list + 1
    self.listID[id] = iteration
    self.list[iteration] = info

    if title then title = string.gsub(title,"\"",[[\"]]) end
    
    if not self.Ready then
        local thread = self:GetThread()

        thread:CreateSimple(function()
            if not IsValid(self) then return end
            if not self.Ready then return false end
            
            self:RunScriptTop('addPanel("' .. id .. '","' .. (avatar or "") .. '","' .. (avatarFrame or "") .. '","' .. (title or "") .. '")')
            self:RunScript('addPanel("' .. id .. '","' .. (background or "") .. '","' .. (opacity or 0.7) .. '","' .. (backgroundY or 0.5) .. '")')
        end)
    else
        self:RunScriptTop('addPanel("' .. id .. '","' .. (avatar or "") .. '","' .. (avatarFrame or "") .. '","' .. (title or "") .. '")')
        self:RunScript('addPanel("' .. id .. '","' .. (background or "") .. '","' .. (opacity or 0.7) .. '","' .. (backgroundY or 0.5) .. '")')
    end

    local parent = self.scrollPanel or self

    local iconSize,wide = self.iconSize,self.wide
    local avatar = oop.CreatePanel("v_panel",parent):setSize(iconSize + wide*2,iconSize+ wide*2)
    
    if not IS64BIT then
        local avatar = oop.CreatePanel("v_avatarimage",avatar):setSize(iconSize,iconSize):setPos(wide,wide)
        avatar:SetPlayer(player.GetBySteamID64(id),184)
    end

    avatar.iteration = iteration
    info.gmodAvatar = avatar

    avatar:ad(function(avatar,w,h) avatar:setPos(0,(iconSize + wide) * (avatar.iteration - 1)) end)

    if not dontCreate then
        local panel = oop.CreatePanel("v_button",parent)
        panel.id = id
        panel.iteration = iteration

        info.panel = panel

        panel:ad(function(panel,w,h)
            panel:setPos(iconSize + wide * 2,wide + (iconSize + wide) * (panel.iteration - 1)):setSize(w - iconSize - wide * 3,iconSize)
        end)
        
        return panel,avatar
    end
end

function PANEL:AddPlayer(ply,dontCreate)
    return self:AddPanel(ply:SteamID64(),ply:Name(),ply:GetAvatar(),ply:GetAvatarFrame(),ply:GetBackground(),ply:GetBackgroundOpacity(),ply:GetBackgroundY(),dontCreate)
end

function PANEL:RemovePanel(id)
    if (TypeID(id) == TYPE_ENTITY) then id = id:SteamID() end

    local iteration = self.listID[id]
    if not iteration then return end
    local info = self.list[iteration]
    
    self:RunScriptTop('removePanel("' .. id .. '")')
    self:RunScript('removePanel("' .. id .. '")')

    if IsValid(info.gmodAvatar) then info.gmodAvatar:Remove() end
    if IsValid(info.panel) then info.panel:Remove() end

    table.remove(self.list,iteration)
    self.listID[id] = nil
    for iteration,info in pairs(self.list) do
        self.listID[info.id] = iteration
        
        if IsValid(info.panel) then info.panel.iteration = iteration end
        if IsValid(info.gmodAvatar) then info.gmodAvatar.iteration = iteration end
    end

    if self:GetThread().list[id] then
        self:GetThread().list[id]:Remove()
    end
end

function PANEL:SetAlphaPanel(id,value)
    if not self.Ready then return end

    value = value or 0

    if not IS64BIT then
        local iteration = self.listID[id]
        if not iteration then return end

        local avatar = self.list[iteration].gmodAvatar
        if IsValid(avatar) then avatar:SetAlpha(255 * value) end

        local panel = self.list[iteration].panel
        if IsValid(panel) then panel:SetAlpha(255 * value) end
    else
        local id = (TypeID(id) == TYPE_STRING and id or id:SteamID())

        self:RunScriptTop('setAlpha("' .. id .. '",' .. value .. ')')
        self:RunScript('setAlpha("' .. id .. '",' .. value .. ')')
    end
end

function PANEL:Clear()
    for i,info in pairs(self.list) do
        if IsValid(info.gmodAvatar) then info.gmodAvatar:Remove() end
        if IsValid(info.panel) then info.panel:Remove() end
    end

    self.list = {}//panel
    self.listID = {}

    self:GetThread():Remove()

    if self.Ready then
        self:RunScriptTop('clear()')
        self:RunScript('clear()')
    end
end

function PANEL:SetPlayerY(id,y)
    --self:RunJavascript('setY("' .. (TypeID(ply) == TYPE_STRING and ply or ply:SteamID()) .. '",' .. y .. ')')//а.. ладно похуй я уже придумал как это пофиксить
end

function PANEL:OnRemove()
    self:GetThread():Remove()
end

--https://music.youtube.com/watch?v=OSbn_8vnY6s&list=OLAK5uy_lpFH3M9q8-rs69NCpSDvaliZvEGOym0Y0
--пользуйся омежка