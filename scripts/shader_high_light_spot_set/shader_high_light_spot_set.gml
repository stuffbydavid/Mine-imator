/// shader_high_light_spot_set()

render_set_uniform("uBrightness", 0)
render_set_uniform("uBlockBrightness", app.setting_block_brightness)

render_set_uniform_int("uIsSky", 0)

render_set_uniform_int("uLightAmount", render_light_amount)
render_set_uniform("uLightMatrix", render_light_matrix)
render_set_uniform_vec3("uLightPosition", render_light_from[X], render_light_from[Y], render_light_from[Z])
render_set_uniform_color("uLightColor", render_light_color, 1)
render_set_uniform("uLightNear", render_light_near)
render_set_uniform("uLightFar", render_light_far)
render_set_uniform("uLightFadeSize", render_light_fade_size)
render_set_uniform("uLightSpotSharpness", render_light_spot_sharpness)

texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_spot_buffer))
gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], true)

if (app.setting_render_shadows_blur_size > 0)
	render_set_uniform_int("uBlurQuality", app.setting_render_shadows_blur_quality)
else
	render_set_uniform_int("uBlurQuality", 1)

if (app.setting_render_shadows_blur_quality > 1)
	render_set_uniform("uBlurSize", app.setting_render_shadows_blur_size)
else
	render_set_uniform("uBlurSize", 0)