local config = {
	metier = {
		'Policier',
		'Civil',
		'RAID',
		'Vendeur',
		'Gang'
	}
}

App.bgColor = color_black
App.deepweb_chat = true

surface.CreateFont('iphone_deepweb_status', {
	font = 'Fira Code',
	size = 28,
})

local addMessage = function(scroll, text, my, messages, key)
	if IsValid(scroll) then
		local split = string.Split(text, '~!~')

		if #split == 6 then
			local contractbg
			ImgLoader.LoadMaterial('materials/elysion/iphone/formulaire.png', function(mat)
				contractbg = mat
			end)

			local c = vgui.Create('Panel', scroll)
			c:SetSize(351, 611)
			c:Dock(TOP)

			function c:Paint(w, h)
				if contractbg then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(contractbg)
					surface.DrawTexturedRect(0, 0, w, h)

					draw.SimpleText(split[1], 'iphone_deepweb_status', 28 + 8, 42 + 17, Color(76, 147, 87), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(split[2], 'iphone_deepweb_status', 28 + 8, 332 + 17, Color(76, 147, 87), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end

			local function createField(h, text)
				local field1 = vgui.Create('DButton', c)
				field1:SetAutoStretchVertical(true)
				field1:SetFont('iphone_deepweb_status')
				field1:SetText(text)
				field1:SetColor(Color(76, 147, 87))
				field1:SetWrap(true)
				field1:SetPos(35, h)
				field1:SetSize(280, 80)
				field1.Paint = function() end
			end

			createField(114, split[3])
			createField(230, split[4])
			createField(403, split[5])
			createField(520, split[6])

			if not my then
				local confirmMat
				ImgLoader.LoadMaterial('materials/elysion/iphone/accept_reject.png', function(mat)
					confirmMat = mat
				end)

				local reject
				local confirm = vgui.Create('DButton', scroll)
				confirm:SetSize(351, 51)
				confirm:Dock(TOP)
				function confirm:Paint(w, h)
					iPhone.cursorUpdate(self)
					if confirmMat then
						surface.SetDrawColor(255, 255, 255)
						surface.SetMaterial(confirmMat)
						surface.DrawTexturedRect(0, 0, w, 109)
					end
					
					if self.Hovered then
						surface.SetDrawColor(255, 255, 255, 40)
						surface.DrawRect(0, 0, w, 51)
					end

					return true
				end
				function confirm:DoClick()
					local target
					for _, p in pairs(player.GetAll()) do
						if p:GetName() == split[1] then
							target = p
							break
						end
					end
					
					if target then
						local pos = target:GetPos()
						scroll.sendMessage(string.format('//Contrat accepter\ntarget : %s\njob : %s\nlocation : %s %s', 
							target:GetName(), team.GetName(target:Team()), math.floor(pos.x), math.floor(pos.y)))
						iPhone.hitman_locked = false
						iPhone.hitman_target = target

						reject:Remove()
						confirm:Remove()
						table.remove(messages, key)
					else
						notification.AddLegacy("Player can't be found", NOTIFY_ERROR, 2)
					end
				end

				reject = vgui.Create('DButton', scroll)
				reject:SetSize(402, 51)
				reject:Dock(TOP)
				function reject:Paint(w, h)
					iPhone.cursorUpdate(self)
					if self.Hovered then
						surface.SetDrawColor(255, 255, 255, 40)
						surface.DrawRect(0, 0, w, 51)
					end

					return true
				end
				function reject:DoClick()
					scroll.sendMessage('//Contrat refuser')
					iPhone.hitman_locked = false
					iPhone.hitman_target = false

					reject:Remove()
					confirm:Remove()
					table.remove(messages, key)
				end
			end
		else

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

	local messages = iPhone.deepweb_messages[isstring(iPhone.playerDeepMessaging) and iPhone.playerDeepMessaging or iPhone.getNumber(iPhone.playerDeepMessaging)]
	local function sendMessage(msgtext)
		if isstring(iPhone.playerDeepMessaging) or not IsValid(iPhone.playerDeepMessaging) then
			return 
		end

		local msg = {text = utf8.sub(msgtext, 0, 1024), my = true}
		
		if not messages then
			messages = {}
			iPhone.deepweb_messages[iPhone.getNumber(iPhone.playerDeepMessaging)] = messages
		end

		table.insert(messages, msg)
		messages.last = os.time()
		addMessage(scroll, msg.text, true)
		iPhone.saveMessages()

		net.Start('iPhone')
			net.WriteString('deepmsg')
			net.WriteEntity(iPhone.playerDeepMessaging)
			net.WriteString(msg.text)
		net.SendToServer()
	end

	scroll.sendMessage = sendMessage

	local hisTeam
	local p = iPhone.playerDeepMessaging
	if not isstring(p) and IsValid(p) then
		hisTeam = p:GetNWBool('m_bDisguised', false) and p:GetNWInt('m_iPrevTeam', p:Team()) or p:Team()
	end

	p = LocalPlayer()
	local myTeam = p:GetNWBool('m_bDisguised', false) and p:GetNWInt('m_iPrevTeam', p:Team()) or p:Team()

	if hisTeam == TEAM_HIT and myTeam != TEAM_HIT then
		local contractIcon
		ImgLoader.LoadMaterial('materials/elysion/iphone/contrat_icon.png', function(mat)
			contractIcon = mat
		end)
		local contract = vgui.Create('DButton', window)
		contract:SetPos(280, 8)
		contract:SetSize(49, 72)
		function contract:Paint(w, h)
			iPhone.cursorUpdate(self)
			if contractIcon then
				if self.Hovered then
					surface.SetDrawColor(200, 200, 200)
				else
					surface.SetDrawColor(255, 255, 255)
				end

				surface.SetMaterial(contractIcon)
				surface.DrawTexturedRect(0, 0, w, h)
			end

			return true
		end
		function contract:DoClick()
			if IsValid(self.contractPanel) then return end
			
			local contractbg
			ImgLoader.LoadMaterial('materials/elysion/iphone/formulaire.png', function(mat)
				contractbg = mat
			end)

			local c = vgui.Create('Panel', scroll)
			c:SetSize(351, 611)
			c:Dock(TOP)
			self.contractPanel = contract

			function c:Paint(w, h)
				if contractbg then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(contractbg)
					surface.DrawTexturedRect(0, 0, w, h)
				end
			end

			local selectPlayer = vgui.Create('DButton', c)
			selectPlayer:SetPos(28, 42)
			selectPlayer:SetSize(300, 34)
			selectPlayer.text = 'IDENTITÉ'
			function selectPlayer:Paint(w, h)
				iPhone.cursorUpdate(self)
				if self.Hovered then
					surface.SetDrawColor(255, 255, 255, 20)
					surface.DrawRect(0, 0, w, h)
				end

				draw.SimpleText(self.text, 'iphone_deepweb_status', 8, h/2, Color(76, 147, 87), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				return true
			end

			function selectPlayer:DoClick()
				if not self.options then
					self.options = {}
					local i = 0
					for _, ply in ipairs(player.GetAll()) do
						if ply == LocalPlayer() then continue end
						i = i + 1
						local option = vgui.Create('DButton', scroll)
						local _, yPos = c:GetPos()
						option:SetPos(28, yPos + 46 + 28 * i)
						option:SetSize(298, 28)

						function option:Paint(w, h)
							iPhone.cursorUpdate(self)
							if self.Hovered then
								surface.SetDrawColor(60, 60, 60)
							else
								surface.SetDrawColor(0, 0, 0)
							end
							surface.DrawRect(0, 0, w, h)

							surface.SetDrawColor(0, 215, 40)
							surface.DrawOutlinedRect(0, 0, w, h)
							draw.SimpleText(ply:GetName(), 'iphone_deepweb_status', 8, h/2, Color(76, 147, 87), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

							return true
						end

						function option:DoClick()
							selectPlayer.text = ply:GetName()
							selectPlayer.ply = ply
							selectPlayer:DoClick()
						end

						table.insert(self.options, option)
					end
				else
					for k, v in pairs(self.options) do
						v:Remove()
					end
					self.options = nil
				end
			end


			local selectJob = vgui.Create('DButton', c)
			selectJob:SetPos(28, 332)
			selectJob:SetSize(300, 34)
			selectJob.text = 'MÉTIER'
			function selectJob:Paint(w, h)
				iPhone.cursorUpdate(self)
				if self.Hovered then
					surface.SetDrawColor(255, 255, 255, 20)
					surface.DrawRect(0, 0, w, h)
				end

				draw.SimpleText(self.text, 'iphone_deepweb_status', 8, h/2, Color(76, 147, 87), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				return true
			end

			function selectJob:DoClick()
				if not self.options then
					self.options = {}
					for i, job in ipairs(config.metier) do
						local option = vgui.Create('DButton', scroll)
						local _, yPos = c:GetPos()
						option:SetPos(28, yPos + 336 + 28 * i)
						option:SetSize(298, 28)

						function option:Paint(w, h)
							iPhone.cursorUpdate(self)
							if self.Hovered then
								surface.SetDrawColor(60, 60, 60)
							else
								surface.SetDrawColor(0, 0, 0)
							end
							surface.DrawRect(0, 0, w, h)

							surface.SetDrawColor(0, 215, 40)
							surface.DrawOutlinedRect(0, 0, w, h)
							draw.SimpleText(job, 'iphone_deepweb_status', 8, h/2, Color(76, 147, 87), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

							return true
						end

						function option:DoClick()
							selectJob.text = job
							selectJob:DoClick()
						end

						table.insert(self.options, option)
					end
				else
					for k, v in pairs(self.options) do
						v:Remove()
					end
					self.options = nil
				end
			end

			c.fields = {}
			local function createField(h)
				local field1 = vgui.Create('DButton', c)
				field1:SetAutoStretchVertical(true)
				field1:SetFont('iphone_deepweb_status')
				field1:SetText('Ecrire ici ...')
				field1:SetColor(Color(76, 147, 87))
				field1:SetWrap(true)
				field1:SetPos(35, h)
				field1:SetSize(280, 80)
				function field1:Paint(w, h)
					iPhone.cursorUpdate(self, w, 80)
					if self.Hovered then
						surface.SetDrawColor(0, 0, 0, 96)
						surface.DrawRect(-8, 0, w + 16, 80)
					end
				end

				function field1:DoClick()
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
						surface.SetFont('iphone_deepweb_status')
						local tw = surface.GetTextSize(str)
						if tw > 760 then
							entry:SetValue(self:GetText())
						else
							self:SetText(str)
						end
					end

					self.textEntry = entry
				end
				
				table.insert(c.fields, field1)
			end

			createField(114)
			createField(230)
			createField(403)
			createField(520)

			local confirmMat
			ImgLoader.LoadMaterial('materials/elysion/iphone/confirmer_le_contrat.png', function(mat)
				confirmMat = mat
			end)
			local confirm = vgui.Create('DButton', scroll)
			confirm:SetSize(351, 51)
			confirm:Dock(TOP)
			function confirm:Paint(w, h)
				iPhone.cursorUpdate(self)
				if confirmMat then
					if self.Hovered then
						surface.SetDrawColor(200, 200, 200)
					else
						surface.SetDrawColor(255, 255, 255)
					end

					surface.SetMaterial(confirmMat)
					surface.DrawTexturedRect(0, 0, w, h)
				end

				return true
			end
			function confirm:DoClick()
				sendMessage(string.format('%s~!~%s~!~%s~!~%s~!~%s~!~%s', selectPlayer.text, selectJob.text, c.fields[1]:GetText(), c.fields[2]:GetText(), c.fields[3]:GetText(), c.fields[4]:GetText()))

				if selectPlayer.options then
					selectPlayer:DoClick()
				end

				if selectJob.options then
					selectJob:DoClick()
				end

				c:Remove()
				self:Remove()
			end
		end
	end

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

			local s = ''
			if isstring(iPhone.playerDeepMessaging) then
				s = iPhone.playerDeepMessaging
			elseif IsValid(iPhone.playerDeepMessaging) then
				s = iPhone.playerDeepMessaging:GetName()
			end
			shadowedText(s, 'iphone_deepweb_name', w/2, 66, TEXT_ALIGN_CENTER)
		end
	end

	-- nickname
	
	if messages then
		for key, msg in ipairs(messages) do
			addMessage(scroll, msg.text, msg.my, messages, key)
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
			text = 'HORS LIGNE'
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
			sendMessage(self:GetValue())
		end

		entry.OnLoseFocus = function()
			entry:Remove()
			self.textEntry = nil
		end
		entry.OnMousePressed = entry.OnLoseFocus
		self.textEntry = entry
	end
end

net.Receive('iPhone_contract_remove', function()
	iPhone.hitman_locked = false
	iPhone.hitman_target = false
	chat.AddText(Color(64, 200, 0), 'Contract completed!')
end)