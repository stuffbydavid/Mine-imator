/// shader_high_ssao_blur_set(depthsurface, normalsurface, checkx, checky)
/// @arg depthsurface
/// @arg normalsurface
/// @arg checkx
/// @arg checky

var uDepthBuffer = shader_get_sampler_index(shader_high_ssao_blur, "uDepthBuffer"), 
	uNormalBuffer = shader_get_sampler_index(shader_high_ssao_blur, "uNormalBuffer"), 
	uScreenSize = shader_get_uniform(shader_high_ssao_blur, "uScreenSize"), 
	uPixelCheck = shader_get_uniform(shader_high_ssao_blur, "uPixelCheck");
	
shader_set(shader_high_ssao_blur)

texture_set_stage(uDepthBuffer, surface_get_texture(argument0))
gpu_set_texrepeat_ext(uDepthBuffer, false)
texture_set_stage(uNormalBuffer, surface_get_texture(argument1))
gpu_set_texrepeat_ext(uNormalBuffer, false)
shader_set_uniform_f(uScreenSize, render_width, render_height)
shader_set_uniform_f(uPixelCheck, argument2, argument3)

shader_set_wind(shader_high_ssao_blur)
