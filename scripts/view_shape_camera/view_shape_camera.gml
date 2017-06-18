/// view_shape_camera()
/// @desc Renders a camera shape.

// Box
view_shape_box(point3D(-3.5, -5, -4), point3D(3.5, 5, 4), matrix)

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
view_shape_draw(lens, matrix)

// Rolls
view_shape_circle(point3D(0, 3, 6.5), 2.5, matrix)
view_shape_circle(point3D(0, -3, 6.5), 2.5, matrix)
