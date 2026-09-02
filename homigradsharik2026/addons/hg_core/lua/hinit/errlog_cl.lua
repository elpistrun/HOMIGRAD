local panel

local COLORS = {
    code = Color(240,90,90),
    loader = Color(240,170,60),
    autorun = Color(220,220,80)
}

local NAMES = {
    code = "Код",
    loader = "Loader",
    autorun = "Autorun"
}

local filters = {
    code = true,
    loader = true,
    autorun = true
}

local function Truncate(text,max)
    text = tostring(text or "")
    if #text <= max then return text end
    return string.sub(text,1,max - 3) .. "..."
end

local function GetEntries()
    local entries = {}
    local seen = {}

    local function AddList(list)
        for i = #list,1,-1 do
            local entry = list[i]
            if not filters[entry.cat] then continue end

            local key = (entry.cat or "") .. "|" .. (entry.path or "") .. "|" .. (entry.text or "")
            local old = seen[key]
            if old then
                old.count = (old.count or 1) + (entry.count or 1)
                continue
            end

            local copy = table.Copy(entry)
            copy.realm = entry.realm or "SV"
            seen[key] = copy
            entries[#entries + 1] = copy
        end
    end

    AddList(HG_ERRLOG.sync)
    AddList(HG_ERRLOG.list)

    return entries
end

local function MakeButton(parent,text,color,DoClick)
    local btn = vgui.Create("DButton",parent)
    btn:SetText(text)
    btn:SetTextColor(color_white)
    btn:SetFont("DermaDefaultBold")
    btn.DoClick = DoClick

    function btn:Paint(w,h)
        surface.SetDrawColor(30,34,44,255)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(60,66,82,255)
        surface.DrawOutlinedRect(0,0,w,h)

        if self:IsHovered() then
            surface.SetDrawColor(48,54,70,255)
            surface.DrawRect(1,1,w - 2,h - 2)
        end
    end

    return btn
end

local function MakeSwitch(parent,text,key)
    local sw = vgui.Create("DCheckBoxLabel",parent)
    sw:SetText(text)
    sw:SetTextColor(color_white)
    sw:SetChecked(filters[key])

    function sw:OnChange(val)
        filters[key] = val
        if panel then panel:Rebuild() end
    end

    return sw
end

local function CreatePanel()
    if IsValid(panel) then panel:Remove() end

    panel = vgui.Create("DFrame")
    panel:SetTitle("Homigrad — лог ошибок")
    panel:SetSize(900,600)
    panel:Center()
    panel:MakePopup()
    panel:SetSizable(true)
    panel:SetMinWidth(600)
    panel:SetMinHeight(400)

    function panel:Paint(w,h)
        surface.SetDrawColor(16,18,24,255)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(60,66,82,255)
        surface.DrawOutlinedRect(0,0,w,h)
    end

    local top = vgui.Create("DPanel",panel)
    top:Dock(TOP)
    top:SetHeight(44)

    function top:Paint(w,h)
        surface.SetDrawColor(22,25,32,255)
        surface.DrawRect(0,0,w,h)
    end

    local switches = {
        MakeSwitch(top,"Код","code"),
        MakeSwitch(top,"Loader","loader"),
        MakeSwitch(top,"Autorun","autorun")
    }

    local function LayoutTop(w)
        local x = 10
        for i,sw in ipairs(switches) do
            sw:SetPos(x,14)
            sw:SizeToContents()
            x = x + sw:GetWide() + 18
        end
    end

    local btnRefresh = MakeButton(top,"Обновить",color_white,function()
        HG_ERRLOG:RequestSync()
    end)
    btnRefresh:SetSize(90,28)
    btnRefresh:SetPos(0,0)

    local btnClear = MakeButton(top,"Очистить",color_white,function()
        HG_ERRLOG:ClearAll()
        if panel then panel:Rebuild() end
    end)
    btnClear:SetSize(90,28)

    local btnExport = MakeButton(top,"Экспорт",color_white,function()
        local entries = GetEntries()
        local text = "Homigrad Error Log — " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"

        for i,entry in ipairs(entries) do
            text = text .. string.format("\n[%s] %s %s x%s\n%s\n%s\n",entry.cat,os.date("%H:%M:%S",entry.time),entry.realm or "SV",entry.count or 1,entry.path,entry.text)
        end

        file.Write("hg_errlog_export.txt",text)

        if file.Exists("hg_errlog_export.txt","DATA") then
            chat.AddText(color_white,"Экспортировано: ",color_green,"data/hg_errlog_export.txt")
        end
    end)
    btnExport:SetSize(90,28)

    local status = vgui.Create("DLabel",top)
    status:SetText("")
    status:SetTextColor(Color(150,158,175))

    local scroll = vgui.Create("DScrollPanel",panel)
    scroll:Dock(FILL)
    scroll:SetPaintBackground(false)

    local list = vgui.Create("DListLayout",scroll)
    list:SetWidth(10)

    function panel:LayoutTopButtons(w)
        local x = w - 10
        for _,btn in ipairs({btnExport,btnClear,btnRefresh}) do
            x = x - btn:GetWide() - 8
            btn:SetPos(x,8)
        end

        status:SetSize(300,20)
        status:SetPos(10,top:GetHeight() - 20)
    end

    function panel:Rebuild()
        list:Clear()

        local entries = GetEntries()
        table.sort(entries,function(a,b) return (a.time or 0) > (b.time or 0) end)

        for _,entry in ipairs(entries) do
            local row = vgui.Create("DPanel",list)
            row:SetHeight(66)
            row:SetCursor("hand")

            local color = COLORS[entry.cat] or color_white
            local fullText = string.format("[%s] %s\n%s",entry.cat,entry.path,entry.text)

            function row:Paint(w,h)
                surface.SetDrawColor(28,31,40,255)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(38,42,54,255)
                surface.DrawRect(0,h - 1,w,1)

                surface.SetDrawColor(color)
                surface.DrawRect(0,0,4,h)
            end

            row.OnMousePressed = function()
                SetClipboardText(fullText)
                status:SetText("Скопировано: " .. entry.path)
            end

            local tag = vgui.Create("DLabel",row)
            tag:SetPos(14,6)
            tag:SetText(NAMES[entry.cat] or entry.cat)
            tag:SetTextColor(color)
            tag:SetFont("DermaDefaultBold")
            tag:SizeToContents()

            local meta = vgui.Create("DLabel",row)
            meta:SetPos(14,24)
            meta:SetText(string.format("%s %s x%s — %s",os.date("%H:%M:%S",entry.time),entry.realm or "SV",entry.count or 1,Truncate(entry.path,80)))
            meta:SetTextColor(Color(140,148,165))
            meta:SetFont("DermaDefault")
            meta:SetSize(600,16)

            local text = vgui.Create("DLabel",row)
            text:SetPos(14,40)
            text:SetText(Truncate(entry.text,130))
            text:SetTextColor(Color(220,224,232))
            text:SetFont("DermaDefault")
            text:SetSize(600,18)
        end

        status:SetText("Записей: " .. #entries)
    end

    function panel:OnClose()
        panel = nil
    end

    function panel:PerformLayout(w,h)
        self:LayoutTopButtons(w)
        list:SetWidth(w)
    end

    hook.Add("Think","HG_ERRLOG_Panel",function()
        if not IsValid(panel) then hook.Remove("Think","HG_ERRLOG_Panel") return end

        if (panel.nextSync or 0) < CurTime() then
            panel.nextSync = CurTime() + 2
            HG_ERRLOG:RequestSync()
        end
    end)

    HG_ERRLOG.OnSync = function()
        if IsValid(panel) then panel:Rebuild() end
    end

    panel:Rebuild()
    HG_ERRLOG:RequestSync()
end

concommand.Add("hg_errlog",function()
    if IsValid(panel) then panel:Remove() return end
    CreatePanel()
end)
