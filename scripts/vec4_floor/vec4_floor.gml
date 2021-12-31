/// vec4_floor(vector)
/// @arg vector

function vec4_floor(vec)
{
	return [floor(vec[@ X]), floor(vec[@ Y]), floor(vec[@ Z]), floor(vec[@ W])]
}
