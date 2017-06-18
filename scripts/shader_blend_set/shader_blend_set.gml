/// shader_blend_set()

var uTexture = shader_get_sampler_index(shader_blend, "uTexture"), 
	uBlendColor = shader_get_uniform(shader_blend, "uBlendColor");

shader_set(shader_blend)

texture_set_filtering(uTexture, shader_texture_filter_linear, shader_texture_filter_mipmap)
if (shader_texture_gm)
	texture_set_stage(uTexture, shader_texture)
else
	texture_set_stage_lib(uTexture, shader_texture)
	
shader_set_uniform_color(uBlendColor, shader_blend_color, shader_alpha)

shader_set_wind(shader_blend)
