/// vec2_normalize(vector)
/// @arg vector

function vec2_normalize(vec)
{
	return vec2_div(vec, vec2_length(vec))
}
