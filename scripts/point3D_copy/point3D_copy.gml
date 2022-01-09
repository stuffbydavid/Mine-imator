/// point3D_copy(point)
/// @arg point

function point3D_copy(p)
{
	gml_pragma("forceinline")
	
	return array_copy_1d(p)
}
