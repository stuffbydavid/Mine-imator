/// shader_high_ssao_set(depthsurface, normalsurface, brightnesssurf)
/// @arg depthsurface
/// @arg normalsurface
/// @arg brightnesssurf

var uDepthBuffer = shader_get_sampler_index(shader_high_ssao, "uDepthBuffer"), 
    uNormalBuffer = shader_get_sampler_index(shader_high_ssao, "uNormalBuffer"), 
    uBrightnessBuffer = shader_get_sampler_index(shader_high_ssao, "uBrightnessBuffer"), 
    uNoiseBuffer = shader_get_sampler_index(shader_high_ssao, "uNoiseBuffer"), 
    uNear = shader_get_uniform(shader_high_ssao, "uNear"), 
    uFar = shader_get_uniform(shader_high_ssao, "uFar"), 
    uProjMatrix = shader_get_uniform(shader_high_ssao, "uProjMatrix"), 
    uProjMatrixInv = shader_get_uniform(shader_high_ssao, "uProjMatrixInv"), 
    uScreenSize = shader_get_uniform(shader_high_ssao, "uScreenSize"), 
    uKernel = shader_get_uniform(shader_high_ssao, "uKernel"), 
    uRadius = shader_get_uniform(shader_high_ssao, "uRadius"), 
    uPower = shader_get_uniform(shader_high_ssao, "uPower"), 
    uColor = shader_get_uniform(shader_high_ssao, "uColor");
    
if (!surface_exists(render_ssao_noise))
    render_ssao_noise = render_generate_noise(4, 4)

shader_set(shader_high_ssao)

texture_set_stage(uDepthBuffer, surface_get_texture(argument0))
texture_set_stage(uNormalBuffer, surface_get_texture(argument1))
texture_set_stage(uBrightnessBuffer, surface_get_texture(argument2))
texture_set_stage(uNoiseBuffer, surface_get_texture(render_ssao_noise))
gpu_set_texrepeat_ext(uDepthBuffer, false)
gpu_set_texrepeat_ext(uNormalBuffer, false)
gpu_set_texrepeat_ext(uBrightnessBuffer, false)
gpu_set_texrepeat_ext(uNoiseBuffer, true)

shader_set_uniform_f(uNear, cam_near)
shader_set_uniform_f(uFar, cam_far)
shader_set_uniform_f_array(uProjMatrix, proj_matrix)
shader_set_uniform_f_array(uProjMatrixInv, matrix_inverse(proj_matrix))
shader_set_uniform_f(uScreenSize, render_width, render_height)

shader_set_uniform_f_array(uKernel, render_ssao_kernel)
shader_set_uniform_f(uRadius, setting_render_ssao_radius)
shader_set_uniform_f(uPower, setting_render_ssao_power)
shader_set_uniform_color(uColor, setting_render_ssao_color, 1)
