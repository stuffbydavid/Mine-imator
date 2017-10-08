/// array3D_set(array, zsize, point, value)
/// array3D_set(array, zsize, x, y, z, value)
/// @arg array
/// @arg zsize
/// @arg point
/// @arg value

//gml_pragma("forceinline")

if (argument_count = 4)
{
	var arr, zsize, pnt, val;
	arr = argument[0]
	zsize = argument[1]
	pnt = argument[2]
	val = argument[3]

	ds_grid_set(arr, pnt[@ X], pnt[@ Y] * zsize + pnt[@ Z], val)
}
else
{
	var arr, zsize, xx, yy, zz, val;
	arr = argument[0]
	zsize = argument[1]
	xx = argument[2]
	yy = argument[3]
	zz = argument[4]
	val = argument[5]
	
	ds_grid_set(arr, xx, yy * zsize + zz, val)
}