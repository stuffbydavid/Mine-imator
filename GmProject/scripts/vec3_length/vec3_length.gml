/// CppSeparate RealType vec3_length(VecType)
/// vec3_length(vector)
/// @arg vector

function vec3_length(vec)
{
	gml_pragma("forceinline")
	
	return sqrt(vec[@ X] * vec[@ X] + vec[@ Y] * vec[@ Y] + vec[@ Z] * vec[@ Z])
}
