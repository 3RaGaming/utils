-- @module admin
-- A 3Ra Gaming creation

global.green = { r = 0, g = 1, b = 0 }
global.red = { r = 1, g = 0, b = 0 }

global.follow_targets = {}
global.original_position = {}
global.original_surface = {}

local function update_position(event)
    for player_index, follow_target_index in pairs(global.follow_targets) do
        if follow_target_index then
            local player = game.connected_players[player_index]
            local follow_target = game.connected_players[follow_target_index]
            player.teleport(follow_target.position, follow_target.surface)
        end
    end
end

Event.register(defines.events.on_tick, update_position)


-- Handle various gui clicks, either spectate or character modification
-- @param event gui click event
local function gui_click(event)
    local i = event.player_index
    local p = game.players[i]
    local e = event.element.name
    if e == "character" and event.element.caption == "Disabled" then
        p.print("Character modification disabled in Spectator mode.")
        return
    end
    if e ~= nil then
        if e == "spectate" then
            if not p.admin then
                p.gui.top.spectate.destroy()
                p.print("You are no longer an admin.")
                return
            end
            force_spectators(i)
        elseif e == "character" then
            p.gui.top.character.destroy()
            create_character_gui(i)
        elseif e == "character_close" then
            p.gui.top.character_panel.destroy()
            p.gui.top.add { name = "character", type = "button", direction = "vertical", caption = "Character" }
        elseif e == "character_pickup" then
            if global.player_character_stats[i].item_loot_pickup then
                global.player_character_stats[i].item_loot_pickup = false
                event.element.style.font_color = global.red
                p.character_item_pickup_distance_bonus = 0
                p.character_loot_pickup_distance_bonus = 0
            else
                global.player_character_stats[i].item_loot_pickup = true
                event.element.style.font_color = global.green
                p.character_item_pickup_distance_bonus = 125
                p.character_loot_pickup_distance_bonus = 125
            end
        elseif e == "character_reach" then
            if global.player_character_stats[i].build_itemdrop_reach_resourcereach_distance then
                global.player_character_stats[i].build_itemdrop_reach_resourcereach_distance = false
                event.element.style.font_color = global.red
                p.character_build_distance_bonus = 0
                p.character_item_drop_distance_bonus = 0
                p.character_reach_distance_bonus = 0
                p.character_resource_reach_distance_bonus = 0
            else
                global.player_character_stats[i].build_itemdrop_reach_resourcereach_distance = true
                event.element.style.font_color = global.green
                p.character_build_distance_bonus = 125
                p.character_item_drop_distance_bonus = 125
                p.character_reach_distance_bonus = 125
                p.character_resource_reach_distance_bonus = 125
            end
        elseif e == "character_craft" then
            if global.player_character_stats[i].crafting_speed then
                global.player_character_stats[i].crafting_speed = false
                event.element.style.font_color = global.red
                p.character_crafting_speed_modifier = 0
            else
                global.player_character_stats[i].crafting_speed = true
                event.element.style.font_color = global.green
                p.character_crafting_speed_modifier = 60
            end
        elseif e == "character_mine" then
            if global.player_character_stats[i].mining_speed then
                global.player_character_stats[i].mining_speed = false
                event.element.style.font_color = global.red
                p.character_mining_speed_modifier = 0
            else
                global.player_character_stats[i].mining_speed = true
                event.element.style.font_color = global.green
                p.character_mining_speed_modifier = 150
            end
        elseif e == "character_run1" then
            local run_table = event.element.parent
            run_table.character_run1.state = true
            run_table.character_run2.state = false
            run_table.character_run3.state = false
            run_table.character_run5.state = false
            run_table.character_run10.state = false
            p.character_running_speed_modifier = 0
            global.player_character_stats[i].running_speed = 0
        elseif e == "character_run2" then
            local run_table = event.element.parent
            run_table.character_run1.state = false
            run_table.character_run2.state = true
            run_table.character_run3.state = false
            run_table.character_run5.state = false
            run_table.character_run10.state = false
            p.character_running_speed_modifier = 1
            global.player_character_stats[i].running_speed = 1
        elseif e == "character_run3" then
            local run_table = event.element.parent
            run_table.character_run1.state = false
            run_table.character_run2.state = false
            run_table.character_run3.state = true
            run_table.character_run5.state = false
            run_table.character_run10.state = false
            p.character_running_speed_modifier = 2
            global.player_character_stats[i].running_speed = 2
        elseif e == "character_run5" then
            local run_table = event.element.parent
            run_table.character_run1.state = false
            run_table.character_run2.state = false
            run_table.character_run3.state = false
            run_table.character_run5.state = true
            run_table.character_run10.state = false
            p.character_running_speed_modifier = 4
            global.player_character_stats[i].running_speed = 4
        elseif e == "character_run10" then
            local run_table = event.element.parent
            run_table.character_run1.state = false
            run_table.character_run2.state = false
            run_table.character_run3.state = false
            run_table.character_run5.state = false
            run_table.character_run10.state = true
            p.character_running_speed_modifier = 9
            global.player_character_stats[i].running_speed = 9
        elseif e == "follow" then
            toggle_follow_panel(p)
        elseif e == "unfollow" then
            global.follow_targets[i] = nil
        elseif e == "return" then
            global.follow_targets[i] = nil
            p.teleport(global.original_position[i], global.original_surface[i])
        end
        --set who to follow
        for _, player in pairs(game.connected_players) do
            if e == player.name then
                global.original_position[i] = player.position
                global.original_surface[i] = player.surface
                global.follow_targets[i] = player.index
            end
        end
    end
end

Event.register(defines.events.on_gui_click, gui_click)

-- Create the full character GUI for admins to update their character settings
-- @param index index of the player to change
function create_character_gui(index)
    local player = game.players[index]
    local character_frame = player.gui.top.add { name = "character_panel", type = "frame", direction = "vertical", caption = "Character" }
    character_frame.add { name = "character_pickup", type = "button", caption = "Pickup" }
    character_frame.add { name = "character_reach", type = "button", caption = "Reach" }
    character_frame.add { name = "character_craft", type = "button", caption = "Crafting" }
    character_frame.add { name = "character_mine", type = "button", caption = "Mining" }
    character_frame.add { name = "run_label", type = "label", caption = "Run speed control:" }
    local run_table = character_frame.add { name = "character_run", type = "table", colspan = 5, caption = "Run Speed" }
    run_table.add { name = "run1_label", type = "label", caption = "1x" }
    run_table.add { name = "run2_label", type = "label", caption = "2x" }
    run_table.add { name = "run3_label", type = "label", caption = "3x" }
    run_table.add { name = "run5_label", type = "label", caption = "5x" }
    run_table.add { name = "run10git pull origin master_label", type = "label", caption = "10x" }
    run_table.add { name = "character_run1", type = "radiobutton", state = false }
    run_table.add { name = "character_run2", type = "radiobutton", state = false }
    run_table.add { name = "character_run3", type = "radiobutton", state = false }
    run_table.add { name = "character_run5", type = "radiobutton", state = false }
    run_table.add { name = "character_run10", type = "radiobutton", state = false }
    character_frame.add { name = "character_close", type = "button", caption = "Close" }
    update_character_settings(index)
end

-- Updates the full character GUI to show the current settings
-- @param index index of the player to change
function update_character_settings(index)
    local char_gui = game.players[index].gui.top.character_panel
    local settings = global.player_character_stats[index]

    if settings.item_loot_pickup then
        char_gui.character_pickup.style.font_color = global.green
    else
        char_gui.character_pickup.style.font_color = global.red
    end

    if settings.build_itemdrop_reach_resourcereach_distance then
        char_gui.character_reach.style.font_color = global.green
    else
        char_gui.character_reach.style.font_color = global.red
    end

    if settings.crafting_speed then
        char_gui.character_craft.style.font_color = global.green
    else
        char_gui.character_craft.style.font_color = global.red
    end

    if settings.mining_speed then
        char_gui.character_mine.style.font_color = global.green
    else
        char_gui.character_mine.style.font_color = global.red
    end

    local run_table = char_gui.character_run
    if settings.running_speed == 0 then
        run_table.character_run1.state = true
    elseif settings.running_speed == 1 then
        run_table.character_run2.state = true
    elseif settings.running_speed == 2 then
        run_table.character_run3.state = true
    elseif settings.running_speed == 4 then
        run_table.character_run5.state = true
    elseif settings.running_speed == 9 then
        run_table.character_run10.state = true
    end
end

-- Updates the new character of an admin coming out of spectate mode
-- @param index index of the player to change
function update_character(index)
    local player = game.players[index]
    local settings = global.player_character_stats[index]

    if settings.item_loot_pickup then
        player.character_item_pickup_distance_bonus = 125
        player.character_loot_pickup_distance_bonus = 125
    end

    if settings.build_itemdrop_reach_resourcereach_distance then
        player.character_item_drop_distance_bonus = 125
        player.character_reach_distance_bonus = 125
        player.character_resource_reach_distance_bonus = 125
    end

    if settings.crafting_speed then
        player.character_crafting_speed_modifier = 60
    end

    if settings.mining_speed then
        player.character_mining_speed_modifier = 150
    end

    player.character_running_speed_modifier = settings.running_speed
end

local function update_follow_panel(player)
    if player.gui.left.follow_panel then
        player.gui.left.follow_panel.destroy()

        local follow_frame = player.gui.left.add { name = "follow_panel", type = "table", colspan = 10, caption = "Choose player to follow" }
        for _, player in pairs(game.connected_players) do
            follow_frame.add { name = player.name, type = "button", caption = player.name }
        end
        follow_frame.add { name = "unfollow", type = "button", caption = "Unfollow" }
        follow_frame.add { name = "return", type = "button", caption = "Return" }
    end
end

function toggle_follow_panel(player)
    if player.gui.left.follow_panel then
        player.gui.left.follow_panel.destroy()
        global.follow_targets[player.index] = nil
    else
        player.gui.left.add { name = "follow_panel", type = "frame" }
        update_follow_panel(player)
    end
end

local function connected_players_changed(event)
    local changed_player = game.players[event.player_index]
    for player, follow_target in pairs(global.follow_targets) do
        if player == changed_player or follow_target == changed_player then
            global.follow_targets[player.index] = nil
        end
    end

    for _, player in pairs(game.connected_players) do
        update_follow_panel(player)
    end
end

Event.register(defines.events.on_player_joined_game, connected_players_changed)
Event.register(defines.events.on_player_left_game, connected_players_changed)

-- Announce an admin's joining and give them the admin gui
-- @param event player joined event
local function admin_joined(event)
    local index = event.player_index
    local player = game.players[index]
    global.player_character_stats = global.player_character_stats or {}
    if player.admin then
        if not player.gui.top.spectate then
            player.gui.top.add { name = "spectate", type = "button", direction = "horizontal", caption = "Spectate" }
        end
        if not player.gui.top.character then
            player.gui.top.add { name = "character", type = "button", direction = "vertical", caption = "Character" }
        end
        if global.player_character_stats[index] == nil then
            global.player_character_stats[index] = {
                item_loot_pickup = false,
                build_itemdrop_reach_resourcereach_distance = false,
                crafting_speed = false,
                mining_speed = false,
                running_speed = 0
            }
        end

        game.print("All Hail Admin " .. player.name)
    end
end

Event.register(defines.events.on_player_joined_game, admin_joined)

-- Toggle the player's spectator state
-- @param index index of the player to change
function force_spectators(index)
    local player = game.players[index]
    global.player_spectator_state = global.player_spectator_state or {}
    global.player_spectator_character = global.player_spectator_character or {}
    global.player_spectator_force = global.player_spectator_force or {}
    if global.player_spectator_state[index] then
        --remove spectator mode
        if player.character == nil and global.player_spectator_character[index] then
            local pos = player.position
            if global.player_spectator_character[index].valid then
                player.set_controller { type = defines.controllers.character, character = global.player_spectator_character[index] }
            else
                player.set_controller { type = defines.controllers.character, character = player.surface.create_entity { name = "player", position = { 0, 0 }, force = global.player_spectator_force[index] } }
            end
            player.teleport(pos)
        end
        global.player_spectator_state[index] = false
        player.force = game.forces[global.player_spectator_force[index].name]
        player.print("Summoning your character")
        player.gui.top.spectate.caption = "Spectate"
        player.gui.top.character.caption = "Character"
        if player.gui.top.follow then
            player.gui.top.follow.destroy()
        end
        if player.gui.left.follow_panel then
            toggle_follow_panel(player)
        end
        update_character(index)
    else
        --put player in spectator mode
        if player.character then
            player.walking_state = { walking = false, direction = defines.direction.north }
            global.player_spectator_character[index] = player.character
            global.player_spectator_force[index] = player.force
            player.set_controller { type = defines.controllers.god }
            player.cheat_mode = true
        end
        if not game.forces["Spectators"] then game.create_force("Spectators") end
        player.force = game.forces["Spectators"]
        global.player_spectator_state[index] = true
        player.print("You are now a spectator")
        player.gui.top.spectate.caption = "Return"
        if player.gui.top.character_panel ~= nil then
            player.gui.top.character_panel.destroy()
            player.gui.top.add { name = "character", type = "button", direction = "vertical", caption = "Character" }
        end
        player.gui.top.character.caption = "Disabled"
        -- adds an option to follow another player.
        if player.gui.top.follow_panel == nil then
            player.gui.top.add { name = "follow", type = "button", caption = "Follow" }
        end
    end
end