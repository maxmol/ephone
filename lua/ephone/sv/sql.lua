local mysql_config = {
	host = "ip_or_domain",
	port = "port_number",
	database = "database_name",
	username = "your_mysql_username",
	password = "your_mysql_password"
}

local mysql
local useMySQL = iphone_config.mysql
return {
	init = function(node)
		if not useMySQL then
			if not sql.TableExists("iphone_bank") then
				sql.Query[[
					CREATE TABLE iphone_bank (
						steamid INT,
						money INT,
						PRIMARY KEY (steamid)
					);
				]]
			end
		else
			require("mysqloo")

			if mysqloo == nil then
				MsgC(Color(255, 0, 0), "[iPhone] Failed to load mysqloo, please check if it is installed\n")
				return
			end

			local db = mysqloo.connect(mysql_config.host,
				mysql_config.username,
				mysql_config.password,
				mysql_config.database,
				tonumber(mysql_config.port)
			)

			function db:onConnected()
				MsgC(Color(0, 255, 0), "[iPhone] Successfuly connected to the database\n")

				local query = self:query[[
					CREATE TABLE iphone_bank (
						steamid BIGINT,
						money BIGINT,
						PRIMARY KEY (steamid)
					);
				]]

				query:start()

				mysql = self
			end

			function db:onConnectionFailed(err)
				MsgC(Color(255, 0, 0), "[iPhone] Can't connect to the database! (" .. err .. ")\n")
			end

			db:setAutoReconnect(true)
			db:connect()
			db:wait()
		end
	end,
	getBankMoney = function(ply, callback)
		if not useMySQL then
			callback(sql.QueryValue("SELECT money FROM iphone_bank WHERE steamid = " .. ply:SteamID64() .. ";") or 0)
		else
			if not mysql then
				callback("ERROR")
				return
			end

			local query = mysql:query("SELECT * FROM iphone_bank WHERE steamid = " .. ply:SteamID64() .. ";")

			function query:onSuccess(res)
				if istable(res) and res[1] then
					callback(res[1].money)
				else
					callback(0)
				end
			end

			function query:onError(err)
				MsgC(Color(255, 0, 0), "[iPhone] Can't query bank money from the database: " .. err)
				callback("ERROR")
			end

			query:start()
		end
	end,
	setBankMoney = function(ply, money)
		money = tonumber(money)
		if not money then
			return false
		end

		if not useMySQL then
			sql.Query("INSERT OR REPLACE INTO iphone_bank VALUES (" .. ply:SteamID64() .. ", " .. money .. ");")
		else
			if not mysql then
				return false
			end

			local query = mysql:query("INSERT INTO iphone_bank (steamid, money) VALUES (" .. ply:SteamID64() .. ", "
				.. money .. ") ON DUPLICATE KEY UPDATE money = " .. money .. ";")

			/*function query:onSuccess(res)
				print('success')
			end

			function query:onError(err)
				MsgC(Color(255, 0, 0), "[iPhone] Can't set bank money in the database: " .. err)
			end*/

			query:start()
		end

		return true
	end
}