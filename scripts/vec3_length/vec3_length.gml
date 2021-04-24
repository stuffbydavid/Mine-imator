/// vec3_length(vector)
/// @arg vector

function vec3_length(vec)
{
	return sqrt(vec[@ X] * vec[@ X] + vec[@ Y] * vec[@ Y] + vec[@ Z] * vec[@ Z])
}
