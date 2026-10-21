/// CppSeparate VecType point2D_add(VecType, VecType)
/// @arg point1
/// @arg point2

function point2D_add(pnt1, pnt2)
{
	gml_pragma("forceinline")
	
	return [ pnt1[@ X] + pnt2[@ X], pnt1[@ Y] + pnt2[@ Y] ]
}
