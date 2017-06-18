/// view_shape_spotlight()
/// @desc Renders a spotlight shape.

var points;

// Sphere
view_shape_circle(pos, 2)

// Cone
points = array(
	point3D(-2, -3, -2),
	point3D(-2, -3, 2),
	point3D(2, -3, -2),
	point3D(2, -3, 2),
	point3D(-4, 6, -4),
	point3D(-4, 6, 4),
	point3D(4, 6, -4),
	point3D(4, 6, 4)
)
view_shape_draw(points, matrix)
