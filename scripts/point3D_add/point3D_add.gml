/// point3D_add(point, vector)
/// @arg point
/// @arg vector

function point3D_add(pnt, vec)
{
	return [pnt[@ X] + vec[@ X], pnt[@ Y] + vec[@ Y], pnt[@ Z] + vec[@ Z]]
}
