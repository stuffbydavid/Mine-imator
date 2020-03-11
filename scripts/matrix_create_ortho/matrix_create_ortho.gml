/// matrix_create_ortho(left, right, bottom, top, near, far)
/// @arg left
/// @arg right
/// @arg bottom
/// @arg top
/// @arg near
/// @arg far

var left, right, bottom, top, near, far, mat;
left = argument0
right = argument1
bottom = argument2
top = argument3
near = argument4
far = argument5

mat = [ 2 / (right - left), 0, 0, -(right + left) / (right - left),
		0, 2 / (top - bottom), 0, -(top + bottom) / (top - bottom),
		0, 0, -2 / (far - near), -(far + near) / (far - near),
		0, 0, 0, 1 ]

return mat