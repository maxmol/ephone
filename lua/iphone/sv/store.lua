util.AddNetworkString('iphone_store')

-- from DarkRP
-- https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/sh_createitems.lua
local function defaultSpawn(ply, tr, tblE)
	local ent = ents.Create(tblE.ent)

	if not ent:IsValid() then error("Entity '" .. tblE.ent .. "' does not exist or is not valid.") end
	if ent.Setowning_ent then ent:Setowning_ent(ply) end

	ent:SetPos(tr.HitPos)
	-- These must be set before :Spawn()
	ent.SID = ply.SID
	ent.allowed = tblE.allowed
	ent.DarkRPItem = tblE
	ent:Spawn()
	ent:Activate()

	DarkRP.placeEntity(ent, tr, ply)

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	return ent
end


net.Receive('iphone_store', function(len, ply)
	local itemId = net.ReadUInt(12)
	item = iphone_config.store_items[itemId]

	if item then
		if not iphone_config.canAfford(ply, item.price) then
			ply:ChatPrint('[iPhone] ' .. L('not_enough_money'))
			return
		end

		iphone_config.addMoney(ply, -item.price)

		if item.type == 'custom' then
			if item.customCode then
				item.customCode(ply)
			end
		elseif item.type == 'weapon' then
			ply:Give(item.classname)
		elseif item.type == 'darkrpentity' then
			local tblEnt
			for _, t in ipairs(DarkRPEntities) do
				if t.cmd == item.cmd then
					tblEnt = t
					break
				end
			end

			if not tblEnt then
				MsgC(Color(255, 0, 0), '[iPhone] Entity with cmd "' .. item.cmd .. '" does not exist')
				return
			end

			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace)

			local ent = (tblEnt.spawn or defaultSpawn)(ply, tr, tblEnt)
			ent.onlyremover = not tblEnt.allowTools
			ent.SID = ply.SID
			ent.allowed = tblEnt.allowed
			ent.DarkRPItem = tblEnt

			hook.Call('playerBoughtCustomEntity', nil, ply, tblEnt, ent, 0)
		elseif item.type == 'console' then
			local cmd = item.command
			game.ConsoleCommand(cmd:Replace('{steamid}', ply:SteamID())
				:Replace('{steamid64}', ply:SteamID64())
				:Replace('{nickname}', ply:GetName()) .. '\n')
		end
	end
end)