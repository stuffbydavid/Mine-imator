/// spline_get_point(progress, points, closed, [amount])
/// @arg progress
/// @arg points
/// @arg closed
/// @arg [amount]
/// @desc Calculates a 3D point on a 3D spline curve given a list of points

function spline_get_point(t, points, closed, amount = 0)
{
	var tfract, p0, p1, p2, p3, tt, ttt, q0, q1, q2, q3;
	tfract = frac(t)
	
	if (amount = 0)
		amount = array_length(points)
	
	// B-splines
	if (true)
	{
		var segment = floor(t / 2) * 2;
		
		// Get points in current curve
		p0 = segment
		p1 = p0 + 1
		p2 = p1 + 1
		
		var curvet = percent(t, p0, p2);
		
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
			var point;
			
			if (t <= 0)
			{
				var pos = vec3_add(points[0], vec3_mul(vec3_normalize(vec3_sub(points[0], points[1])), abs(t)));
				point = [pos[X], pos[Y], pos[Z], points[0][3], points[0][4]]
			}
			else
			{
				var lastpoint;
				lastpoint = array_length(points) - 1
				
				var pos = vec3_add(points[lastpoint], vec3_mul(vec3_normalize(vec3_sub(points[lastpoint], points[lastpoint - 1])), abs(t - lastpoint)));
				point = [pos[X], pos[Y], pos[Z], points[lastpoint][3], points[lastpoint][4]]
			}
			
			return point
		}
		
		return bezier_curve_quad(points[p0], points[p1], points[p2], curvet)
	}
	else // Regular spline
	{
		p1 = floor(t - 1) + 1
		p2 = p1 + 1
		p3 = p2 + 1
		p0 = p1 - 1
		
		var curvet = percent(t, p0, p3);
		
		if (closed)
		{
			p0 = mod_fix(p0, amount)
			p1 = mod_fix(p1, amount)
			p2 = mod_fix(p2, amount)
			p3 = mod_fix(p3, amount)
		}
		else
		{
			p0 = clamp(p0, 0, amount - 1)
			p1 = clamp(p1, 0, amount - 1)
			p2 = clamp(p2, 0, amount - 1)
			p3 = clamp(p3, 0, amount - 1)
		}
		
		tt = tfract * tfract
		ttt = tt * tfract
		
		q0 = -ttt + 2*tt - tfract
		q1 = 3*ttt - 5*tt + 2
		q2 = -3*ttt + 4*tt + tfract
		q3 = ttt - tt
		
		var coord;
		
		for (var j = X; j <= W; j++)
			coord[j] = 0.5 * (points[|p0][j] * q0 + points[|p1][j] * q1 + points[|p2][j] * q2 + points[|p3][j] * q3)
		
		return coord
	}
}