local imports = import("./_common/_exports.lua")
local getStickerBounds = imports.getStickerBounds
local ref = imports.ref

local function getRefBounds()
	if ref.top then
		return
	end

	local whiteName = G.sticker_map and G.sticker_map["stake_white"]
	if whiteName then
		local bounds = getStickerBounds(whiteName)
		if bounds then
			ref.top = bounds.top
			ref.right = bounds.right
			return
		end
	end

	ref.top = 6 / 95
	ref.right = (71 - 6) / 71
end

return getRefBounds
