/// shader_blend_fog_set()

var uTexture = shader_get_sampler_index(shader_blend_fog, "uTexture"), 
	uBlendColor = shader_get_uniform(shader_blend_fog, "uBlendColor");

shader_set(shader_blend_fog)

shader_set_texture(uTexture, shader_texture)
shader_set_uniform_color(uBlendColor, shader_blend_color, shader_alpha)

shader_set_fog(shader_blend_fog)
shader_set_wind(shader_blend_fog)
