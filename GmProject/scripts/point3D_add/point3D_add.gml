/// CppSeparate VecType point3D_add(VecType, VecType)
/// @arg point
/// @arg vector

function point3D_add(pnt, vec)
{
	gml_pragma("forceinline")
	
	return [ pnt[@ X] + vec[@ X], pnt[@ Y] + vec[@ Y], pnt[@ Z] + vec[@ Z] ]
}
