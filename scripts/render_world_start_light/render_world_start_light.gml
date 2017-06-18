/// render_world_start_light(from, to, near, far, fov, color, [fadesize, [spotsharpness]])
/// @arg from
/// @arg to
/// @arg near
/// @arg far
/// @arg fov
/// @arg color
/// @arg [fadesize
/// @arg [spotsharpness]]
/// @desc Render the scene from the light's point of view.

shader_light_from = argument[0]
shader_light_to = argument[1]
shader_light_near = argument[2]
shader_light_far = argument[3]
shader_light_fov = argument[4]
shader_light_color = argument[5]
if (argument_count > 6)
	shader_light_fadesize = argument[6]
if (argument_count > 7)
	shader_light_spotsharpness = argument[7]

gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
render_set_projection(shader_light_from, shader_light_to, vec3(0, 0, 1), shader_light_fov, 1, 1, shader_light_far)

proj_from = shader_light_from
proj_matrix = matrix_get(matrix_projection)
view_proj_matrix = matrix_multiply(matrix_get(matrix_view), matrix_get(matrix_projection))

proj_depth_near = shader_light_near
proj_depth_far = shader_light_far

shader_light_matrix = view_proj_matrix
