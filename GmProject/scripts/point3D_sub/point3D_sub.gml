/// CppSeparate VecType point3D_sub(VecType, VecType)
/// point3D_sub(point1, point2)
/// @arg point1
/// @arg point2

function point3D_sub(pnt1, pnt2)
{
	gml_pragma("forceinline")
	
	return [pnt1[@ X] - pnt2[@ X], pnt1[@ Y] - pnt2[@ Y], pnt1[@ Z] - pnt2[@ Z]]
}
