util.AddNetworkString('iphone_bank')

net.Receive('iphone_bank', function(len, ply)
	if ply.iphone_bank_cooldown and ply.iphone_bank_cooldown > CurTime() then return end
		
	if GlorifiedBanking then -- checks if glorified bank is installed if so then it adds a global variable to check bank balance
		gBankMoney = GlorifiedBanking.GetPlayerBalance(ply)
	end

	local operation = net.ReadUInt(3)
	if operation == 1 then -- get balance
		if GlorifiedBanking then
			net.Start('iphone_bank')
				net.WriteString(tostring(gBankMoney))
			net.Send(ply)

		else
			iPhone.db.getBankMoney(ply, function(money)
				net.Start('iphone_bank')
					net.WriteString(tostring(money))
				net.Send(ply)
			end)
		end 
	elseif operation == 2 then -- withdraw
		local amt = net.ReadUInt(32)

		if GlorifiedBanking then -- checks if glorified banking is installed

			ply:WithdrawFromBank(amt)


		else 
			
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
		end
		ply.iphone_bank_cooldown = CurTime() + 1
	elseif operation == 3 then -- deposit
		local amt = net.ReadUInt(32)

		if not ply:canAfford(amt) then
			ply:ChatPrint('[iPhone] ' .. L('not_enough_money'))
			return
		end

		if GlorifiedBanking then
			GlorifiedBanking.AddPlayerBalance(ply, amt)
			ply:addMoney(-amt)

		else
			iPhone.db.getBankMoney(ply, function(bankMoney)
				bankMoney = tonumber(bankMoney)

				if bankMoney then
					if iPhone.db.setBankMoney(ply, bankMoney + amt) then
						ply:addMoney(-amt)
					end
				end
			end)
		end 
		ply.iphone_bank_cooldown = CurTime() + 1
	end
end)
