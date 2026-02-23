local boundsCache = {}

local function getStickerBounds(name)
	if boundsCache[name] ~= nil then
		return boundsCache[name]
	end

	local sprite = G.shared_stickers[name]
	if not sprite or not sprite.atlas or not sprite.sprite then
		boundsCache[name] = false
		return false
	end

	local qx, qy, qw, qh = sprite.sprite:getViewport()
	local data, sx, sy, scanW, scanH, shouldRelease

	if sprite.atlas.image_data then
		local dpi = sprite.atlas.image:getDPIScale()
		data = sprite.atlas.image_data
		sx, sy = math.floor(qx * dpi), math.floor(qy * dpi)
		scanW, scanH = math.floor(qw * dpi), math.floor(qh * dpi)
		shouldRelease = false
	elseif sprite.atlas.image then
		local cw, ch = math.ceil(qw), math.ceil(qh)
		local ok, canvas = pcall(love.graphics.newCanvas, cw, ch)
		if ok and canvas then
			love.graphics.push("all")
			love.graphics.setCanvas(canvas)
			love.graphics.origin()
			love.graphics.clear(0, 0, 0, 0)
			love.graphics.setShader()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(sprite.atlas.image, sprite.sprite, 0, 0)
			love.graphics.setCanvas()
			love.graphics.pop()
			data = canvas:newImageData()
			canvas:release()
			sx, sy = 0, 0
			scanW, scanH = cw, ch
			shouldRelease = true
		end
	end

	if not data then
		boundsCache[name] = false
		return false
	end

	local topRow, rightCol = -1, -1
	for y = 0, scanH - 1 do
		for x = 0, scanW - 1 do
			local _, _, _, a = data:getPixel(sx + x, sy + y)
			if a > 0.1 then
				if topRow < 0 then
					topRow = y
				end
				if x > rightCol then
					rightCol = x
				end
			end
		end
	end

	if shouldRelease then
		data:release()
	end

	if topRow < 0 then
		boundsCache[name] = false
		return false
	end

	boundsCache[name] = {
		top = topRow / scanH,
		right = (rightCol + 1) / scanW,
	}
	return boundsCache[name]
end

return getStickerBounds
