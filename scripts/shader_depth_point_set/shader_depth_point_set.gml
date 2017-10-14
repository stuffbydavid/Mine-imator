/// shader_depth_point_set()

render_set_uniform_vec3("uEye", proj_from[X], proj_from[Y], proj_from[Z])
render_set_uniform("uNear", proj_depth_near)
render_set_uniform("uFar", proj_depth_far)
