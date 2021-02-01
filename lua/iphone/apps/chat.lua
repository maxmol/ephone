local L = include('iphone/translation.lua')

local addMessage = function(scroll, text, my)
	if IsValid(scroll) then
		local l = vgui.Create('DLabel', scroll)
		l:SetSize(220, 32)
		l:SetText(text)
		l:SetFont('iphone_contact')
		local tw, th = l:GetTextSize()
		local indent = math.max(82, 330 - (tw + 24))
		l:DockMargin(my and indent or 24, 24, my and 24 or indent, 0)
		l:SetWrap(true)
		l:SetAutoStretchVertical(true)
		l:Dock(TOP)
		l:SetColor(my and color_white or Color(16, 16, 16))

		function l:Paint(w, h)
			draw.RoundedBox(16, -10, -5, w + 20, h + 10, my and Color(61, 179, 252, 240) or Color(230, 231, 235))
		end

		timer.Create('iPhone_chatScrollToBottom', 0.1, 1, function()
			scroll.VBar:SetScroll(scroll.VBar.CanvasSize)
		end)
	end
end

App.init = function(window)
	local name = vgui.Create('DLabel', window)
	name:SetText(isstring(iPhone.playerMessaging) and iPhone.playerMessaging or iPhone.playerMessaging:GetName())
	name:SetFont('iphone_contact_bold')
	local tw, th = name:GetTextSize()
	name:SetSize(math.min(tw, 320), th)
	name:SetPos(window:GetWide()/2 - name:GetWide()/2, 90)
	name:SetColor(Color(16, 16, 16))

	local backMat
	iPhone.loadMaterial('materials/elysion/iphone/back_smsicon.png', function(mat)
		backMat = mat
	end)

	local back = vgui.Create('DButton', window)
	back:SetPos(12, 20)
	back:SetSize(42, 43)
	function back:Paint(w, h)
		iPhone.cursorUpdate(self)
		if backMat then
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.SetMaterial(backMat)
			surface.DrawTexturedRect(0, 0, w, h)
			
			return true
		end
	end
	function back:DoClick()
		iPhone.appSwitch(window, iPhone.apps['messages'])
	end

	local scroll = iPhone.apps['contacts'].spawnScroll(window)
	scroll.pnlCanvas:DockPadding(0, 0, 0, 32)

	local ava
	
	if not isstring(iPhone.playerMessaging) then
		ava = vgui.Create('AvatarImage', window)
		ava:SetPlayer(iPhone.playerMessaging, 64)
		ava.circleColor = Color(245, 245, 245)
		iPhone.circularInit(ava)
	/*elseif iPhone.playerMessaging == 'Sergay' then
		local sergay
		iPhone.loadMaterial('materials/elysion/iphone/sergay.png', function(mat)
			sergay = mat
		end)

		ava = vgui.Create('Panel', window)
		ava.Paint = function(self, w, h)
			if sergay then
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(sergay)
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end*/
	end

	if ava then
		ava:SetSize(64, 64)
		ava:SetPos(window:GetWide()/2 - 32, 20)
	end

	-- nickname

	local messages = iPhone.messages[isstring(iPhone.playerMessaging) and iPhone.playerMessaging or iPhone.getNumber(iPhone.playerMessaging)]
	
	if messages then
		for _, msg in ipairs(messages) do
			addMessage(scroll, msg.text, msg.my)
		end
	end

	iPhone.newMessage = function(text) -- bad
		addMessage(scroll, text)
	end

	local input = vgui.Create('DButton', window)
	input:SetPos(32, window:GetTall() - 64)
	input:SetSize(350-64, 32)

	function input:Paint(w, h)
		iPhone.cursorUpdate(self)
		local offline = isstring(iPhone.playerMessaging) or not IsValid(iPhone.playerMessaging)

		draw.RoundedBox(16, 0, 0, w, h, Color(175, 175, 190))
		draw.RoundedBox(12, 2, 2, w - 4, h - 4, Color(255, 255, 255, (self.Hovered or offline) and 170 or 255))

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
			text = L'offline'
		else
			text = IsValid(self.textEntry) and self.textEntry:GetValue() or L'message'
		end

		surface.SetFont('iphone_search')
		local tw = surface.GetTextSize(text)
		if tw > w-20 then
			draw.SimpleText(text, 'iphone_search', w - 4, 4, Color(175, 175, 190), TEXT_ALIGN_RIGHT)
		else
			draw.SimpleText(text, 'iphone_search', 16, 4, Color(175, 175, 190))
		end

		render.SetStencilEnable(false)
		render.ClearStencil()

		return true
	end

	function input:DoClick()
		if isstring(iPhone.playerMessaging) or not IsValid(iPhone.playerMessaging) then
			return 
		end

		local entry = vgui.Create('DTextEntry')
		entry:SetSize(ScrW(), ScrH())
		entry:MakePopup()
		entry:SetAlpha(0)
		entry:SetUpdateOnType(true)
		
		entry.OnEnter = function(self)
			if isstring(iPhone.playerMessaging) or not IsValid(iPhone.playerMessaging) then
				return 
			end

			local msg = {text = utf8.sub(self:GetValue(), 0, 128), my = true}
			
			if not messages then
				messages = {}
				iPhone.messages[iPhone.getNumber(iPhone.playerMessaging)] = messages
			end

			table.insert(messages, msg)
			messages.last = os.time()
			addMessage(scroll, self:GetValue(), true)
			iPhone.saveMessages()

			net.Start('iPhone')
				net.WriteString('msg')
				net.WriteEntity(iPhone.playerMessaging)
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