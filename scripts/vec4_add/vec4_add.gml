/// vec4_add(vector, add)
/// @arg vector
/// @arg add

function vec4_add(vec, a)
{
	if (is_array(a))
		return [vec[@ X] + a[@ X], vec[@ Y] + a[@ Y], vec[@ Z] + a[@ Z], vec[@ W] + a[@ W]]
	else
		return [vec[@ X] + a, vec[@ Y] + a, vec[@ Z] + a, vec[@ W] + a]
}
