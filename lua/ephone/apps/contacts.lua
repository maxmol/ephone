local L = include('ephone/translation.lua')

App.name = L'contacts'
App.icon = 'contact_appli_icon'
App.pos_x = 216
App.pos_y = 630

local spawnScroll = function(window, noBackground, yPos, bottomMargin)
	local scroll = vgui.Create('DScrollPanel', window)
	scroll:SetPos(0, yPos or 128)
	scroll:SetSize(window:GetWide(), window:GetTall() - (yPos and yPos + (bottomMargin or 50) or 210))
	function scroll:Paint(w, h)
		iPhone.cursorUpdate(self)

		if not noBackground then
			surface.SetDrawColor(229, 229, 229)
			surface.DrawRect(0, 0, w, 4)
			surface.DrawRect(0, h-4, w, 4)
		end

		render.ClearStencil()
		render.SetStencilEnable(true)

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)

		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilReferenceValue(1)

			surface.SetDrawColor(255, 255, 255)
			surface.DrawRect(0, 4, w, h - 8)

		render.SetStencilFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilReferenceValue(1);

			if not noBackground then
				surface.DrawRect(0, 0, w, h)
			end
	end

	function scroll:PaintOver()
		render.SetStencilEnable(false)
		render.ClearStencil()
	end

	local sbar = scroll:GetVBar()
	function sbar:Paint(w, h) end
	function sbar.btnUp:Paint(w, h) end
	function sbar.btnDown:Paint(w, h) end

	function sbar.btnGrip:Paint(w, h)
		iPhone.cursorUpdate(self)
		draw.RoundedBox(4, 4, 0, 7, h, self.Hovered and Color(64, 64, 64) or Color(64, 64, 64, 200))
	end

	return scroll
end
App.spawnScroll = spawnScroll

local base = function(window, noBackground, searchPaint)
	local search = vgui.Create('DButton', window)
	search:SetPos(16, 74)
	search:SetSize(350-32, 42)

	local searchIcon
	iPhone.loadMaterial('materials/elysion/iphone/recherche_messageicon.png', function(mat)
		searchIcon = mat
	end)

	search.Paint = searchPaint or function(self, w, h)
		iPhone.cursorUpdate(self)
		draw.RoundedBox(12, 0, 0, w, h, Color(227, 227, 227, self.Hovered and 170 or 255))
		if searchIcon then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(searchIcon)
			surface.DrawTexturedRect(0, 0, 42, 43)
		end

		draw.SimpleText(IsValid(self.textEntry) and self.textEntry:GetValue() or L'search', 'iphone_search', 38, 8, Color(175, 175, 190))

		return true
	end

	local scroll = spawnScroll(window, noBackground)
	function search:DoClick()
		if not IsValid(iPhone.panel2d) then return end

		local entry = vgui.Create('DTextEntry', iPhone.panel2d)
		entry:SetSize(ScrW(), ScrH())
		entry:MakePopup()
		entry:SetAlpha(0)
		entry:SetUpdateOnType(true)
		entry.OnEnter = function()
			-- search
			entry:Remove()
			self.textEntry = nil
		end

		entry.OnLoseFocus = entry.OnEnter
		entry.OnMousePressed = entry.OnEnter

		entry.OnValueChange = function(entry, str)
			for _, btn in ipairs(window.contactButtons) do
				if btn.name then
					if string.find(btn.name, str) then
						btn:Show()
					else
						btn:Hide()
					end
				end
			end
			
			scroll.pnlCanvas:InvalidateLayout()
			scroll:InvalidateLayout()
		end

		entry:OnValueChange('')

		self.textEntry = entry
	end

	return scroll
end
App.base = base

local createBottomButtons = function(window, current)
	local recents = vgui.Create('DButton', window)

	iPhone.loadMaterial('materials/elysion/iphone/recent_numbericon unused.png', function(mat)
		recents.mat = mat
	end)
	iPhone.loadMaterial('materials/elysion/iphone/recent_numbericon used.png', function(mat)
		recents.matActive = mat
	end)

	recents:SetPos(50, window:GetTall() - 82)
	recents:SetSize(62, 50)
	recents.text = L'recents'
	recents.num = 1
	function recents:Paint(w, h)
		if not self.mat then return end

		iPhone.cursorUpdate(self)

		surface.SetDrawColor(255, 255, 255)
		local active = current == self.num or self.Hovered
		surface.SetMaterial(active and self.matActive or self.mat)
		surface.DrawTexturedRect(10, 0, 42, 43)
		
		draw.SimpleText(self.text, 'iphone_time', w/2, 38, active and Color(62, 134, 255) or Color(184, 184, 184), TEXT_ALIGN_CENTER)
		return true
	end

	if current ~= 1 then
		function recents:DoClick()
			iPhone.appSwitch(window, iPhone.apps['recents'])
		end
	end

	--

	local contacts = vgui.Create('DButton', window)

	iPhone.loadMaterial('materials/elysion/iphone/contacts_numbericon unused.png', function(mat)
		contacts.mat = mat
	end)
	iPhone.loadMaterial('materials/elysion/iphone/contacts_numbericon used.png', function(mat)
		contacts.matActive = mat
	end)

	contacts:SetPos(144, window:GetTall() - 82)
	contacts:SetSize(62, 50)
	contacts.text = L'contacts'
	contacts.num = 2
	contacts.Paint = recents.Paint

	if current ~= 2 then
		function contacts:DoClick()
			iPhone.appSwitch(window, iPhone.apps['contacts'])
		end
	end

	--

	local keys = vgui.Create('DButton', window)

	iPhone.loadMaterial('materials/elysion/iphone/clavier_numbericon unused.png', function(mat)
		if IsValid(keys) then
			keys.mat = mat
		end
	end)
	iPhone.loadMaterial('materials/elysion/iphone/clavier_numbericon used.png', function(mat)
		if IsValid(keys) then
			keys.matActive = mat
		end
	end)

	keys:SetPos(238, window:GetTall() - 82)
	keys:SetSize(62, 50)
	keys.text = L'dial'
	keys.num = 3
	keys.Paint = recents.Paint

	if current ~= 3 then
		function keys:DoClick()
			iPhone.appSwitch(window, iPhone.apps['digits'])
		end
	end
end

App.createBottomButtons = createBottomButtons

App.init = function(window)
	local scroll = base(window)

	local bPaint = function(self, w, h)
		iPhone.cursorUpdate(self)
		surface.SetDrawColor(229, 229, 229)
		surface.DrawRect(16, h-4, w - 32, 4)

		if self.Hovered then
			surface.SetDrawColor(240, 240, 240)
			surface.DrawRect(0, 0, w, h-4)
		end

		self.open = Lerp(FrameTime() * 5, self.open, self.opened and (self.rem and 220 or 160) or 0)
		
		draw.SimpleText(self.name or self.num, 'iphone_contact', 24 + self.open, 8, Color(16, 16, 16))

		draw.RoundedBox(8, self.open - 68, 10, 64, h - 20, self.call.Hovered and Color(96, 200, 96) or Color(64, 160, 64))
		draw.SimpleText(L'call', 'iphone_search', self.open - 36, 12, Color(240, 240, 240), TEXT_ALIGN_CENTER)

		draw.RoundedBox(8, self.open - 140, 10, 64, h - 20, self.sms.Hovered and Color(240, 170, 64) or Color(200, 140, 32))
		draw.SimpleText('SMS', 'iphone_search', self.open - 108, 12, Color(240, 240, 240), TEXT_ALIGN_CENTER)

		if self.rem then
			draw.RoundedBox(8, self.open - 212, 10, 64, h - 20, self.rem.Hovered and Color(240, 96, 96) or Color(200, 64, 64))
			draw.SimpleText(L'delete', 'iphone_search', self.open - 180, 12, Color(240, 240, 240), TEXT_ALIGN_CENTER)
		end

		return true
	end
	
	local my = vgui.Create('Panel', scroll)
	my:SetSize(0, 124)
	my:Dock(TOP)

	local ava = vgui.Create("AvatarImage", my)
	ava:SetSize(64, 64)
	ava:SetPos(20, 24)
	ava:SetPlayer(LocalPlayer(), 64)
	iPhone.circularInit(ava)
	
	function my:Paint(w, h)
		draw.SimpleText(LocalPlayer():GetName(), 'iphone_contact_bold', 104, 24, Color(16, 16, 16))
		draw.SimpleText(iPhone.getNumber(LocalPlayer()), 'iphone_search', 104, 55, Color(184, 184, 184))
	end

	local getFirstLetterCode = function(str)
		local code = string.byte(str, 1)
		if code >= 97 and code <= 122 then
			return code - 32
		end

		return code
	end

	local contactsTable = table.Copy(iPhone.contacts)
	if iphone_config.show_online_players_in_contacts then
		for _, p in ipairs(player.GetAll()) do
			if p ~= LocalPlayer() then
				table.insert(contactsTable, {
					name = p:GetName(),
					num = iPhone.getNumber(p),
					isPlayer = true
				})
			end
		end
	end

	table.sort(contactsTable, function(a, b)
		if not a.name or not b.name then
			return false
		end

		if a.isPlayer and not b.isPlayer then
			return false
		elseif not a.isPlayer and b.isPlayer then
			return true
		end

		a = getFirstLetterCode(a.name)
		b = getFirstLetterCode(b.name)

		return a > b
	end)

	local lastIsPlayer = false
	local lastOpened
	window.contactButtons = {}
	local letterCode
	for i, contact in ipairs(contactsTable) do
		if not lastIsPlayer and contact.isPlayer then
			local spacer = vgui.Create('Panel', scroll)
			spacer:SetSize(0, 74)
			spacer:Dock(TOP)
			function spacer:Paint(w, h)
				draw.SimpleText(L'online_players', 'iphone_contact_bold', w / 2, 32, Color(16, 16, 16), TEXT_ALIGN_CENTER)
			end

			letterCode = nil
		end

		lastIsPlayer = contact.isPlayer

		local ply = iPhone.getPlayerByNumber(contact.num)
		if ply then
			contact.name = contact.name or ply:GetName()
		end
		--if ply == LocalPlayer() then continue end

		local currentLetterCode = getFirstLetterCode(contact.name or ' ')
		if letterCode != currentLetterCode then
			letterCode = currentLetterCode

			local letter = vgui.Create('Panel', scroll)
			letter:SetSize(0, 34)
			letter:Dock(TOP)
			function letter:Paint(w, h)
				surface.SetDrawColor(229, 229, 229)
				surface.DrawRect(0, 0, w, h)

				draw.SimpleText(string.char(currentLetterCode), 'iphone_contact_bold', 24, 0, Color(16, 16, 16))
			end
		end

		local canRemove = not contact.isPlayer

		local b = vgui.Create('DButton', scroll)
		b:SetSize(0, 52)
		b:Dock(TOP)
		b.Paint = bPaint
		b.ply = ply
		b.num = contact.num
		b.name = contact.name
		b.open = 0
		table.insert(window.contactButtons, b)

		function b:DoClick()
			self.opened = not self.opened
			self.sms:SetVisible(self.opened)
			self.call:SetVisible(self.opened)

			if canRemove then
				self.rem:SetVisible(self.opened)
			end

			if lastOpened then
				lastOpened.opened = false
				lastOpened.sms:SetVisible(false)
				lastOpened.call:SetVisible(false)
				if canRemove then
					lastOpened.rem:SetVisible(false)
				end
				lastOpened = nil
			end

			if self.opened then
				lastOpened = self
			end
		end

		local call = vgui.Create('DButton', b)
		call:SetSize(72, 52)
		call:SetPos(canRemove and 172 or 92, 0)
		call:SetVisible(false)
		call.Paint = function(self)
			iPhone.cursorUpdate(self)
			return true
		end
		b.call = call

		function call:DoClick()
			iPhone.call(contact.num)
		end

		local sms = vgui.Create('DButton', b)
		sms:SetSize(72, 52)
		sms:SetPos(canRemove and 100 or 20, 0)
		sms:SetVisible(false)
		sms.Paint = call.Paint
		b.sms = sms

		function sms:DoClick()
			iPhone.playerMessaging = ply or contact.num
			iPhone.appSwitch(window, iPhone.apps['chat'])
		end

		if canRemove then
			local rem = vgui.Create('DButton', b)
			rem:SetSize(100, 52)
			rem:SetPos(0, 0)
			rem:SetVisible(false)
			rem.Paint = call.Paint
			b.rem = rem

			function rem:DoClick()
				table.remove(iPhone.contacts, i)
				iPhone.saveContacts()
				iPhone.appSwitch(window, iPhone.apps['contacts'])
			end
		end
	end

	createBottomButtons(window, 2)
end