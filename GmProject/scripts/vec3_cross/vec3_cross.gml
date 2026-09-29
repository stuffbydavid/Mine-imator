/// CppSeparate VecType vec3_cross(VecType, VecType)
/// @arg vector1
/// @arg vector2

function vec3_cross(v1, v2)
{
	gml_pragma("forceinline")
	
	return [
		v1[@ Y] * v2[@ Z] - v1[@ Z] * v2[@ Y],
		v1[@ Z] * v2[@ X] - v1[@ X] * v2[@ Z],
		v1[@ X] * v2[@ Y] - v1[@ Y] * v2[@ X]
	]
}
