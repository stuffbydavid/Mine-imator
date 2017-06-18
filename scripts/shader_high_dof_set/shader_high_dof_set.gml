/// shader_high_dof_set(depthbuffer)
/// @arg depthbuffer

var uDepthBuffer = shader_get_sampler_index(shader_high_dof, "uDepthBuffer"), 
    uScreenSize = shader_get_uniform(shader_high_dof, "uScreenSize"), 
    uBlurSize = shader_get_uniform(shader_high_dof, "uBlurSize"), 
    uDepth = shader_get_uniform(shader_high_dof, "uDepth"), 
    uRange = shader_get_uniform(shader_high_dof, "uRange"), 
    uFadeSize = shader_get_uniform(shader_high_dof, "uFadeSize"), 
    uNear = shader_get_uniform(shader_high_dof, "uNear"), 
    uFar = shader_get_uniform(shader_high_dof, "uFar");
    
shader_set(shader_high_dof)

texture_set_stage(uDepthBuffer, surface_get_texture(argument0))
gpu_set_texfilter_ext(uDepthBuffer, false)

shader_set_uniform_f(uScreenSize, render_width, render_height)

shader_set_uniform_f(uBlurSize, setting_render_dof_blur_size)
shader_set_uniform_f(uDepth, render_camera.value[CAMDOFDEPTH])
shader_set_uniform_f(uRange, render_camera.value[CAMDOFRANGE])
shader_set_uniform_f(uFadeSize, render_camera.value[CAMDOFFADESIZE])
shader_set_uniform_f(uNear, cam_near)
shader_set_uniform_f(uFar, cam_far)
