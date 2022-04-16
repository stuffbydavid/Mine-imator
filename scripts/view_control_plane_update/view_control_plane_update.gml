/// view_control_plane_update()
/// @desc Updates plane gizmo

function view_control_plane_update()
{
	var mousex, mousey;
	mousex = ((view_control_plane_mouse[X] - content_x + view_control_plane_offset[X]) / content_width)
	mousey = ((view_control_plane_mouse[Y] - content_y + view_control_plane_offset[Y]) / content_height)
	view_control_ray_dir = vec3_project_ray([mousex, mousey])
	
	// Update mouse
	view_control_plane_mouse[X] += mouse_dx * dragger_multiplier
	view_control_plane_mouse[Y] += mouse_dy * dragger_multiplier
}
