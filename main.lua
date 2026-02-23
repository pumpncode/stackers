import = assert(
	loadfile(
		love.filesystem.getSaveDirectory()
			.. "/"
			.. SMODS.current_mod.path
			.. "import.lua"
	)
)()

local imports = import("./utilities/_exports.lua")
local drawStacked = imports.drawStacked
local getCachedStakes = imports.getCachedStakes

local oldStickers = SMODS.DrawSteps.stickers.func

SMODS.DrawStep:take_ownership("stickers", {
	func = function(self, layer)
		local stakes = getCachedStakes(self)

		if #stakes > 0 then
			drawStacked(self, stakes)
			for _, v in pairs(SMODS.Stickers) do
				if self.ability[v.key] then
					if v.draw and type(v.draw) == "function" then
						v:draw(self, layer)
					else
						G.shared_stickers[v.key].role.draw_major = self
						G.shared_stickers[v.key]:draw_shader(
							"dissolve",
							nil,
							nil,
							nil,
							self.children.center
						)
						G.shared_stickers[v.key]:draw_shader(
							"voucher",
							nil,
							self.ARGS.send_to_shader,
							nil,
							self.children.center
						)
					end
				end
			end
		else
			if oldStickers ~= nil then
				oldStickers(self, layer)
			end
		end
	end,
})

local oldBackSticker = SMODS.DrawSteps.back_sticker.func

SMODS.DrawStep:take_ownership("back_sticker", {
	func = function(self)
		local stakes = getCachedStakes(self)

		if #stakes > 0 then
			local off = self.sticker_offset or {}
			drawStacked(self, stakes, true, self.sticker_rotation, off.x, off.y)
		else
			if oldBackSticker ~= nil then
				oldBackSticker(self)
			end
		end
	end,
})

local oldGenerateUIBoxAbilityTable = Card.generate_UIBox_ability_table

local maximumStakesListed = 10
local maximumLineWidth = 25
local cachedTemplate = nil

function Card:generate_UIBox_ability_table(...)
	local stakes = getCachedStakes(self)
	if #stakes <= 0 then
		return oldGenerateUIBoxAbilityTable(self, ...)
	end

	local savedSticker = self.sticker
	local savedStickerRun = self.sticker_run
	self.sticker = nil
	self.sticker_run = nil

	local fullUITable = oldGenerateUIBoxAbilityTable(self, ...)

	self.sticker = savedSticker
	self.sticker_run = savedStickerRun

	local names = {}
	for _, stake in ipairs(stakes) do
		local loc = G.localization.descriptions.Stake[stake.key]
		if loc then
			local suffix = G.localization.misc.dictionary.stackers_stake_suffix
				or ""
			local pattern = suffix:gsub("(%W)", "%%%1") .. "$"
			names[#names + 1] = loc.name:gsub(pattern, "")
		end
	end

	if #names > 0 then
		if not cachedTemplate then
			local loc_entry = G.localization.descriptions.Other.stackers_tooltip
			cachedTemplate = {
				name = loc_entry.name,
				text = table.concat(loc_entry.text, " "),
			}
		end
		local dict = G.localization.misc.dictionary

		local stakeList
		if #names <= maximumStakesListed then
			if #names == 1 then
				stakeList = "{C:attention}"
					.. names[1]
					.. "{} {C:attention}"
					.. dict.stackers_stake
					.. "{}"
			else
				local parts = {}
				for i = 1, #names - 1 do
					parts[#parts + 1] = "{C:attention}" .. names[i] .. "{}"
				end
				stakeList = table.concat(parts, ", ")
					.. " "
					.. dict.stackers_and
					.. " {C:attention}"
					.. names[#names]
					.. "{} {C:attention}"
					.. dict.stackers_stake
					.. "{}"
			end
		else
			local parts = {}
			for i = 1, maximumStakesListed do
				parts[#parts + 1] = "{C:attention}" .. names[i] .. "{}"
			end
			local remaining = #names - maximumStakesListed
			stakeList = table.concat(parts, ", ")
				.. " "
				.. dict.stackers_and
				.. " {C:attention}"
				.. remaining
				.. " "
				.. dict.stackers_other
				.. " "
				.. (remaining == 1 and dict.stackers_stake or dict.stackers_stakes)
				.. "{}"
		end

		local sentence = cachedTemplate.text:gsub("#1#", stakeList)

		local words = {}
		for word in sentence:gmatch("%S+") do
			words[#words + 1] = word
		end
		local lines = {}
		local current = ""
		for _, word in ipairs(words) do
			local test = current == "" and word or (current .. " " .. word)
			local visible = #test:gsub("{[^}]*}", "")
			if visible > maximumLineWidth and current ~= "" then
				lines[#lines + 1] = current
				current = word
			else
				current = test
			end
		end
		if current ~= "" then
			lines[#lines + 1] = current
		end

		local text_parsed = {}
		for _, l in ipairs(lines) do
			text_parsed[#text_parsed + 1] = loc_parse_string(l)
		end
		local name_parsed = { loc_parse_string(cachedTemplate.name) }
		G.localization.descriptions.Other.stackers_tooltip = {
			name = cachedTemplate.name,
			text = lines,
			text_parsed = text_parsed,
			name_parsed = name_parsed,
		}
		generate_card_ui({
			key = "stackers_tooltip",
			set = "Other",
		}, fullUITable)
	end

	return fullUITable
end
