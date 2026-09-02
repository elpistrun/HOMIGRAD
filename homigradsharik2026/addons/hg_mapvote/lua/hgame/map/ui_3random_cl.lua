//https://media.discordapp.net/attachments/1126335812116697150/1146909950073913436/jellymation-Kobeni-Higashiyama-Chainsaw-Man-Anime-4781336.gif?ex=67b83e60&is=67b6ece0&hm=04cbfb615f560dacdc049fb6d48e15b0fe1dbb13f7f19d648b78bcfb424e6442&
//я уже заебался блядь это делать

function RTVUI_CreateRandom(page)
    local startRollTime
    local startWin

    function page:StartRoll()
        LocalPlayer():EmitSound("homigrad/vgui/freeze_cam.wav",75,100,0.3)
        LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_seal.wav",75,100,0.25)
        
        startRollTime = RealTime()
    end

    function page:Start()
        LocalPlayer():EmitSound("homigrad/vgui/item_inspect_01.wav",75,100,0.25)

        startRollTime = nil
        startWin = nil

        RTVSetPage(3)
        
        page:Clear()

        local iconSize = math.max(ScrW(),ScrH()) * 0.1
        local panel = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setSize(w * 0.8,iconSize + mapManager.textH/2):setPos(w/2 - self:W()/2,h/2 - self:H()/2) end)

        local start = RealTime()

        function panel:Step()
            local anim = math.ease.OutElastic(1 - math.max(start - RealTime() + 1.25,0) / 1.25)

            local w = self:GetParent():W()
            local h = self:GetParent():H()

            self:setPos(w/2 - self:W()/2,(h/2 - self:H()/2) * anim - self:H() * (1 - anim))

            if not startRollTime and (start - RealTime() + 1.25 <= 0) then
                page:StartRoll()
            end
            
            local anim = math.max((startRollTime or 0) - RealTime() + 2,0) / 2
            anim = math.ease.InSine(anim) * 15

            self:setPos(self.x + math.random(-anim,anim),self.y + math.random(-anim,anim))
        end

        local roll = 0
        
        local lists = {}
        local anims = {}
        
        local aviable = {}

        local count = 0
        local rollmul = RTVRoulleteMul

        local ft = 1 / 60
        local i = 0

        while true do
            anims[i] = count

            count = count + rollmul * ft
            rollmul = rollmul - RTVRoulleteSub * ft
            
            i = i + 1

            if rollmul <= 0 then break end
        end

        local add = panel:W() / 2 / iconSize
        count = math.floor(count + add)

        for i = 1,count do
            if table.Count(aviable) == 0 then
                for k,v in pairs(RTVRandom) do aviable[k] = v end
            end
            
            if i == count then
                lists[i] = RTVRandomWinner
            else
                local _,vote = table.Random(aviable)
                aviable[vote] = nil
                lists[i] = vote
            end
        end

        count = math.ceil(count + add) - count

        for i = 1,count do//заполняем пустоту
            if table.Count(aviable) == 0 then
                for k,v in pairs(RTVRandom) do aviable[k] = v end
            end
        
            local _,vote = table.Random(aviable)
            aviable[vote] = nil
            lists[#lists + 1] = vote
        end

        local soundOld = 0
        local soundStart = 0
        local soundEnd

        local upAnim = 0

        function panel:Paint(w,h)
            local t = startRollTime and ((RealTime() - startRollTime) * 60) or 0
            
            local frame = math.floor(t)
            local backAnim = anims[math.min(frame,#anims)]
            local forwardAnim = anims[math.min(frame + 1,#anims)]

            roll = Lerp(t % 1,backAnim,forwardAnim)

            local triggerX = w / 2

            for i = 1,#lists do
                local map = lists[i]

                local x = i * iconSize - iconSize * roll

                if i > soundOld and x <= triggerX then
                    page.cursorMap = map
                    
                    if t ~= 0 then
                        LocalPlayer():StopSound("homigrad/vgui/item_scroll_sticker_01.wav")
                        LocalPlayer():EmitSound("homigrad/vgui/item_scroll_sticker_01.wav",75,math.random(98,102),0.25)
                    end 

                    soundOld = i
                    upAnim = RealTime()
                end
        
                //draw.SimpleText(i,"HS.12",x,0)
                mapManager.DrawIcon(x,0,iconSize,h,map)
            end

            DisableClipping(true)

            surface.SetDrawColor(255,255,255)
            surface.DrawRect(0,0,1,h)
            surface.DrawRect(w - 1,0,1,h)

            //local anim = 1 - math.max(upAnim - RealTime() + 0.1,0) / 0.1

            surface.SetDrawColor(255,255,255)
            surface.DrawRect(w/2,0,1,h)

            if frame > #anims then
                draw.SimpleText(RTVRandomWinner,"HS.45",w/2,h + 48 ,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

                page:StartWin()
            end

            DisableClipping(false)
        end
    end

    local startConffeti
    local list = {}

    function page:StartWin()
        if startWin then return end
        startWin = true
        startConffeti = RealTime()
        list = {}

        LocalPlayer():EmitSound("homigrad/vgui/panorama/case_reveal_mythical_01.wav",75,100,0.5)
        LocalPlayer():EmitSound("homigrad/conffeti_pop.wav",75,100,0.5)
    end

    local function addPart(x,y,color,rot)
        if #list == 300 then return end

        table.insert(list,{
            x = x,
            y = y,

            forceX = ScrW() * 0.5 * math.sin(math.rad(rot)),
            forceY = ScrH() * 2 * math.cos(math.rad(rot)),

            color = color
        })
    end

    local white = Material("color")
    local star = Material("homigrad/vgui/models/star.png")

    function page:Draw(w,h)
        if not startConffeti then return end

        local color = HSVToColor(CurTime() * 360,1,1)
        surface.SetDrawColor(color.r,color.g,color.b)

        local canPart = startConffeti - RealTime() + 1.25 > 0

        if canPart then
            local x,y = w * 0.075,h * 0.9

            local rot = math.sin(CurTime() * 15)
            rot = 180 + rot * 45 - 30

            surface.SetMaterial(white)
            surface.DrawTexturedRectRotated(x,y,20,60,rot)

            for i = 1,1 do addPart(x,y,color,rot + math.Rand(-15,15)) end

            rot = rot + 30 + 30

            x,y = w * 0.925,h * 0.9
            surface.DrawTexturedRectRotated(x,y,20,60,rot)

            for i = 1,1 do addPart(x,y,color,rot + math.Rand(-15,15)) end
        end

        surface.SetMaterial(star)

        local ft = FrameTime()
        local i = 0

        ::start::
        i = i + 1
        local part = list[i]
        if not part then return end

        part.x = part.x + part.forceX * ft
        part.y = part.y + part.forceY * ft
        
        part.forceY = part.forceY + ScrH() * 1.5 * ft

        local color = part.color
        surface.SetDrawColor(color.r,color.g,color.b)
        surface.DrawTexturedRectRotated(part.x,part.y,32,32,math.random(-90,90))

        goto start
    end
end