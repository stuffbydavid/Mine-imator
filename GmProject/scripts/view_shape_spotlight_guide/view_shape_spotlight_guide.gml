/// view_shape_spotlight_guide(timeline)
/// @arg timeline
/// @desc Renders an outline of a spotlight's light cone.

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
	
	//draw_set_alpha(.5)
	
	// Range
	draw_set_color(c_control_red)
	var length, lensin, lencos;
	length = max(0, range);
	lensin = sin(degtorad(radius * 0.5));
	lencos = cos(degtorad(radius * 0.5));
	
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

function view_shape_spotlight_guidecircle(tl, range, radius, mat)
{
	// Draws a flat circle that does not face the camera
	var length, lensin, lencos;
	length = max(0, range);
	lensin = sin(degtorad(radius * 0.5));
	lencos = cos(degtorad(radius * 0.5));
	
	var start3D, end3D, detail;
	detail = 32;
	start3D = point3D_mul_matrix(point3D(cos(0) * length * lensin, sin(0) * length * lensin, 0), mat)
	
	// Draw circle
	for (var i = 0; i <= 1; i += 1/detail)
	{
		end3D = point3D_mul_matrix(point3D(cos(pi * 2 * i) * length * lensin, abs(length * lencos), sin(pi * 2 * i) * length * lensin), mat)
		
		// Using 0 to set up start positions
		if (i > 0)
			view_shape_line(start3D, end3D)
		
		start3D = end3D
	}
}