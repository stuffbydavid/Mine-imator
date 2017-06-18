/// view_shape_box(point1, point2, [matrix])
/// @arg point1
/// @arg point2
/// @arg matrix
/// @desc Renders a box shape.

var p1, p2, points;
p1 = argument[0]
p2 = argument[1]

points = array(
	p1,
	point3D(p1[X], p1[Y], p2[Z]),
	point3D(p1[X], p2[Y], p1[Z]),
	point3D(p1[X], p2[Y], p2[Z]),
	point3D(p2[X], p1[Y], p1[Z]),
	point3D(p2[X], p1[Y], p2[Z]),
	point3D(p2[X], p2[Y], p1[Z]),
	p2
)

if (argument_count > 2)
    view_shape_draw(points, argument[2])
else
    view_shape_draw(points)
