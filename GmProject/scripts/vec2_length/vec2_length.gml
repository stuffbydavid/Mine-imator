/// CppSeparate RealType vec2_length(VecType)
/// @arg vector

function vec2_length(vec)
{
	gml_pragma("forceinline")
	
	return sqrt(vec[@ X] * vec[@ X] + vec[@ Y] * vec[@ Y])
}
