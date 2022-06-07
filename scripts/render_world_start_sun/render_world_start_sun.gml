/// render_world_start_sun(cascade)
/// @arg cascade
/// @desc Render the scene from the sun's point of view.

function render_world_start_sun(cascade)
{
	render_sun_near = render_cascades[cascade].near
	render_sun_far = render_cascades[cascade].far
	render_light_fov = 45
	render_light_color = background_sunlight_color_final
	render_light_strength = 1 + background_sunlight_strength
	render_light_specular_strength = 1
	
	gpu_set_ztestenable(true)
	gpu_set_zwriteenable(true)
	
	camera_set_view_mat(cam_render, render_cascades[cascade].matView)
	camera_set_proj_mat(cam_render, render_cascades[cascade].matProj)
	camera_apply(cam_render)
	
	light_proj_matrix = matrix_get(matrix_projection)
	light_view_matrix = matrix_get(matrix_view)
	light_view_proj_matrix = matrix_multiply(light_view_matrix, light_proj_matrix)
	
	render_sun_matrix = light_view_proj_matrix
	render_sun_direction = background_sun_direction
}
