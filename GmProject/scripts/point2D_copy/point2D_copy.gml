/// CppSeparate VecType point2D_copy(VecType)
/// point2D_copy(point)
/// @arg point

function point2D_copy(p)
{
	gml_pragma("forceinline")
	
	return array_copy_1d(p)
}
