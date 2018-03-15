local pawn = { last_id = 0 }

function pawn:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function pawn:move(x, y, walk)
	--- if walk then XXX cause stuff like OAs
	if map:in_bounds(x, y) and (not map[x][y].pawn) then
		if map:in_bounds(self.x, self.y) then
			map[self.x][self.y].pawn = nil
		end
		self.x = x
		self.y = y
		map[x][y].pawn = self.id
		redraw = true
	end
end

function pawn:rotate(df)
	self.facing = self.facing + df
	if self.facing > 6 then
		self.facing = ((self.facing - 1) % 6) + 1 -- ugggh why lua why
	end
	redraw = true
end

function pawn:get_sprite()
	if self.hidden then
		return nil
	else
		if self.facing <= 3 then
			f = self.facing
			sx = 1
		else
			f = 7 - self.facing
			sx = -1
		end

		if map.waterline - map:z(self.x, self.y) >= 2 then
			return {self.sprite .. "_swim", sx}
		else
			return {self.sprite .. "_" .. f, sx}
		end
	end
end

function pawn:apply_status(s, dur)
	self.status[s] = dur + cturn
end

local status_complete_effect =
{

}

function pawn:end_status(s, cancelled) -- if cancelled == true, skip the end effect
	if not cancelled then
		if status_complete_effect[s] then
			status_complete_effect[s](self)
		end
	end
	self.status[s] = nil
end

function pawn:check_status(s)
	for i,v in pairs(self.status) do
		if i == s then
			if v < cturn then
				-- duration ran out
				self:end_status(s, false)
				return false
			else
				return true
			end
		end
	end
	return false
end

return pawn
