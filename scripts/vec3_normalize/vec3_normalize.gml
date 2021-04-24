/// vec3_normalize(vector)
/// @arg vector

function vec3_normalize(vec)
{
	var len = vec3_length(vec);
	return vec3_div(vec, len)
}
