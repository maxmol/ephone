util.AddNetworkString('iphone_bank')

net.Receive('iphone_bank', function(len, ply)
	if ply.iphone_bank_cooldown and ply.iphone_bank_cooldown > CurTime() then return end

	ply.iphone_bank_cooldown = CurTime() + 1

	local operation = net.ReadUInt(3)
	if operation == 1 then -- get balance
		iPhone.db.getBankMoney(ply, function(money)
			net.Start('iphone_bank')
				net.WriteString(tostring(money))
			net.Send(ply)
		end)
	elseif operation == 2 then -- withdraw
		local amt = net.ReadUInt(32)

		iPhone.db.getBankMoney(ply, function(bankMoney)
			bankMoney = tonumber(bankMoney)

			if bankMoney then
				if bankMoney < amt then
					ply:ChatPrint('[iPhone] ' .. L('not_enough_money'))
					return
				end

				if iPhone.db.setBankMoney(ply, bankMoney - amt) then
					ply:addMoney(amt)
				end
			end
		end)
	elseif operation == 3 then -- deposit
		local amt = net.ReadUInt(32)
		if not ply:canAfford(amt) then
			ply:ChatPrint('[iPhone] ' .. L('not_enough_money'))
			return
		end

		iPhone.db.getBankMoney(ply, function(bankMoney)
			bankMoney = tonumber(bankMoney)

			if bankMoney then
				if iPhone.db.setBankMoney(ply, bankMoney + amt) then
					ply:addMoney(-amt)
				end
			end
		end)
	end
end)
