local iphone_config = include('ephone/config.lua')
local L = include('ephone/translation.lua')

for _, file in pairs(file.Find('iphone/apps/*', 'LUA')) do
	AddCSLuaFile('iphone/apps/' .. file)
end

AddCSLuaFile('iphone/config.lua')

util.AddNetworkString('iPhone')

iPhone = {
	calls = {},
	codes = {
		/*['222'] = function(ply)
			DDrugs.CallCoke(0, ply)
		end,
		['666'] = function(ply)
			DDrugs.CallHero(0, ply)
		end,*/
	},
	db = include('ephone/sv/sql.lua'),
}

iPhone.db.init()

include('ephone/sv/bank.lua')
include('ephone/sv/store.lua')

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
			from:ChatPrint(L'player_busy')
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