App.name = 'Settings'
App.icon = 'settings_icon'
App.pos_x = 262
App.pos_y = 80

local createSlider = function(parent, x, y, callback)
	local slider = vgui.Create('DButton', parent)
	slider:SetSize(46, 27)
	slider:SetPos(x, y)

	local offMat, onMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/off_button.png', function(mat)
		offMat = mat
	end)

	ImgLoader.LoadMaterial('materials/elysion/iphone/on_button.png', function(mat)
		onMat = mat
	end)
	
	function slider:Paint(w, h)
		if offMat and onMat then
			iPhone.cursorUpdate(self)

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(self.on and onMat or offMat)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		
		return true
	end
	
	function slider:DoClick()
		self.on = not self.on
		callback(self.on)
	end
end

App.createSlider = createSlider

App.init = function(window)
	local yourNum = vgui.Create('Panel', window)
	yourNum:SetPos(0, 84)
	yourNum:SetSize(window:GetWide(), 60)
	local phoneNumber = iPhone.getNumber(LocalPlayer())
	function yourNum:Paint(w, h)
		surface.SetDrawColor(239, 238, 244)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(204, 205, 207)
		surface.DrawRect(0, 0, w, 2)
		surface.DrawRect(0, h-2, w, 2)

		draw.SimpleText(phoneNumber, 'iphone_medium', 22, h/2, Color(119, 119, 122), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local l = vgui.Create('Panel', window)
	l:SetSize(306, 38)
	l:SetPos(22, 154)
	l.Paint = function(self, w, h)
		surface.SetDrawColor(204, 205, 207)
		surface.DrawRect(0, h-2, w, 2)

		draw.SimpleText('Mode silencieux', 'iphone_search', 0, 14, Color(32, 32, 32), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local switch = createSlider(window, 264, 154, function(on)
		iPhone.silenced = on
	end)
end