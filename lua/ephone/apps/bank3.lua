local L = include('ephone/translation.lua')

App.init = function(window)
	local panel = iPhone.apps['bank1'].bank_main(window, 3)
	iPhone.apps['bank2'].bank_action(window, panel, 3, function(amount)
		if amount > 0 then
			net.Start('iphone_bank')
			net.WriteUInt(3, 3)
			net.WriteUInt(amount, 32)
			net.SendToServer()
		end
	end)
end