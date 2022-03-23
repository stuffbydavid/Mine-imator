/// spline_make_frames(points, closed)
/// @arg points
/// @arg closed
/// @desc Constructs rotation frames based on tangents, detects changes in torsion and aligns normals

function spline_make_frames(points, closed)
{
	var p, pn, t, tn, n, nn, rn;
	p = spline_get_point(0, points, closed)
	pn = spline_get_point(1, points, closed)
	t = vec3_direction(p, pn)
	n = vec3_normal(t, 0)
	
	// Set first normal
	points[@ 0][@ PATH_TANGENT_X] = t[X]
	points[@ 0][@ PATH_TANGENT_Y] = t[Y]
	points[@ 0][@ PATH_TANGENT_Z] = t[Z]
	points[@ 0][@ PATH_NORMAL_X] = n[X]
	points[@ 0][@ PATH_NORMAL_Y] = n[Y]
	points[@ 0][@ PATH_NORMAL_Z] = n[Z]
	
	p = pn
	
	var axis, angle;
	
	// Procedurally calculate and correct normals
	for (var i = 1; i < array_length(points); i++)
	{
		pn = spline_get_point(i + 1, points, closed)
		tn = vec3_direction(p, pn)
		
		// Find angle difference and rotate
		axis = vec3_normalize(vec3_cross(t, tn))
		angle = vec3_dot(t, tn)
		nn = vec3_normalize(vec3_mul_matrix(n, matrix_create_axis_angle(axis, angle)))
		
		// Rotate normal on point angle
		rn = vec3_rotate_axis_angle(nn, tn, degtorad(pn[W]))//vec3_normalize(vec3_mul_matrix(nn, matrix_create_axis_angle(tn, pn[W] / 360)))
		
		points[@ i][@ PATH_TANGENT_X] = tn[X]
		points[@ i][@ PATH_TANGENT_Y] = tn[Y]
		points[@ i][@ PATH_TANGENT_Z] = tn[Z]
		
		points[@ i][@ PATH_NORMAL_X] = rn[X]
		points[@ i][@ PATH_NORMAL_Y] = rn[Y]
		points[@ i][@ PATH_NORMAL_Z] = rn[Z]
		
		p = pn
		n = nn
		t = tn
	}
	
	// Merge last/first point frame in closed spline
	if (closed)
	{
		var i, p, pn, t, n;
		i = array_length(points) - 2
		p = points[@ i - 1]
		pn = points[@ 0]
		
		t = vec3_normalize([p[PATH_TANGENT_X] + pn[PATH_TANGENT_X], p[PATH_TANGENT_Y] + pn[PATH_TANGENT_Y], p[PATH_TANGENT_Z] + pn[PATH_TANGENT_Z]])
		n = vec3_normalize([p[PATH_NORMAL_X] + pn[PATH_NORMAL_X], p[PATH_NORMAL_Y] + pn[PATH_NORMAL_Y], p[PATH_NORMAL_Z] + pn[PATH_NORMAL_Z]])
		
		points[@ i][@ PATH_TANGENT_X] = t[X]
		points[@ i][@ PATH_TANGENT_Y] = t[Y]
		points[@ i][@ PATH_TANGENT_Z] = t[Z]
		
		points[@ i][@ PATH_NORMAL_X] = n[X]
		points[@ i][@ PATH_NORMAL_Y] = n[Y]
		points[@ i][@ PATH_NORMAL_Z] = n[Z]
		
		i = array_length(points) - 1
		points[@ i][@ PATH_TANGENT_X] = pn[@ PATH_TANGENT_X]
		points[@ i][@ PATH_TANGENT_Y] = pn[@ PATH_TANGENT_Y]
		points[@ i][@ PATH_TANGENT_Z] = pn[@ PATH_TANGENT_Z]
		
		points[@ i][@ PATH_NORMAL_X] = pn[@ PATH_NORMAL_X]
		points[@ i][@ PATH_NORMAL_Y] = pn[@ PATH_NORMAL_Y]
		points[@ i][@ PATH_NORMAL_Z] = pn[@ PATH_NORMAL_Z]
	}
}