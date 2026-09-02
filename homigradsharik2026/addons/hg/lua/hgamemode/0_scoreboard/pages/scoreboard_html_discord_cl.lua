DiscordProfileDrawList = DiscordProfileDrawList or {}

function DiscordProfileDraw_Remove(id)
    local info = DiscordProfileDrawList[id]
    if not info then return end

    DiscordProfileDrawList[id] = nil

    if IsValid(info.panel) then info.panel:Remove() end
end

for id,info in pairs(DiscordProfileDrawList) do
    DiscordProfileDraw_Remove(id)
end

function DiscordProfileDraw(id,x,y,profile)
    DiscordProfileDrawList[id] = DiscordProfileDrawList[id] or {}
    local info = DiscordProfileDrawList[id]

    info.profile = profile
    info.render = true

    if not IsValid(info.panel) then
        panel = oop.CreatePanel("v_html")
        panel:SetMouseInputEnabled(false)
        info.panel = panel

        panel:SetZPos(1000)
        local mul = 1
        panel:setSize(math.max(ScrW() * 0.15,300) * mul,math.max(400,ScrH() * 0.37) * mul)

        local w,h = panel:W(),panel:H()

        local color1 = Color(15,15,15)
        local color2 = Color(30,30,30)

        local color3 = color2:Clone()
        local color4 = color1:Clone()

        color4.a = 1
        color3.a = 1

        local htmlRoles = ""
        
        for role in pairs(profile.roles or {}) do
            local color = AdminPanelRoles[role] and AdminPanelRoles[role].color or Color(255,255,255)

            htmlRoles = htmlRoles .. [[
            <div style="
                width: max-content;
                height: 1em;
                background-color: rgba(]] .. color1.r .. [[,]] .. color1.g .. [[,]] .. color1.b .. [[,0.5);
                border-radius: 0.25em;
                border: 1px solid rgb(]] .. color2.r .. [[,]] .. color2.g .. [[,]] .. color2.b .. [[);
                padding: 0.4em;
                margin-right: 0.5em;
                margin-top: 0em;
            ">
                <label style="font-size: 0.8em; display: flex; align-items: center;">
                <div style="width: 1em; height: 1em; border-radius: 100%; margin-right: 0.5em; background-color: rgb(]] .. color.r .. "," .. color.g .. "," .. color.b .. [[)"></div>
                ]] .. (AdminPanelRoles[role] and AdminPanelRoles[role].name or role) .. [[
                </label>
            </div>]]
        end

        panel:SetHTML([[
            <html>
                <style>
                * {
                    margin: 0;
                    padding: 0;
                    
                    font: bold 1em "Arial";
                    color: white;
                }
    
                </style>
                <body style="margin:0; padding: 0; width: 100%; height: 100%;">
                    <div style="
                        overflow: hidden;
                        width: 100%;
                        height: 100%;
                        background: linear-gradient(rgb(]] .. color1.r .. [[,]] .. color1.g .. [[,]] .. color1.b .. [[),rgb(]] .. color2.r .. [[,]] .. color2.g .. [[,]] .. color2.b .. [[));
                        border-radius: 0.5em
                    ">
                        <div style="
                            display: flex;
                            flex-direction: column;
                            overflow: hidden;
                            width: calc(100% - 0.75em);
                            height: calc(100% - 0.75em);
                            
                            border-radius: 0.5em;
                            position: relative;
                            left: 50%;
                            top: 50%;
                            transform: translate(-50%,-50%)
                        ">
                            <div style="width: 100%; height: 26%;">
                                <img src="]] .. (profile.banner or "") .. [[" style="width: auto; height: 100%; image-rendering: pixelated; position: relative; left: 50%; top: 50%; transform: translate(-50%,-50%)">
                            </div>
                            <div style="
                                width: 100%;
                                flex: 1;
                                position: relative;
                                background: linear-gradient(rgba(]] .. color3.r .. [[,]] .. color3.g .. [[,]] .. color3.b .. [[,]] .. color3.a .. [[),rgba(]] .. color4.r .. [[,]] .. color4.g .. [[,]] .. color4.b .. [[,]] .. color4.a .. [[));
                            ">
                                <div style="width: ]] .. w / 3 .. [[px; height: ]] .. w / 3 .. [[px; border-radius: 100%; margin-left: 0.5em; margin-top: -]] .. w / 3 / 2 .. [[px; position: relative; z-index: 100">
                                    <div style="overflow: hidden; width: 90%; height: 90%; border-radius: 100%; position: relative; left: 50%; top: 50%; transform: translate(-50%,-50%)">
                                        <img src="]] .. profile.avatar .. [[" style="width: 100%; height: 100%" image-rendering: pixelated;>
                                    </div>
                                </div>

                                <div style="
                                    display: flex;
                                    flex-direction: column;
                                    width: auto;
                                    height: 70%;
                                    margin: 1em;
                                ">
                                    <label style="font-size: 1.5em;">]] .. profile.displayName .. [[</label><br>
                                    <label style="margin-bottom: 1em;">]] .. profile.username .. [[</label>

                                    <div style="
                                        width: 100%;
                                        height: 100%;
                                        display: inline-flex;
                                        flex-wrap: wrap;
                                    ">
                                        ]] .. htmlRoles .. [[
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </body>
            </html>
        ]])
    end

    if y + panel:H() >= ScrH() then
        panel:setPos(x,y - panel:H())
    else
        panel:setPos(x,y)
    end
end