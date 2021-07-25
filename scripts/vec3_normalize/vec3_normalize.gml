/// vec3_normalize(vector)
/// @arg vector

function vec3_normalize(vec)
{
	var len = point_distance_3d(0, 0, 0, vec[@ X], vec[@ Y], vec[@ Z]);// vec3_length(vec);
	
	if (len = 0)
		return vec
	
	return [vec[@ X] / len, vec[@ Y] / len, vec[@ Z] / len]
}
