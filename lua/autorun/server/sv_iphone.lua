for _, file in pairs(file.Find('iphone/*', 'LUA')) do
	AddCSLuaFile('iphone/' .. file)
end

util.AddNetworkString('iPhone')

iPhone = {
	calls = {},
	codes = {
		['222'] = function(ply)
			DDrugs.CallCoke(0, ply)
		end,
		['666'] = function(ply)
			DDrugs.CallHero(0, ply)
		end,
	},
	contracts = {},
	contracts_pending = {},
	hitmen_teams = {
		['*VIP* Tueur à gages'] = true,
	},
}

local function delmsg(from, to)
	net.Start('iPhone')
		net.WriteString('deepmsgdel')
		net.WriteEntity(to)
	net.Send(from)
end

local canHear = {}

net.Receive('iPhone', function(len, from)
	local id = net.ReadString()

	if id == 'msg' then
		local to = net.ReadEntity()

		if IsValid(to) and to:IsPlayer() then
			local msg = utf8.sub(net.ReadString(), 0, 128)
			net.Start('iPhone')
				net.WriteString('msg')
				net.WriteEntity(from)
				net.WriteString(msg)
			net.Send(to)
		end
	elseif id == 'deepmsg' then
		local to = net.ReadEntity()

		if IsValid(to) and to:IsPlayer() then
			local msg = utf8.sub(net.ReadString(), 0, 256)

			local split = string.Split(msg, '~!~')

			if #split == 6 then
				local target
				for _, p in ipairs(player.GetAll()) do
					if p:GetName() == split[1] then
						target = p
						break
					end
				end

				if not IsValid(target) then
					DarkRP.notify(from, 1, 4, 'Player ' .. split[1] .. ' not found')
					delmsg(from, to)
					return
				end 
				
				local money = tonumber(split[6])
				if not money or money <= 0 or not from:canAfford(money) then
					DarkRP.notify(from, 1, 4, 'Invalid amount (' .. split[6] .. ')')
					delmsg(from, to)
					return
				end

				if not iPhone.hitmen_teams[team.GetName(to:Team())] then
					DarkRP.notify(from, 1, 4, "You can no longer create this contract") -- the player you are writing to doesn't have the hitman job anymore
					delmsg(from, to)
					return
				end

				if iPhone.contracts[to] then
					DarkRP.notify(from, 1, 4, "This hitman is busy")
					delmsg(from, to)
					return
				end

				-- check cooldown

				iPhone.contracts_pending[to] = iPhone.contracts_pending[to] or {}
				iPhone.contracts_pending[to][from] = {target, money}
			elseif msg:StartWith('//Contrat accepter') then
				local contracts = iPhone.contracts_pending[from]
				if contracts and contracts[to] then
					if not IsValid(contracts[to][1]) then
						DarkRP.notify(from, 1, 4, "The target cannot be found")
						delmsg(from, to)
						return
					end

					iPhone.contracts[from] = contracts[to]
					to:addMoney(-contracts[to][2])
					iPhone.contracts_pending[from][to] = nil
				else
					DarkRP.notify(from, 1, 4, "There is no pending contract from this person")
					delmsg(from, to)
					return
				end
			end

			net.Start('iPhone')
				net.WriteString('deepmsg')
				net.WriteEntity(from)
				net.WriteString(msg)
			net.Send(to)
		end
	elseif id == 'call' then
		local to = net.ReadEntity()
		if not IsValid(to) or not to:IsPlayer() then
			net.Start('iPhone')
				net.WriteString('endcall')
			net.Send(from)
			iPhone.calls[from] = nil
			canHear[from] = nil
			return
		end

		if IsValid(iPhone.calls[from]) then
			net.Start('iPhone')
				net.WriteString('endcall')
			net.Send(iPhone.calls[from])

			net.Start('iPhone')
				net.WriteString('endcall')
			net.Send(from)

			canHear[iPhone.calls[from]] = nil
			canHear[from] = nil
			iPhone.calls[iPhone.calls[from]] = nil
			iPhone.calls[from] = nil

			return
		end

		if IsValid(iPhone.calls[to]) then
			from:ChatPrint('Cette personne est occupé') -- visual
			net.Start('iPhone')
				net.WriteString('endcall')
			net.Send(from)
			return
		end

		iPhone.calls[to] = from
		iPhone.calls[from] = to
		
		net.Start('iPhone')
			net.WriteString('call')
			net.WriteEntity(from)
		net.Send(to)

		-- timer to end
	elseif id == 'anscall' then
		if IsValid(iPhone.calls[from]) then
			net.Start('iPhone')
				net.WriteString('anscall')
			net.Send(iPhone.calls[from])
			canHear[iPhone.calls[from]] = from
			canHear[from] = iPhone.calls[from]
		end
	elseif id == 'endcall' then
		if IsValid(iPhone.calls[from]) then
			net.Start('iPhone')
				net.WriteString('endcall')
			net.Send(iPhone.calls[from])

			net.Start('iPhone')
				net.WriteString('endcall')
			net.Send(from)

			canHear[iPhone.calls[from]] = nil
			canHear[from] = nil
			iPhone.calls[iPhone.calls[from]] = nil
			iPhone.calls[from] = nil
		end
	elseif id == 'code' then
		local num = net.ReadString()

		if iPhone.codes[num] then
			iPhone.codes[num](from)
		end
		
		net.Start('iPhone')
			net.WriteString('endcall')
		net.Send(from)
	end
end)

hook.Add('PlayerCanHearPlayersVoice', 'iPhone', function(listener, talker)
	if canHear[listener] == talker then
		return true
	end
end)

local bonusGiven = {}

util.AddNetworkString('iPhone_contract_remove')
hook.Add('PlayerDeath', 'iPhone_hitman', function(ply, wep, att)
	if iPhone.hitmen_teams[team.GetName(att:Team())] and
		iPhone.contracts[att] and iPhone.contracts[att][1] == ply then
		
		att:addMoney(iPhone.contracts[att][2])
		if att.hitmanClass then
			bonusGiven[att:SteamID()] = bonusGiven[att:SteamID()] or {}
			if not bonusGiven[att:SteamID()][ply:SteamID()] then
				bonusGiven[att:SteamID()][ply:SteamID()] = true
				att:addMoney(att.hitmanClass.money)
			end
		end
		iPhone.contracts[att] = nil
		net.Start('iPhone_contract_remove')
		net.Send(att)
	end
end)