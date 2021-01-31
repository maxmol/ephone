util.AddNetworkString('iphone_store')

net.Receive('iphone_store', function(len, ply)
	local itemId = net.ReadUInt(12)
	item = iphone_config.store_items[itemId]

	if item then
		if not ply:canAfford(item.price) then
			ply:ChatPrint('[iPhone] ' .. L('not_enough_money'))
			return
		end

		ply:addMoney(-item.price)

		if item.type == 'custom' then
			if item.customCode then
				item.customCode(ply)
			end
		elseif item.type == 'weapon' then
			ply:Give(item.classname)
		elseif item.type == 'entity' then
			--ply:Give(item.classname)
		end
	end
end)