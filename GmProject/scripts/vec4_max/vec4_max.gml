/// CppSeparate VecType vec4_max(VecType, VecType)
/// vec4_max(vec1, vec2)
/// @arg vec1
/// @arg vec2

function vec4_max(v1, v2)
{
	gml_pragma("forceinline")
	
	return [max(v1[X], v2[X]), max(v1[Y], v2[Y]), max(v1[Z], v2[Z]), max(v1[W], v2[W])]
}
