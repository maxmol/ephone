local L = include('ephone/translation.lua')

surface.CreateFont('iphone_balance', {
	font = 'Montserrat',
	size = 46,
	weight = 1200,
})

App.name = L'bank'
App.icon = 'bank_app_icon'
App.pos_x = 100
App.pos_y = 80

local bank_main = function(window, page)
	local bmat = {}

	for i = 1, 3 do
		iPhone.loadMaterial('materials/elysion/iphone/button_' .. i .. '.png', function(mat)
			bmat[i] = mat
		end)
	end

	local bottom = vgui.Create('Panel', window)
	bottom:SetPos(0, window:GetTall() - 100)
	bottom:SetSize(350, 100)
	bottom.current = page
	function bottom:Paint(w, h)
		if bmat[self.current] then
			surface.SetMaterial(bmat[self.current])
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)

			for i = 1, 3 do
				draw.SimpleText(L('bank' .. i), 'iphone_appname', (w / 3) * i - 58, 60, color_white, TEXT_ALIGN_CENTER)
			end
		end

		self.current = page
	end

	for i = 1, 3 do
		if i == page then continue end

		local b = vgui.Create('DButton', bottom)
		b:SetSize(116, 100)
		b:SetPos(116 * (i - 1), 0)
		function b:DoClick()
			iPhone.appSwitch(window, iPhone.apps['bank' .. i])
		end

		function b:Paint(w, h)
			iPhone.cursorUpdate(self)

			if self.Hovered then
				bottom.current = i
			end

			return true
		end
	end

	local bgMat
	iPhone.loadMaterial('materials/elysion/iphone/background.png', function(mat)
		bgMat = mat
	end)

	function window:Paint(w, h)
		if bgMat then
			surface.SetMaterial(bgMat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, -28, w, h + 28)

			draw.DrawText(L('bank_hello', LocalPlayer():GetName()), 'iphone_call', 16, 74)
			draw.SimpleText(L('bank' .. page), 'iphone_title', w / 2, 16, color_white, TEXT_ALIGN_CENTER)
		end
	end

	local panel = vgui.Create('Panel', window)
	panel:SetSize(350, 475)
	panel:SetPos(0, 139)
	return panel
end

App.bank_main = bank_main

local bankMoney = '0'
App.init = function(window)
	local panel = bank_main(window, 1)

	timer.Simple(0.5, function()
		net.Start('iphone_bank')
		net.WriteUInt(1, 3)
		net.SendToServer()
	end)

	function panel:Paint(w, h)
		draw.SimpleText(L'bank_balance', 'iphone_medium', w / 2, 20, color_black, TEXT_ALIGN_CENTER)
		local bankMoneyNumber = tonumber(bankMoney)
		draw.SimpleText(bankMoneyNumber and DarkRP.formatMoney(bankMoneyNumber) or bankMoney, 'iphone_balance', w / 2, 60, Color(22, 177, 230), TEXT_ALIGN_CENTER)
	end
end

net.Receive('iphone_bank', function()
	bankMoney = net.ReadString()
end)