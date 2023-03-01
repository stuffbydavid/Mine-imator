/// view_shape_tnb_frame(pos, tangent, normal)
/// @arg pos
/// @arg tangent
/// @arg normal

function view_shape_tnb_frame(pos, tangent, normal)
{
	var binormal, poscoord, poscoord2d, poscoord2derror, veccoord, veccoord2d, veccoord2derror, col;
	binormal = vec3_normalize(vec3_cross(tangent, normal))	
	poscoord = pos
	poscoord2d = view_shape_project(poscoord)
	poscoord2derror = point3D_project_error
	
	if (poscoord2derror)
		return 0
	
	col = draw_get_color()
	
	// Normal
	veccoord = vec3_add(poscoord, vec3_mul(normal, 2))
	veccoord2d = view_shape_project(veccoord)
	veccoord2derror = point3D_project_error
	
	draw_set_color(c_control_blue)
	if (!veccoord2derror)
		view_shape_line_draw(poscoord2d, veccoord2d)
	
	// Tangent
	veccoord = vec3_add(poscoord, vec3_mul(tangent, 2))
	veccoord2d = view_shape_project(veccoord)
	veccoord2derror = point3D_project_error
	
	draw_set_color(c_control_red)
	if (!veccoord2derror)
		view_shape_line_draw(poscoord2d, veccoord2d)
	
	// Binormal
	veccoord = vec3_add(poscoord, vec3_mul(binormal, 2))
	veccoord2d = view_shape_project(veccoord)
	veccoord2derror = point3D_project_error
	
	draw_set_color(c_control_green)
	if (!veccoord2derror)
		view_shape_line_draw(poscoord2d, veccoord2d)
	
	draw_set_color(col)
}
