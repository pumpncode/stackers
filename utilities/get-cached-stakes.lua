local imports = import("./get-cached-stakes/_exports.lua")
local getAllWinStakes = imports.getAllWinStakes

local function getCachedStakes(card)
	local cacheKey = card.sticker or card.sticker_run or ""
	if card._stackers_key == cacheKey and card._stackers_list then
		return card._stackers_list
	end

	local stakes = {}
	if
		card.sticker
		or (
			card.sticker_run
			and card.sticker_run ~= "NONE"
			and G.SETTINGS.run_stake_stickers
		)
	then
		stakes = getAllWinStakes(card)
	end

	card._stackers_list = stakes
	card._stackers_key = cacheKey
	return stakes
end

return getCachedStakes
