local imports = import("./draw-stacked/_exports.lua")
local alignStickerQuad = imports.alignStickerQuad
local getRefBounds = imports.getRefBounds

local maxHeight = 0.5
local step = 0.1

local function drawStacked(card, stakes, noTilt, rotation, ox, oyBase)
	local n = #stakes
	local band = n > 1 and math.min(step, maxHeight / (n - 1)) or 0

	getRefBounds()

	for i, stake in ipairs(stakes) do
		local name = G.sticker_map[stake.key]
		if name and G.shared_stickers[name] then
			local sprite = G.shared_stickers[name]
			sprite.role.draw_major = card
			alignStickerQuad(name)

			local my = (n - i) * band + (oyBase or 0)
			sprite:draw_shader(
				"dissolve",
				nil,
				nil,
				noTilt,
				card.children.center,
				nil,
				rotation,
				ox,
				my
			)
			if stake.shiny then
				sprite:draw_shader(
					"voucher",
					nil,
					card.ARGS.send_to_shader,
					noTilt,
					card.children.center,
					nil,
					rotation,
					ox,
					my
				)
			end
		end
	end
end

return drawStacked
