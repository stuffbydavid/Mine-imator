/// @desc Renders a box shape.
/// @arg point1
/// @arg point2
/// @arg [matrix]

function view_shape_box(p1, p2, mat = null)
{
	var points = [
		p1,
		point3D(p1[X], p1[Y], p2[Z]),
		point3D(p1[X], p2[Y], p1[Z]),
		point3D(p1[X], p2[Y], p2[Z]),
		point3D(p2[X], p1[Y], p1[Z]),
		point3D(p2[X], p1[Y], p2[Z]),
		point3D(p2[X], p2[Y], p1[Z]),
		p2
	];
	
	if (mat != null)
		view_shape_draw(points, mat)
	else
		view_shape_draw(points)
}
