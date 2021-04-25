/// render_world_start_light(from, to, sampleoffset, near, far, fov, color, strength, [fadesize, [spotsharpness]])
/// @arg from
/// @arg to
/// @arg sampleoffset
/// @arg near
/// @arg far
/// @arg fov
/// @arg color
/// @arg strength
/// @arg [fadesize
/// @arg [spotsharpness]]
/// @desc Render the scene from the light's point of view.

function render_world_start_light()
{
	render_light_from = argument[0]
	render_light_to = argument[1]
	render_light_offset = argument[2]
	render_light_near = argument[3]
	render_light_far = argument[4]
	render_light_fov = argument[5]
	render_light_color = argument[6]
	render_light_strength = argument[7]
	
	render_light_color = render_light_color
	
	if (argument_count > 8)
		render_light_fade_size = argument[8]
	if (argument_count > 9)
		render_light_spot_sharpness = argument[9]
	
	gpu_set_ztestenable(true)
	gpu_set_zwriteenable(true)
	
	// Get origin matrix for spotlight
	if (argument_count > 9)
	{
		render_set_projection(render_light_from, render_light_to, vec3(0, 0, 1), render_light_fov, 1, 1, render_light_far)
		spot_proj_matrix = matrix_get(matrix_projection)
		spot_view_matrix = matrix_get(matrix_view)
		spot_view_proj_matrix = matrix_multiply(spot_view_matrix, spot_proj_matrix)
		
		render_spot_matrix = spot_view_proj_matrix
	}
	
	render_set_projection(point3D_add(render_light_from, render_light_offset), point3D_add(render_light_to, render_light_offset), vec3(0, 0, 1), render_light_fov, 1, 1, render_light_far)
	
	render_proj_from = point3D_add(render_light_from, render_light_offset)
	render_shadow_from = render_proj_from
	light_proj_matrix = matrix_get(matrix_projection)
	light_view_matrix = matrix_get(matrix_view)
	light_view_proj_matrix = matrix_multiply(light_view_matrix, light_proj_matrix)
	
	proj_depth_near = render_light_near
	proj_depth_far = render_light_far
	
	render_shadow_matrix = light_view_proj_matrix
}
