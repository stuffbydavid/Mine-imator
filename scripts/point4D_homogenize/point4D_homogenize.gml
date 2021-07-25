/// point4D_homogenize(point)
/// @arg point

function point4D_homogenize(pnt)
{
	return [pnt[@ X] / pnt[@ W], pnt[@ Y] / pnt[@ W], pnt[@ Z] / pnt[@ W]]
}
