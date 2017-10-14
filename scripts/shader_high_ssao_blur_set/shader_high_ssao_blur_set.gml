/// shader_high_ssao_blur_set(depthsurface, normalsurface, checkx, checky)
/// @arg depthsurface
/// @arg normalsurface
/// @arg checkx
/// @arg checky

texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(argument0))
texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(argument1))
gpu_set_texrepeat_ext(sampler_map[?"uDepthBuffer"], false)
gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)

render_set_uniform_vec2("uScreenSize", render_width, render_height)
render_set_uniform_vec2("uPixelCheck", argument2, argument3)