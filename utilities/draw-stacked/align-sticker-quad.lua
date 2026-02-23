local imports = import("./_common/_exports.lua")
local getStickerBounds = imports.getStickerBounds
local ref = imports.ref

local alignedCache = {}

local function alignStickerQuad(name)
	if alignedCache[name] then
		return
	end
	alignedCache[name] = true

	local bounds = getStickerBounds(name)
	if not bounds then
		return
	end

	local dt = bounds.top - ref.top
	local dr = ref.right - bounds.right
	if math.abs(dt) < 0.005 and math.abs(dr) < 0.005 then
		return
	end

	local sprite = G.shared_stickers[name]
	if not sprite or not sprite.sprite then
		return
	end

	local qx, qy, qw, qh = sprite.sprite:getViewport()
	sprite.sprite:setViewport(qx - dr * qw, qy + dt * qh, qw, qh)
end

return alignStickerQuad
