/// CppSeparate VecType vec4_div(VecType, VarType)
/// vec4_div(vector, divisor)
/// @arg vector
/// @arg divisor

function vec4_div(vec, d)
{
	gml_pragma("forceinline")
	
	if (is_array(d))
		return [vec[@ X] / d[@ X], vec[@ Y] / d[@ Y], vec[@ Z] / d[@ Z], vec[@ W] / d[@ W]]
	else
		return [vec[@ X] / d, vec[@ Y] / d, vec[@ Z] / d, vec[@ W] / d]
}
