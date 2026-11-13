/// CppSeparate VecType vec4_homogenize(VecType)
/// @arg vector

function vec4_homogenize(vec)
{
	gml_pragma("forceinline")
	
	return [ vec[X] / vec[W], vec[Y] / vec[W], vec[Z] / vec[W] ]
}
