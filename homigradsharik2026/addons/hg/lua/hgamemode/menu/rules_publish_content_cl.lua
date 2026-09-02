local newVersion = 1

local function createPanel(callback)
    if IsValid(frametos) then frametos:Remove() end

	frametos = oop.CreatePanel("v_frame"):setDSize(1,1)
	frametos:MakePopup()
	frametos:SetZPos(100)

	local html = oop.CreatePanel("v_html",frametos):ad(function(self,w,h) self:setSize(w,h * 0.8):setPos(w/2-self:W()/2,h/2-self:H()/2) end)

	function frametos:Draw(w,h)
		surface.SetDrawColor(28,28,28)
		surface.DrawRect(0,0,w,h)

		if not html.Ready then
			draw.SimpleText("Загружаем страницу Правила публикации контента" .. string.rep(".",RealTime() % 4),"HS.45",w/2,h * 0.125,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.SimpleText("Если этого не происходит, значит что-то не так.","HS.18",w/2,h * 0.125 + 45,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			DrawLoading(w/2,h/2,h/2)
		end

		RunConsoleCommand("stopsound")
	end

	function frametos:DrawOver(w,h)
		draw.SimpleText("HOMIGRAD.COM","HS.45",w/2,h * 0.05,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	html:OpenURL("https://kopigrad.com/wiki/rules_publish_content?get&lang=ru")

	html:AddFunction("lua","out",function(str)
		html:RunJavascript("document.body.innerHTML = `" .. Homigrad_PrePareHTML(str) .. "`")
	end)//пиздец...... ну и дурка блядь

	html.OnDocumentReady = function()
		html.Ready = true

		html:RunJavascript("lua.out(document.body.innerHTML)")
	end

	local buttYes = oop.CreatePanel("v_button",frametos):ad(function(self,w,h) self:setSize(w * 0.4,75):setPos(w/2 - self:W()/2,h* 0.9) end)
	buttYes:SetupDrawStyle("white_gradient"); buttYes.text = "Я понял"; buttYes.font = "HS.45"; buttYes.gradientSide = "bottom"

	function buttYes:OnClick()
		if not html.Ready then
			gui.OpenURL("https://kopigrad.com/wiki/rules_publish_content?lang=ru")
		end

        frametos:Remove()
        if callback then callback() end
	end
end

concommand.Add("hg_show_rpc",function()
    createPanel()
end)

local version = 1

function Homigrad_RulesPublishContent(convarName,callback)
	if GetConVar(convarName):GetInt() != version then
    	createPanel(function()
			RunConsoleCommand(convarName,version)
			callback()
		end)
	else
		callback()
	end
end