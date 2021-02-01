local L = include('iphone/translation.lua')

App.hideHomeBar = true
App.call = true
App.bgColor = Color(0, 0, 0, 0)

local formatSeconds = function(secs)
	secs = math.floor(secs)
	local mins = math.floor(secs / 60)
	secs = secs - mins * 60

	if mins < 10 then
		mins = '0' .. mins 
	end

	if secs < 10 then
		secs = '0' .. secs 
	end

	return mins .. ':' .. secs
end

App.init = function(window)
	local bgMat
	iPhone.loadMaterial('materials/elysion/iphone/BACKGROUNDTEST2.png', function(mat)
		bgMat = mat
	end)

	local btnMat
	iPhone.loadMaterial('materials/elysion/iphone/call_icon_refuse.png', function(mat)
		btnMat = mat
	end)

	local bClose = vgui.Create('DButton', window)
	bClose:SetPos(iPhone.width/2 - 36, iPhone.height*0.7)
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

		local calling = iPhone.playerCalling
		if not isstring(calling) then
			if not IsValid(calling) then
				iPhone.appClose(self)
				self.closed = true
				return
			end

			calling = calling:GetName()
		end

		if utf8.len(calling) > 20 then
			calling = utf8.sub(calling, 1, 20) .. '...'
		end
		
		draw.SimpleText(calling, 'iphone_title', w/2, 100, Color(250, 250, 250), TEXT_ALIGN_CENTER)
		draw.SimpleText(iPhone.callAnswered and formatSeconds(SysTime() - iPhone.callAnswered) or L'calling', 'iphone_call', w/2, 150, Color(163, 166, 176), TEXT_ALIGN_CENTER)
	end

	if not isstring(iPhone.playerCalling) and IsValid(iPhone.playerCalling) then
		iPhone.call_history[iPhone.getNumber(iPhone.playerCalling)] = {time = os.time()}
		iPhone.saveHistory()
	end
end