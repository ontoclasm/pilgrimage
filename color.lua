color = {
		white = {1.00, 1.00, 1.00},
		rouge = {0.90, 0.30, 0.20},
		blue = {0.10, 0.30, 0.80}
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
