/// point3D_mul_matrix(point, matrix)
/// @arg point
/// @arg matrix

function point3D_mul_matrix(pnt, mat)
{
	var pntmat = point4D_mul_matrix(point4D(pnt[@ X], pnt[@ Y], pnt[@ Z], 1), mat);
	
	return point3D(pntmat[X], pntmat[Y], pntmat[Z])
}
