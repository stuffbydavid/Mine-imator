/// shader_high_light_sun_set()

var uTexture = shader_get_sampler_index(shader_high_light_sun, "uTexture"), 
	uAlpha = shader_get_uniform(shader_high_light_sun, "uAlpha"), 
	uBrightness = shader_get_uniform(shader_high_light_sun, "uBrightness"), 
	uBlockBrightness = shader_get_uniform(shader_high_light_sun, "uBlockBrightness"), 
	uLightMatrix = shader_get_uniform(shader_high_light_sun, "uLightMatrix"), 
	uIsGround = shader_get_uniform(shader_high_light_sun, "uIsGround"), 
	uSunAt = shader_get_uniform(shader_high_light_sun, "uSunAt"), 
	uLightPosition = shader_get_uniform(shader_high_light_sun, "uLightPosition"), 
	uLightNear = shader_get_uniform(shader_high_light_sun, "uLightNear"), 
	uLightFar = shader_get_uniform(shader_high_light_sun, "uLightFar"), 
	uLightColor = shader_get_uniform(shader_high_light_sun, "uLightColor"), 
	uDepthBuffer = shader_get_sampler_index(shader_high_light_sun, "uDepthBuffer"), 
	uBlurQuality = shader_get_uniform(shader_high_light_sun, "uBlurQuality"), 
	uBlurSize = shader_get_uniform(shader_high_light_sun, "uBlurSize");
	
shader_set(shader_high_light_sun)

shader_set_texture(uTexture, shader_texture)
	
shader_set_uniform_f(uAlpha, shader_alpha)
shader_set_uniform_f(uBrightness, shader_brightness)
shader_set_uniform_f(uBlockBrightness, app.setting_block_brightness)

shader_set_uniform_f_array(uLightMatrix, shader_light_matrix)
shader_set_uniform_i(uIsGround, shader_is_ground)
if (app.background_sunlight_follow)
	shader_set_uniform_f(uSunAt, cam_from[X], cam_from[Y], 0)
else
	shader_set_uniform_f(uSunAt, 0, 0, 0)

shader_set_uniform_f(uLightPosition, shader_light_from[X], shader_light_from[Y], shader_light_from[Z])
shader_set_uniform_f(uLightNear, shader_light_near)
shader_set_uniform_f(uLightFar, shader_light_far)
shader_set_uniform_color(uLightColor, shader_light_color, 1)

texture_set_stage(uDepthBuffer, surface_get_texture(app.render_surface_sun_buffer))
gpu_set_texfilter_ext(uDepthBuffer, true)

if (app.setting_render_shadows_blur_size > 0)
	shader_set_uniform_i(uBlurQuality, app.setting_render_shadows_blur_quality)
else
	shader_set_uniform_i(uBlurQuality, 1)

if (app.setting_render_shadows_blur_quality > 1)
	shader_set_uniform_f(uBlurSize, app.setting_render_shadows_blur_size)
else
	shader_set_uniform_f(uBlurSize, 0)

shader_set_wind(shader_high_light_sun)
