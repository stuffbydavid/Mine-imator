/// view_shape_camera(timeline)
/// @arg timeline
/// @desc Renders a camera shape.

function view_shape_camera(tl)
{
	// Box
	view_shape_box(point3D(-3.5, -5, -4), point3D(3.5, 5, 4), tl.matrix)
	
	// Lens
	var lens = array(
		point3D(-1.5, 5, -1.5),
		point3D(-1.5, 5, 1.5),
		point3D(1.5, 5, -1.5),
		point3D(1.5, 5, 1.5),
		point3D(-3, 9, -3),
		point3D(-3, 9, 3),
		point3D(3, 9, -3),
		point3D(3, 9, 3)
	)
	view_shape_draw(lens, tl.matrix)
	
	// Rolls
	view_shape_circle(point3D(0, 3, 6.5), 2.5, tl.matrix)
	view_shape_circle(point3D(0, -3, 6.5), 2.5, tl.matrix)
}
