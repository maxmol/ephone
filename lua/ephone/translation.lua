if SERVER then
	AddCSLuaFile()

	local lang_files = file.Find('ephone/languages/*', 'LUA')

	for _, f in ipairs(lang_files) do
		AddCSLuaFile('ephone/languages/' .. f)
	end
end

local lang = include('ephone/languages/' .. iphone_config.lang .. '.lua')

return function(str, ...)
	local text = lang[str] or str

	if ... then
		text = string.format(text, ...)
	end

	return text
end