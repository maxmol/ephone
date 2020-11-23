App.bgColor = color_black

surface.CreateFont('iphone_deepweb_status', {
	font = 'Fira Code',
	size = 28,
})

local addMessage = function(scroll, text, my)
	if IsValid(scroll) then
		local l = vgui.Create('DLabel', scroll)
		l:SetSize(220, 32)
		l:SetText(text)
		l:SetFont('iphone_deepweb_status')
		local tw, th = l:GetTextSize()
		local indent = math.max(82, 330 - (tw + 24))
		l:DockMargin(my and indent or 24, 24, my and 24 or indent, 0)
		l:SetWrap(true)
		l:SetAutoStretchVertical(true)
		l:Dock(TOP)
		l:SetColor(my and Color(0, 215, 40) or Color(76, 147, 87))

		function l:Paint(w, h)
			if my then
				surface.SetDrawColor(0, 215, 40)
			else
				surface.SetDrawColor(76, 147, 87)
			end

			surface.DrawRect(my and w + 8 or -10, -5, 2, h + 10)
		end
	end
end

App.init = function(window)
	local shadowedText = iPhone.apps['deepweb'].shadowedText

	local back = vgui.Create('DButton', window)
	back:SetPos(8, 26)
	back:SetSize(42, 42)
	function back:Paint(w, h)
		iPhone.cursorUpdate(self)
		if self.Hovered then
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawRect(0, 0, w, h)
		end
		
		return true
	end
	function back:DoClick()
		iPhone.appSwitch(window, iPhone.apps['deepweb'])
	end

	local scroll = iPhone.apps['contacts'].spawnScroll(window, true)
	scroll.pnlCanvas:DockPadding(0, 0, 0, 32)
	scroll:SetPos(0, 95)
	scroll:SetSize(window:GetWide(), window:GetTall() - 180)

	local ava = vgui.Create("AvatarImage", window)
	ava:SetSize(50, 50)
	ava:SetPos(window:GetWide()/2 - 24, 8)
	ava:SetPaintedManually(true)
	ava:SetPlayer(iPhone.playerDeepMessaging, 64)

	local bgMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/deep_background.png', function(mat)
		bgMat = mat
	end)

	function window:Paint(w, h)
		if bgMat then
			if IsValid(ava) then ava:PaintManual() end

			surface.SetMaterial(bgMat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, -28, w, h+28)

			shadowedText(LocalPlayer():GetName(), 'iphone_deepweb_name', w/2, 66, TEXT_ALIGN_CENTER)
		end
	end

	-- nickname

	local messages = iPhone.deepweb_messages[isstring(iPhone.playerDeepMessaging) and iPhone.playerDeepMessaging or iPhone.getNumber(iPhone.playerDeepMessaging)]
	
	if messages then
		for _, msg in ipairs(messages) do
			addMessage(scroll, msg.text, msg.my)
		end
	end

	iPhone.newDeepMessage = function(text) -- bad
		addMessage(scroll, text)
	end

	local input = vgui.Create('DButton', window)
	input:SetPos(32, window:GetTall() - 64)
	input:SetSize(350-64, 32)

	function input:Paint(w, h)
		iPhone.cursorUpdate(self)
		local offline = isstring(iPhone.playerDeepMessaging) or not IsValid(iPhone.playerDeepMessaging)

		draw.RoundedBox(16, 0, 0, w, h, Color(0, 111, 16))
		draw.RoundedBox(12, 2, 2, w - 4, h - 4, Color(0, (self.Hovered or offline) and 64 or 0, 0))

		render.ClearStencil()
		render.SetStencilEnable(true)

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)

		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilReferenceValue(1)

			surface.DrawRect(2, 2, w - 4, h - 4)

		render.SetStencilFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilReferenceValue(1);

		local text 
		if offline then
			text = 'OFFLINE'
		else
			text = IsValid(self.textEntry) and self.textEntry:GetValue() or 'Message'
		end

		surface.SetFont('iphone_search')
		local tw = surface.GetTextSize(text)
		if tw > w-20 then
			draw.SimpleText(text, 'iphone_search', w - 4, 4, Color(0, 111, 16), TEXT_ALIGN_RIGHT)
		else
			draw.SimpleText(text, 'iphone_search', 16, 4, Color(0, 111, 16))
		end

		render.SetStencilEnable(false)
		render.ClearStencil()

		return true
	end

	function input:DoClick()
		if isstring(iPhone.playerDeepMessaging) or not IsValid(iPhone.playerDeepMessaging) then
			return 
		end

		local entry = vgui.Create('DTextEntry')
		entry:SetSize(ScrW(), ScrH())
		entry:MakePopup()
		entry:SetAlpha(0)
		entry:SetUpdateOnType(true)
		
		entry.OnEnter = function(self)
			if isstring(iPhone.playerDeepMessaging) or not IsValid(iPhone.playerDeepMessaging) then
				return 
			end

			local msg = {text = utf8.sub(self:GetValue(), 0, 128), my = true}
			
			if not messages then
				messages = {}
				iPhone.deepweb_messages[iPhone.getNumber(iPhone.playerDeepMessaging)] = messages
			end

			table.insert(messages, msg)
			messages.last = os.time()
			addMessage(scroll, self:GetValue(), true)
			iPhone.saveMessages()

			net.Start('iPhone')
				net.WriteString('deepmsg')
				net.WriteEntity(iPhone.playerDeepMessaging)
				net.WriteString(msg.text)
			net.SendToServer()
		end

		entry.OnLoseFocus = function()
			entry:Remove()
			self.textEntry = nil
		end
		entry.OnMousePressed = entry.OnLoseFocus
		self.textEntry = entry
	end
end