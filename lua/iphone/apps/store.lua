local L = include('iphone/translation.lua')

file.CreateDir('iphone_images')

App.name = L'store'
App.icon = 'store_icon'
App.pos_x = 178
App.pos_y = 80
App.bgColor = color_white

local imageCache = {}
local loadImage = function(url, callback)
	local name = string.match(url, ".*/(.*)")

	if imageCache[name] then
		callback(imageCache[name])
		return
	end

	if name and #name > 0 then
		http.Fetch(url, function(image)
			if image then
				file.Write('iphone_images/' .. name, image)
				local mat = Material('../data/iphone_images/' .. name)
				imageCache[name] = mat
				callback(mat)
			end
		end)
	end
end

App.loadImage = loadImage

App.init = function(window)
	local scroll = iPhone.apps['contacts'].spawnScroll(window, true, 64, 32)
	scroll.pnlCanvas:DockPadding(16, 8, 16, 0)

	local bigStencil
	iPhone.loadMaterial('materials/elysion/iphone/big_appicon.png', function(mat)
		bigStencil = mat
	end)

	local littleStencil
	iPhone.loadMaterial('materials/elysion/iphone/big_appicon.png', function(mat)
		littleStencil = mat
	end)

	local featuredName = iphone_config.store_featured_item

	for id, item in ipairs(iphone_config.store_items) do
		item.id = id

		local iconMat
		loadImage(item.icon, function(mat)
			iconMat = mat
		end)

		local itemPnl = vgui.Create('DButton', scroll)

		if item.name == featuredName then
			itemPnl:SetSize(318, 208)
			itemPnl:Dock(TOP)

			function itemPnl:Paint(w, h)
				iPhone.cursorUpdate(self)

				if iconMat then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(iconMat)
					surface.DrawTexturedRect(0, 16, w, w)

					surface.SetDrawColor(0, 0, 0, 80)
					surface.DrawRect(0, 16, w, w)

					surface.SetDrawColor(255, 255, 255)
					if bigStencil then
						surface.SetMaterial(bigStencil)
						surface.DrawTexturedRect(0, 16, w, 160)
					end

					surface.DrawRect(0, 176, w, w - 160)
				end

				surface.SetDrawColor(209, 209, 211)
				surface.DrawRect(0, 0, w, 2)
				surface.DrawRect(0, h - 18, w, 2)

				draw.SimpleText(item.name, 'iphone_contact_bold', 16, 32, color_white)

				draw.RoundedBox(14, 16, h - 80, 78, 28, self.Hovered and Color(192, 192, 200) or Color(240, 240, 248))
				draw.SimpleText(L'open', 'iphone_small', 55, h - 66, Color(75, 137, 233), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				return true
			end
		else
			itemPnl:SetSize(318, 90)
			itemPnl:Dock(TOP)
			function itemPnl:Paint(w, h)
				iPhone.cursorUpdate(self)
				if iconMat then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(iconMat)
					surface.DrawTexturedRect(0, 0, 67, 67)

					if littleStencil then
						surface.SetMaterial(littleStencil)
						surface.DrawTexturedRect(0, 0, 67, 67)
					end
				end

				draw.SimpleText(item.name, 'iphone_search', 78, 0, color_black)
				draw.SimpleText(iphone_config.currency_format(item.price), 'iphone_search', 78, 30, Color(187, 187, 187))
				draw.RoundedBox(14, w - 78, 25, 78, 28, self.Hovered and Color(192, 192, 200) or Color(240, 240, 248))
				draw.SimpleText(L'open', 'iphone_small', w - 37, 39, Color(75, 137, 233), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				return true
			end
		end

		function itemPnl:DoClick()
			iPhone.appSwitch(window, iPhone.apps['storeitem'], item)
		end
	end

	/*local bottomPnl = vgui.Create('Panel', window)
	local scrollX, scrollY = scroll:GetPos()
	bottomPnl:SetPos(0, scrollY + )
	bottomPnl:SetSize(350, )*/
end