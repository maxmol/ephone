local L = include('iphone/translation.lua')

App.name = L'recents'
App.icon = 'call_appli_icon'
App.pos_x = 25
App.pos_y = 628
App.bgColor = color_white

local createSwitch = function(parent, x, y, offText, onText, callback)
	local bOff, bOn
	local p = vgui.Create('Panel', parent)
	p:SetPos(x, y)
	p:SetSize(220, 32)
	p.selectPos = 0
	p.on = false
	function p:Paint(w, h)
		draw.RoundedBox(12, 0, 0, w, h, (bOff.Hovered or bOn.Hovered) and Color(225, 225, 225) or Color(238, 238, 240))

		self.selectPos = Lerp(FrameTime() * 10, self.selectPos, self.on and w/2 or 0)
		draw.RoundedBox(10, 3 + self.selectPos, 3, w/2 - 6, h - 6, color_white)
	end
	
	bOff = vgui.Create('DButton', p)
	bOff:SetPos(0, 0)
	bOff:SetSize(110, 32)
	function bOff:Paint(w, h)
		iPhone.cursorUpdate(self)
		draw.SimpleText(offText, 'iphone_search', w/2, h/2, Color(16, 16, 16), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return true
	end
	function bOff:DoClick()
		p.on = false
		callback(false)
	end

	bOn = vgui.Create('DButton', p)
	bOn:SetPos(110, 0)
	bOn:SetSize(110, 32)
	function bOn:Paint(w, h)
		iPhone.cursorUpdate(self)
		draw.SimpleText(onText, 'iphone_search', w/2, h/2, Color(16, 16, 16), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return true
	end
	function bOn:DoClick()
		p.on = true
		callback(true)
	end
end

App.createSwitch = createSwitch

App.init = function(window)
	local scroll = iPhone.apps['contacts'].spawnScroll(window)

	local bPaint = function(self, w, h)
		iPhone.cursorUpdate(self)
		surface.SetDrawColor(229, 229, 229)
		surface.DrawRect(16, h-3, w - 32, 3)

		if self.Hovered then
			surface.SetDrawColor(240, 240, 240)
			surface.DrawRect(0, 0, w, h-3)
		end

		draw.SimpleText(self.text, 'iphone_contact_bold', 24, 19, self.missed and Color(210, 16, 16) or Color(16, 16, 16))
		draw.SimpleText(self.when, 'iphone_call', w - 24, 21, Color(96, 96, 96), TEXT_ALIGN_RIGHT)
		
		return true
	end

	local ids = table.GetKeys(iPhone.call_history)
	table.sort(ids, function(a, b) return iPhone.call_history[a].time > iPhone.call_history[b].time end)

	window.contactButtons = {}
	for i, id in ipairs(ids) do
		local ply = iPhone.getPlayerByNumber(id)
		--if ply == LocalPlayer() then continue end

		local b = vgui.Create('DButton', scroll)
		b:SetSize(0, 70)
		b:Dock(TOP)
		b.Paint = bPaint
		b.ply = ply
		b.id = id
		b.text = ply and ply:GetName() or id
		if utf8.len(b.text) > 12 then
			b.text = utf8.sub(b.text, 1, 13) .. '...'
		end
		b.hoverColor = Color(240, 240, 240)
		b.missed = iPhone.call_history[id].missed
		b.when = string.upper(os.date('%I:%M %p', iPhone.call_history[id].time))
		table.insert(window.contactButtons, b)

		function b:DoClick()
			iPhone.call(self.id)
		end
	end

	createSwitch(window, iPhone.width/2 - 105, 80, L'all', L'missed', function(missed)
		for _, btn in ipairs(window.contactButtons) do
			if missed and (not iPhone.call_history[btn.id] or not iPhone.call_history[btn.id].missed) then
				btn:Hide()
			else
				btn:Show()
			end
		end
		
		scroll.pnlCanvas:InvalidateLayout()
		scroll:InvalidateLayout()
	end)

	iPhone.apps['contacts'].createBottomButtons(window, 1)
end