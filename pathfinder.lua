hex = require "hex"

local pathfinder = { fringes = {}}

function pathfinder:reset()
	self:clear_move_radius()
	self:clear_path()
	self.origin = {}
	self.radius = nil
	self.reached = {}
	self.deadends = {}
	for k = 0, 64 do
		self.fringes[k] = {}
	end
end

function pathfinder:build_move_radius(cx, cy, r, movetype, faction)
	self:reset()
	self.origin = {x=cx,y=cy}
	self.radius = r
	self.fringes[0][hex.hash(cx, cy)] = true
	self.reached[hex.hash(cx, cy)] = true

	local c = {}
	local neighbor = {}
	local navtype = nil
	local neighbor_hash = nil
	for k = 1, r do
		for i,_ in pairs(self.fringes[k-1]) do
			if not self.deadends[i] then
				c = hex.unhash(i)
				for d = 1, 6 do
					neighbor = hex.adj(c.x, c.y, d)
					navtype = map:navtype(neighbor.x, neighbor.y, movetype, faction)
					if map:in_bounds(neighbor.x, neighbor.y) and navtype ~= -1 then
						neighbor_hash = hex.hash(neighbor.x, neighbor.y)
						if not self.reached[neighbor_hash] then
							self.reached[neighbor_hash] = true
							self.fringes[k][neighbor_hash] = true
							if navtype == 2 then
								self.deadends[neighbor_hash] = true
							end
						end
					end
				end
			end
		end
	end
end

function pathfinder:find_path(tx, ty)
	if not self.radius then return false end
	self:clear_path()

	local t_hash = hex.hash(tx, ty)
	if not self.reached[t_hash] then return false end

	local distance = nil
	for k = 0, self.radius do
		if self.fringes[k][t_hash] then
			distance = k
			self.path[k] = {x = tx, y = ty}
		end
		if distance then break end
	end

	if distance == 0 then return distance end -- that was easy

	local pen = {x = tx, y = ty}
	local neighbor = {}
	local neighbor_hash = nil
	for k = distance - 1, 0, -1 do
		for d = 1, 6 do
			neighbor = hex.adj(pen.x, pen.y, d)
			if map:in_bounds(neighbor.x, neighbor.y) then
				neighbor_hash = hex.hash(neighbor.x, neighbor.y)
				if self.fringes[k][neighbor_hash] and not self.deadends[neighbor_hash] then
					self.path[k] = neighbor
					pen = neighbor
					break
				end
			end
		end
	end

	return distance
end

function pathfinder:display_move_radius()
	local c = {}
	for k = 0, self.radius do
		for i,_ in pairs(self.fringes[k]) do
			c = hex.unhash(i)
			map[c.x][c.y].underlays.movement_a = true
		end
	end
	redraw = true
end

function pathfinder:clear_move_radius()
	if self.radius then
		local c = {}
		for k=0, self.radius do
			for i,_ in pairs(self.fringes[k]) do
				c = hex.unhash(i)
				map[c.x][c.y].underlays.movement_a = nil
				map[c.x][c.y].underlays.movement_b = nil
			end
		end
		redraw = true
	end
end

function pathfinder:display_path()
	for k = 1, self.radius do
		if not self.path[k] then break end
		map[self.path[k].x][self.path[k].y].underlays.nav_node = true
	end
	redraw = true
end

function pathfinder:clear_path()
	if self.radius then
		for k = 0, self.radius do
			if not self.path[k] then break end
			map[self.path[k].x][self.path[k].y].underlays.nav_node = nil
		end
		redraw = true
	end
	self.path = {}
end

return pathfinder
