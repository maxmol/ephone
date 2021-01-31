local L = include('iphone/translation.lua')

App.init = function(window, item)
	local bgMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/storebackground.png', function(mat)
		bgMat = mat
	end)

	local iconMat
	iPhone.apps['store'].loadImage(item.icon, function(mat)
		iconMat = mat
	end)

	function window:Paint(w, h)
		if iconMat then
			surface.SetMaterial(iconMat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(25, 134, 302, 302)
		end

		if bgMat then
			surface.SetMaterial(bgMat)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, -28, w, h + 28)
		end

		draw.SimpleText(item.name, 'iphone_contact_bold', w / 2, 460, color_black, TEXT_ALIGN_CENTER)
		draw.SimpleText(DarkRP.formatMoney(item.price), 'iphone_medium', w / 2, 500, Color(187, 187, 187), TEXT_ALIGN_CENTER)
	end

	local buy = vgui.Create('DButton', window)
	buy:SetPos(50, 570)
	buy:SetSize(250, 55)
	function buy:Paint(w, h)
		iPhone.cursorUpdate(self)

		draw.RoundedBox(14, 0, 0, w, h, self.Hovered and Color(192, 192, 200) or color_white)
		draw.SimpleText(L'buy', 'iphone_medium', w / 2, h / 2, Color(75, 137, 233), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		return true
	end

	function buy:DoClick()
		net.Start('iphone_store')
			net.WriteUInt(item.id, 12)
		net.SendToServer()
		iPhone.appSwitch(window, iPhone.apps['store'])
	end

	local back = vgui.Create('DButton', window)
	back:SetPos(4, 36)
	back:SetSize(40, 35)
	function back:Paint(w, h)
		iPhone.cursorUpdate(self)

		if self.Hovered then
			surface.SetDrawColor(0, 0, 0, 64)
			surface.DrawRect(0, 0, w, h)
		end

		return true
	end

	function back:DoClick()
		iPhone.appSwitch(window, iPhone.apps['store'])
	end
end