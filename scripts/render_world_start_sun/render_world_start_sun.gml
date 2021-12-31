/// render_world_start_sun(from, to, offset)
/// @arg from
/// @arg to
/// @arg offset
/// @desc Render the scene from the sun's point of view.

function render_world_start_sun(from, to, offset)
{
	render_light_from = from
	render_light_to = to
	render_light_offset = offset
	render_sun_near = render_cascades[render_cascade_debug].near //0.1
	render_sun_far = render_cascades[render_cascade_debug].far //world_size/2
	render_light_fov = 45
	render_light_color = background_sunlight_color_final
	render_light_strength = 1 + background_sunlight_strength
	render_light_specular_strength = 1
	
	gpu_set_ztestenable(true)
	gpu_set_zwriteenable(true)
	
	var shadowfrom, shadowto;
	shadowfrom = point3D_add(render_light_from, render_light_offset)
	shadowto = render_light_to
	
	var mV = render_cascades[render_cascade_debug].matView;/*matrix_build_lookat(shadowfrom[X], shadowfrom[Y], shadowfrom[Z], 
								 shadowto[X], shadowto[Y], shadowto[Z],
								 0, 0, 1);*/
	
	var mP = render_cascades[render_cascade_debug].matProj;//matrix_build_projection_ortho(background_sunlight_range/2, -background_sunlight_range/2, render_sun_near, render_sun_far);
	
	camera_set_view_mat(cam_render, mV)
	camera_set_proj_mat(cam_render, mP)
	camera_apply(cam_render)
	
	render_proj_from = shadowfrom
	light_proj_matrix = matrix_get(matrix_projection)
	light_view_matrix = matrix_get(matrix_view)
	light_view_proj_matrix = matrix_multiply(light_view_matrix, light_proj_matrix)
	
	// Frustum culling is wack in ortho, disable it for now
	render_frustum.build(light_view_proj_matrix)
	render_frustum.active = false
	bbox_update_visible()
	
	render_sun_matrix = light_view_proj_matrix
	//render_sun_direction = background_sun_direction
}
