/// shader_blend_fog_set()

var uTexture = shader_get_sampler_index(shader_blend_fog, "uTexture"), 
	uBlendColor = shader_get_uniform(shader_blend_fog, "uBlendColor");

shader_set(shader_blend_fog)

gpu_set_tex_filter_ext(uTexture, shader_texture_filter_linear)
gpu_set_tex_mip_enable(shader_texture_filter_mipmap)
gpu_set_tex_mip_filter_ext(uTexture, test(shader_texture_filter_mipmap, tf_linear, tf_point))
texture_set_stage(uTexture, texture_get(shader_texture))

shader_set_uniform_color(uBlendColor, shader_blend_color, shader_alpha)

shader_set_fog(shader_blend_fog)
shader_set_wind(shader_blend_fog)
