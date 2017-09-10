/// shader_blend_set()

var uTexture = shader_get_sampler_index(shader_blend, "uTexture"), 
	uBlendColor = shader_get_uniform(shader_blend, "uBlendColor");

shader_set(shader_blend)

shader_set_texture(uTexture, shader_texture)
shader_set_uniform_color(uBlendColor, shader_blend_color, shader_alpha)

shader_set_wind(shader_blend)
