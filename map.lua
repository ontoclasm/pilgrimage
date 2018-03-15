hex = require "hex"

local map = {}

function map:setup(w, h)
	self.width = w
	self.height = h
	self.waterline = 4

	for x=1, self.width do
		self[x] = {}
		for y=1, self.height do
			self[x][y] = { underlays = {}}
		end
	end

	self:generate_terrain()

	-- region = self:circle(6,4,5)
	-- for i,v in pairs(region) do
	-- 	self[v.x][v.y].terrain = "dirt"
	-- end
end

function map:on_grid(x, y)
	if x == nil or y == nil then return false end
	return x>=1 and x<=self.width and y>=1 and y<=self.height
end

function map:in_bounds(x, y)
	return self:on_grid(x, y) and self[x][y].terrain ~= "void"
end

function map:terrain_type(x, y)
	if not self:on_grid(x, y) then
		return "void"
	else
		return self[x][y].terrain
	end
end

function map:z(x, y)
	if not self:in_bounds(x, y) then
		return 0
	else
		return self[x][y].z
	end
end

function map:pawn_at(x, y)
	if not self:in_bounds(x, y) then
		return nil
	else
		return self[x][y].pawn
	end
end

function map:disc(cx, cy, r)
	local region = {}
	for dx = -r, r do
		for dy = math.max(-r, -r+dx), math.min(r, r+dx) do
			if self:in_bounds(cx + dx, cy + dy) then
				table.insert(region, {x = cx + dx, y = cy + dy})
			end
		end
	end

	return region
end

function map:neighborhood(cx, cy)
	return self:disc(cx, cy, 1)
end

function map:circle(cx, cy, r)
	local region = {}

	if r == 0 then -- trivial
		if self:in_bounds(cx, cy) then
			table.insert(region, {x = cx, y = cy})
		end
		return region
	end

	for dy = -r, 0 do
		if self:in_bounds(cx - r, cy + dy) then
			table.insert(region, {x = cx - r, y = cy + dy})
		end
	end
	for dy = 0, r do
		if self:in_bounds(cx + r, cy + dy) then
			table.insert(region, {x = cx + r, y = cy + dy})
		end
	end

	for dx = -r + 1, r - 1 do
		if self:in_bounds(cx + dx, cy + math.max(-r, -r+dx)) then
			table.insert(region, {x = cx + dx, y = cy + math.max(-r, -r+dx)})
		end
		if self:in_bounds(cx + dx, cy + math.min(r, r+dx)) then
			table.insert(region, {x = cx + dx, y = cy + math.min(r, r+dx)})
		end
	end

	return region
end

function map:generate_terrain()
	-- XXX
	local noise_x = love.math.random() * 1238.1
	local noise_y = love.math.random() * 1238.1

	for x=1, self.width do
		for y=1, self.height do
			if x-y >= 12 or y-x >= 12 then
				self[x][y].terrain = "void"
				self[x][y].z = 0
			else
				-- set heights
				-- self[x][y].z = math.floor(6 - math.sqrt(love.math.random(1,25)))
				self[x][y].z = 1 + math.floor(5 * math.pow(love.math.noise(noise_x + (x / 17.17) - (y / 34.34), noise_y + (y / 17.17)), 1.5)
														 + 2 * math.pow(love.math.noise(noise_x - (x / 5.04) + (y / 10.08), noise_y - (y / 5.04)), 1.5))

				-- set terrain
				if self.waterline - self[x][y].z >= 2 then
					self[x][y].terrain = "depths"
				elseif self.waterline - self[x][y].z == 1 then
					self[x][y].terrain = "shallows"
				elseif self[x][y].z == self.waterline then
					self[x][y].terrain = "dirt"
				elseif mymath.one_chance_in(3) then
					self[x][y].terrain = "dirt"
				else
					self[x][y].terrain = "grass"
				end
			end
		end
	end

	pathfinder:reset()
	clear_selection()
	redraw = true
end

function map:navtype(x, y, movetype, faction)
	-- for now, -1: impassable, 1: normal, 2: difficult (ends movement). in future maybe terrain should have varying costs
	-- movetype unused right now
	if not self:in_bounds(x, y) then return -1
	else
		pid = map:pawn_at(x, y)
		if pid and pawns[pid].faction ~= faction then
			return -1
		end
	end
	local tt = self:terrain_type(x, y)
	if tt == "void" then
		return -1
	end

	for d = 1, 6 do
		neighbor = hex.adj(x, y, d)
		pid = map:pawn_at(neighbor.x, neighbor.y)
		if pid and pawns[pid].faction ~= faction then
			return 2
		end
	end
	if tt == "shallows" or tt == "depths" then
		return 2
	end

	if tt == "dirt" or tt == "grass" then
		return 1
	end
end

-- function map:tile_at(x, y)
-- 	if not self:on_grid(x, y) then
-- 		return img.tile["void"]
-- 	end

-- 	feat = self:feat_at(x, y)
-- 	if feat == "void" then
-- 		return img.tile["void"]
-- 	end

-- function map:is_solid(x, y)
-- 	f = self:feat_at(x, y)
-- 	return f == "void"
-- end

-- function map:is_floor(x, y)
-- 	return not self:is_solid(x, y)
-- end

-- function map:is_transparent(x, y)
-- 	return not self:is_solid(x, y)
-- 	-- could be glass or something
-- end

-- function map:blocker_at(x, y)
-- 	--what is in this space that would block us walking there
-- 	if not self:is_floor(x, y) then return self:feat_at(x, y) end

-- 	if player.x == x and player.y == y then return "player" end
-- 	for i,v in ipairs(enemies) do
-- 		if v then
-- 			if v.x == x and v.y == y then
-- 				return v.id
-- 			end
-- 		end
-- 	end
-- 	for i,v in ipairs(objects) do
-- 		if v then
-- 			if v.x == x and v.y == y then
-- 				return v.id
-- 			end
-- 		end
-- 	end

-- 	return false -- nothing there
-- end

function map:find_empty_floor()
	local x = love.math.random(2, self.width-1)
	local y = love.math.random(2, self.height-1)

	--ew
	while self:navtype(x, y) == -1 or self[x][y].pawn do
		x = love.math.random(2, self.width-1)
		y = love.math.random(2, self.height-1)
	end
	return x, y
end

return map
