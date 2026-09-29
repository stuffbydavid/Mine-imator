/// CppSeparate VecType point4D_homogenize(VecType)
/// @arg point

function point4D_homogenize(pnt)
{
	gml_pragma("forceinline")
	
	return [ pnt[@ X] / pnt[@ W], pnt[@ Y] / pnt[@ W], pnt[@ Z] / pnt[@ W] ]
}
