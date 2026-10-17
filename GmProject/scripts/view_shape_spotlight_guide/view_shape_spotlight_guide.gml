/// @desc Renders an outline of a spotlight's light cone.
/// @arg timeline

function view_shape_spotlight_guide(tl)
{
	// Convert to world space
	var mat = array_copy_1d(tl.matrix);
	matrix_remove_scale(mat)
	
	var range, radius, sharpness, fadesize;
	range = tl.value[e_value.LIGHT_RANGE]
	radius = tl.value[e_value.LIGHT_SPOT_RADIUS]
	sharpness = tl.value[e_value.LIGHT_SPOT_SHARPNESS]
	fadesize = tl.value[e_value.LIGHT_FADE_SIZE]
	
	// Range
	var length, lensin, lencos;
	length = max(0, range)
	lensin = sin(degtorad(radius * 0.5))
	lencos = cos(degtorad(radius * 0.5))
	
	//draw_set_alpha(.5)
	draw_set_color(c_control_red)
	view_shape_line(point3D_mul_matrix(point3D(0, 0, 0), mat), point3D_mul_matrix(point3D(0, length, 0), mat))
	
	// Spot radius
	view_shape_line(point3D_mul_matrix(point3D(0, 0, 0), mat), point3D_mul_matrix(point3D(0, abs(length * lencos), length * lensin), mat))
	view_shape_line(point3D_mul_matrix(point3D(0, 0, 0), mat), point3D_mul_matrix(point3D(0, abs(length * lencos), length * -lensin), mat))
	view_shape_line(point3D_mul_matrix(point3D(0, 0, 0), mat), point3D_mul_matrix(point3D(length * lensin, abs(length * lencos), 0), mat))
	view_shape_line(point3D_mul_matrix(point3D(0, 0, 0), mat), point3D_mul_matrix(point3D(length * -lensin, abs(length * lencos), 0), mat))
	
	view_shape_spotlight_guidecircle(tl, range, radius, mat)
	
	// Sharpness
	draw_set_color(c_control_yellow)
	view_shape_spotlight_guidecircle(tl, range, max(0, radius) * clamp((sharpness), 0, 1), mat)
	
	// Fade size
	draw_set_color(c_control_yellow)
	view_shape_spotlight_guidecircle(tl, max(0, range) * clamp((1 - fadesize), 0, 1), radius, mat)
	
	draw_set_color(c_white)
	//draw_set_alpha(1)
}
