/// shader_grain_set()

texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_grain_noise))
gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
gpu_set_tex_filter_ext(sampler_map[?"uNoiseBuffer"], true)

render_set_uniform_vec2("uScreenSize", render_width, render_height)

render_set_uniform("uStrength", render_camera.value[e_value.CAM_GRAIN_STRENGTH])
render_set_uniform("uSaturation", render_camera.value[e_value.CAM_GRAIN_SATURATION])
render_set_uniform("uSize", vec2_mul(vec2(ceil(render_width/8), ceil(render_height/8)), render_camera.value[e_value.CAM_GRAIN_SIZE]))
