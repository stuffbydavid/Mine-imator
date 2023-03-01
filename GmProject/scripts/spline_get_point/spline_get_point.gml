/// spline_get_point(progress, points, closed, smooth, [amount])
/// @arg progress
/// @arg points
/// @arg closed
/// @arg smooth
/// @arg [amount]
/// @desc Calculates a 3D point on a 3D B-Spline curve given a list of points

function spline_get_point(t, points, closed, smooth, amount = 0)
{
	var p0, p1, p2, seg, curvet;
	
	// Get points in current curve
	seg = floor(t / 2) * 2
	p0 = seg
	p1 = p0 + 1
	p2 = p1 + 1
	curvet = percent(t, p0, p2)
	
	if (amount = 0)
		amount = array_length(points)
	
	if (closed)
	{
		p0 = mod_fix(p0, amount)
		p1 = mod_fix(p1, amount)
		p2 = mod_fix(p2, amount)
	}
	else
	{
		p0 = max(0, min(p0, amount - 1))
		p1 = max(0, min(p1, amount - 1))
		p2 = max(0, min(p2, amount - 1))
	}
	
	if (amount = array_length(points))
		curvet = percent(t, p0, p2)
	
	// Before/after open path
	if (!closed && (t <= 0 || t >= amount - 1))
	{
		var i, point, pos;
		
		if (t <= 0)
		{
			i = 0
			pos = vec3_add(points[i], vec3_mul(vec3_normalize(vec3_sub(points[i], points[i + 1])), abs(t)));
		}
		else
		{
			i = array_length(points) - 1
			pos = vec3_add(points[i], vec3_mul([points[i - 1][PATH_TANGENT_X], points[i - 1][PATH_TANGENT_Y], points[i - 1][PATH_TANGENT_Z]], abs(t - i)));
		}
		
		point = array_copy_1d(points[i])
		point[X] = pos[X]
		point[Y] = pos[Y]
		point[Z] = pos[Z]
		point[PATH_TANGENT_X] = point[PATH_TANGENT_X] // Convert to VarType
		
		return point
	}
	
	if (smooth)
		return bezier_curve_quad(points[p0], points[p1], points[p2], curvet)
	else
	{
		if (curvet < 0.5)
			return point_lerp(points[p0], points[p1], curvet * 2)
		else
			return point_lerp(points[p1], points[p2], (curvet - 0.5) * 2)
	}	
}