local MOD_PATH = love.filesystem.getSaveDirectory()
	.. "/" .. SMODS.current_mod.path
local cache = {}

local function import(path)
	if path:sub(1, 2) == "./" then
		local source = debug.getinfo(2, "S").source:gsub("^@", "")
		local dir = source:match("(.*/)") or MOD_PATH
		path = dir .. path:sub(3)
	else
		path = MOD_PATH .. path
	end

	while path:find("/[^/]+/%.%./") do
		path = path:gsub("/[^/]+/%.%./", "/")
	end

	if cache[path] then
		return cache[path]
	end

	local result = assert(loadfile(path))()
	cache[path] = result
	return result
end

return import
