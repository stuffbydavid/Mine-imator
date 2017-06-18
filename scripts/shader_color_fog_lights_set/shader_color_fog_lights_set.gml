/// shader_color_fog_lights_set()

var uTexture = shader_get_sampler_index(shader_color_fog_lights, "uTexture"), 
	uBlendColor = shader_get_uniform(shader_color_fog_lights, "uBlendColor"), 
	uColorsExt = shader_get_uniform(shader_color_fog_lights, "uColorsExt"), 
	uRGBAdd = shader_get_uniform(shader_color_fog_lights, "uRGBAdd"), 
	uRGBSub = shader_get_uniform(shader_color_fog_lights, "uRGBSub"), 
	uRGBMul = shader_get_uniform(shader_color_fog_lights, "uRGBMul"), 
	uHSBAdd = shader_get_uniform(shader_color_fog_lights, "uHSBAdd"), 
	uHSBSub = shader_get_uniform(shader_color_fog_lights, "uHSBSub"), 
	uHSBMul = shader_get_uniform(shader_color_fog_lights, "uHSBMul"), 
	uMixColor = shader_get_uniform(shader_color_fog_lights, "uMixColor"), 
	uLights = shader_get_uniform(shader_color_fog_lights, "uLights"), 
	uLightData = shader_get_uniform(shader_color_fog_lights, "uLightData"), 
	uAmbientColor = shader_get_uniform(shader_color_fog_lights, "uAmbientColor"), 
	uBrightness = shader_get_uniform(shader_color_fog_lights, "uBrightness"), 
	uBlockBrightness = shader_get_uniform(shader_color_fog_lights, "uBlockBrightness");
	
shader_set(shader_color_fog_lights)

// Texture
texture_set_filtering(uTexture, shader_texture_filter_linear, shader_texture_filter_mipmap)
if (shader_texture_gm)
	texture_set_stage(uTexture, shader_texture)
else
	texture_set_stage_lib(uTexture, shader_texture)

// Colors
shader_set_uniform_color(uBlendColor, shader_blend_color, shader_alpha)
shader_set_uniform_f(uColorsExt, bool_to_float(shader_colors_ext))
if (shader_colors_ext)
{
	shader_set_uniform_color(uRGBAdd, shader_rgbadd, 1)
	shader_set_uniform_color(uRGBSub, shader_rgbsub, 1)
	shader_set_uniform_color(uRGBMul, shader_rgbmul, shader_alpha)
	shader_set_uniform_color(uHSBAdd, shader_hsbadd, 1)
	shader_set_uniform_color(uHSBSub, shader_hsbsub, 1)
	shader_set_uniform_color(uHSBMul, shader_hsbmul, 1)
	shader_set_uniform_color(uMixColor, shader_mixcolor, shader_mixpercent)
}

// Lights
shader_set_uniform_i(uLights, app.background_lights)
shader_set_uniform_f_array(uLightData, app.background_light_data)
shader_set_uniform_color(uAmbientColor, app.background_ambient_color_final, 1)
shader_set_uniform_f(uBrightness, shader_brightness)
shader_set_uniform_f(uBlockBrightness, app.setting_block_brightness)

// Fog
shader_set_fog(shader_color_fog_lights)

// Wind
shader_set_wind(shader_color_fog_lights)
