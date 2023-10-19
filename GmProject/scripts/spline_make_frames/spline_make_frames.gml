/// spline_make_frames(points, closed, smooth)
/// @arg points
/// @arg closed
/// @arg smooth
/// @desc Constructs rotation frames based on tangents, detects changes in torsion and aligns normals

function spline_make_frames(points, closed, smooth)
{
	var p, pn, t, tn, n, nn, rn, j;
	p = spline_get_point(0, points, closed, smooth)
	pn = spline_get_point(1, points, closed, smooth)
	t = vec3_direction(p, pn)
	
	if (t[Z] = 1 || t[Z] = -1)
		n = [t[Z], 0, 0]
	else
		n = vec3_normal(t, 0)
	
	n = vec3_rotate_axis_angle(n, t, p[W])
	
	// Set begin tangent/normal
	for (j = X; j <= Z; j++)
	{
		points[@ 0][@ PATH_TANGENT_X + j] = t[j]
		points[@ 0][@ PATH_NORMAL_X + j] = n[j]
	}
	p = pn
	
	var axis, angle;
	
	// Procedurally calculate and correct normals
	for (var i = 1; i < array_length(points); i++)
	{
		pn = spline_get_point(i + 1, points, closed, smooth)
		tn = vec3_direction(p, pn)
		
		// Find angle difference and rotate
		axis = vec3_normalize(vec3_cross(t, tn))
		angle = vec3_dot(t, tn)
		nn = vec3_normalize(vec3_mul_matrix(n, matrix_create_axis_angle(axis, angle)))
		
		// Rotate normal on point angle
		rn = vec3_rotate_axis_angle(nn, tn, degtorad(pn[W]))
		
		for (j = X; j <= Z; j++)
		{
			points[@ i][@ PATH_TANGENT_X + j] = tn[j]
			points[@ i][@ PATH_NORMAL_X + j] = rn[j]
		}
		
		p = pn
		n = nn
		t = tn
	}
	
	// Connect ends
	if (closed)
	{
		var p1, p2, p;
		p1 = points[1]
		p2 = points[array_length(points) - 2]
		
		t = vec3_normalize([p1[PATH_TANGENT_X] + p2[PATH_TANGENT_X], p1[PATH_TANGENT_Y] + p2[PATH_TANGENT_Y], p1[PATH_TANGENT_Z] + p2[PATH_TANGENT_Z]])
		n = vec3_normalize([p1[PATH_NORMAL_X] + p2[PATH_NORMAL_X], p1[PATH_NORMAL_Y] + p2[PATH_NORMAL_Y], p1[PATH_NORMAL_Z] + p2[PATH_NORMAL_Z]])
		
		for (j = X; j <= Z; j++)
		{
			points[@ 0][@ PATH_TANGENT_X + j] = t[j]
			points[@ 0][@ PATH_NORMAL_X + j] = n[j]
			
			points[@ array_length(points) - 1][@ PATH_TANGENT_X + j] = t[j]
			points[@ array_length(points) - 1][@ PATH_NORMAL_X + j] = n[j]
		}
	}
	
}