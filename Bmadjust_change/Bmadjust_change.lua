--- STEAMODDED HEADER
--- MOD_NAME: Bmadjust_change_Pro_Max
--- MOD_ID: Bmadjust_change
--- MOD_AUTHOR: ["BaiMao", "280chan"]
--- MOD_DESCRIPTION: Adjust and modify the original content, but in a more controlled way
--- BADGE_COLOUR: D9D919
--- PRIORITY: 1000
--- VERSION: 1.0.8t
----------------------------------------------
------------MOD CODE -------------------------

local function juice_flip(used_tarot)
    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.4,func = function()
        play_sound('tarot1')
        used_tarot:juice_up(0.3, 0.5)
    return true end}))
    for i = 1, #G.hand.cards do
        local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
            G.hand.cards[i]:flip(); play_sound('card1', percent); G.hand.cards[i]:juice_up(0.3, 0.3)
        return true end}))
    end
end

local function selected_destroy(used_tarot)
    local destroyed_cards = {}
    local temp_hand = {}
    for i = #G.hand.highlighted, 1, -1 do
        temp_hand[#temp_hand + 1] = G.hand.highlighted[i]
    end
    for i = 1, used_tarot.ability.extra do destroyed_cards[#destroyed_cards+1] = temp_hand[i] end
    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.4,func = function()
        play_sound('tarot1')
        used_tarot:juice_up(0.3, 0.5)
    return true end}))
    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
        for i = #destroyed_cards, 1, -1 do
            local card = destroyed_cards[i]
            if card.ability.name == 'Glass Card' then
                card:shatter()
            else
                card:start_dissolve(nil, i ~= #destroyed_cards)
            end
        end
    return true end}))
    return destroyed_cards
end

SMODS.Joker:take_ownership('hiker', {
    perishable_compat = false,
    config = {extra = {chips = 0, chip_mod = 10}},
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.end_of_round and not context.blueprint and G.GAME.current_round.hands_left >= 1 then
            card.ability.extra.chips = card.ability.extra.chips + (card.ability.extra.chip_mod*G.GAME.current_round.hands_left)
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
        end
        if context.cardarea == G.jokers and context.joker_main and card.ability.extra.chips >= 1 then
            return {
                message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips, 
                colour = G.C.CHIPS
            }
        end
    end
})

SMODS.Joker:take_ownership('ring_master', {
    config = {extra = nil},
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint and not card.ability.extra then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card and G.jokers.cards[i + 1] == context.card then
                    card.ability.extra = context.card.config.center_key
                    G.E_MANAGER:add_event(Event({func = function()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_copied_ex')})
                    return true end}))
                end
            end
        end
        if context.setting_blind and not context.blueprint and not card.getting_sliced and context.blind.boss and card.ability.extra then
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_joker')})
            for i = 1, 2 do
                local _card = create_card('Joker', G.jokers, nil, nil, nil, nil, card.ability.extra, 'rin')
                _card:set_edition({negative = true}, true)
                _card:add_to_deck()
                G.jokers:emplace(_card)
                _card:start_materialize()
            end
            card.ability.extra = nil
        end
    end
})

SMODS.Joker:take_ownership('troubadour', {
    config = {extra = {h_size = 1, t_h_size = 0}},
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            G.hand:change_size(card.ability.extra.h_size)
            card.ability.extra.t_h_size = card.ability.extra.t_h_size + card.ability.extra.h_size
            card_eval_status_text(card, 'jokers', nil, nil, nil, {message = localize('k_reward')})
        end
        if context.cardarea == G.jokers and context.end_of_round and not context.blueprint and card.ability.extra.t_h_size >= 1 then
            G.hand:change_size(-card.ability.extra.t_h_size)
            card.ability.extra.t_h_size = 0
            card_eval_status_text(card, 'jokers', nil, nil, nil, {message = localize('k_reset')})
        end
    end
})

SMODS.Joker:take_ownership('merry_andy', {
    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced then
            G.E_MANAGER:add_event(Event({func = function()
                ease_discard(card.ability.d_size)
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('b_discard'), colour = G.C.RED})
            return true end}))
        end
    end
})

SMODS.Joker:take_ownership('hit_the_road', {
    perishable_compat = false,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint and not context.other_card.debuff and context.other_card:get_id() == 11 then
            card.ability.x_mult = card.ability.x_mult + card.ability.extra
            for i = 1, #context.full_hand do
                if context.full_hand[i] == context.other_card then
                    for j = i + 1, #context.full_hand do
                        if context.full_hand[j]:get_id() == 11 and not context.full_hand[j].debuff then
                            return { remove = true }
                        end
                    end
                    return {
                        message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.x_mult}},
                        colour = G.C.RED,
                        remove = true,
                        card = card
                    }
                end
            end
        end
    end
})

SMODS.Joker:take_ownership('satellite', {
    config = {extra = {dollars = 1, increase = 1}},
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == 'Planet' then
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.increase
            G.E_MANAGER:add_event(Event({func = function()
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.BLUE})
            return true end}))
        end
    end
})

SMODS.Consumable:take_ownership('strength', {
    config = {mod_conv = 'up_rank', rank_conv = 0, max_highlighted = 2},
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            used_tarot:juice_up(0.3, 0.5)
        return true end}))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
                G.hand.highlighted[i]:flip()
                play_sound('card1', percent)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
            return true end}))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                assert(SMODS.modify_rank(G.hand.highlighted[i], used_tarot.ability.consumeable.rank_conv))
            return true end}))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
                G.hand.highlighted[i]:flip()
                play_sound('tarot2', percent, 0.6)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
            return true end}))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            G.hand:unhighlight_all()
        return true end}))
        delay(0.5)
    end,
})

SMODS.Consumable:take_ownership('sigil', {
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        juice_flip(used_tarot)
        local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('sigil'))
        if G.hand.highlighted[1] and G.hand.highlighted[1].ability.effect ~= 'Stone Card' and not G.hand.highlighted[1].config.center.no_suit then
            _suit = G.hand.highlighted[1].base.suit
            for i = 1, #G.hand.cards do
                G.E_MANAGER:add_event(Event({func = function()
                    local _card = G.hand.cards[i]
                    assert(SMODS.change_base(_card, _suit))
                return true end}))
            end
        else
            for i = 1, #G.hand.cards do
                G.E_MANAGER:add_event(Event({func = function()
                    local _card = G.hand.cards[i]
                    assert(SMODS.change_base(_card, _suit.key))
                return true end}))
            end
        end
        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.cards[i]:juice_up(0.3, 0.3)
            return true end}))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end}))
        delay(0.5)
    end,
    can_use = function(self, card)
        if #G.hand.highlighted <= 1 then
            return true
        end
    end
})

SMODS.Consumable:take_ownership('ouija', {
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        juice_flip(used_tarot)
        local _rank = pseudorandom_element(SMODS.Ranks, pseudoseed('ouija'))
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({func = function()
                local _card = G.hand.cards[i]
                assert(SMODS.change_base(_card, nil, _rank.key))
            return true end}))
        end
        G.hand:change_size(1)
        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.cards[i]:juice_up(0.3, 0.3)
            return true end}))
        end
        delay(0.5)
    end
})

SMODS.Consumable:take_ownership('grim', {
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local destroyed_cards = selected_destroy(used_tarot)
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.7,func = function()
            local cards = {}
            for i = 1, card.ability.extra do
                cards[i] = true
                local _suit, _rank = pseudorandom_element(SMODS.Suits, pseudoseed('grim_create')).card_key, 'A'
                local cen_pool = {}
                for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                    if v.key ~= 'm_stone' and not v.overrides_base_rank then
                        cen_pool[#cen_pool + 1] = v
                    end
                end
                create_playing_card({front = G.P_CARDS[_suit .. '_' .. _rank], center = pseudorandom_element(cen_pool, pseudoseed('spe_card'))}, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Spectral })
            end
            playing_card_joker_effects(cards)
        return true end}))
        delay(0.3)
        SMODS.calculate_context({ remove_playing_cards = true, removed = destroyed_cards })
    end
})

SMODS.Consumable:take_ownership('familiar', {
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local destroyed_cards = selected_destroy(used_tarot)
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.7,func = function()
            local cards = {}
            local faces = {}
            for _, v in ipairs(SMODS.Rank.obj_buffer) do
                local r = SMODS.Ranks[v]
                if r.face then table.insert(faces, r) end
            end
            local _rank = pseudorandom_element(faces, pseudoseed('familiar_create')).card_key
            for i = 1, card.ability.extra do
                cards[i] = true
                local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('familiar_create')).card_key
                local cen_pool = {}
                for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                    if v.key ~= 'm_stone' and not v.overrides_base_rank then
                        cen_pool[#cen_pool + 1] = v
                    end
                end
                create_playing_card({front = G.P_CARDS[_suit .. '_' .. _rank], center = pseudorandom_element(cen_pool, pseudoseed('spe_card'))}, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Spectral })
            end
            playing_card_joker_effects(cards)
        return true end}))
        delay(0.3)
        SMODS.calculate_context({ remove_playing_cards = true, removed = destroyed_cards })
    end
})

SMODS.Consumable:take_ownership('incantation', {
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local destroyed_cards = selected_destroy(used_tarot)
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.7,func = function()
            local cards = {}
            local numbers = {}
            for _, v in ipairs(SMODS.Rank.obj_buffer) do
                local r = SMODS.Ranks[v]
                if v ~= 'Ace' and not r.face then table.insert(numbers, r) end
            end
            local _rank = pseudorandom_element(numbers, pseudoseed('incantation_create')).card_key
            for i = 1, card.ability.extra do
                cards[i] = true
                local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('incantation_create')).card_key
                local cen_pool = {}
                for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                    if v.key ~= 'm_stone' and not v.overrides_base_rank then
                        cen_pool[#cen_pool + 1] = v
                    end
                end
                create_playing_card({front = G.P_CARDS[_suit .. '_' .. _rank], center = pseudorandom_element(cen_pool, pseudoseed('spe_card'))}, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Spectral })
            end
            playing_card_joker_effects(cards)
        return true end}))
        delay(0.3)
        SMODS.calculate_context({ remove_playing_cards = true, removed = destroyed_cards })
    end
})

function find_chicot(name, non_debuff)
    local jokers = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for k, v in pairs(G.jokers.cards) do
        if v and type(v) == 'table' and v.ability.name == name and v.ability.retriggers == 0 and (non_debuff or not v.debuff) then
            table.insert(jokers, v)
        end
    end
    return jokers
end

local Blind_set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    local cc = find_chicot("Chicot")
    if cc and #cc == 1 and not reset then
        self.config.prize = nil
        if blind then
            self.in_blind = true
        end
        self.config.blind = blind or {}
        self.name = blind and blind.name or '' --'Small Blind'
        self.dollars = blind and blind.dollars or 0
        self.sound_pings = self.dollars + 2
        if G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[self:get_type()] then self.dollars = 0 end
        self.debuff = blind and blind.debuff or {} --'Small Blind'
        self.pos = blind and blind.pos
        self.mult = blind and blind.boss and 1 or blind and blind.mult or 0 --'Small Blind'
        self.disabled = blind and blind.boss and true --'Small Blind'
        self.discards_sub = 0
        self.hands_sub = 0
        self.boss = blind and not not blind.boss --'Small Blind'
        self.blind_set = false
        self.triggered = nil
        self.prepped = true
        self:set_text()

        local obj = self.config.blind --'Small Blind'
        self.children.animatedSprite.atlas = G.ANIMATION_ATLAS[obj.atlas] or G.ANIMATION_ATLAS['blind_chips']
        G.GAME.last_blind = G.GAME.last_blind or {}
        G.GAME.last_blind.boss = self.boss
        G.GAME.last_blind.name = self.name

        if blind and blind.name then
            self:change_colour()
        else
            self:change_colour(G.C.BLACK)
        end

        self.chips = get_blind_amount(G.GAME.round_resets.ante)*self.mult*G.GAME.starting_params.ante_scaling
        self.chip_text = number_format(self.chips)

        if not blind then self.chips = 0 end

        G.GAME.current_round.dollars_to_be_earned = self.dollars > 0 and (string.rep(localize('$'), self.dollars)..'') or ('')
        G.HUD_blind.alignment.offset.y = -10
        G.HUD_blind:recalculate(false)

        if blind and blind.name and blind.name ~= '' then
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.05,blockable = false,func = (function()
                G.HUD_blind:get_UIE_by_ID("HUD_blind_name").states.visible = false
                G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").parent.parent.states.visible = false
                G.HUD_blind.alignment.offset.y = 0
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,blockable = false,func = (function()
                    G.HUD_blind:get_UIE_by_ID("HUD_blind_name").states.visible = true
                    G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").parent.parent.states.visible = true
                    G.HUD_blind:get_UIE_by_ID("dollars_to_be_earned").config.object:pop_in(0)
                    G.HUD_blind:get_UIE_by_ID("HUD_blind_name").config.object:pop_in(0)
                    G.HUD_blind:get_UIE_by_ID("HUD_blind_count"):juice_up()
                    self.children.animatedSprite:set_sprite_pos(self.config.blind.pos)
                    self.blind_set = true
                    G.ROOM.jiggle = G.ROOM.jiggle + 3
                    if not reset and not silent then
                        self:juice_up()
                        if blind then
                            play_sound('chips1', math.random()*0.1 + 0.55, 0.42);play_sound('gold_seal', math.random()*0.1 + 1.85, 0.26)
                        end
                    end
                return true end)}))
            return true end)}))
        end
        self.config.h_popup_config = {align="tm", offset = {x=0,y=-0.1}, parent = self}
        G.ARGS.spin.real = (G.SETTINGS.reduced_motion and 0 or 1)*(self.config.blind.boss and (self.config.blind.boss.showdown and 0.5 or 0.25) or 0)
    else
        Blind_set_blind_ref(self, blind, reset, silent)
    end
end

local Blind_disable_ref = Blind.disable
function Blind:disable()
    local cc = find_chicot("Chicot")
    if cc and #cc == 1 then
        return
    else
        Blind_disable_ref(self)
    end
end

local Card_add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    Card_add_to_deck_ref(self, from_debuff)
    if not self.added_to_deck then
        if self.ability.name == 'Chicot' then
            G.GAME.modifiers.scaling = 1
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        end
    end
end

function Blind:modify_hand_final(mult, hand_chips)
    if self.disabled then return mult, hand_chips, false end
    local obj = self.config.blind
    if obj.modify_hand_final and type(obj.modify_hand_final) == 'function' then
        return obj:modify_hand_final(mult, hand_chips)
    elseif self.name == 'Amber Acorn' and math.floor(hand_chips*mult) >= G.GAME.blind.chips/2 then
        self.triggered = true
        hand_chips = math.sqrt(G.GAME.blind.chips/2)
        mult = math.sqrt(G.GAME.blind.chips/2)
        return mult, hand_chips, true
    end
    return mult, hand_chips, false
end

local Blind_debuff_card_ref = Blind.debuff_card
function Blind:debuff_card(card, from_blind)
    if card.ability.name == "Wild Card" then card:set_debuff(false) return end
    return Blind_debuff_card_ref(self, card, from_blind)
end

local Card_highlight_ref = Card.highlight
function Card:highlight(is_higlighted)
    self.highlighted = is_higlighted
    if self.ability.consumeable and self.highlighted and self.ability.name == 'Strength' then
        if self.ability.consumeable.rank_conv >= 12 then
            self.ability.consumeable.rank_conv = 0
        elseif self.ability.consumeable.rank_conv < 12 then
            self.ability.consumeable.rank_conv = self.ability.consumeable.rank_conv + 1
        end
    end
    Card_highlight_ref(self, is_higlighted)
end

local G_FUNCS_can_discard_ref = G.FUNCS.can_discard
G.FUNCS.can_discard = function(e)
    local _back = nil
    if #G.hand.highlighted >= 1 then
        for i = 1, #G.hand.highlighted do
            if G.hand.highlighted[i].facing == 'back' then
                _back = true
                break
            end
        end
    end
    G_FUNCS_can_discard_ref(e)
end

----------------------------------------------
------------MOD CODE END----------------------