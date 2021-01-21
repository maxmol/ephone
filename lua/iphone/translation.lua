if SERVER then
	AddCSLuaFile()

	local lang_files = file.Find('iphone/languages/*', 'LUA')

	for _, f in ipairs(lang_files) do
		AddCSLuaFile('iphone/languages/' .. f)
	end
end

local lang = include('iphone/languages/' .. iphone_config.lang .. '.lua')

return function(str, ...)
	local text = lang[str] or str

	if ... then
		text = string.format(text, ...)
	end

	return text
end