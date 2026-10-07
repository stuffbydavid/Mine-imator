/// @desc Tests the point/spot light's influence sphere or cone against the camera frustum.

function render_light_visible(planes)
{
	var range, dir, rad, margin;
	range = value[e_value.LIGHT_RANGE]
	if (range <= 0)
		return true
	
	dir = vec3(0)
	rad = 0
	margin = max(0.001, range * 0.000001)
	
	if (type = e_tl_type.SPOT_LIGHT)
	{
		// Match the unjittered spotlight projection, including its small direction offset
		dir = vec3(matrix[4] + matrix[0] * 0.0001, matrix[5] + matrix[1] * 0.0001, matrix[6] + matrix[2] * 0.0001)
		if (vec3_length(dir) <= 0)
			return true
		
		dir = vec3_normalize(dir)
		rad = range * tan(degtorad(value[e_value.LIGHT_SPOT_RADIUS] * 0.5))
	}
	
	for (var p = 0; p < 6; p++)
	{
		var plane, dis, support;
		plane = planes[@ p]
		dis = vec3_dot(plane, world_pos) + plane[W]
		support = dis + range
		
		if (type = e_tl_type.SPOT_LIGHT)
		{
			var along, base;
			along = clamp(vec3_dot(plane, dir), -1, 1)
			base = dis + range * along + rad * sqrt(max(0, 1 - along * along))
			
			// Both the range sphere and the cone must reach the plane
			support = min(support, max(dis, base))
		}
		
		if (support < -margin)
			return false
	}
	
	return true
}
