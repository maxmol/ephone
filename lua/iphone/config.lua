iphone_config = {
	-- if you wish to use the Store widget, copy the web address for your store
	-- ex: 'https://google.com',
	-- if you don't want to use the widget, you can leave this empty
	store_widget_link = 'https://google.com',

	-- discord link, leave empty to disable the widget
	discord_widget_link = 'https://google.com',

	-- set to true if you want all players to show in Contacts app
	-- or false if you want players to add phone numbers manually
	all_players_in_contacts = true,

	-- here you can disable applications from showing on the home screen, use the file name (iphone/apps/)
	disabled_apps = {
		'maps',
	},

	-- avaliable languages: 'en', 'fr', 'ru'
	lang = 'ru',

	-- use mysqloo (true to use mysql, false for default sqlite)
	-- if you wish to use mysql, database settings can be found in sql.lua
	mysql = true,
}

return iphone_config