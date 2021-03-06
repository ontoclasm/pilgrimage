local Hex = {}

-- math dealing with the hex grid, using axial coords
--  Y
-- /_ X
-- note that, for all hexes, x + y + z = 0

Hex.__index = function(t,k)
	if k == 'z' then
		return -t.x - t.y
	else
		return Hex[k]
	end
end

function Hex.new(x, y)
	return setmetatable({ x = x or 0, y = y or 0 }, Hex)
end

function Hex:clone()
	return Hex.new(self.x, self.y)
end

function Hex.__add(a, b)
	return Hex.new(a.x + b.x, a.y + b.y)
end

function Hex.__sub(a, b)
	return Hex.new(a.x - b.x, a.y - b.y)
end

function Hex.__unm(a)
	return Hex.new(-a.x, -a.b)
end

function Hex.__mul(a, b)
	if type(a) == "number" then
		return Hex.new(b.x * a, b.y * a)
	else
		return Hex.new(a.x * b, a.y * b)
	end
end

function Hex.__div(a, b)
	if type(a) == "number" then
		return Hex.new(b.x / a, b.y / a)
	else
		return Hex.new(a.x / b, a.y / b)
	end
end

function Hex.__eq(a, b)
	return a.x == b.x and a.y == b.y
end

function Hex.__tostring(a)
	return "(" .. a.x .. ", " .. a.y .. ", " .. -a.x - a.y .. ")"
end

function Hex:add_dir(dir, m)
	return self + hex_dir[dir] * m
end

function Hex:adjacent(dir)
	return self + hex_dir[dir]
end

function Hex.distance(a, b)
	-- also works as Hex:distance(b)
	return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y), math.abs(a.x - b.x - a.y + b.y))
end

function Hex:disc(radius)
	local region = {}
	for dx = -radius, radius do
		for dy = math.max(-radius, -radius + dx), math.min(radius, radius + dx) do
			table.insert(region, Hex(self.x + dx, self.y - dy))
		end
	end

	return region
end

function Hex:neighborhood()
	return self:disc(1)
end

function Hex:circle(radius)
	if radius == 0 then -- trivial
		return {self:clone()}
	end

	local region = {}

	for dy = -radius, 0 do
		table.insert(region, Hex(self.x - radius, self.y - dy))
	end
	for dy = 0, radius do
		table.insert(region, Hex(self.x + radius, self.y - dy))
	end

	for dx = -radius + 1, radius - 1 do
		table.insert(region, Hex(self.x + dx, self.y - math.max(-radius, -radius + dx)))
		table.insert(region, Hex(self.x + dx, self.y - math.min(radius, radius + dx)))
	end

	return region
end

function Hex:rotate_left()
	-- (x, y, z) -> (-y, -z, -x)
	return Hex(-self.y, self.x + self.y)
end

function Hex:rotate_right()
	-- (x, y, z) -> (-z, -x, -y)
	return Hex(self.x + self.y, -self.x)
end

function Hex:length()
	return math.floor((math.abs(self.x) + math.abs(self.y) + math.abs(-self.x - self.y)) / 2)
end

-- functions for hashing hexes as integers

local HASH_MODULUS = 512

function Hex:hash()
	return HASH_MODULUS * self.x + self.y
end

function Hex.unhash(hash)
	return Hex.new(math.floor(hash / HASH_MODULUS), hash % HASH_MODULUS)
end

-- direction hexes

hex_dir = {Hex.new( 0, -1), -- sw
		   Hex.new(-1,  0), -- w
		   Hex.new(-1,  1), -- nw
		   Hex.new( 0,  1), -- ne
		   Hex.new( 1,  0), -- e
		   Hex.new( 1, -1)} -- se

function Hex.dir(dir_string)
	if dir_string == "sw" then
		return hex_dir[1]
	elseif dir_string == "w" then
		return hex_dir[2]
	elseif dir_string == "nw" then
		return hex_dir[3]
	elseif dir_string == "ne" then
		return hex_dir[4]
	elseif dir_string == "e" then
		return hex_dir[5]
	elseif dir_string == "se" then
		return hex_dir[6]
	end
end

setmetatable(Hex, { __call = function(_, ...) return Hex.new(...) end })

return Hex
