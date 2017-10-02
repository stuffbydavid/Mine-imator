/// array3D_fill(array, size, value)
/// @arg array
/// @arg size
/// @arg value

var arr, size, value, pnt;
arr = argument0
size = argument1
value = argument2

for (pnt[X] = 0; pnt[X] < size[@ X]; pnt[X]++)
	for (pnt[Y] = 0; pnt[Y] < size[@ Y]; pnt[Y]++)
		for (pnt[Z] = 0; pnt[Z] < size[@ Z]; pnt[Z]++)
			array3D_set(arr, size, pnt, value)