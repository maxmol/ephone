local L = include('iphone/translation.lua')

App.init = function(window, contact, ply)
	local bgMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/background_last.png', function(mat)
		bgMat = mat
	end)

	local ava = vgui.Create('AvatarImage', window)
	ava:SetSize(140, 140)
	ava:SetPos(window:GetWide()/2 - 70, 60)
	ava:SetPlayer(ply or NULL, 128)
	ava:SetPaintedManually(true)

	local save = vgui.Create('DButton', window)
	save:SetSize(43, 20)
	save:SetPos(303, 42 - 28)
	function save:Paint(w, h)
		iPhone.cursorUpdate(self)

		if self.Hovered then
			surface.SetDrawColor(0, 0, 0, 20)
			surface.DrawRect(0, 0, w, h)
		end

		return true
	end

	function save:DoClick()
		contact.num = contact.num:Replace(' ', '')
		table.insert(iPhone.contacts, contact)
		iPhone.saveContacts()

		iPhone.appSwitch(window, iPhone.apps['contacts'])
	end

	local addNumber = vgui.Create('DButton', window)
	addNumber:SetSize(350, 42)
	addNumber:SetPos(0, 399 - 28)
	function addNumber:Paint(w, h)
		iPhone.cursorUpdate(self)

		if self.Hovered then
			surface.SetDrawColor(0, 0, 0, 20)
			surface.DrawRect(0, 0, w, h)
		end

		return true
	end

	addNumber.DoClick = save.DoClick

	local cancel = vgui.Create('DButton', window)
	cancel:SetSize(70, 23)
	cancel:SetPos(9, 42  - 28)
	function cancel:Paint(w, h)
		iPhone.cursorUpdate(self)

		if self.Hovered then
			surface.SetDrawColor(0, 0, 0, 20)
			surface.DrawRect(0, 0, w, h)
		end

		return true
	end

	function cancel:DoClick()
		iPhone.appSwitch(window, iPhone.apps['digits'])
	end

	window.Paint = function(self, w, h)
		if bgMat then
			if IsValid(ava) then ava:PaintManual() end
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(bgMat)
			surface.DrawTexturedRect(0, -28, w, h + 28)
		end
	end

	local name = vgui.Create('DButton', window)
	name:SetPos(0, 266 - 28)
	name:SetSize(350, 42)
	name.text = contact.name or L'name'

	function name:Paint(w, h)
		iPhone.cursorUpdate(self)

		if self.Hovered then
			surface.SetDrawColor(0, 0, 0, 20)
			surface.DrawRect(0, 0, w, h)
		end

		text = IsValid(self.textEntry) and self.textEntry:GetValue() or self.text

		draw.SimpleText(text, 'iphone_search', 32, 6, Color(64, 64, 64))

		return true
	end

	function name:DoClick()
		local entry = vgui.Create('DTextEntry')
		entry:SetSize(ScrW(), ScrH())
		entry:MakePopup()
		entry:SetAlpha(0)
		entry:SetUpdateOnType(true)
		entry:SetValue(self.text)
		entry.OnEnter = function(self)
			local text = utf8.sub(self:GetValue(), 0, 30)
			name.text = text
			contact.name = text
		end

		entry.OnLoseFocus = function(self)
			local text = utf8.sub(self:GetValue(), 0, 30)
			name.text = text
			contact.name = text
			entry:Remove()
			self.textEntry = nil
		end
		entry.OnMousePressed = entry.OnLoseFocus
		self.textEntry = entry
	end

	local number = vgui.Create('DButton', window)
	number:SetPos(0, 311 - 28)
	number:SetSize(350, 42)
	number.text = contact.num or L'number'

	function number:Paint(w, h)
		iPhone.cursorUpdate(self)

		if self.Hovered then
			surface.SetDrawColor(0, 0, 0, 20)
			surface.DrawRect(0, 0, w, h)
		end

		text = IsValid(self.textEntry) and self.textEntry:GetValue() or self.text

		draw.SimpleText(text, 'iphone_search', 32, 6, Color(64, 64, 64))

		return true
	end

	function number:DoClick()
		local entry = vgui.Create('DTextEntry')
		entry:SetSize(ScrW(), ScrH())
		entry:MakePopup()
		entry:SetAlpha(0)
		entry:SetUpdateOnType(true)
		entry:SetValue(number.text)
		
		entry.OnEnter = function(self)
			local text = utf8.sub(self:GetValue(), 0, 30)
			number.text = text
			contact.num = text
		end

		entry.OnLoseFocus = function(self)
			local text = utf8.sub(self:GetValue(), 0, 30)
			number.text = text
			contact.num = text
			entry:Remove()
			self.textEntry = nil
		end
		entry.OnMousePressed = entry.OnLoseFocus
		self.textEntry = entry
	end
end