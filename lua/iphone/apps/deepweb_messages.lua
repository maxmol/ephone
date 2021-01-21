App.name = 'Messages'
App.bgColor = color_black

App.init = function(window)
	local shadowedText = iPhone.apps['deepweb'].shadowedText

	local bgMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/deep_messagebackground.png', function(mat)
		bgMat = mat
	end)

	function window:Paint(w, h)
		if bgMat then
			if IsValid(ava) then ava:PaintManual() end

			surface.SetMaterial(bgMat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, -28, w, h+28)
		end
	end

	local scroll = iPhone.apps['contacts'].base(window, true, function(self, w, h)
		iPhone.cursorUpdate(self)
		if self.Hovered then
			draw.RoundedBox(16, 1, 5, w - 2, h - 2, Color(255, 255, 255, 10))
		end

		draw.SimpleText(IsValid(self.textEntry) and self.textEntry:GetValue() or 'Rechercher', 'iphone_deepweb_status', 38, 14, Color(76, 147, 87))

		return true
	end)

	local plus = vgui.Create('DButton', window)
	plus:SetPos(298, 2)
	plus:SetSize(32, 32)
	function plus:Paint(w, h)
		iPhone.cursorUpdate(self)
		if self.Hovered then
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawRect(0, 0, w, h)
		end
			
		return true
	end
	function plus:DoClick()
		iPhone.appSwitch(window, iPhone.apps['deepweb'])
	end

	local bPaint = function(self, w, h)
		iPhone.cursorUpdate(self)
		surface.SetDrawColor(0, 32, 4)
		surface.DrawRect(0, h-2, w, 2)
		
		shadowedText(self.name, 'iphone_deepweb_title', 104, 12)
			
		return true
	end

	local bPaintOver = function(self, w, h)
		if self.Hovered then
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawRect(0, 0, w, h-2)
		end
	end

	local ids = table.GetKeys(iPhone.deepweb_messages)
	table.sort(ids, function(a, b) return iPhone.deepweb_messages[a].last > iPhone.deepweb_messages[b].last end)

	window.contactButtons = {}
	for i, id in ipairs(ids) do
		ply = iPhone.getPlayerByNumber(id)
		--if ply == LocalPlayer() then continue end

		local b = vgui.Create('DButton', scroll)
		b:SetSize(0, 90)
		b:Dock(TOP)
		b.Paint = bPaint
		b.PaintOver = bPaintOver
		b.ply = ply
		b.id = id
		b.name = ply and ply:GetName() or id
		table.insert(window.contactButtons, b)

		local ava = vgui.Create("AvatarImage", b)
		ava:SetSize(64, 64)
		ava:SetPos(20, 13)
		if ply then ava:SetPlayer(ply, 64) end
		iPhone.circularInit(ava, true)
		b.ava = ava

		function b:DoClick()
			iPhone.playerDeepMessaging = IsValid(self.ply) and self.ply or self.id
			iPhone.appSwitch(window, iPhone.apps['deepweb_chat'])
		end

		local l = vgui.Create('DLabel', b)
		l:SetSize(220, 60)
		l:SetPos(104, 28)
		local msgs = iPhone.deepweb_messages[id]
		l:SetText(msgs[#msgs].text)
		l:SetFont('iphone_deepweb_normal')
		l:SetColor(Color(76, 147, 87))
	end
end