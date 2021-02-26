local iphone_config = include('ephone/config.lua')
local L = include('ephone/translation.lua')

surface.CreateFont('iphone_time', {
	font = 'Calibri',
	size = 24,
	extended = true,
})

surface.CreateFont('iphone_appname', {
	font = 'Calibri',
	size = 22,
	extended = true,
})

surface.CreateFont('iphone_title', {
	font = 'Calibri',
	size = 46,
	weight = 1200,
	extended = true,
})

surface.CreateFont('iphone_call', {
	font = 'Calibri',
	size = 28,
	weight = 600,
	extended = true,
})

surface.CreateFont('iphone_medium', {
	font = 'Calibri',
	size = 34,
	weight = 600,
	extended = true,
})

surface.CreateFont('iphone_large', {
	font = 'Montserrat',
	size = 48,
	weight = 400,
	extended = true,
})

surface.CreateFont('iphone_contact', {
	font = 'Calibri',
	size = 32,
	extended = true,
})

surface.CreateFont('iphone_contact_bold', {
	font = 'Calibri',
	size = 32,
	weight = 1200,
	extended = true,
})

surface.CreateFont('iphone_search', {
	font = 'Calibri',
	size = 26,
	weight = 900,
	extended = true,
})

surface.CreateFont('iphone_small', {
	font = 'Calibri Light',
	size = 21,
	weight = 600,
	extended = true,
})

file.CreateDir('ephone')

local circularInit = function(panel, dark)
	local circle
	iPhone.loadMaterial('materials/elysion/iphone/' .. (dark and 'player_img' or 'circle') .. '.png', function(mat)
		circle = mat
	end)

	function panel:PaintOver(w, h)
		if circle then
			surface.SetDrawColor(self.circleColor or color_white)
			surface.SetMaterial(circle)
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end
end

iPhone = {--iPhone or {
	width = 350,
	height = 725,
	iconSize = 73,
	getNumber = function(ply)
		local stm = ply.SteamID64 and ply:SteamID64() or '0'
		local num = stm:sub(stm:len() - 7)
		local k
		while true do
			num, k = string.gsub(num, "^(-?%d+)(%d%d)", "%1 %2")
			if k == 0 then break end
		end

		return num
	end,
	getPlayerByNumber = function(num)
		for _, ply in ipairs(player.GetAll()) do
			if string.Replace(iPhone.getNumber(ply), ' ', '') == string.Replace(num, ' ', '') then
				return ply
			end
		end
	end,
	loadMaterial = function(path, callback)
		callback(Material(path))
	end,
	appOpen = function(self)
		local startX, startY = self:GetPos()
		self:SetZPos(self:GetZPos() + 1)
		self.Hovered = false
		iPhone.appOpening = self.app
		self:NewAnimation(0.3, 0, -1, function(t, pnl)
			iPhone.appCreate(pnl.app, function()
				pnl:SetSize(iPhone.iconSize, iPhone.iconSize)
				pnl:SetPos(pnl.app.pos_x, pnl.app.pos_y)
				pnl.openAnimFraction = 0
			end)
			self:SetZPos(self:GetZPos() - 1)
		end).Think = function(anim, pnl, fraction)
			self:SetSize(iPhone.iconSize + fraction * (iPhone.width - iPhone.iconSize), iPhone.iconSize + fraction * (iPhone.height - iPhone.iconSize - 28))
			self:SetPos(startX - fraction * startX, startY - fraction * (startY - 28))
			self.openAnimFraction = fraction
			self:GetParent().openAnimFraction = fraction
		end
	end,
	appCreate = function(app, callback, ...)
		local window = vgui.Create('EditablePanel', iPhone.panel)
		window:SetZPos(window:GetZPos() + 20)
		window:SetSize(iPhone.width, iPhone.height - 28)
		window.app = app
		window.closingFraction = 0

		function window:Paint(w, h)
			--draw.RoundedBoxEx(48, 0, 64, w, h - 64, self.app.bgColor or Color(245, 245, 245), false, false, true, true)
			--draw.RoundedBoxEx(6 + math.min(42, 42 * (self.closingFraction*4)), 0, 0, w, 64, self.app.bgColor or Color(245, 245, 245), true, true, false, false)

			if not self.app.noTitle and self.app.name then
				draw.SimpleText(self.app.name, 'iphone_title', 16, 20, Color(16, 16, 16, (1 - self.closingFraction * 2.5) * 255))
			end
		end

		window:SetPos(0, 28)
		window:SetAlpha(0)
		window:AlphaTo(255, 0.2, 0.1, callback)

		if not app.hideHomeBar then
			local homeBar = vgui.Create('DButton', window)
			homeBar:SetSize(300, 40)
			homeBar:SetPos(iPhone.width/2 - 150, window:GetTall() - 28)
			homeBar.color = app.homeBarColor or Color(96, 96, 96)
			homeBar:SetZPos(homeBar:GetZPos() + 50)
			function homeBar:Paint(w, h)
				iPhone.cursorUpdate(self)
				draw.RoundedBox(8, 50, 12, w-100, 10, self.Hovered and self.color or ColorAlpha(self.color, 200))
				return true
			end

			function homeBar:OnMousePressed()
				iPhone.appClose(window)
				local posx, posy = self:GetPos()
				self:MoveTo(posx, posy - 50, 0.15)
			end
		end

		if app.init then
			local success, errors = pcall(app.init, window, ...)
			if not success then
				ErrorNoHalt(errors)
			end
		end

		table.insert(iPhone.appsOpened, window)
		return window
	end,
	appDisableInput = function(panel)
		panel.CursorDisabled = true
		for k, v in ipairs(panel:GetChildren()) do
			iPhone.appDisableInput(v)
		end
	end,
	appClose = function(window, secondary)
		if not window then
			window = iPhone.appsOpened[#iPhone.appsOpened]
			if not window then
				return
			end
		end

		local startW, startH = window:GetSize()
		local startX, startY = window:GetPos()
		local changeX, changeY
		if not secondary and window.app.icon then
			changeX, changeY = window.app.pos_x - startX, window.app.pos_y - startY
		end
		
		iPhone.appDisableInput(window)
		for k, v in ipairs(window:GetChildren()) do
			v:AlphaTo(0, 0.15, 0, function(_, pnl)
				pnl:Remove()
			end)
		end

		window:NewAnimation(0.4, 0.15, -1, function(t, pnl)
			table.RemoveByValue(iPhone.appsOpened, window)
			window:Remove()
		end).Think = function(anim, pnl, fraction)
			if changeX then
				window:SetSize(startW * (1-fraction), startH * (1-fraction))
				window:SetPos(startX + fraction * changeX, startY + fraction * changeY)
			end
			window:SetAlpha((1 - fraction*1.6) * 255)
			window.closingFraction = fraction
			if not secondary then iPhone.panel.openAnimFraction = 1 - fraction end
		end
	end,
	appByName = function(name)
		for i, app in pairs(iPhone.apps) do
			if app.name == name then
				return app
			end
		end
	end,
	appSwitch = function(window, app, ...)
		iPhone.appDisableInput(window)
		local newWindow = iPhone.appCreate(app, function()
			iPhone.appOpening = app
		end, ...)

		iPhone.appClose(window, true)
		newWindow:SetZPos(newWindow:GetZPos() + 1)
	end,
	createScreen = function()
		if not IsValid(iPhone.panel) then
			iPhone.appsOpened = {}
	
			local f = vgui.Create('EditablePanel')
			f:SetPaintedManually(true)
			f:SetSize(350, 725)
			f.openAnimFraction = 0
			f:SetAlpha(0)
			f:AlphaTo(255, 0.15, 0.4)
			iPhone.panel = f
	
			local bgMat
			iPhone.loadMaterial('materials/elysion/iphone/BACKGROUNDTEST.png', function(mat)
				bgMat = mat
			end)

			local bgWhiteMat
			iPhone.loadMaterial('materials/elysion/iphone/whitebackground.png', function(mat)
				bgWhiteMat = mat
			end)

			function f:Paint(w, h)
				if bgMat and self.openAnimFraction < 1 then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(bgMat)
					surface.DrawTexturedRect(0, 0, w, h)
				end
	
				if self.openAnimFraction > 0 and bgWhiteMat then
					--draw.RoundedBox(32, 0, 0, w, h, Color(15, 15, 15, self.openAnimFraction * 255))
					local clr = iPhone.appOpening and iPhone.appOpening.bgColor or Color(245, 245, 245)
					surface.SetDrawColor(clr.r, clr.g, clr.b, self.openAnimFraction * 510 - 255)
					surface.SetMaterial(bgWhiteMat)
					surface.DrawTexturedRect(0, 0, w, h)
				end

				local clrMod = 240 - self.openAnimFraction * 240
				draw.SimpleText(os.date(iphone_config.internationalTime and '%H:%M' or '%I:%M', os.time()),
					'iphone_time', 50, 17, Color(clrMod, clrMod, clrMod, iPhone.panel:GetAlpha()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			for i, widget in pairs(iPhone.widgets) do
				local b = vgui.Create('DButton', f)
				b:SetSize(widget.w, widget.h)
				b:SetPos(widget.pos_x, widget.pos_y)
				b.sizeAnim = 0
				b.widget = widget
	
				local bgMat
				iPhone.loadMaterial('materials/elysion/iphone/' .. widget.bg .. '.png', function(mat)
					bgMat = mat
				end)

				function b:Paint(w, h)
					if f.openAnimFraction == 1 then
						return true
					end

					if #iPhone.appsOpened == 0 and f.openAnimFraction == 0 then
						iPhone.cursorUpdate(self)
					end

					self.sizeAnim = Lerp(FrameTime() * 10, self.sizeAnim, self.Depressed and -8 or (self.Hovered and 4 or 0))

					local anim = self.sizeAnim
					if bgMat then
						local mul = anim < 0 and 1 or 3
						draw.RoundedBox(12, -anim*mul, -anim*(mul*0.7), w + math.min(0, anim*2) - 2, h + math.min(0, anim*2) - 2, Color(0, 0, 0, 64))

						surface.SetMaterial(bgMat)
						surface.SetDrawColor(255, 255, 255, 255 - f.openAnimFraction * 255)
						surface.DrawTexturedRect(-anim, -anim, w + anim*2, h + anim*2)
					end

					if self.widget.paint then
						self.widget.paint(self, w, h, anim)
					end

					draw.SimpleText(self.widget.name, 'iphone_appname', w/2, h + 5 + anim, color_white, TEXT_ALIGN_CENTER)

					return true
				end

				function b:DoClick()
					widget.open()
				end

				if widget.create then widget.create(b) end
			end

			for i, app in pairs(iPhone.apps) do
				if not app.icon or table.HasValue(iphone_config.disabled_apps, i) then
					continue
				end

				local b = vgui.Create('DButton', f)
				b:SetSize(iPhone.iconSize, iPhone.iconSize)
				b:SetPos(app.pos_x, app.pos_y)
				b.app = app

				local appMat
				iPhone.loadMaterial('materials/elysion/iphone/' .. app.icon .. '.png', function(mat)
					appMat = mat
				end)

				b.openAnimFraction = 0
				function b:Paint(w, h)
					if f.openAnimFraction == 1 then
						return true
					end

					if #iPhone.appsOpened == 0 and f.openAnimFraction == 0 then
						iPhone.cursorUpdate(self)
					end

					if appMat then
						if self.Hovered then
							surface.SetDrawColor(200, 200, 200)
						else
							surface.SetDrawColor(255, 255, 255, 255 - f.openAnimFraction * 255)
						end
					
						surface.SetMaterial(appMat)
						surface.DrawTexturedRect(0, 0, w, w)
					end

					local frac = self.openAnimFraction
					if frac > 0 then
						local stretch = frac * 28
						local clr = ColorAlpha(self.app.bgColor or Color(245, 245, 245), frac * 350)
						draw.RoundedBoxEx(48, 0, 64, w, h - 64, clr, false, false, true, true)
						draw.RoundedBoxEx(48*(1 - frac*frac*frac*0.8125), 0, 0, w, 64, clr, true, true, false, false)
					end

					if self.app.name and self.app.pos_y < 600 then
						draw.SimpleText(self.app.name, 'iphone_appname', w/2, h, color_white, TEXT_ALIGN_CENTER)
					end
	
					return true
				end
	
				b.DoClick = iPhone.appOpen
			end
		end
	end,
	cursorUpdate = cursorUpdate,
	circularInit = circularInit,
	messages = {},
	saveMessages = function()
		file.Write('ephone/iphone_messages' .. iPhone.ipCRC .. '.txt', util.TableToJSON(iPhone.messages))
	end,
	deepweb_messages = {},
	call_history = {},
	saveHistory = function()
		file.Write('ephone/iphone_history' .. iPhone.ipCRC .. '.txt', util.TableToJSON(iPhone.call_history))
	end,
	contacts = {},
	saveContacts = function()
		file.Write('ephone/iphone_contacts' .. iPhone.ipCRC .. '.txt', util.TableToJSON(iPhone.contacts))
	end,
	AddApplication = function(self, id)
		local newApp = {}

		if id then
			self.apps[id] = newApp
		else
			table.insert(self.apps, newApp)
		end

		return newApp
	end,
	call = function(number)
		if not isstring(number) or string.len(number) > 5 then
			local ply
			if isstring(number) then
				ply = iPhone.getPlayerByNumber(number)
			elseif IsValid(number) and number:IsPlayer() then
				ply = number
			end

			if not ply then
				chat.AddText(Color(64, 100, 255), '[iPhone] ', color_white, L('player_is_offline', number))
			else
				iPhone.playerCalling = ply
				iPhone.appSwitch(iPhone.appsOpened[#iPhone.appsOpened], iPhone.apps['calling'])

				net.Start('iPhone')
				net.WriteString('call')
				net.WriteEntity(ply)
				net.SendToServer()
			end
		else
			iPhone.playerCalling = number
			iPhone.appSwitch(iPhone.appsOpened[#iPhone.appsOpened], iPhone.apps['calling'])

			net.Start('iPhone')
			net.WriteString('code')
			net.WriteString(number)
			net.SendToServer()
		end
	end,
	receiveMessage = function(num, msg)
		iPhone.messages[num] = iPhone.messages[num] or {}
		table.insert(iPhone.messages[num], {text = msg})
		iPhone.messages[num].last = os.time()
		iPhone.saveMessages()

		chat.AddText(Color(64, 100, 255), '[iPhone] ', color_white, L('new_message_from', num))
		if iPhone.playerMessaging == num and iPhone.newMessage then
			iPhone.newMessage(msg)
		end

		if not iPhone.silenced then
			surface.PlaySound('iphone/msg.mp3')
		end
	end,
	ipCRC = util.CRC(game.GetIPAddress()),
}

iPhone.apps = {
	/*{
		icon = 'photo_appli_icon',
		pos_x = 100,
		pos_y = 50,
	},*/
}

surface.CreateFont('iphone_loup_light', {
	font = 'Calibri Light',
	size = 23,
	weight = 300,
})

surface.CreateFont('iphone_loup_bold', {
	font = 'Calibri Bold',
	size = 23,
	weight = 1200,
})

surface.CreateFont('iphone_loup', {
	font = 'Montserrat ExtraBold',
	size = 24,
})

iPhone.widgets = {}

if iphone_config.website_widget_link and iphone_config.website_widget_link ~= '' then
	table.insert(iPhone.widgets, {
		bg = 'widget_store',
		name = iphone_config.website_widget_name,
		pos_x = 24,
		pos_y = 200,
		w = 139,
		h = 149,
		open = function()
			gui.OpenURL(iphone_config.website_widget_link)
		end
	})
end

if iphone_config.discord_widget_link and iphone_config.discord_widget_link ~= '' then
	table.insert(iPhone.widgets, {
		bg = 'widget_discord',
		name = 'Discord',
		pos_x = 187,
		pos_y = 200,
		w = 139,
		h = 149,
		open = function()
			gui.OpenURL(iphone_config.discord_widget_link)
		end
	})
end

if file.Exists('ephone/iphone_messages' .. iPhone.ipCRC .. '.txt', 'DATA') then
	iPhone.messages = util.JSONToTable(file.Read('ephone/iphone_messages' .. iPhone.ipCRC .. '.txt', 'DATA'))
end

if file.Exists('ephone/iphone_history' .. iPhone.ipCRC .. '.txt', 'DATA') then
	iPhone.call_history = util.JSONToTable(file.Read('ephone/iphone_history' .. iPhone.ipCRC .. '.txt', 'DATA'))
end

if file.Exists('ephone/iphone_contacts' .. iPhone.ipCRC .. '.txt', 'DATA') then
	iPhone.contacts = util.JSONToTable(file.Read('ephone/iphone_contacts' .. iPhone.ipCRC .. '.txt', 'DATA'))
end

local env = getfenv()
for _, file in pairs(file.Find('ephone/apps/*', 'LUA')) do
	local appId = string.StripExtension(file)

	env.App = iPhone:AddApplication(appId)
	include('ephone/apps/' .. file)
end
env.App = nil

net.Receive('iPhone', function()
	local id = net.ReadString()

	if id == 'msg' then
		local from = net.ReadEntity()
		local msg = net.ReadString()

		local id = iPhone.getNumber(from)
		iPhone.messages[id] = iPhone.messages[id] or {}
		table.insert(iPhone.messages[id], {text = msg})
		iPhone.messages[id].last = os.time()
		iPhone.saveMessages()

		chat.AddText(Color(64, 100, 255), '[iPhone] ', color_white, L('new_message_from', from:GetName()))
		if iPhone.playerMessaging == from and iPhone.newMessage then
			iPhone.newMessage(msg)
		end

		if not iPhone.silenced then
			surface.PlaySound('iphone/msg.mp3')
		end
	elseif id == 'msgnum' then
		local num = net.ReadString()
		local msg = net.ReadString()
		
		receiveMessage(num, msg)
	elseif id == 'call' then
		iPhone.appClose()
		local from = net.ReadEntity()
		iPhone.playerCalling = from
		local newWindow = iPhone.appCreate(iPhone.apps['call'])
		newWindow:SetZPos(newWindow:GetZPos() + 10)
		chat.AddText(Color(64, 100, 255), '[iPhone] ', color_white, L('player_is_calling_you', from:GetName()))
		iPhone.call_history[iPhone.getNumber(from)] = {time = os.time(), missed = true}
		iPhone.saveHistory()

		if not iPhone.silenced then
			if iPhone.ringtone then iPhone.ringtone:Stop() end

			iPhone.ringtone = CreateSound(LocalPlayer(), 'iphone/ring.mp3')
			iPhone.ringtone:SetSoundLevel(0)
			iPhone.ringtone:Play()
		end
	elseif id == 'endcall' then
		for k, window in pairs(iPhone.appsOpened) do
			if window.app.call then
				iPhone.appClose(window)
			end
		end

		iPhone.callAnswered = nil
		
		if iPhone.ringtone then
			iPhone.ringtone:Stop()
		end
	elseif id == 'anscall' then
		iPhone.callAnswered = SysTime()
		chat.AddText(Color(64, 100, 255), '[iPhone] ', color_white, L('player_answered_your_call', iPhone.playerCalling:GetName()))
	end
end)

hook.Call('iPhoneInitialized', nil, iPhone)