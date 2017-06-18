/// shader_high_light_spot_set()

var uTexture = shader_get_sampler_index(shader_high_light_spot, "uTexture"), 
    uAlpha = shader_get_uniform(shader_high_light_spot, "uAlpha"), 
    uBrightness = shader_get_uniform(shader_high_light_spot, "uBrightness"), 
    uBlockBrightness = shader_get_uniform(shader_high_light_spot, "uBlockBrightness"), 
    uLightMatrix = shader_get_uniform(shader_high_light_spot, "uLightMatrix"), 
    uLightPosition = shader_get_uniform(shader_high_light_spot, "uLightPosition"), 
    uLightColor = shader_get_uniform(shader_high_light_spot, "uLightColor"), 
    uLightNear = shader_get_uniform(shader_high_light_spot, "uLightNear"), 
    uLightFar = shader_get_uniform(shader_high_light_spot, "uLightFar"), 
    uLightFadeSize = shader_get_uniform(shader_high_light_spot, "uLightFadeSize"), 
    uLightSpotSharpness = shader_get_uniform(shader_high_light_spot, "uLightSpotSharpness"), 
    uDepthBuffer = shader_get_sampler_index(shader_high_light_spot, "uDepthBuffer"), 
    uBlurQuality = shader_get_uniform(shader_high_light_spot, "uBlurQuality"), 
    uBlurSize = shader_get_uniform(shader_high_light_spot, "uBlurSize");
    
shader_set(shader_high_light_spot)

if (shader_texture_gm)
    texture_set_stage(uTexture, shader_texture)
else
    texture_set_stage_lib(uTexture, shader_texture)
    
shader_set_uniform_f(uAlpha, shader_alpha)
shader_set_uniform_f(uBrightness, shader_brightness / shader_lights)
shader_set_uniform_f(uBlockBrightness, app.setting_block_brightness / shader_lights)

shader_set_uniform_f_array(uLightMatrix, shader_light_matrix)

shader_set_uniform_f(uLightPosition, shader_light_from[X], shader_light_from[Y], shader_light_from[Z])
shader_set_uniform_color(uLightColor, shader_light_color, 1)
shader_set_uniform_f(uLightNear, shader_light_near)
shader_set_uniform_f(uLightFar, shader_light_far)
shader_set_uniform_f(uLightFadeSize, shader_light_fadesize)
shader_set_uniform_f(uLightSpotSharpness, shader_light_spotsharpness)

texture_set_stage(uDepthBuffer, surface_get_texture(app.render_surface_spot_buffer))
gpu_set_texfilter_ext(uDepthBuffer, true)

if (app.setting_render_shadows_blur_size > 0)
    shader_set_uniform_i(uBlurQuality, app.setting_render_shadows_blur_quality)
else
    shader_set_uniform_i(uBlurQuality, 1)

if (app.setting_render_shadows_blur_quality > 1)
    shader_set_uniform_f(uBlurSize, app.setting_render_shadows_blur_size)
else
    shader_set_uniform_f(uBlurSize, 0)

shader_set_wind(shader_high_light_spot)
