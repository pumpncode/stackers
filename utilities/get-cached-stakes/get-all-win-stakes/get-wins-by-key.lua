local function getWinsByKey(card)
	local profile = G.PROFILES[G.SETTINGS.profile]

	if card.params and card.params.sleeve_card then
		local key = card.config
			and card.config.center
			and card.config.center.key

		if
			key
			and profile.sleeve_usage
			and profile.sleeve_usage[key]
			and profile.sleeve_usage[key].wins_by_key
		then
			return profile.sleeve_usage[key].wins_by_key
		end

		return nil
	end

	if card.sprite_facing ~= "back" then
		local key = card.config and card.config.center_key

		if
			key
			and profile.joker_usage
			and profile.joker_usage[key]
			and profile.joker_usage[key].wins
		then
			return profile.joker_usage[key].wins_by_key
		end

		return nil
	end

	if profile.deck_usage then
		local key = card.config and card.config.center_key

		if
			key
			and profile.deck_usage[key]
			and profile.deck_usage[key].wins_by_key
		then
			return profile.deck_usage[key].wins_by_key
		end

		if G.GAME and G.GAME.viewed_back then
			local vb = G.GAME.viewed_back.effect
				and G.GAME.viewed_back.effect.center

			if
				vb
				and vb.key
				and profile.deck_usage[vb.key]
				and profile.deck_usage[vb.key].wins_by_key
			then
				return profile.deck_usage[vb.key].wins_by_key
			end
		end
	end

	return nil
end

return getWinsByKey
