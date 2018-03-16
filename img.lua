img = {}

function img.setup()
	-- tile pixel dimension constants
	img.tile_size = 64
	img.hex_width = 32
	img.hex_height = 17
	img.hex_depth = 10
	img.pawn_yoffset = 20

	img.quads = {}

	img.tileset = love.graphics.newImage("art/tileset.png")
	img.tileset:setFilter("nearest", "linear")
	img.quads.tileset = {}
	local row = 0 --terrain
	img.nq("tileset",	"grass", 				0, row)
	img.nq("tileset",	"dirt",					1, row)
	img.nq("tileset",	"shallows",				2, row)
	img.nq("tileset",	"depths",				3, row)
	row = 1 --terrain outlines
	img.nq("tileset",	"hexoutline_w1", 		0, row)
	img.nq("tileset",	"hexoutline_e1",		1, row)
	img.nq("tileset",	"hexoutline_nw",		2, row)
	img.nq("tileset",	"hexoutline_ne", 		3, row)
	img.nq("tileset",	"hexoutline_se",		4, row)
	img.nq("tileset",	"hexoutline_sw",		5, row)
	row = 2 -- cursors
	img.nq("tileset",	"cursor",				0, row)
	img.nq("tileset",	"selection",			1, row)
	img.nq("tileset",	"movementa",			2, row)
	img.nq("tileset",	"movementb",			3, row)
	img.nq("tileset",	"nav_node",				4, row)

	img.overlays = love.graphics.newImage("art/overlays.png")
	img.overlays:setFilter("nearest", "linear")
	img.quads.overlays = {}
	row = 0 -- cursors
	img.nq("overlays",	"cursor_knife", 		0, row)
	img.nq("overlays",	"nav_node", 			1, row)
	row = 1
	img.nq("overlays",	"cursor_b", 			0, row)
	img.nq("overlays",	"cursor_f", 			0, row+1)
	img.nq("overlays",	"selection_b", 			1, row)
	img.nq("overlays",	"selection_f", 			1, row+1)
	img.nq("overlays",	"movementa_b", 			2, row)
	img.nq("overlays",	"movementa_f", 			2, row+1)
	img.nq("overlays",	"movementb_b", 			3, row)
	img.nq("overlays",	"movementb_f", 			3, row+1)
	row = 3 -- terrain bits
	img.nq("overlays",	"hexoutline_w2", 		0, row)
	img.nq("overlays",	"hexoutline_e2", 		1, row)
	img.nq("overlays",	"pawnshadow", 			2, row)
	img.nq("overlays",	"water", 				3, row)
	img.nq("overlays",	"water_ripple", 		4, row)

	img.sprites = love.graphics.newImage("art/sprites.png")
	img.sprites:setFilter("nearest", "linear")
	img.quads.sprites = {}
	row = 0
	img.nq("sprites",	"abby_1_u", 			0, row)
	img.nq("sprites",	"abby_1_l", 			0, row+1)
	img.nq("sprites",	"abby_2_u", 			1, row)
	img.nq("sprites",	"abby_2_l", 			1, row+1)
	img.nq("sprites",	"abby_3_u", 			2, row)
	img.nq("sprites",	"abby_3_l", 			2, row+1)
	img.nq("sprites",	"abby_swim_u", 			0, row+2)
	img.nq("sprites",	"abby_swim_l", 			0, row+3)
	img.nq("sprites",	"quentin_1_u", 			3, row)
	img.nq("sprites",	"quentin_1_l", 			3, row+1)
	img.nq("sprites",	"quentin_2_u", 			4, row)
	img.nq("sprites",	"quentin_2_l", 			4, row+1)
	img.nq("sprites",	"quentin_3_u", 			5, row)
	img.nq("sprites",	"quentin_3_l", 			5, row+1)
	img.nq("sprites",	"quentin_swim_u", 		3, row+2)
	img.nq("sprites",	"quentin_swim_l", 		3, row+3)

	img.view_tilewidth = math.ceil(window.w / img.tile_size)
	img.view_tileheight = math.ceil(window.h / img.tile_size)

	img.tileset_batch = {}
	for y = 1, 32 do
		img.tileset_batch[y] = love.graphics.newSpriteBatch(img.tileset, 24 * 16)
	end
end

function img.nq(page, id, x, y)
	img.quads[page][id] = love.graphics.newQuad(x * img.tile_size, y * img.tile_size, img.tile_size, img.tile_size,
										img[page]:getWidth(), img[page]:getHeight())
end

function img.draw_terrain_row(y)
	img.tileset_batch[y]:clear()

	local waterline = map.waterline

	for x=1, map.width do
		if map:in_bounds(x,y) then
			-- draw the hex at x,y
			local tt = map:terrain_type(x, y)
			local elev = map:elev(x, y)
			local hx, hy = img.canvas_pos(x, y)
			local underlays = map[x][y].underlays

			for z = 0, elev-1 do
				img.tileset_batch[y]:add(img.quads.tileset[tt], hx, hy - z*img.hex_depth)
			end

			-- add outlines
			if not map:in_bounds(x-1, y) and elev >= waterline then
				for z = 0, elev-1 do
					img.tileset_batch[y]:add(img.quads.tileset["hexoutline_w1"], hx, hy - z*img.hex_depth)
				end
			end
			if not map:in_bounds(x+1, y) and elev >= waterline then
				for z = 0, elev-1 do
					img.tileset_batch[y]:add(img.quads.tileset["hexoutline_e1"], hx, hy - z*img.hex_depth)
				end
			end

			if (not map:in_bounds(x-1, y+1) and elev >= waterline) or map:elev(x-1, y+1) < elev then
				img.tileset_batch[y]:add(img.quads.tileset["hexoutline_nw"], hx, hy - (elev - 1)*img.hex_depth)
			end
			if (not map:in_bounds(x, y+1) and elev >= waterline) or map:elev(x, y+1) < elev then
				img.tileset_batch[y]:add(img.quads.tileset["hexoutline_ne"], hx, hy - (elev - 1)*img.hex_depth)
			end
			if (not map:in_bounds(x+1, y-1) and elev >= waterline) then
				img.tileset_batch[y]:add(img.quads.tileset["hexoutline_se"], hx, hy)
			end
			if (not map:in_bounds(x, y-1) and elev >= waterline) then
				img.tileset_batch[y]:add(img.quads.tileset["hexoutline_sw"], hx, hy)
			end

			-- cursor parts that are on the ground; upper parts are in the foreground
			if underlays.movement_a then
				img.tileset_batch[y]:add(img.quads.tileset["movementa"], hx, hy - (elev - 1)*img.hex_depth)
			end
			if underlays.movement_b then
				img.tileset_batch[y]:add(img.quads.tileset["movementb"], hx, hy - (elev - 1)*img.hex_depth)
			end
			if underlays.selection then
				img.tileset_batch[y]:add(img.quads.tileset["selection"], hx, hy - (elev - 1)*img.hex_depth)
			end
			if underlays.cursor then
				img.tileset_batch[y]:add(img.quads.tileset["cursor"], hx, hy - (elev - 1)*img.hex_depth)
			end
			if underlays.nav_node then
				img.tileset_batch[y]:add(img.quads.tileset["nav_node"], hx, hy - (elev - 1)*img.hex_depth)
			end
		end
	end
	-- for i,v in ipairs(objects) do
	-- 	img.tileset_batch[y]:add(v:get_sprite(), v.x*img.tile_size, v.y*img.tile_size)
	-- end

	-- for i,v in ipairs(enemies) do
	-- 	img.tileset_batch[y]:add(v:get_sprite(), v.x*img.tile_size, v.y*img.tile_size)
	-- end

	-- img.tileset_batch[y]:add(player:get_sprite(), player.x*img.tile_size, player.y*img.tile_size)

	love.graphics.draw(img.tileset_batch[y], 0, 0)
end

function img.draw_foreground(x, y)
	local waterline = map.waterline
	local elev = map:elev(x, y)
	-- XXX make a function for hx, hy
	local hx, hy = img.canvas_pos(x, y)
	local underlays = map[x][y].underlays
	local pawn = map:pawn_at(x,y)
	if pawn then pawn = pawns[pawn]:get_sprite() end

	-- potentially-underwater parts of the pawn
	-- XXX use individual spritesheets
	if pawn then
		love.graphics.draw(img.overlays, img.quads.overlays["pawnshadow"], hx, hy - (elev-1)*img.hex_depth)
		if waterline - elev >= 2 then
			love.graphics.draw(img.sprites, img.quads.sprites[pawn[1] .. "_l"],
							   hx + 32, hy - (waterline-3)*img.hex_depth - img.pawn_yoffset + 32, 0, pawn[2], 1, 32, 32)
		else
			love.graphics.draw(img.sprites, img.quads.sprites[pawn[1] .. "_l"],
							   hx + 32, hy - (elev-1)*img.hex_depth - img.pawn_yoffset + 32, 0, pawn[2], 1, 32, 32)
		end
	end

	-- water level
	if elev < waterline then
		if map:in_bounds(x-1, y) and map:elev(x-1, y) > elev then
			for z = elev-1, map:elev(x-1, y)-2 do
				love.graphics.draw(img.overlays, img.quads.overlays["hexoutline_w2"], hx, hy - z*img.hex_depth)
			end
		end
		if map:in_bounds(x+1, y) and map:elev(x+1, y) > elev then
			for z = elev-1, map:elev(x+1, y)-2 do
				love.graphics.draw(img.overlays, img.quads.overlays["hexoutline_e2"], hx, hy - z*img.hex_depth)
			end
		end
		love.graphics.draw(img.overlays, img.quads.overlays["water"], hx, hy - (waterline - 1)*img.hex_depth)
		if pawn then
			love.graphics.draw(img.overlays, img.quads.overlays["water_ripple"], hx, hy - (waterline - 1)*img.hex_depth)
		end

		-- back parts of cursors
		if underlays.movement_a then
			love.graphics.draw(img.overlays, img.quads.overlays["movementa_b"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
		if underlays.movement_b then
			love.graphics.draw(img.overlays, img.quads.overlays["movementb_b"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
		if underlays.selection then
			love.graphics.draw(img.overlays, img.quads.overlays["selection_b"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
		if underlays.cursor then
			love.graphics.draw(img.overlays, img.quads.overlays["cursor_b"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
	end

	if pawn then
		if waterline - elev >= 2 then
			love.graphics.draw(img.sprites, img.quads.sprites[pawn[1] .. "_u"],
							   hx + 32, hy - (waterline-3)*img.hex_depth - img.pawn_yoffset + 32, 0, pawn[2], 1, 32, 32)
		else
			love.graphics.draw(img.sprites, img.quads.sprites[pawn[1] .. "_u"],
							   hx + 32, hy - (elev-1)*img.hex_depth - img.pawn_yoffset + 32, 0, pawn[2], 1, 32, 32)
		end
	end

	if elev < waterline then
		if underlays.movement_a then
			love.graphics.draw(img.overlays, img.quads.overlays["movementa_f"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
		if underlays.movement_b then
			love.graphics.draw(img.overlays, img.quads.overlays["movementb_f"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
		if underlays.selection then
			love.graphics.draw(img.overlays, img.quads.overlays["selection_f"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
		if underlays.cursor then
			love.graphics.draw(img.overlays, img.quads.overlays["cursor_f"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
		if underlays.nav_node then
			love.graphics.draw(img.overlays, img.quads.overlays["nav_node"], hx, hy - (waterline - 1)*img.hex_depth + 2)
		end
	end

	if map:in_bounds(x-1, y) and map:elev(x-1, y) > elev and map:elev(x-1, y) >= waterline then
		for z = elev-1, map:elev(x-1, y)-2 do
			love.graphics.draw(img.overlays, img.quads.overlays["hexoutline_w2"], hx, hy - z*img.hex_depth)
		end
	end
	if map:in_bounds(x+1, y) and map:elev(x+1, y) > elev and map:elev(x+1, y) >= waterline then
		for z = elev-1, map:elev(x+1, y)-2 do
			love.graphics.draw(img.overlays, img.quads.overlays["hexoutline_e2"], hx, hy - z*img.hex_depth)
		end
	end

	if underlays.cursor then
		if elev < waterline then
			love.graphics.draw(img.overlays, img.quads.overlays["cursor_knife"], hx, hy - (waterline - 1)*img.hex_depth - 32)
		else
			love.graphics.draw(img.overlays, img.quads.overlays["cursor_knife"], hx, hy - (elev - 1)*img.hex_depth - 34)
		end
	end
end

-- get the position on canvas of a given hex
function img.canvas_pos(x, y)
	return (x + y/2)*img.hex_width, (map.height-y+4)*img.hex_height
end

function img.canvas_hexcenter(x, y)
	local hx, hy = img.canvas_pos(x, y)
	local elev = map:elev(x, y)
	if elev >= map.waterline then
		return hx + img.tile_size/2, hy + img.tile_size/2 - 4 - (map:elev(x, y) - 1)*img.hex_depth
	else
		return hx + img.tile_size/2, hy + img.tile_size/2 - 2 - (map.waterline - 1)*img.hex_depth
	end
end

return img
