local turnmanager = { turn_list = {}, last_turn = 0 }

function turnmanager.roll_initiative(pid_list)
	turnmanager.turn_list = {}

	for i = 1, #pid_list do
		k = love.math.random(#pid_list + 1 - i)
		turnmanager.turn_list[i] = pid_list[k]
		pid_list[k] = pid_list[#pid_list + 1 - i]
	end
end

function turnmanager.get_turn_id()
	turnmanager.last_turn = turnmanager.last_turn + 1
	if turnmanager.last_turn > #turnmanager.turn_list then turnmanager.last_turn = 1 end

	return turnmanager.turn_list[turnmanager.last_turn]
end

return turnmanager
