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
