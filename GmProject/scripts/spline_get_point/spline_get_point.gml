/// CppGen array splinecontrols
/// CppGen ConstRef splinecontrols
/// @desc Calculates a 3D point on a 3D B-Spline curve given a list of points.
/// @arg progress
/// @arg points
/// @arg closed
/// @arg smooth
/// @arg [amount]

function spline_get_point(t, splinecontrols, closed, smooth, amount = 0)
{
	var p0, p1, p2, seg, curvet;
	
	// Get points in current curve
	seg = floor(t / 2) * 2
	p0 = seg
	p1 = p0 + 1
	p2 = p1 + 1
	curvet = percent(t, p0, p2)
	
	if (amount = 0)
		amount = array_length(splinecontrols)
	
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
	
	if (amount = array_length(splinecontrols))
		curvet = percent(t, p0, p2)
	
	// Before/after open path
	if (!closed && (t <= 0 || t >= amount - 1))
	{
		var i, point, pos;
		
		if (t <= 0)
		{
			i = 0
			pos = vec3_add(splinecontrols[i], vec3_mul(vec3_normalize(vec3_sub(splinecontrols[i], splinecontrols[i + 1])), abs(t)))
		}
		else
		{
			i = array_length(splinecontrols) - 1
			var tangent = point3D(splinecontrols[i - 1][PATH_TANGENT_X], splinecontrols[i - 1][PATH_TANGENT_Y], splinecontrols[i - 1][PATH_TANGENT_Z]);
			pos = vec3_add(splinecontrols[i], vec3_mul(tangent, abs(t - i)))
		}
		
		point = array_copy_1d(splinecontrols[i])
		point[X] = pos[X]
		point[Y] = pos[Y]
		point[Z] = pos[Z]
		
		return point
	}
	
	if (smooth)
		return bezier_curve_quad(splinecontrols[p0], splinecontrols[p1], splinecontrols[p2], curvet)
	else
	{
		if (curvet < 0.5)
			return point_lerp(splinecontrols[p0], splinecontrols[p1], curvet * 2)
		else
			return point_lerp(splinecontrols[p1], splinecontrols[p2], (curvet - 0.5) * 2)
	}	
}
