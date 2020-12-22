local config = {
	{
		name = 'Tueur à gages',
		team = '*VIP* Tueur à gages',
		desc = [[Prenez contact avec les meilleurs tueurs à gages.]],
	},
	{
		name = 'Hackeurs',
		team = '*VIP* Hackeurs',
		desc = [[Besoin de s'introduire dans un serveur ? Vous êtes au bon endroit.]],
	},
	{
		name = 'Mercenaires',
		team = '*VIP* Mercenaire',
		desc = [[Prennez contact avec un Mercenaire pour votre protection.]],
	},
}

surface.CreateFont('iphone_deepweb_name', {
	font = 'Bad Signal',
	size = 20,
})

surface.CreateFont('iphone_deepweb_title', {
	font = 'Fira Code',
	size = 32,
})

surface.CreateFont('iphone_deepweb_normal', {
	font = 'Fira Code',
	size = 23,
})

surface.CreateFont('iphone_deepweb_status', {
	font = 'Fira Code',
	size = 24,
})

local shadowedText = function(text, font, x, y, align_horiz, align_vertical)
	draw.SimpleTextOutlined(text, font, x, y, Color(0, 215, 40), align_horiz, align_vertical, 6, Color(150, 255, 150, 2))
	draw.SimpleTextOutlined(text, font, x, y, Color(0, 215, 40), align_horiz, align_vertical, 4, Color(150, 255, 150, 5))
end

App.shadowedText = shadowedText

App.name = 'DeepWeb'
App.icon = 'deepweb_icon'
App.pos_x = 178
App.pos_y = 80
App.bgColor = color_black

App.init = function(window)
	local scroll = iPhone.apps['contacts'].spawnScroll(window, true)
	scroll:SetPos(0, 95)
	scroll:SetSize(window:GetWide(), window:GetTall() - 140)

	local ava = vgui.Create("AvatarImage", window)
	ava:SetSize(50, 50)
	ava:SetPos(window:GetWide()/2 - 24, 8)
	ava:SetPlayer(LocalPlayer(), 64)
	ava:SetPaintedManually(true)
	
	local msgsIcon
	ImgLoader.LoadMaterial('materials/elysion/iphone/message_deepcallicon.png', function(mat)
		msgsIcon = mat
	end)
	local msgs = vgui.Create('DButton', window)
	msgs:SetPos(300, 4)
	msgs:SetSize(42, 43)
	function msgs:Paint(w, h)
		iPhone.cursorUpdate(self)
		if msgsIcon then
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.SetMaterial(msgsIcon)
			surface.DrawTexturedRect(0, 0, w, h)
			
			return true
		end
	end
	function msgs:DoClick()
		iPhone.appSwitch(window, iPhone.apps['deepweb_messages'])
	end

	local bgMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/deep_background_noarrow.png', function(mat)
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

	local bPaint = function(self, w, h)
		iPhone.cursorUpdate(self)
		surface.SetDrawColor(229, 229, 229)
		surface.DrawRect(0, h-4, w, 4)

		if self.Hovered then
			surface.SetDrawColor(self.hoverColor)
			surface.DrawRect(0, 0, w, h-4)
			self.ava.circleColor = self.hoverColor
		else
			self.ava.circleColor = color_white
		end
		
		draw.SimpleText(self.name, 'iphone_contact_bold', 104, 12, Color(16, 16, 16))
			
		return true
	end

	local lineMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/line_point_point.png', function(mat)
		lineMat = mat
	end)

	local arrowMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/deep_arrowright.png', function(mat)
		arrowMat = mat
	end)

	for i, block in ipairs(config) do
		local p = vgui.Create('Panel', scroll)
		p:SetSize(0, 140)
		p:Dock(TOP)
		function p:Paint(w, h)
			shadowedText('# ' .. block.name .. ' =', 'iphone_deepweb_title', 16, 32)
			draw.SimpleText('*/', 'iphone_deepweb_normal', 14, 70, Color(76, 147, 87))
		end

		local label = vgui.Create('DLabel', p)
		label:SetPos(45, 64)
		label:SetSize(300, 80)
		label:SetText('{' .. block.desc .. '}')
		label:SetWrap(true)
		label:SetFont('iphone_deepweb_normal')
		label:SetColor(Color(76, 147, 87))

		for _, ply in ipairs(player.GetAll()) do
			local team = ply:GetNWBool('m_bDisguised', false) and ply:SetNWInt('m_iPrevTeam', ply:Team()) or ply:Team()

			if team.GetName(team) == block.team then
				local b = vgui.Create('DButton', scroll)
				b:SetSize(0, 48)
				b:Dock(TOP)
				b.ply = ply
				local anonid = string.sub(ply:SteamID(), -3)
				function b:Paint(w, h)
					iPhone.cursorUpdate(self)

					if self.Hovered then
						surface.SetDrawColor(255, 255, 255, 10)
						surface.DrawRect(0, 0, w, h)
					end

					shadowedText(anonid .. '  STATUT = (<Online>)', 'iphone_deepweb_status', 16, 12)

					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(arrowMat)
					surface.DrawTexturedRect(w - 42, 0, 42, 43)

					return true
				end

				function b:DoClick()
					iPhone.playerDeepMessaging = self.ply
					iPhone.appSwitch(window, iPhone.apps['deepweb_chat'])
				end
			end
		end

		local line = vgui.Create('Panel', scroll)
		line:SetSize(350, 2)
		line:Dock(TOP)
		function line:Paint(w, h)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(lineMat)
			surface.DrawTexturedRect(11, 0, 328, 2)
		end
	end
end