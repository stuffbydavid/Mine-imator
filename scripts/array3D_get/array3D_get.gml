/// array3D_get(array, zsize, point)
/// array3D_get(array, zsize, xx, yy, zz)
/// @arg array
/// @arg zsize
/// @arg point

//gml_pragma("forceinline")

if (argument_count = 3)
{
	var arr, zsize, pnt;
	arr = argument[0]
	zsize = argument[1]
	pnt = argument[2]

	return ds_grid_get(arr, pnt[@ X], pnt[@ Y] * zsize + pnt[@ Z])
}
else
{
	var arr, zsize, xx, yy, zz;
	arr = argument[0]
	zsize = argument[1]
	xx = argument[2]
	yy = argument[3]
	zz = argument[4]
	
	return ds_grid_get(arr, xx, yy * zsize + zz)
}