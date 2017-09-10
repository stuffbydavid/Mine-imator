/// shader_high_ssao_depth_normal_set()

var uTexture = shader_get_sampler_index(shader_high_ssao_depth_normal, "uTexture"), 
	uBrightness = shader_get_uniform(shader_high_ssao_depth_normal, "uBrightness"), 
	uAlpha = shader_get_uniform(shader_high_ssao_depth_normal, "uAlpha"), 
	uNear = shader_get_uniform(shader_high_ssao_depth_normal, "uNear"), 
	uFar = shader_get_uniform(shader_high_ssao_depth_normal, "uFar");

shader_set(shader_high_ssao_depth_normal)

shader_set_texture(uTexture, shader_texture)

shader_set_uniform_f(uAlpha, shader_alpha)
shader_set_uniform_f(uBrightness, shader_brightness + !shader_ssao)

shader_set_uniform_f(uNear, cam_near)
shader_set_uniform_f(uFar, cam_far)

shader_set_wind(shader_high_ssao_depth_normal)
