/// shader_high_light_point_set()

var uTexture = shader_get_sampler_index(shader_high_light_point, "uTexture"), 
	uAlpha = shader_get_uniform(shader_high_light_point, "uAlpha"), 
	uBrightness = shader_get_uniform(shader_high_light_point, "uBrightness"), 
	uBlockBrightness = shader_get_uniform(shader_high_light_point, "uBlockBrightness"), 
	uLightPosition = shader_get_uniform(shader_high_light_point, "uLightPosition"), 
	uLightColor = shader_get_uniform(shader_high_light_point, "uLightColor"), 
	uLightNear = shader_get_uniform(shader_high_light_point, "uLightNear"), 
	uLightFar = shader_get_uniform(shader_high_light_point, "uLightFar"), 
	uLightFadeSize = shader_get_uniform(shader_high_light_point, "uLightFadeSize"), 
	uDepthBufferXp = shader_get_sampler_index(shader_high_light_point, "uDepthBufferXp"), 
	uDepthBufferXn = shader_get_sampler_index(shader_high_light_point, "uDepthBufferXn"), 
	uDepthBufferYp = shader_get_sampler_index(shader_high_light_point, "uDepthBufferYp"), 
	uDepthBufferYn = shader_get_sampler_index(shader_high_light_point, "uDepthBufferYn"), 
	uDepthBufferZp = shader_get_sampler_index(shader_high_light_point, "uDepthBufferZp"), 
	uDepthBufferZn = shader_get_sampler_index(shader_high_light_point, "uDepthBufferZn"), 
	uBlurQuality = shader_get_uniform(shader_high_light_point, "uBlurQuality"), 
	uBlurSize = shader_get_uniform(shader_high_light_point, "uBlurSize");
	
shader_set(shader_high_light_point)

if (shader_texture_gm)
	texture_set_stage(uTexture, shader_texture)
else
	texture_set_stage_lib(uTexture, shader_texture)
	
shader_set_uniform_f(uAlpha, shader_alpha)
shader_set_uniform_f(uBrightness, shader_brightness / shader_lights)
shader_set_uniform_f(uBlockBrightness, app.setting_block_brightness / shader_lights)

shader_set_uniform_f(uLightPosition, shader_light_from[X], shader_light_from[Y], shader_light_from[Z])
shader_set_uniform_color(uLightColor, shader_light_color, 1)
shader_set_uniform_f(uLightNear, shader_light_near)
shader_set_uniform_f(uLightFar, shader_light_far)
shader_set_uniform_f(uLightFadeSize, shader_light_fadesize)

texture_set_stage(uDepthBufferXp, surface_get_texture(app.render_surface_point_buffer[0]))
texture_set_stage(uDepthBufferXn, surface_get_texture(app.render_surface_point_buffer[1]))
texture_set_stage(uDepthBufferYp, surface_get_texture(app.render_surface_point_buffer[2]))
texture_set_stage(uDepthBufferYn, surface_get_texture(app.render_surface_point_buffer[3]))
texture_set_stage(uDepthBufferZp, surface_get_texture(app.render_surface_point_buffer[4]))
texture_set_stage(uDepthBufferZn, surface_get_texture(app.render_surface_point_buffer[5]))
gpu_set_texfilter_ext(uDepthBufferXp, true)
gpu_set_texfilter_ext(uDepthBufferXn, true)
gpu_set_texfilter_ext(uDepthBufferYp, true)
gpu_set_texfilter_ext(uDepthBufferYn, true)
gpu_set_texfilter_ext(uDepthBufferZp, true)
gpu_set_texfilter_ext(uDepthBufferZn, true)
gpu_set_texrepeat_ext(uDepthBufferXp, false)
gpu_set_texrepeat_ext(uDepthBufferXn, false)
gpu_set_texrepeat_ext(uDepthBufferYp, false)
gpu_set_texrepeat_ext(uDepthBufferYn, false)
gpu_set_texrepeat_ext(uDepthBufferZp, false)
gpu_set_texrepeat_ext(uDepthBufferZn, false)

if (app.setting_render_shadows_blur_size > 0)
	shader_set_uniform_i(uBlurQuality, app.setting_render_shadows_blur_quality)
else
	shader_set_uniform_i(uBlurQuality, 1)

if (app.setting_render_shadows_blur_quality > 1)
	shader_set_uniform_f(uBlurSize, app.setting_render_shadows_blur_size)
else
	shader_set_uniform_f(uBlurSize, 0)

shader_set_wind(shader_high_light_point)
