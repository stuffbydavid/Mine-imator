/// shader_high_dof_set(blurbuffer)
/// @arg blurbuffer

texture_set_stage(sampler_map[?"uBlurBuffer"], surface_get_texture(argument0))
gpu_set_texfilter_ext(sampler_map[?"uBlurBuffer"], false)

render_set_uniform_vec2("uScreenSize", render_width, render_height)

render_set_uniform("uBlurSize", render_camera.value[e_value.CAM_DOF_BLUR_SIZE])

render_set_uniform("uBias", render_camera.value[e_value.CAM_DOF_BIAS])
render_set_uniform("uThreshold", render_camera.value[e_value.CAM_DOF_THRESHOLD])
render_set_uniform("uGain", render_camera.value[e_value.CAM_DOF_GAIN])

render_set_uniform_int("uFringe", bool_to_float(render_camera.value[e_value.CAM_DOF_FRINGE]))
render_set_uniform_vec3("uFringeAngle", -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_RED] + 180), -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_GREEN] + 180), -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_BLUE] + 180))
render_set_uniform_vec3("uFringeStrength", render_camera.value[e_value.CAM_DOF_FRINGE_RED], render_camera.value[e_value.CAM_DOF_FRINGE_GREEN], render_camera.value[e_value.CAM_DOF_FRINGE_BLUE])

render_generate_dof_samples(render_camera.value[e_value.CAM_BLADE_AMOUNT], render_camera.value[e_value.CAM_BLADE_ANGLE], render_camera.value[e_value.CAM_DOF_BLUR_RATIO])
render_set_uniform_int("uSampleAmount", render_dof_sample_amount)
render_set_uniform("uSamples", render_dof_samples)
render_set_uniform("uWeightSamples", render_dof_weight_samples)
