/// CppSeparate VecType point2D_copy(VecType)
/// @arg point

function point2D_copy(p)
{
	gml_pragma("forceinline")
	
	return array_copy_1d(p)
}
