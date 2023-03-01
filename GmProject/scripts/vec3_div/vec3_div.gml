/// CppSeparate VecType vec3_div(VecType, VarType)
/// vec3_div(vector, divisor)
/// @arg vector
/// @arg divisor

function vec3_div(vec, d)
{
	gml_pragma("forceinline")
	
	if (is_array(d))
		return [vec[@ X] / d[@ X], vec[@ Y] / d[@ Y], vec[@ Z] / d[@ Z]]
	else
		return [vec[@ X] / d, vec[@ Y] / d, vec[@ Z] / d]
}
