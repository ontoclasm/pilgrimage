require "requires"

function love.load()
	ctime = love.timer.getTime()

	controller = controls.setup()

	-- baton.new {
	-- 	controls = {
	-- 		-- camera controls
	-- 		left1 = {'key:left', 'axis:rightx-'},
	-- 		right1 = {'key:right', 'axis:rightx+'},
	-- 		up1 = {'key:up', 'axis:righty-'},
	-- 		down1 = {'key:down', 'axis:righty+'},
	-- 		-- movement
	-- 		left2 = {'key:a', 'button:dpleft'},
	-- 		right2 = {'key:d', 'button:dpright'},
	-- 		up2 = {'key:w', 'button:dpup'},
	-- 		down2 = {'key:s', 'button:dpdown'},
	-- 		-- buttons
	-- 		a = {'key:space', 'button:a'},
	-- 		x = {'key:t', 'button:x'},
	-- 		y = {'key:r', 'button:y'},

	-- 		menu = {'key:escape', 'button:start'},
	-- 		view = {'key:q', 'button:back'},
	-- 	} -- set controller.joystick to a Joystick later
	-- }
	-- controller.deadzone = 0.2

	love.window.setMode(0, 0)
	love.window.setFullscreen(true)
	window = {}
	window.w, window.h = love.graphics.getDimensions()

	love.graphics.setBackgroundColor(0, 50, 50)
	game_canvas = love.graphics.newCanvas()
	game_canvas:setFilter("linear", "nearest")
	gui_canvas = love.graphics.newCanvas()
	gui_canvas:setFilter("linear", "nearest")
	shaderDesaturate = love.graphics.newShader("desaturate.lua")

	love.mouse.setVisible(false)
	love.keyboard.setKeyRepeat(true)

	font = love.graphics.newImageFont("art/font.png",
		" abcdefghijklmnopqrstuvwxyz" ..
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
		"123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)

	img.setup()

	cturn = 1

	pawns = {}
	floor_setup()

	camera_x, camera_y = img.canvas_hexcenter(12,12)
	camera_target_x, camera_target_y = nil, nil
	set_cursor(12, 12)

	game_state = "play"
	redraw = true
	-- new_turn(false)
end

local cdx, cdy
function love.update(dt)
	ctime = love.timer.getTime()

	if camera_target_x then
		camera_x = camera_x - (camera_x - camera_target_x) * dt * 6
		camera_y = camera_y - (camera_y - camera_target_y) * dt * 6
		if math.abs(camera_x - camera_target_x) < 1 and math.abs(camera_y - camera_target_y) < 1 then
			camera_target_x = nil
			camera_target_y = nil
		end
	end

	-- handle input
	controller:update()
	if game_state == "menu" then
		if controller:pressed('menu') then
			game_state = "play"
			redraw = true
		end
		if controller:pressed('view') then love.event.push("quit") end
	elseif game_state == "play" then
		if controller:pressed('menu') then game_state = "menu" end
		if controller:pressed('view') then map:generate_terrain() end

		cdx, cdy = controller:get('rstick')
		if cdx ~= 0 or cdy ~= 0 then
			shift_camera(6 * img.tile_size * dt * cdx, 6 * img.tile_size * dt * cdy)
		end

		if controller:pressed('dp_up')		then set_cursor(cursor_x,		cursor_y + 1) end
		if controller:pressed('dp_left') 	then set_cursor(cursor_x - 1,	cursor_y) end
		if controller:pressed('dp_down') 	then set_cursor(cursor_x,		cursor_y - 1) end
		if controller:pressed('dp_right')	then set_cursor(cursor_x + 1,	cursor_y) end

		if controller:pressed('a') then click_on(cursor_x, cursor_y) end
		if controller:pressed('x') then
			local pid = turnmanager.get_turn_id()
			set_cursor(pawns[pid].x, pawns[pid].y)
			set_selection(pid)
			new_message(pid)
			camera_target_x, camera_target_y = img.canvas_hexcenter(pawns[pid].x, pawns[pid].y)
		end
		if controller:pressed('y') then
			-- local pid = map:pawn_at(cursor_x, cursor_y)
			-- if pid then
			-- 	pawns[pid]:rotate(1)
			-- end

			region = Hex(cursor_x, cursor_y):circle(3)
			for k,v in pairs(region) do
				if map:in_bounds(v.x, v.y) then
					map[v.x][v.y].underlays.nav_node = true
				end
			end
		end
	end
end

function love.draw()
	if game_state == "menu" then
		love.graphics.setShader(shaderDesaturate)
	end

	love.graphics.setColor(color.white)
	if redraw then
		love.graphics.setCanvas(game_canvas)
		love.graphics.clear()

		-- update and draw the new view to canvas
		for y = map.height, 1, -1 do
			img.draw_terrain_row(y)
			for x = 1, map.width do
				if map:in_bounds (x,y) then
					img.draw_foreground(x, y)
				end
			end
		end

		love.graphics.setCanvas()
		redraw = false
	end

	-- copy game canvas to screen
	love.graphics.draw(game_canvas, 2 * math.floor(-camera_x + window.w / 4), 2 * math.floor(-camera_y + window.h / 4), 0, 2)

	-- draw the gui
	love.graphics.setCanvas(gui_canvas)
	love.graphics.clear()
	love.graphics.setColor(color.rouge)
	if map:in_bounds(cursor_x, cursor_y) then
		love.graphics.print(tostring(Hex(cursor_x, cursor_y)) .. " h:" .. map:elev(cursor_x, cursor_y) - map.waterline, window.w/2 - 160, 10)
	end
	-- debug msg
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, window.h/2 - 80)
	local dc = love.graphics.getStats()
	love.graphics.print("Draws: "..dc.drawcalls, 10, window.h/2 - 60)
	love.graphics.print("Camera: "..math.floor(camera_x) .. ", " .. math.floor(camera_y), 10, window.h/2 - 40)
	if message then
		love.graphics.print(message, 10, window.h/2 - 20)
	end

	if game_state == "menu" then
		love.graphics.setShader()
		draw_pause_menu()
	end
	love.graphics.setCanvas()

	love.graphics.setColor(color.white)
	love.graphics.draw(gui_canvas, 0, 0, 0, 2)
end

function love.joystickadded(joystick)
	controller.joystick = joystick
	new_message("joystick added")
end

function love.focus(f)
	if f then
		love.mouse.setVisible(false)
	else
		game_state = "menu"
		love.mouse.setVisible(true)
	end
end

function new_message(m)
	message = m
	redraw = true
end

function draw_pause_menu()
	love.graphics.setColor(color.blue)
	love.graphics.circle("fill", window.w/4, window.h/4, 100)
	love.graphics.setColor(color.white)
	love.graphics.printf("Press Q to quit", math.floor(window.w/4 - 200), math.floor(window.h/4 - font:getHeight()/2), 400, "center")
	love.graphics.setColor(color.white)
end

function shift_camera(dx, dy)
	camera_x = camera_x + dx
	camera_y = camera_y + dy
	camera_target_x, camera_target_y = camera_x, camera_y
end

function shift_camera_target(dx, dy)
	camera_target_x, camera_target_y = camera_x + dx, camera_y + dy
end

function set_cursor(x, y)
	if map:in_bounds(x, y) then
		if map:in_bounds(cursor_x, cursor_y) then
			map[cursor_x][cursor_y].underlays.cursor = nil
		end
		map[x][y].underlays.cursor = true
		cursor_x = x
		cursor_y = y

		local cx, cy = img.canvas_hexcenter(cursor_x, cursor_y)
		cx = cx + math.floor(-camera_x + window.w / 4)
		cy = cy + math.floor(-camera_y + window.h / 4)
		cdx, cdy = 0, 0
		if cx < 40 then
			cdx = -100 + cx
		elseif cx > window.w/2 - 40 then
			cdx = 100 - (window.w/2 - cx)
		end
		if cy < 40 then
			cdy = -100 + cy
		elseif cy > window.h/2 - 40 then
			cdy = 100 - (window.h/2 - cy)
		end
		if cdx ~= 0 or cdy ~= 0 then
			shift_camera_target(cdx, cdy)
		end

		if pathfinder:find_path(Hex(x, y)) then
			pathfinder:display_path()
		end

		pid = map:pawn_at(x, y)
		if pid then
			new_message(pid .. ": " .. pawns[pid].name .. ", " .. pawns[pid].gender .. " " .. pawns[pid].faith .. " " .. pawns[pid].job)
		else
			new_message()
		end
		redraw = true
		return true
	end
	return false
end

function click_on(x, y)
	if x == selection_x and y == selection_y then
		clear_selection()
	else
		pid = map:pawn_at(x, y)
		if pid then
			set_selection(pid)
			camera_target_x, camera_target_y = img.canvas_hexcenter(x,y)
		elseif selection_pawn and pathfinder.reached[Hex(x,y):hash()] then
			pawns[selection_pawn]:move(x, y, true)
			camera_target_x, camera_target_y = img.canvas_hexcenter(x,y)
			clear_selection()
		else
			clear_selection()
			new_message("deselected, " .. Hex(x,y):length())
		end
	end
end

function set_selection(pid)
	clear_selection()
	selection_pawn = pid
	px, py = pawns[pid].x, pawns[pid].y
	selection_x = px
	selection_y = py
	pathfinder:build_move_radius(Hex(px, py), pawns[pid].movespeed, pawns[pid].movetype, pawns[pid].faction)
	pathfinder:display_move_radius()
	map[px][py].underlays.selection = true
	redraw = true
end

function clear_selection()
	if map:in_bounds(selection_x, selection_y) then
		map[selection_x][selection_y].underlays.selection = nil
	end
	selection_pawn = nil
	selection_x = nil
	selection_y = nil
	pathfinder:reset()
	redraw = true
end

function floor_setup()
	map:setup(24, 24)

	pid_list = {}
	for i = 1, 8 do
		local pid = pawnmanager.create_pawn({faction = 'player'})
		local x, y = map:find_empty_floor()
		pawns[pid]:move(x, y, false)
		pawns[pid].facing = love.math.random(6)
		table.insert(pid_list, pid)
	end

	for i = 1, 8 do
		local pid = pawnmanager.create_pawn({faction = 'enemy'})
		local x, y = map:find_empty_floor()
		pawns[pid]:move(x, y, false)
		pawns[pid].facing = love.math.random(6)
		table.insert(pid_list, pid)
	end

	turnmanager.roll_initiative(pid_list)
end

-- function new_turn(t)
-- 	if t then -- time passed
-- 		for i,v in ipairs(enemies) do
-- 			v:update()
-- 		end
-- 	end

-- 	player:update()

-- 	cturn = cturn + 1
-- 	redraw = true
-- end
