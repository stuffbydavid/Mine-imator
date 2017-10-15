/// shader_high_ssao_depth_normal_set()

render_set_uniform_int("uSSAOEnable", 1)

render_set_uniform("uBrightness", 0)
render_set_uniform("uNear", cam_near)
render_set_uniform("uFar", cam_far)