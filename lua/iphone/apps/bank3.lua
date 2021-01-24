local L = include('iphone/translation.lua')

App.init = function(window)
	local panel = iPhone.apps['bank1'].bank_main(window, 3)
	iPhone.apps['bank2'].bank_action(window, panel, 3, function(amount)
		if amount > 0 then
			net.Start('blueatm')
			net.WriteUInt(BATM_NET_COMMANDS.deposit, 8)
			net.WriteEntity(ents.FindByClass('atm_wall')[1])
			net.WriteString(BATM.SelectedAccount)
			net.WriteDouble(amount)
			net.SendToServer()
		end
	end)
end