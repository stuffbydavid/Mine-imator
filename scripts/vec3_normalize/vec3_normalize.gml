/// vec3_normalize(vector)
/// @arg vector

function vec3_normalize(vec)
{
	var len = vec3_length(vec);
	
	if (len = 0)
		len = 1
	
	return vec3_div(vec, len)
}
