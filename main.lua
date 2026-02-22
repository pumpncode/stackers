local function get_wins_by_key(card)
	local profile = G.PROFILES[G.SETTINGS.profile];

	if card.params and card.params.sleeve_card then
		local key = card.config and card.config.center and card.config.center
			.key;

		if key and profile.sleeve_usage and profile.sleeve_usage[key]
			and profile.sleeve_usage[key].wins_by_key then
			return profile.sleeve_usage[key].wins_by_key;
		end;

		return nil;
	end;

	if card.sprite_facing ~= "back" then
		local key = card.config and card.config.center_key;

		if key and profile.joker_usage and profile.joker_usage[key]
			and profile.joker_usage[key].wins then
			return profile.joker_usage[key].wins_by_key;
		end;

		return nil;
	end;

	if profile.deck_usage then
		local key = card.config and card.config.center_key;

		if key and profile.deck_usage[key] and profile.deck_usage[key].wins_by_key then
			return profile.deck_usage[key].wins_by_key;
		end;

		if G.GAME and G.GAME.viewed_back then
			local vb = G.GAME.viewed_back.effect and
				G.GAME.viewed_back.effect.center;

			if vb and vb.key and profile.deck_usage[vb.key]
				and profile.deck_usage[vb.key].wins_by_key then
				return profile.deck_usage[vb.key].wins_by_key;
			end;
		end;
	end;

	return nil;
end;

local function get_all_win_stakes(card)
	local wins_by_key = get_wins_by_key(card);

	if not wins_by_key then return {}; end;

	local applied = {};

	for k, v in pairs(wins_by_key) do
		SMODS.build_stake_chain(G.P_STAKES[k], applied);
	end;

	local result = {};

	for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
		if applied[v.order] then result[#result + 1] = v; end;
	end;

	return result;
end;

local function get_cached_stakes(card)
	local cache_key = card.sticker or card.sticker_run or "";

	if card._stackers_key == cache_key and card._stackers_list then
		return card._stackers_list;
	end;

	local stakes = {};

	if card.sticker or (card.sticker_run and card.sticker_run ~= "NONE"
			and G.SETTINGS.run_stake_stickers) then
		stakes = get_all_win_stakes(card);
	end;

	card._stackers_list = stakes;

	card._stackers_key = cache_key;

	return stakes;
end;

local max_height = 0.5;

local step = 0.1;

local function draw_stacked(card, stakes, no_tilt, rotation, ox, oy_base)
	local n = #stakes;

	local step = n > 1 and math.min(step, max_height / (n - 1)) or
		0;

	for i, stake in ipairs(stakes) do
		local name = G.sticker_map[stake.key];

		if name and G.shared_stickers[name] then
			local sprite = G.shared_stickers[name];

			sprite.role.draw_major = card;

			local my = (n - i) * step + (oy_base or 0);

			sprite:draw_shader("dissolve", nil, nil, no_tilt,
				card.children.center, nil, rotation, ox, my);

			if stake.shiny then
				sprite:draw_shader("voucher", nil,
					card.ARGS.send_to_shader, no_tilt,
					card.children.center, nil, rotation, ox, my);
			end;
		end;
	end;
end;

local old_stickers = SMODS.DrawSteps.stickers.func;

SMODS.DrawStep:take_ownership("stickers", {
	func = function(self, layer)
		local stakes = get_cached_stakes(self);

		if #stakes > 0 then
			draw_stacked(self, stakes);

			for k, v in pairs(SMODS.Stickers) do
				if self.ability[v.key] then
					if v.draw and type(v.draw) == "function" then
						v:draw(self, layer);
					else
						G.shared_stickers[v.key].role.draw_major = self;

						G.shared_stickers[v.key]:draw_shader("dissolve", nil, nil,
							nil, self.children.center);

						G.shared_stickers[v.key]:draw_shader("voucher", nil,
							self.ARGS.send_to_shader, nil, self.children.center);
					end;
				end;
			end;
		else
			old_stickers(self, layer);
		end;
	end
});

local old_back = SMODS.DrawSteps.back_sticker.func;

SMODS.DrawStep:take_ownership("back_sticker", {
	func = function(self)
		local stakes = get_cached_stakes(self);

		if #stakes > 0 then
			local off = self.sticker_offset or {};

			draw_stacked(self, stakes, true, self.sticker_rotation, off.x, off.y);
		else
			old_back(self);
		end;
	end
});

local old_generate_UIBox_ability_table = Card.generate_UIBox_ability_table;

function Card:generate_UIBox_ability_table(...)
	local stakes = get_cached_stakes(self);

	if #stakes <= 0 then
		return old_generate_UIBox_ability_table(self, ...);
	end;

	local saved_sticker = self.sticker;

	local saved_sticker_run = self.sticker_run;

	self.sticker = nil;

	self.sticker_run = nil;

	local full_UI_table = old_generate_UIBox_ability_table(self, ...);

	self.sticker = saved_sticker;

	self.sticker_run = saved_sticker_run;

	for _, stake in ipairs(stakes) do
		local name = G.sticker_map[stake.key];

		if name then
			generate_card_ui(
				{
					key = string.lower(name) .. "_sticker",
					set = "Other"
				}, full_UI_table);
		end;
	end;

	return full_UI_table;
end;
