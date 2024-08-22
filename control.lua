local thoughts = require("lib.thoughts")

local get_global_player = function(player_index)
    if not global.players[player_index] then
        global.players[player_index] = {}
    end
    return global.players[player_index]
end

local init = function()
    if not global.players then
        global.players = {}
    end
end

script.on_configuration_changed(function()
    init()
end)

script.on_init(function()
    init()
end)

local show_bubble = function(player)
    local p = player

    -- Get item prototypes map
    local i = 1
    local map = {}
    for name, prototype in pairs(game.item_prototypes) do
        map[i] = name
        i = i + 1
    end

    -- Get variables
    local gp = get_global_player(p.index)
    local TTL = settings.global["tb_thought-duration"].value * 60

    -- Get random non-hidden item to think about
    local itm
    while not itm do
        local is_hidden = false
        itm = map[math.random(1, #map)]
        if game.item_prototypes[itm].has_flag("hidden") then
            itm = nil
        end
    end

    -- Draw a new bubble
    local pos = {
        x = 1.3,
        y = -2.7
    }
    local prop = {
        sprite = "thought-bubble",
        target = p.character,
        target_offset = pos,
        surface = p.character.surface,
        time_to_live = TTL,
        players = {p},
        x_scale = 0.6,
        y_scale = 0.6
    }
    gp.bubble = rendering.draw_sprite(prop)

    local iprop = {
        sprite = "item." .. itm,
        target = p.character,
        target_offset = {pos.x + 0.08, pos.y - 0.23},
        surface = p.character.surface,
        time_to_live = TTL,
        players = {p},
        x_scale = 0.8,
        y_scale = 0.8
    }

    gp.icon = rendering.draw_sprite(iprop)
end

local get_thought_categories = function()
    local cat = {}
    if settings.global["tb_show-thoughts_joking"].value then
        table.insert(cat, "joking")
    end
    if settings.global["tb_show-thoughts_sentient"].value then
        table.insert(cat, "sentient")
    end
    if settings.global["tb_show-thoughts_depressed"].value then
        table.insert(cat, "depressed")
    end
    if settings.global["tb_show-thoughts_factorio"].value then
        table.insert(cat, "factorio")
    end
    if game.active_mods["expansion-reminder"] and settings.global["tb_show-thoughts_fff"].value then
        table.insert(cat, "fff")
    end
    return cat
end

local has_thoughts_categories = function()
    local cat = get_thought_categories()
    if #cat > 0 then
        return true
    else
        return false
    end
end

local show_thought = function(player)
    local p = player

    -- Get variables
    local gp = get_global_player(p.index)
    local TTL = settings.global["tb_thought-duration"].value * 60

    -- Get random thought
    local pos = {
        x = -3.5,
        y = -3.35
    }

    -- Compose array of thought categories
    local cat = get_thought_categories()

    -- Early exit if no array
    if #cat == 0 then
        return
    end

    -- Get thought text
    local rnd = cat[math.random(1, #cat)]
    local t
    if rnd == "joking" or rnd == "sentient" or rnd == "depressed" or rnd == "factorio" then
        -- Get random thought from the chosen category
        t = thoughts[rnd][math.random(1, #thoughts[rnd])]
    elseif rnd == "fff" then
        -- Get friday fact thought
        local fact = remote.call("friday-facts", "get-random-fact")
        if fact.detail then
            t = fact.fff .. ": " .. fact.detail.summary
        else
            t = fact.fff .. ": " .. fact.title
        end
    else
        t = "Hmm the mod creator made an error, I'm having a hard coded thought which should not occur..."
    end
    local prop = {
        text = t,
        surface = p.character.surface,
        target = p.character,
        target_offset = pos,
        color = {1, 1, 1},
        players = {p},
        time_to_live = TTL
    }
    gp.text = rendering.draw_text(prop)

    local lprop = {
        color = {1, 1, 1},
        width = 1,
        from = p.character,
        to = p.character,
        from_offset = {pos.x + 3.1, pos.y + 1.65},
        to_offset = {pos.x + 2.4, pos.y + 0.7},
        surface = p.character.surface,
        time_to_live = TTL
    }
    gp.line = rendering.draw_line(lprop)
end

script.on_event(defines.events.on_tick, function(e)
    -- Loop through players
    for _, p in pairs(game.players) do
        -- Only if the player has a character
        if p.character then
            local gp = get_global_player(p.index)
            local last_bubble_tick = gp.last_bubble_tick or 0

            -- Check if the last bubble was more than 10sec ago
            local ticks_since_last_thought = e.tick - last_bubble_tick
            local tick_threshold = (settings.global["tb_thought-duration"].value +
                                       settings.global["tb_time-between-thoughts"].value) * 60
            if ticks_since_last_thought > tick_threshold then

                -- Check which settings are enabled
                local show_thoughts = has_thoughts_categories()
                local show_bubbles = settings.global["tb_show-bubbles"].value
                if show_bubbles and show_thoughts then
                    -- 50/50 chance on a bubble or thought
                    if math.random(1, 2) == 1 then
                        show_bubble(p)
                    else
                        show_thought(p)
                    end
                elseif show_bubbles then
                    show_bubble(p)
                elseif show_thoughts then
                    show_thought(p)
                end

                gp.last_bubble_tick = e.tick
            end
        end
    end
end)
