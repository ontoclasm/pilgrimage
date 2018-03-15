-- math dealing with the hex grid
-- Y
--  \_ X

dir = {{x = -1, y = -1}, -- sw
	   {x = -1, y =  0}, -- w
	   {x =  0, y =  1}, -- nw
	   {x =  1, y =  1}, -- ne
	   {x =  1, y =  0}, -- e
	   {x =  0, y = -1}} -- se

local hex = {}

function hex.add_dir(hx, hy, d, m)
	return {x = hx + m * dir[d].x, y = hy + m * dir[d].y}
end

function hex.adj(hx, hy, d)
	return {x = hx + dir[d].x, y = hy + dir[d].y}
end

function hex.distance(ax, ay, bx, by)
	return math.max(math.abs(ax - bx), math.abs(ay - by), math.abs(ax - bx - ay + by))
end

function hex.hash(x,y)
	return 512*x + y
end

function hex.unhash(v)
	return {x = math.floor(v / 512), y = v % 512}
end

return hex
