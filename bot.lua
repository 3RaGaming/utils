Event.register(defines.events.on_player_died, function (event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("PLAYER$die," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name)
	end
end)

Event.register(defines.events.on_player_respawned, function (event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("PLAYER$respawn," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name)
	end
end)

Event.register(defines.events.on_player_joined_game, function (event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("PLAYER$join," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name)
	end
end)

Event.register(defines.events.on_player_left_game, function (event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("PLAYER$leave," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name)
	end
end)
