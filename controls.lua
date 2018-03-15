local controls = {}

function controls.setup()
	local controller = baton.new({
		controls = {
			-- dpad
			dp_left = {'key:a', 'button:dpleft'},
			dp_right = {'key:d', 'button:dpright'},
			dp_up = {'key:w', 'button:dpup'},
			dp_down = {'key:s', 'button:dpdown'},
			-- right stick
			r_left = {'key:left', 'axis:rightx-'},
			r_right = {'key:right', 'axis:rightx+'},
			r_up = {'key:up', 'axis:righty-'},
			r_down = {'key:down', 'axis:righty+'},
			-- buttons
			a = {'key:space', 'button:a'},
			x = {'key:r', 'button:x'},
			y = {'key:t', 'button:y'},

			menu = {'key:escape', 'button:start'},
			view = {'key:q', 'button:back'},
		},
		pairs = {
			dpad = {'dp_left', 'dp_right', 'dp_up', 'dp_down'},
			rstick = {'r_left', 'r_right', 'r_up', 'r_down'},
		}
	})
	-- set controller.joystick to a Joystick later
	controller.deadzone = 0.2

	return controller
end

function love.joystickadded(joystick)
	controller.joystick = joystick
end

function love.joystickpressed(j, _)
	-- new joystick
	if player_input.joystick ~= j then
		player_input.joystick = j
	end
end

return controls
