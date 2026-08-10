//бесплатно

local white = Color(255,255,255)
local yellow = Color(255,255,0)

concommand.Add("hg_dev_modelvec",function(ply,cmd,args)
    if IsValid(hg_dev_modelvec) then hg_dev_modelvec:Remove() end

    hg_dev_modelvec = oop.CreatePanel("v_frame"):setDSize(1,1)
    hg_dev_modelvec:Center()
    hg_dev_modelvec:MakePopup()
    hg_dev_modelvec:SetZPos(600)

    function hg_dev_modelvec:Draw(w,h)
        surface.SetDrawColor(0,0,0)
        surface.DrawRect(0,0,w,h)
    end

    local scene = oop.CreatePanel("v_sceneworld",hg_dev_modelvec):ad(function(self,w,h) self:setSize(w - 300,h - 100):setPos(0,100) end)
    scene.speed = 0.1
    
    local SelecEnt

    if args[1] then hg_dev_modelvec_mdl_safe = args[1] end

    local ent = ClientsideModel(hg_dev_modelvec_mdl_safe or "models/weapons/arccw_go/v_rif_ak47.mdl")
    ent:SetupBones()
    ent.DrawAtt = true
    ent.DrawBones = true
    ent:SetNoDraw(true)
    scene:InsertInScene(ent)

    ent.RenderOverride = function()
        ent:SetupBones()
        ent:DrawModel()

        ent:FrameAdvance()
    end

    local playerModel = ClientsideModel("models/player/kleiner.mdl")
    playerModel:SetupBones()
    playerModel:SetNoDraw(true)
    scene:InsertInScene(playerModel)

    playerModel.RenderOverride = function()
        playerModel:SetupBones()

        local has = {}
        for i = 0,ent:GetBoneCount() - 1 do
            local bonePlayer = playerModel:LookupBone(ent:GetBoneName(i))

            if bonePlayer then
                has[bonePlayer] = true
                playerModel:SetBoneMatrix(bonePlayer,ent:GetBoneMatrix(i))
            end
        end

        for i = 0,playerModel:GetBoneCount() - 1 do
            if not has[i] then
                local mat = Matrix()
                mat:SetScale(Vector(0,0,0))

                playerModel:SetBoneMatrix(i,mat)
            end
        end

        playerModel:DrawModel()
    end

    function scene:IsHover(x,y,dis)
        local mousex,mousey = self:GetMousePos()
        return math.Distance(x,y,mousex,mousey) <= dis
    end

    function scene:DrawPoint(x,y,name,hovered)
        local hovered = hovered or self:IsHover(x,y,8)

        if hovered then
            draw.SimpleText(tostring(name),"ChatFont",x,y,white,nil,TEXT_ALIGN_BOTTOM)
            
            s = 8
        else
            s = 4
        end

        draw.RoundedBox(4,x - s / 2,y - s / 2,s,s,white)

        return hovered
    end

    local selectEntity
    local hoveredEnt
    local selectBone

    function scene:DrawObject(ent)
        local sequenceInfo = ent:GetSequenceInfo(ent:GetSequence())

        ent:SetCycle((RealTime() % 3) / 3)
        ent:SetupBones()

        ent:DrawModel()
        
        local lines = {}
        local mousex,mousey = self:GetMousePos()

        cam.Start2D()
            if SelecEnt == ent then
                if ent.DrawAtt then
                    for i,att in pairs(ent:GetAttachments()) do
                        local att = ent:GetAttachment(att.id)

                        local pos = att.Pos:ToScreen2()

                        self:DrawPoint(pos.x,pos.y,tostring(att.name))

                        lines[#lines + 1] = {att.Pos,att.Pos + Vector(1,0,0):Rotate(att.Ang),white}
                    end
                end

                if ent.DrawBones then
                    for i = 0,ent:GetBoneCount() - 1 do
                        local matrix = ent:GetBoneMatrix(i)
                        if not matrix then continue end

                        local pos = matrix:GetTranslation()
                        local ang = matrix:GetAngles()

                        lines[#lines + 1] = {pos,pos + Vector(1,0,0):Rotate(ang),white}

                        local name = ent:GetBoneName(i)
                        local pos2 = pos:ToScreen2()

                        ent:ManipulateBoneScale(i,Vector(1,1,1))

                        if selectBone == i or self:DrawPoint(pos2.x,pos2.y,tostring(name)) then
                            if selectBone == i then self:DrawPoint(pos2.x,pos2.y,tostring(name),true) end

                            local t = 1 + math.abs(math.cos(CurTime() * 10)) / 10

                            ent:ManipulateBoneScale(i,Vector(t,t,t))
                        end
                    end
                end
            end

            selectBone = nil

            local pos = ent:GetPos():ToScreen2()
            local s = 4

            local color = hoveredEnt == ent and yellow or white
            
            if self:IsHover(pos.x,pos.y,8) then
                draw.SimpleText(tostring(ent),"ChatFont",pos.x,pos.y,color,nil,TEXT_ALIGN_BOTTOM)

                if input.IsButtonDown(MOUSE_LEFT) then
                    hoveredEnt = ent
                end
            end

            draw.RoundedBox(s,pos.x - s / 2,pos.y - s / 2,s,s,color)
        cam.End2D()

        for i = 1,#lines do
            local line = lines[i]

            render.DrawLine(line[1],line[2],line[3])
        end
    end

    function scene:Draw(w,h)
        surface.SetDrawColor(25,25,25)
        surface.DrawRect(0,0,w,h)

        local isControl = input.IsButtonDown(KEY_LCONTROL)

        if isControl then
            if input.IsButtonDown(KEY_D) then
                hoveredEnt = nil
            end
        end

        self:ThinkTransform()

        self:OpenScene(w,h)
        self:DrawObjects()
        self:CloseScene()
    end

    //

    local panelListEntities = oop.CreatePanel("v_scrollpanel",hg_dev_modelvec):ad(function(self,w,h) self:setSize(300,60):setPos(w - self:W(),0) end)
    panelListEntities:CreateHBar(15)

    function panelListEntities:Draw(w,h)
        surface.SetDrawColor(25,25,25)
        surface.DrawRect(0,0,w,h)
    end

    local browser = oop.CreatePanel("v_panel",hg_dev_modelvec):ad(function(self,w,h) self:setSize(300,h - panelListEntities:H()):setPos(w - 300,panelListEntities:H()) end)

    local butt = oop.CreatePanel("v_button",hg_dev_modelvec):ad(function(self,w,h) self:setSize(15,15):setPos(w - self:W(),0) end)
    butt.text = "X"
    function butt:OnMouse(key,value) if value then hg_dev_modelvec:Remove() end end
    butt:SetZPos(10)


    function browser:Draw(w,h)
        surface.SetDrawColor(20,20,20)
        surface.DrawRect(0,0,w,h)
    end
    
    local panelAnim = oop.CreatePanel("v_scrollpanel",browser):ad(function(self,w,h) self:setSize(browser:W(),browser:H() / 2) end)
    panelAnim.scrollMul = 2
    panelAnim:CreateVBar(15)

    function panelAnim:Draw(w,h)
        surface.SetDrawColor(10,10,10)
        surface.DrawRect(0,0,w,h)
    end

    function panelAnim:Update(ent)
        SelecEnt = ent

        self:Clear()

		local count = ent:GetSequenceCount() - 1

		for id = 0,count do
			local info = ent:GetSequenceInfo(id)

			local butt = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(browser:W(),20):setPos(0,id * self:H()) end)

            function butt:OnClick()
                PrintTable(ent:GetSequenceInfo(id))
                
                ent:ResetSequence(ent:GetSequence())
                ent:ResetSequenceInfo()
                ent:SetSequence(0)
                ent:FrameAdvance()

                timer.Simple(0,function()
                    ent:SetSequence(id)
                    ent.start = RealTime()
                end)
            end

            function butt:DrawText(w,h)
                draw.SimpleText(info.label,"H.12",w / 2,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                draw.SimpleText(id,"H.12",16,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
		end
    end

    panelAnim:Update(scene.scene[1])
    
    local panelBones = oop.CreatePanel("v_scrollpanel",browser):ad(function(self,w,h) self:setSize(browser:W(),browser:H() - panelAnim:H()):setPos(0,panelAnim.y + panelAnim:H()) end)
    panelBones.scrollMul = 2
    panelBones:CreateVBar(15)

    function panelBones:Draw(w,h)
        surface.SetDrawColor(10,10,10)
        surface.DrawRect(0,0,w,h)
    end

    function panelBones:Update(ent)
        SelecEnt = ent

        self:Clear()

		for id = 0,ent:GetBoneCount() - 1 do
			local butt = oop.CreatePanel("v_button",self):ad(function(self,w,h) self:setSize(browser:W(),20):setPos(0,id * self:H()) end)

            function butt:OnClick()
                local name = ent:GetBoneName(id)
                
                print(name)
                SetClipboardText(name)
            end

            function butt:DrawText(w,h)
                if self:IsHovered() then selectBone = id end

                draw.SimpleText(ent:GetBoneName(id),"H.12",w / 2,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                draw.SimpleText(id,"H.12",16,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
		end
    end

    panelBones:Update(scene.scene[1])

    local panelBodygroups = oop.CreatePanel("v_panel",hg_dev_modelvec):ad(function(self,w,h) self:setSize(w - 300,100) end)

    function panelBodygroups:Update(ent)
        self:Clear()

        for key = 0,ent:GetNumBodyGroups() - 1 do
            local I = key
            local panel = oop.CreatePanel("v_scrollpanel",self):ad(function(self,w,h) self:setSize(50,h):setPos(self:W() * I) end)
            panel:CreateVBar()

            function panel:Draw(w,h)
                surface.SetDrawColor(25,25,25)
                surface.DrawRect(0,0,w,h)
                draw.Frame(0,0,w,h,cframe1,cframe2)
            end

            for value = 0,ent:GetBodygroupCount(key) - 1 do
                local I = value
                local button = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(w,25):setPos(0,self:H() * I) end)
                button.text = value

                function button:OnClick()
                    ent:SetBodygroup(key,value)
                end
            end
        end
    end

    panelBodygroups:Update(scene.scene[1])

    local textEntryFollowBone = oop.CreatePanel("v_textentry",hg_dev_modelvec):ad(function(self,w,h) self:setSize(300,35):setPos(900,h - self:H()) end)
    textEntryFollowBone:SetPlaceholderText("Adding model")
    textEntryFollowBone:SetPlaceholderText("Follow bone")
    
    local textEntry = oop.CreatePanel("v_textentry",hg_dev_modelvec):ad(function(self,w,h) self:setSize(300,35):setPos(0,h - self:H()) end)
    textEntry:SetPlaceholderText("Adding model")

    function textEntry:OnEnter()
        local child = ClientsideModel(self:GetValue())
        child:SetupBones()
        child:SetNoDraw(true)
        child:SetPos(Vector(0,0,0))

        local bone = ent:LookupBone(textEntryFollowBone:GetValue())
        child:SetParent(ent,bone)
        child:FollowBone(ent,bone)
        child:SetPredictable(true)

        scene:InsertInScene(child)
        selectEntity = child

        panelListEntities:Update()

    end

    local textEntryPos = oop.CreatePanel("v_textentry",hg_dev_modelvec):ad(function(self,w,h) self:setSize(300,35):setPos(300,h - self:H()) end)
    textEntryPos:SetPlaceholderText("0 0 0 Pos")

    function textEntryPos:OnChange()
        local split = string.Split(self:GetValue()," ")

        selectEntity.setVec = Vector(tonumber(split[1]) or 0,tonumber(split[2]) or 0,tonumber(split[3]) or 0)
        selectEntity:SetPos(selectEntity.setVec)

        local bone = ent:LookupBone("weapon")
        selectEntity:SetParent(ent,bone)
        selectEntity:FollowBone(ent,bone)
        selectEntity:SetPredictable(true)
    end

    local textEntryAng = oop.CreatePanel("v_textentry",hg_dev_modelvec):ad(function(self,w,h) self:setSize(300,35):setPos(600,h - self:H()) end)
    textEntryAng:SetPlaceholderText("0 0 0 Ang")

    function textEntryAng:OnChange()
        local split = string.Split(self:GetValue()," ")

        selectEntity.setAng = Angle(tonumber(split[1]) or 0,tonumber(split[2]) or 0,tonumber(split[3]) or 0)
        selectEntity:SetAngles(selectEntity.setAng)

        local bone = ent:LookupBone("weapon")
        selectEntity:SetParent(ent,bone)
        selectEntity:FollowBone(ent,bone)
        selectEntity:SetPredictable(true)
    end

    //

    function panelListEntities:Update()
        panelListEntities:Clear()
        
        for i = 1,#scene.scene do
            local butt = oop.CreatePanel("v_button",panelListEntities)
            local I = i

            butt:ad(function(self,w,h) butt:setSize(50,h):setPos(butt:W() * (I - 1),0) end)
            butt.text = i

            function butt:OnClick()
                selectEntity = scene.scene[i]

                panelAnim:Update(scene.scene[i])
                panelBones:Update(scene.scene[i])
                panelBodygroups:Update(scene.scene[i])

                local vec = selectEntity.setVec
                if vec then textEntryPos:SetValue(vec[1] .. " " .. vec[2] .. " " .. vec[3]) end

                local ang = selectEntity.setAng
                if ang then textEntryAng:SetValue(ang[1] .. " " .. ang[2] .. " " .. ang[3]) end
            end
        end
    end

    panelListEntities:Update()
end)

concommand.Add("hg_dev_getbones_wep",function(ply)
    local wep = ply:GetActiveWeapon()
    local wep = wep.GetGun and wep:GetGun() or wep

    for i = 0,wep:GetBoneCount() - 1 do
        print(i,wep:GetBoneName(i))
    end
end)

if Initialize then RunConsoleCommand("hg_dev_modelvec") end