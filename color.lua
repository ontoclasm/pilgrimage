color = {
		white = {255, 255, 255},
		rouge = {220, 80, 80},
		blue = {20, 60, 180}
}

color.r = function (name)
        return color[name][1]
end

color.g = function (name)
        return color[name][2]
end

color.b = function (name)
        return color[name][3]
end

color.rgb = function (name)
        return color[name][1], color[name][2], color[name][3]
end

return color
