iphone_config = {
	-- time format
	-- true for international 24-hour clock format
	-- false for US 12-hour clock format
	internationalTime = true,

	-- if you wish to use Server Website widget, copy the URL for your project's website / store
	-- ex: "https://google.com",
	-- if you don't want to use the widget, you can leave this empty
	website_widget_link = "https://google.com",
	website_widget_name = "Donate",

	-- discord link, leave empty to disable the widget
	discord_widget_link = "https://discord.gg/XXXXXXXX",

	-- set to true if you want online players to show in Contacts app
	-- or false if you want players to add phone numbers manually
	show_online_players_in_contacts = true,

	-- here you can disable applications from showing on the home screen, use the file name (iphone/apps/)
	disabled_apps = {
		-- "bank1",
		-- "store",
	},

	-- avaliable languages: 'en', 'fr', 'ru'
	lang = "en",

	-- use mysqloo (true to use mysql, false for default sqlite)
	-- if you wish to use mysql, please download and install mysqloo dll!
	-- database settings can be found in lua/ephone/sql.lua
	mysql = false,

	-- custom items for the Store app
	store_items = {
		{
			-- the name must be unique
			name = "Example Item",

			price = 50,
			-- image URL, ends with ".png" or ".jpg"
			icon = "https://i.imgur.com/U0uCgWv.png",

			-- item type, can be "console", "darkrpentity", "weapon" or "custom"
			type = "custom",

			-- if you use "custom" item type, this function will run when the player buys the item
			customCode = function(buyer)
				buyer:ChatPrint("You have bought the example item!")
			end,
		},

		{
			name = "Example Weapon",
			price = 100,
			icon = "https://i.imgur.com/aEvVWW1.png",
			type = "weapon",

			-- weapon class
			classname = "weapon_frag",
		},
		{
			name = "`say` Console command",
			price = 10,
			icon = "https://i.imgur.com/7wsx9qb.png",
			type = "console",

			-- server console command
			-- {nickname}, {steamid} and {steamid64} are replaced correspondingly
			command = [[say "{nickname} {steamid} {steamid64} is cool!"]],
		},
		{
			name = "Example Entity",
			price = 100,
			icon = "https://i.imgur.com/DJQZ1Q2.png",
			type = "darkrpentity",

			-- unique entity cmd as defined with DarkRP.createEntity
			cmd = "buymoneyprinter",
		},
	},

	-- Here you can put the name of the item that should show at the top with a big banner
	store_featured_item = "Example Item",

	-- change this if you don't have DarkRP or you want to use custom currencies
	currency_format = function(money)
		return DarkRP.formatMoney(money)
	end,
	addMoney = function(ply, money)
		ply:addMoney(money)
	end,
	canAfford = function(ply, money)
		return ply:canAfford(money)
	end,
}

return iphone_config