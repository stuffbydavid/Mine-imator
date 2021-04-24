/// render_world_start_sun(from, to)
/// @arg from
/// @arg to
/// @desc Render the scene from the sun's point of view.

function render_world_start_sun(from, to)
{
	render_light_from = from
	render_light_to = to
	render_sun_near = world_size/2
	render_sun_far = -world_size/2
	render_light_fov = 45
	render_light_color = background_sunlight_color_final
	render_light_strength = 1 + background_sunlight_strength
	
	gpu_set_ztestenable(true)
	gpu_set_zwriteenable(true)
	
	var mV = matrix_build_lookat(render_light_from[X], render_light_from[Y], render_light_from[Z], 
								 render_light_to[X], render_light_to[Y], render_light_to[Z],
								 0, 0, 1);
	
	var mP = matrix_create_ortho(-background_sunlight_range/2, background_sunlight_range/2, background_sunlight_range/2, -background_sunlight_range/2, render_sun_near, render_sun_far);
	
	camera_set_view_mat(cam_render, mV)
	camera_set_proj_mat(cam_render, mP)
	camera_apply(cam_render)
	
	render_proj_from = render_light_from
	light_proj_matrix = matrix_get(matrix_projection)
	light_view_matrix = matrix_get(matrix_view)
	light_view_proj_matrix = matrix_multiply(light_view_matrix, light_proj_matrix)
	
	render_sun_matrix = light_view_proj_matrix
	render_sun_direction = vec3_normalize(point3D_sub(render_light_from, render_light_to))
}
