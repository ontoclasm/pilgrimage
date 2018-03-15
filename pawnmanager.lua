local pawnmanager = { last_id = 0 }

function pawnmanager.get_id()
	pawnmanager.last_id = pawnmanager.last_id + 1
	return pawnmanager.last_id
end

-- dumb placeholders
function pawnmanager.spawn_pawn(name, faction)
	local pid = pawnmanager.get_id()
	pawns[pid] = pawn:new(
		{
			id = pid,
			name = name .. pid,
			faction = faction,
			x = nil, y = nil, facing = 1,
			sprite = name,
			movespeed = 6, movetype = "walk",
			status = {}
		})
	return pid
end

return pawnmanager
