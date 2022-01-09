/// point3D_distance(point1, point2)
/// @arg point1
/// @arg point2

function point3D_distance(pnt1, pnt2)
{
	gml_pragma("forceinline")
	
	return point_distance_3d(pnt1[@ X], pnt1[@ Y], pnt1[@ Z], pnt2[@ X], pnt2[@ Y], pnt2[@ Z])
}
