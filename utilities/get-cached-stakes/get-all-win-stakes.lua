local imports = import("./get-all-win-stakes/_exports.lua")
local getWinsByKey = imports.getWinsByKey

local function getAllWinStakes(card)
	local winsByKey = getWinsByKey(card)
	if not winsByKey then
		return {}
	end

	local won = {}
	for k, v in pairs(winsByKey) do
		if G.P_STAKES[k] then
			won[G.P_STAKES[k].order] = true
		end
	end

	local result = {}
	for _, v in ipairs(G.P_CENTER_POOLS.Stake) do
		local name = G.sticker_map[v.key]
		if won[v.order] and name and G.shared_stickers[name] then
			result[#result + 1] = v
		end
	end

	return result
end

return getAllWinStakes
