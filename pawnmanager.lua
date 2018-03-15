local pawnmanager = {}

-- dumb placeholders
function pawnmanager.spawn_pawn(name, sprite, faction)
	local pid = idcounter.get_id('pawn')
	pawns[pid] = pawn:new(
		{
			id = pid,
			name = name .. pid,
			faction = faction,
			x = nil, y = nil, facing = 1,
			sprite = sprite,
			movespeed = 6, movetype = "walk",
			status = {}
		})
	return pid
end

return pawnmanager
