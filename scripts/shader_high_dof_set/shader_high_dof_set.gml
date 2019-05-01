/// shader_high_dof_set(depthbuffer)
/// @arg depthbuffer

texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(argument0))
gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)

render_set_uniform_vec2("uScreenSize", render_width, render_height)

var blursize = vec2(1 + render_camera.value[e_value.CAM_DOF_BLUR_RATIO], 1 - render_camera.value[e_value.CAM_DOF_BLUR_RATIO]);
blursize = vec2_mul(blursize, render_camera.value[e_value.CAM_DOF_BLUR_SIZE])

render_set_uniform_vec2("uBlurSize", blursize[X], blursize[Y])
render_set_uniform("uDepth", render_camera.value[e_value.CAM_DOF_DEPTH])
render_set_uniform("uRange", render_camera.value[e_value.CAM_DOF_RANGE])
render_set_uniform("uFadeSize", render_camera.value[e_value.CAM_DOF_FADE_SIZE])
render_set_uniform("uNear", cam_near)
render_set_uniform("uFar", cam_far)

render_set_uniform("uBias", render_camera.value[e_value.CAM_DOF_BIAS])
render_set_uniform("uThreshold", render_camera.value[e_value.CAM_DOF_THRESHOLD])
render_set_uniform("uGain", render_camera.value[e_value.CAM_DOF_GAIN])

render_set_uniform_int("uFringe", bool_to_float(render_camera.value[e_value.CAM_DOF_FRINGE]))
render_set_uniform_vec3("uFringeAngle", -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_RED] + 180), -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_GREEN] + 180), -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_BLUE] + 180))
render_set_uniform_vec3("uFringeStrength", render_camera.value[e_value.CAM_DOF_FRINGE_RED], render_camera.value[e_value.CAM_DOF_FRINGE_GREEN], render_camera.value[e_value.CAM_DOF_FRINGE_BLUE])