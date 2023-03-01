/// render_world_start_light(from, to, sampleoffset, timeline]
/// @arg from
/// @arg to
/// @arg sampleoffset
/// @arg timeline
/// @desc Render the scene from the light's point of view.

function render_world_start_light(from, to, offset, tl)
{
	render_light_from = from
	render_light_to = to
	render_light_offset = offset
	render_light_near = 1
	render_light_far = tl.value[e_value.LIGHT_RANGE]
	render_light_color = tl.value[e_value.LIGHT_COLOR]
	render_light_strength = tl.value[e_value.LIGHT_STRENGTH]
	render_light_specular_strength = tl.value[e_value.LIGHT_SPECULAR_STRENGTH]
	render_light_size = tl.value[e_value.LIGHT_SIZE]
	render_light_fade_size = tl.value[e_value.LIGHT_FADE_SIZE]
	
	if (tl.type = e_tl_type.POINT_LIGHT)
	{
		render_light_fov = 90
	}
	else if (tl.type = e_tl_type.SPOT_LIGHT)
	{
		render_light_fov = tl.value[e_value.LIGHT_SPOT_RADIUS]
		render_light_spot_sharpness = tl.value[e_value.LIGHT_SPOT_SHARPNESS]
	}
	
	gpu_set_ztestenable(true)
	
	// Get origin matrix for spotlight
	if (tl.type = e_tl_type.SPOT_LIGHT)
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
