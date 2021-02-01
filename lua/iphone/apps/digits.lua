local L = include('iphone/translation.lua')

App.bgColor = color_white

App.init = function(window)
	local callMat
	iPhone.loadMaterial('materials/elysion/iphone/call_icon.png', function(mat)
		callMat = mat
	end)

	local l
	local bCall = vgui.Create('DButton', window)
	bCall:SetPos(iPhone.width/2 - 36, iPhone.height*0.7)
	bCall:SetSize(73, 73)
	function bCall:Paint(w, h)
		iPhone.cursorUpdate(self)
		if callMat then
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.SetMaterial(callMat)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		return true
	end
	function bCall:DoClick()
		iPhone.call(l.text)
	end

	l = vgui.Create('Panel', window)
	l:SetSize(280, 43)
	l:SetPos(iPhone.width/2 - 140, iPhone.height*0.05)
	l.text = ''
	function l:Paint(w, h)
		draw.SimpleText(self.text, 'iphone_title', w/2, h/2, Color(16, 16, 16), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local backspaceMat
	iPhone.loadMaterial('materials/elysion/iphone/supr_numbericonnew.png', function(mat)
		backspaceMat = mat
	end)
	local btnClear = vgui.Create('DButton', window)
	btnClear:SetSize(42, 43)
	btnClear:SetPos(240, iPhone.height*0.7 + 15)
	function btnClear:Paint(w, h)
		iPhone.cursorUpdate(self)
		if backspaceMat then
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.SetMaterial(backspaceMat)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		return true
	end

	function btnClear:DoClick()
		l.text = l.text:sub(0, l.text:len() - 1)
	end

	local btnAdd = vgui.Create('DButton', window)
	btnAdd:SetSize(180, 35)
	btnAdd:SetPos(iPhone.width/2 - 90, 80)
	function btnAdd:Paint(w, h)
		if #l.text > 0 then
			iPhone.cursorUpdate(self)
			draw.SimpleText(L'add_number', 'iphone_search', w/2, h/2, Color(62, 134, 255, self.Hovered and 190 or 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		return true
	end

	function btnAdd:DoClick()
		local contact = {num = l.text}
		local ply = iPhone.getPlayerByNumber(contact.num)
		if ply then
			contact.name = ply:GetName()
		end

		iPhone.appSwitch(window, iPhone.apps['addcontact'], contact, ply)
	end

	local btnNum = 0
	for line = 0, 3 do
		for column = -1, 1 do
			btnNum = btnNum + 1
			local iconMat
			iPhone.loadMaterial('materials/elysion/iphone/' .. btnNum .. '_icon.png', function(mat)
				iconMat = mat
			end)

			local btn = vgui.Create('DButton', window)
			btn:SetPos(iPhone.width/2 - 36 + column * 90, iPhone.height*0.2 + line * 90)
			btn:SetSize(73, 73)

			if btnNum == 11 then
				btn.digit = '0'
			elseif btnNum == 10 then
				btn.digit = '*'
			elseif btnNum == 12 then
				btn.digit = '#'
			else
				btn.digit = btnNum
			end
			
			function btn:Paint(w, h)
				iPhone.cursorUpdate(self)
				if iconMat then
					if self.Hovered then
						surface.SetDrawColor(192, 192, 192)
					else
						surface.SetDrawColor(255, 255, 255)
					end
					surface.SetMaterial(iconMat)
					surface.DrawTexturedRect(0, 0, w, h)
				end
				return true
			end
			function btn:DoClick()
				if #l.text <= 16 then
					l.text = l.text .. self.digit
				end
			end
		end
	end

	iPhone.apps['contacts'].createBottomButtons(window, 3)
end