/// shader_high_light_night_set()

var uTexture = shader_get_sampler_index(shader_high_light_night, "uTexture"), 
	uBrightness = shader_get_uniform(shader_high_light_night, "uBrightness"), 
	uBlockBrightness = shader_get_uniform(shader_high_light_night, "uBlockBrightness"), 
	uAlpha = shader_get_uniform(shader_high_light_night, "uAlpha");

shader_set(shader_high_light_night)

shader_set_texture(uTexture, shader_texture)
	
shader_set_uniform_f(uBrightness, shader_brightness)
shader_set_uniform_f(uBlockBrightness, app.setting_block_brightness)
shader_set_uniform_f(uAlpha, shader_alpha)

shader_set_wind(shader_high_light_night)
