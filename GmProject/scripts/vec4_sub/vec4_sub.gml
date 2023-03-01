/// CppSeparate VecType vec4_sub(VecType, VarType)
/// vec4_sub(vector, sub)
/// @arg vector
/// @arg sub

function vec4_sub(vec, s)
{
	gml_pragma("forceinline")
	
	if (is_array(s))
		return [vec[@ X] - s[@ X], vec[@ Y] - s[@ Y], vec[@ Z] - s[@ Z], vec[@ W] - s[@ W]]
	else
		return [vec[@ X] - s, vec[@ Y] - s, vec[@ Z] - s, vec[@ W] - s]
}
