/// shader_depth_point_set()

render_set_uniform_vec3("uEye", render_proj_from[X], render_proj_from[Y], render_proj_from[Z])
render_set_uniform("uNear", proj_depth_near)
render_set_uniform("uFar", proj_depth_far)
