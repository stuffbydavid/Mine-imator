/// vec2_length(vector)
/// @arg vector

function vec2_length(vec)
{
	gml_pragma("forceinline")
	
	return sqrt(vec[@ X] * vec[@ X] + vec[@ Y] * vec[@ Y])
}
