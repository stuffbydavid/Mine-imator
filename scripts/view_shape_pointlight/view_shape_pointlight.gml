/// view_shape_pointlight()
/// @desc Renders a pointlight shape.

// Bulb
view_shape_circle(point3D_add(pos, vec3(0, 0, 4)), 4)

// Bottom
view_shape_box(point3D_add(pos, vec3(-1.5, -1.5, -4)), point3D_add(pos, vec3(1.5, 1.5, 0)))
