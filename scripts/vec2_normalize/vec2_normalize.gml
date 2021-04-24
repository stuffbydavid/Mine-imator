/// vec2_normalize(vector)
/// @arg vector

function vec2_normalize(vec)
{
	var len = vec2_length(vec);
	return vec2_div(vec, len)
}
