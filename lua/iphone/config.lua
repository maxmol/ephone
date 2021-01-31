iphone_config = {
	-- if you wish to use the Store widget, copy the web address for your store
	-- ex: "https://google.com",
	-- if you don't want to use the widget, you can leave this empty
	store_widget_link = "https://google.com",

	-- discord link, leave empty to disable the widget
	discord_widget_link = "https://google.com",

	-- set to true if you want online players to show in Contacts app
	-- or false if you want players to add phone numbers manually
	show_online_players_in_contacts = true,

	-- here you can disable applications from showing on the home screen, use the file name (iphone/apps/)
	disabled_apps = {
		"maps",
	},

	-- avaliable languages: 'en', 'fr', 'ru'
	lang = "en",

	-- use mysqloo (true to use mysql, false for default sqlite)
	-- if you wish to use mysql, database settings can be found in sql.lua
	mysql = true,

	-- custom items for the Store app
	store_items = {
		{
			-- the name must be unique
			name = "Example Item",
			
			price = 50,
			-- image URL, ends with ".png" or ".jpg"
			icon = "https://i.imgur.com/YSPb4E0.png",

			-- item type, can be "entity", "weapon" or "custom"
			type = "custom",

			-- if you use "custom" item type, this function will run when the player buys the item
			customCode = function(buyer)
				buyer:ChatPrint("You have bought the example item!")
			end,
		},
		{name = "Example Item2",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item3",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item4",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item5",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item6",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item7",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item8",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item9",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item10",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item11",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item12",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
		{name = "Example Item13",	price = 50, icon = "https://i.imgur.com/YSPb4E0.png", type = "custom", customCode = function(buyer) buyer:ChatPrint("You have bought the example item!") end},
	},

	-- Here you can put the name of the item that should show at the top with a big banner
	store_featured_item = "Example Item",
}

return iphone_config