local L = include('iphone/translation.lua')

App.hideHomeBar = true
App.call = true
App.bgColor = Color(0, 0, 0, 0)

App.init = function(window)
	local bgMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/BACKGROUNDTEST2.png', function(mat)
		bgMat = mat
	end)

	local btnAnsMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/call_icon.png', function(mat)
		btnAnsMat = mat
	end)

	local bAns = vgui.Create('DButton', window)
	bAns:SetPos(iPhone.width*0.33 - 36, iPhone.height*0.7)
	bAns:SetSize(73, 73)
	function bAns:Paint(w, h)
		iPhone.cursorUpdate(bAns)
		if btnAnsMat then
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.SetMaterial(btnAnsMat)
			surface.DrawTexturedRect(0, 0, w, h)
			
			return true
		end
	end
	function bAns:DoClick()
		iPhone.appSwitch(window, iPhone.apps['calling'])
		net.Start('iPhone')
		net.WriteString('anscall')
		net.SendToServer()
		iPhone.callAnswered = SysTime()
		if iPhone.ringtone then
			iPhone.ringtone:Stop()
		end
	end

	local btnMat
	ImgLoader.LoadMaterial('materials/elysion/iphone/call_icon_refuse.png', function(mat)
		btnMat = mat
	end)

	local bClose = vgui.Create('DButton', window)
	bClose:SetPos(iPhone.width*0.66 - 36, iPhone.height*0.7)
	bClose:SetSize(73, 73)
	function bClose:Paint(w, h)
		iPhone.cursorUpdate(bClose)
		if btnMat then
			if self.Hovered then
				surface.SetDrawColor(200, 200, 200)
			else
				surface.SetDrawColor(255, 255, 255)
			end

			surface.SetMaterial(btnMat)
			surface.DrawTexturedRect(0, 0, w, h)
			
			return true
		end
	end
	function bClose:DoClick()
		net.Start('iPhone')
		net.WriteString('endcall')
		net.SendToServer()
	end
	
	window.Paint = function(self, w, h)
		if bgMat then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(bgMat)
			surface.DrawTexturedRect(0, -28, w, h + 28)
		end

		if self.closed then
			return
		end

		local ply = iPhone.playerCalling
		if IsValid(ply) then
			local text = ply:GetName()
			if utf8.len(text) > 20 then
				text = utf8.sub(text, 1, 20) .. '...'
			end
			draw.SimpleText(text, 'iphone_title', w/2, 100, Color(250, 250, 250), TEXT_ALIGN_CENTER)
			draw.SimpleText(L'calling', 'iphone_call', w/2, 150, Color(163, 166, 176), TEXT_ALIGN_CENTER)
		else
			iPhone.appClose(self)
			self.closed = true
		end
	end
end