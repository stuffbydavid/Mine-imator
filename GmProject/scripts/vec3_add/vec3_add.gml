/// CppSeparate VecType vec3_add(VecType, VarType)
/// vec3_add(vector1, vector2)
/// @arg vector1
/// @arg vector2

function vec3_add(v1, v2)
{
	gml_pragma("forceinline")
	
	if (is_array(v2))
		return [v1[@ X] + v2[@ X], v1[@ Y] + v2[@ Y], v1[@ Z] + v2[@ Z]]
	else
		return [v1[@ X] + v2, v1[@ Y] + v2, v1[@ Z] + v2]
}
