shader_palette = love.graphics.newShader[[

extern vec3 palette[64];

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec3 color = palette[int(Texel(texture, texture_coords).r)*255]
	return vec4(color4.r/255, color4.g/255, color4.b/255, pixel.a);
}
]]