/// CppSeparate VecType point3D_copy(VecType)
/// @arg point

function point3D_copy(p)
{
	gml_pragma("forceinline")
	
	return array_copy_1d(p)
}
