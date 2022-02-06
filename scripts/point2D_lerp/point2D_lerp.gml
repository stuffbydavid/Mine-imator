/// point2D_lerp(point1, point2, amount)
/// @arg point1
/// @arg point2
/// @arg amount

function point2D_lerp(pnt1, pnt2, amount)
{
	gml_pragma("forceinline")
	
	return [lerp(pnt1[X], pnt2[X], amount), lerp(pnt1[Y], pnt2[Y], amount)]
}
