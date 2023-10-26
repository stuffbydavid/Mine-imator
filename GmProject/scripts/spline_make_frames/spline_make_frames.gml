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
	
	// Set first normal
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
	
	// Merge last/first point frame in closed spline
	if (closed)
	{
		var i, p, pn, t, n;
		i = array_length(points) - 2
		p = points[@ i - 1]
		pn = points[@ 0]
		
		t = vec3_normalize([p[PATH_TANGENT_X] + pn[PATH_TANGENT_X], p[PATH_TANGENT_Y] + pn[PATH_TANGENT_Y], p[PATH_TANGENT_Z] + pn[PATH_TANGENT_Z]])
		n = vec3_normalize([p[PATH_NORMAL_X] + pn[PATH_NORMAL_X], p[PATH_NORMAL_Y] + pn[PATH_NORMAL_Y], p[PATH_NORMAL_Z] + pn[PATH_NORMAL_Z]])
		
		for (j = X; j <= Z; j++)
		{
			points[@ i][@ PATH_TANGENT_X + j] = t[j]
			points[@ i][@ PATH_NORMAL_X + j] = n[j]
		}
		
		i = array_length(points) - 1
		
		for (j = X; j <= Z; j++)
		{
			points[@ i][@ PATH_TANGENT_X + j] = pn[@ PATH_TANGENT_X + j]
			points[@ i][@ PATH_NORMAL_X + j] = pn[@ PATH_NORMAL_X + j]
		}
	}
}