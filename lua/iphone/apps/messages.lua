App.name = 'Messages'
App.icon = 'sms_appli_icon'
App.pos_x = 175
App.pos_y = 628

App.init = function(window)
	local scroll = iPhone.apps['contacts'].base(window)

	local plusMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/addconstact_icon.png', function(mat)
		plusMat = mat
	end)

	local plus = vgui.Create('DButton', window)
	plus:SetPos(300, 4)
	plus:SetSize(42, 43)
	function plus:Paint(w, h)
		iPhone.cursorUpdate(self)
		if plusMat then
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.SetMaterial(plusMat)
			surface.DrawTexturedRect(0, 0, w, h)
			
			return true
		end
	end
	function plus:DoClick()
		iPhone.appSwitch(window, iPhone.apps['contacts'])
	end

	local bPaint = function(self, w, h)
		iPhone.cursorUpdate(self)
		surface.SetDrawColor(229, 229, 229)
		surface.DrawRect(0, h-4, w, 4)

		if self.Hovered then
			surface.SetDrawColor(self.hoverColor)
			surface.DrawRect(0, 0, w, h-4)
			if self.ava then self.ava.circleColor = self.hoverColor end
		else
			if self.ava then self.ava.circleColor = color_white end
		end
		
		draw.SimpleText(self.name, 'iphone_contact_bold', 104, 12, Color(16, 16, 16))
			
		return true
	end

	local ids = table.GetKeys(iPhone.messages)
	table.sort(ids, function(a, b) return iPhone.messages[a].last > iPhone.messages[b].last end)

	window.contactButtons = {}
	for i, id in ipairs(ids) do
		ply = iPhone.getPlayerByNumber(id)
		--if ply == LocalPlayer() then continue end

		local b = vgui.Create('DButton', scroll)
		b:SetSize(0, 90)
		b:Dock(TOP)
		b.Paint = bPaint
		b.ply = ply
		b.id = id
		local contactNum = string.Replace(id, ' ', '')
		b.name = ply and ply:GetName() or (iPhone.contacts[contactNum] and iPhone.contacts[contactNum].name or id)
		b.hoverColor = Color(240, 240, 240)
		table.insert(window.contactButtons, b)

		local ava
		if ply then 
			ava = vgui.Create('AvatarImage', b)
			ava:SetPlayer(ply, 64)
			iPhone.circularInit(ava)
			b.ava = ava
		elseif id == 'Sergay' then
			local sergay
			ImgLoader.LoadMaterial('materials/elysion/iphone/sergay.png', function(mat)
				sergay = mat
			end)

			ava = vgui.Create('Panel', b)
			ava.Paint = function(self, w, h)
				if sergay then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(sergay)
					surface.DrawTexturedRect(0, 0, w, h)
				end
			end
		end

		if ava then
			ava:SetSize(64, 64)
			ava:SetPos(20, 13)
		end

		function b:DoClick()
			iPhone.playerMessaging = IsValid(self.ply) and self.ply or self.id
			iPhone.appSwitch(window, iPhone.apps['chat'])
		end

		local l = vgui.Create('DLabel', b)
		l:SetSize(220, 60)
		l:SetPos(104, 28)
		local msgs = iPhone.messages[id]
		l:SetText(msgs[#msgs].text)
		l:SetFont('iphone_time')
		l:SetColor(Color(175, 175, 190))
	end
end