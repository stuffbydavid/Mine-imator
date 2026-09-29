/// CppSeparate VecType vec4_floor(VecType)
/// @arg vector

function vec4_floor(vec)
{
	gml_pragma("forceinline")
	
	return [floor(vec[@ X]), floor(vec[@ Y]), floor(vec[@ Z]), floor(vec[@ W])]
}
