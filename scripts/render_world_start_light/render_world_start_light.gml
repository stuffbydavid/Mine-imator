/// render_world_start_light(from, to, near, far, fov, color, strength, [fadesize, [spotsharpness]])
/// @arg from
/// @arg to
/// @arg near
/// @arg far
/// @arg fov
/// @arg color
/// @arg strength
/// @arg [fadesize
/// @arg [spotsharpness]]
/// @desc Render the scene from the light's point of view.

render_light_from = argument[0]
render_light_to = argument[1]
render_light_near = argument[2]
render_light_far = argument[3]
render_light_fov = argument[4]
render_light_color = argument[5]
render_light_strength = argument[6]

render_light_color = render_light_color

if (argument_count > 7)
	render_light_fade_size = argument[7]
if (argument_count > 8)
	render_light_spot_sharpness = argument[8]

gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
render_set_projection(render_light_from, render_light_to, vec3(0, 0, 1), render_light_fov, 1, 1, render_light_far)

render_proj_from = render_light_from
proj_matrix = matrix_get(matrix_projection)
view_proj_matrix = matrix_multiply(matrix_get(matrix_view), matrix_get(matrix_projection))

proj_depth_near = render_light_near
proj_depth_far = render_light_far

render_light_matrix = view_proj_matrix
